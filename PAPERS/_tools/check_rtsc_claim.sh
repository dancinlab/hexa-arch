#!/bin/bash
# check_rtsc_claim.sh — Stage 2 enforcement hook (constitution.md v1.4.0 R4)
#
# Scans a paper's main.tex for the substring "RTSC absorbed=true" (case-insensitive).
# - No match → exit 0 silently (paper makes no RTSC claim · optimistic default).
# - Guarded match (sentence contains "is LTS" / "is HTS" / "NOT RTSC" /
#   "NOT a room-temperature") → exit 0 (honest disclaimer present).
# - Unguarded match → locate companion attestation JSON via paper's README.md,
#   inspect `rtsc_5_gate_evaluation`:
#     · missing/null    → FAIL (likely R4 Pattern 1 violation)
#     · aggregate != ALL_PASS → FAIL with aggregate value
#     · aggregate == ALL_PASS → exit 0 (legitimate claim)
#   No companion record found → FAIL.
#
# API:
#   check_rtsc_claim.sh <paper_dir>
#
# Exit codes:
#   0   pass (no claim · guarded claim · ALL_PASS attestation)
#   1   unguarded claim · no companion record
#   2   unguarded claim · companion missing rtsc_5_gate_evaluation
#   3   unguarded claim · aggregate != ALL_PASS

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "[check_rtsc_claim] usage: $0 <paper_dir>" >&2
  exit 64
fi

PAPER_DIR="$1"
PAPER_DIR="${PAPER_DIR%/}"  # strip trailing slash

if [ ! -d "$PAPER_DIR" ]; then
  echo "[check_rtsc_claim] error: paper_dir not found: $PAPER_DIR" >&2
  exit 64
fi

TEX="$PAPER_DIR/main.tex"
if [ ! -f "$TEX" ]; then
  echo "[check_rtsc_claim] error: main.tex not found at $TEX" >&2
  exit 64
fi

# ------------------------------------------------------------------
# Step 1 · scan for candidate "RTSC absorbed=true" substring.
# ------------------------------------------------------------------
PATTERN='RTSC[[:space:]]+absorbed[[:space:]]*=[[:space:]]*true'
if ! grep -i -q -E "$PATTERN" "$TEX"; then
  # No claim → optimistic-default silent pass.
  exit 0
fi

# Python-side pattern (re module — uses \s, not POSIX classes).
PY_PATTERN='RTSC\s+absorbed\s*=\s*true'

# ------------------------------------------------------------------
# Step 2 · for each matching line, check sentence-level guard.
# A claim is "guarded" when the sentence around the match contains
# an explicit disclaimer string (case-insensitive).
# ------------------------------------------------------------------
GUARD_RE='(is LTS|is HTS|NOT RTSC|NOT a room-temperature|not a room-temperature)'

# Read whole file, collapse newlines for sentence-scope check around each hit.
# We use python for sentence-level analysis (more robust than awk for this).
GUARDED_ALL=$(PAPER_TEX="$TEX" PATTERN="$PY_PATTERN" GUARD_RE="$GUARD_RE" python3 - <<'PY'
import os, re, sys

tex_path = os.environ["PAPER_TEX"]
pattern  = os.environ["PATTERN"]
guard_re = os.environ["GUARD_RE"]

with open(tex_path, "r", encoding="utf-8") as f:
    text = f.read()

# Normalize whitespace per sentence-window: split into sentences on '.', '!', '?'
# (LaTeX-naive but adequate for hook purposes). We also accept paragraph breaks
# as sentence boundaries.
# Use a simple sliding-window: for each regex hit, grab 200 chars before and after,
# then bound by nearest sentence boundary (.!?) or paragraph break.
hits = list(re.finditer(pattern, text, flags=re.IGNORECASE))
if not hits:
    print("NO_HITS")
    sys.exit(0)

all_guarded = True
for m in hits:
    s, e = m.start(), m.end()
    left  = text[max(0, s - 400):s]
    right = text[e:e + 400]
    # Find nearest sentence boundary backward
    left_bound = max(left.rfind('. '), left.rfind('.\n'), left.rfind('!\n'),
                     left.rfind('?\n'), left.rfind('\n\n'))
    if left_bound >= 0:
        left = left[left_bound + 1:]
    # Find nearest sentence boundary forward
    right_bound_candidates = [i for i in (right.find('. '), right.find('.\n'),
                                          right.find('!\n'), right.find('?\n'),
                                          right.find('\n\n')) if i >= 0]
    if right_bound_candidates:
        right = right[:min(right_bound_candidates) + 1]
    window = left + text[s:e] + right
    if not re.search(guard_re, window, flags=re.IGNORECASE):
        all_guarded = False
        # Emit first ~120 chars of offending window for diagnostics
        snippet = re.sub(r'\s+', ' ', window).strip()[:160]
        print(f"UNGUARDED::{snippet}")

if all_guarded:
    print("ALL_GUARDED")
PY
)

if echo "$GUARDED_ALL" | grep -q "^ALL_GUARDED$"; then
  # Every claim sentence has a disclaimer — legitimate honest claim.
  exit 0
fi

# At least one unguarded claim — must resolve via companion attestation record.

# ------------------------------------------------------------------
# Step 3 · locate companion attestation JSON via paper README.md.
# ------------------------------------------------------------------
README="$PAPER_DIR/README.md"
if [ ! -f "$README" ]; then
  echo "[check_rtsc_claim] FAIL: unguarded 'RTSC absorbed=true' claim but README.md not found at $README" >&2
  exit 1
fi

# Extract first exports/material_attestation/.../*.json reference from README.
JSON_REF=$(grep -o -E "exports/material_attestation/[^[:space:]\`)]+\.json" "$README" | head -1 || true)

# Repo root for resolving the export path
REPO_ROOT=$(cd "$PAPER_DIR" && git rev-parse --show-toplevel 2>/dev/null || true)
if [ -z "$REPO_ROOT" ]; then
  # Fallback: assume two levels up from paper_dir (PAPERS/<paper>/) → demiurge/
  REPO_ROOT=$(cd "$PAPER_DIR/../.." && pwd)
fi

JSON_PATH=""
if [ -n "$JSON_REF" ]; then
  # README may have wildcard like .../*.json — expand to most recent.
  if echo "$JSON_REF" | grep -q '\*'; then
    # shellcheck disable=SC2086
    JSON_PATH=$(ls -1t $REPO_ROOT/$JSON_REF 2>/dev/null | head -1 || true)
  else
    JSON_PATH="$REPO_ROOT/$JSON_REF"
  fi
fi

# If literal path didn't resolve, try README-referenced directory + *.json glob.
if [ -z "$JSON_PATH" ] || [ ! -f "$JSON_PATH" ]; then
  DIR_REF=$(grep -o -E "exports/material_attestation/[^[:space:]\`)*]+/" "$README" | head -1 || true)
  if [ -n "$DIR_REF" ]; then
    JSON_PATH=$(ls -1t "$REPO_ROOT/$DIR_REF"*.json 2>/dev/null | head -1 || true)
  fi
fi

if [ -z "$JSON_PATH" ] || [ ! -f "$JSON_PATH" ]; then
  echo "[check_rtsc_claim] FAIL: unguarded 'RTSC absorbed=true' claim in $TEX but cannot locate companion attestation record (parsed README.md for 'exports/material_attestation/...json' references)" >&2
  echo "$GUARDED_ALL" | grep "^UNGUARDED::" | head -3 >&2
  exit 1
fi

# ------------------------------------------------------------------
# Step 4 · inspect companion JSON's rtsc_5_gate_evaluation field.
# ------------------------------------------------------------------
EVAL=$(JSON_FILE="$JSON_PATH" python3 - <<'PY'
import json, os, sys
p = os.environ["JSON_FILE"]
try:
    with open(p, "r", encoding="utf-8") as f:
        d = json.load(f)
except Exception as e:
    print(f"PARSE_ERROR::{e}")
    sys.exit(0)

if "rtsc_5_gate_evaluation" not in d or d["rtsc_5_gate_evaluation"] is None:
    print("MISSING_FIELD")
    sys.exit(0)

block = d["rtsc_5_gate_evaluation"]
agg = None
if isinstance(block, dict):
    # Try a few conventional field names; default to "aggregate".
    for k in ("aggregate", "aggregate_verdict", "verdict", "result"):
        if k in block:
            agg = block[k]
            break
if agg is None:
    print("MISSING_AGGREGATE")
else:
    print(f"AGGREGATE::{agg}")
PY
)

case "$EVAL" in
  PARSE_ERROR::*)
    echo "[check_rtsc_claim] FAIL: cannot parse companion JSON $JSON_PATH (${EVAL#PARSE_ERROR::})" >&2
    exit 2
    ;;
  MISSING_FIELD)
    echo "[check_rtsc_claim] FAIL: RTSC absorbed=true claim in paper but no rtsc_5_gate_evaluation field in companion record — likely R4 Pattern 1 violation" >&2
    echo "  paper:    $TEX" >&2
    echo "  record:   $JSON_PATH" >&2
    exit 2
    ;;
  MISSING_AGGREGATE)
    echo "[check_rtsc_claim] FAIL: rtsc_5_gate_evaluation block present but lacks 'aggregate' verdict" >&2
    echo "  record:   $JSON_PATH" >&2
    exit 2
    ;;
  AGGREGATE::ALL_PASS)
    # Legitimate claim — 5/5 PASS.
    exit 0
    ;;
  AGGREGATE::*)
    AGG="${EVAL#AGGREGATE::}"
    echo "[check_rtsc_claim] FAIL: RTSC absorbed=true claim but aggregate is $AGG — current state is NOT 5/5 PASS" >&2
    echo "  paper:    $TEX" >&2
    echo "  record:   $JSON_PATH" >&2
    exit 3
    ;;
  *)
    echo "[check_rtsc_claim] FAIL: unexpected evaluator output: $EVAL" >&2
    exit 2
    ;;
esac
