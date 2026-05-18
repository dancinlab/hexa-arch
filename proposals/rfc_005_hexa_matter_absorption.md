# RFC 005 — hexa-matter absorption + tombstone (program)

> Status: **draft / program — NOT complete** · 2026-05-18 · Source:
> user directive + `design.md` Decision 12. Pattern mirror:
> `hexa-lang/proposals/rfc_047_mc_integrate_absorption.md`,
> `rfc_048_xeno_absorption.md` (absorb → archive_ rename → local
> delete, with a measured gate). g3 RETAINED (D12) — "흡수 완료" is
> claimed ONLY at the measured gate (§4), never asserted.

---

## 1. Goal

Consolidate `~/core/hexa-matter` (own sibling repo,
`github.com/dancinlab/hexa-matter`, MIT) **into hexa-arch** as the
**materials-synthesis stage** of the meta-conductor chain
(rfc_004 §4: 물질합성 → 칩아키텍쳐 → 부품설계), then tombstone the
sibling repo (archive_ rename + local delete). Reverses D2/D11 *for
hexa-matter only* (D12); hexa-bio + comb stay decoupled.

## 2. Scope — measured from the actual repo (g3, no fabrication)

`~/core/hexa-matter` @ `main` (snapshot 2026-05-18):

- Size **210 MB**, **9755 files**. By ext: 4297 `.md` · 2356 `.py`
  · 938 `.json` · 837 `.marker` · 324 `.gitkeep` · 312 `.hexa` ·
  269 `.sh` · 112 `.toml` · 57 `.tape`.
- README: "🧬 hexa-matter — 36-verb materials toolkit · 16+ DB
  bridges · 29 parity gates · selftest 32/32 · v1.2.0", DOI
  10.5281/zenodo.20102811, MIT.
- Top-level: material domains (`ceramics`, `carbon`, `2d-materials`,
  `aramid`, `aerogel-foam`, `biodegradable-plastics`,
  `compound-semi`, …) + `_python_bridge` / `_hexa_bridge` /
  `_absorption_bridge` / `_research_bridge` + `cli` + `AGENTS.tape` ·
  `AXIS*` · `CLOSURE_STATUS*` governance.
- 15 unpushed commits — **already pushed to origin/main
  2026-05-18** (anti-data-loss precondition for the eventual delete;
  D12 sequencing).

## 3. Target placement in hexa-arch

Recommend `domains/matter/` (the materials-synthesis chain stage —
consistent with the 14 Cohort domain maps + rfc_004 §4 meta-conductor
seam: `domains/matter/` HANDOFF → chip SPECIFY). Open sub-decision
(§7): `domains/matter/` vs `stdlib/matter/` vs verbatim-preserved
tree. Pending user pick before content lands.

## 4. g3 measurement gate — when "absorbed" may be claimed

`absorbed` (project-wide honesty, retained per D12) flips only when,
**under the hexa-arch tree**:

- hexa-matter's own **selftest 32/32 GREEN** + **29/29 parity gates
  GREEN** reproduce, and
- the 36 verbs run via the hexa-arch entrypoint, and
- the result is filed in `PLAN.md` with cited numbers.

Until then status = **program-in-progress** (the rfc_003 idiom:
GATE-style, not asserted). No record/PLAN line may say
"hexa-matter absorbed" before this gate.

## 5. The hexa-native tension (major, honest — g3)

CHARTER g5 = **hexa-native-only** (no Python, no shell-out). hexa-matter
ships **2356 `.py` files** + `_python_bridge` + 269 `.sh`. Literal
"완전 흡수" into a hexa-native-only program therefore requires either:

- **(5a) progressive hexa-native re-derivation** of the Python/bridge
  layers (same class as rfc_003's BookSim2 re-derivation, but ~10×
  scale — a large multi-phase program), or
- **(5b) verbatim archive + hexa-native CLI shim** — preserve the
  py/sh tree under `domains/matter/` as frozen content, expose a
  hexa-native dispatcher (rfc_048_xeno's "bash CLI → hexa-native
  dispatcher, original preserved verbatim" pattern), python invoked
  as a documented absorbed-substrate subprocess with fail-loud — a
  *bounded* g5 exception precedented by rfc_048.

This is the program's biggest decision and effort driver — **flagged,
not papered over**. rfc_048_xeno chose (5b)-like; recommend the same
for parity of pattern, with (5a) as incremental follow-on per verb.
**Open (§7) — user pick before bulk content move.**

## 6. Tombstone sequence (rfc_047/048 pattern · D12-gated)

```
① D12 recorded ✓ · rfc_005 (this) ✓ · comb archive snapshot ✓
② hexa-matter content → hexa-arch domains/matter/ (per §3/§5 pick)
③ verify: §4 gate GREEN under hexa-arch tree + hexa-arch pushed
④ dependents check + fix: who references dancinlab/hexa-matter —
   HEXA-family READMEs, hexa-bio/hexa-space/hexa-physics sibling
   badges, comb, hexa-arch's own refs, the Zenodo DOI record
⑤ GitHub rename dancinlab/hexa-matter → dancinlab/archive_hexa-matter
   (OUTWARD, irreversible — explicit go required at this step)
⑥ delete ~/core/hexa-matter (DESTRUCTIVE — only after ②③④⑤)
```

**Done now**: ① only. ②–⑥ are the program; ⑤⑥ additionally need an
explicit per-step go (confirmed #3). hexa-matter origin already
protected (15 commits pushed).

## 7. Open decisions (gate before bulk move)

- **D13** — target placement: `domains/matter/` (recommended) vs
  `stdlib/matter/` vs verbatim tree.
- **D14** — hexa-native tension §5: (5b) verbatim+shim (rfc_048
  parity, recommended) vs (5a) full re-derivation now vs hybrid.
- Dependents inventory (step ④) — enumerate before ⑤.

## 8. What is NOT done (g3 honesty)

The 9755-file content is **not** moved; selftest is **not** re-run
under hexa-arch; the repo is **not** renamed; the local folder is
**not** deleted. This RFC is the *program design only*. Nothing here
asserts hexa-matter is absorbed.

## 9. Cross-references

`design.md` D12 (+ D2/D11/D10 history) · rfc_004 §3/§4 (meta-conductor
chain) · rfc_047/048 (absorb-tombstone pattern) · `archive/
ARCHIVE_NOTE.md` (comb snapshot, D2 preserved) · CHARTER g5
(hexa-native-only) · HANDOFF §5.
