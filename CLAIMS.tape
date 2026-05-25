@V := "tape" :: spec [active]
  version = "1.2"

@I := "claims-index" :: identity [active]
  brief = "Single audit index of verifiable demiurge research claims (d_claim_manifest)."
  flow  = "claim → attestation/verdict record → .verdicts/<slug>/<id>.txt → /paper gate (d_paper_gate)"

# Method legend (d_claim_verify):
#   atom    — `hexa verify --expr <fn> <n> <v>` (atlas atom recompute → 🔵)
#   expr    — `hexa verify --expr <fn> ...` (numerical recompute → 🟢)
#   record  — exports/material_attestation|material_verdict/<m>/*.json (typed gate record)
#   run     — sim / FEM / DFT run, verdict = producer stdout (empirical)
#
# Verdict surface = demiurge's typed records (NOT a fresh oracle):
#   exports/material_attestation/<m>/*.json  — absorbed-gate (measurement_gate)
#   exports/material_verdict/<m>/*.json       — tier4 falsifier-dispatch (aggregate_verdict)
# The .verdicts/<slug>/<id>.txt mirror holds the verbatim record excerpt the
# paper section links to. Do NOT paraphrase; copy the record field verbatim.
#
# Gate (d_paper_gate): every section claim must be terminal —
#   🔵 formal / 🟢 numerical / 🔴 CLOSED-negative. No 🟠 / 🟡 residual.
# Groups (d_paper_one_per_group): ABSORPTION · SYNTHESIS · ARCH — one canonical paper each.

# ───────────────────────────────────────────────────────────────────────
# ABSORPTION — nb-bcs-absorbed (slug · group=ABSORPTION · paper-track)
# Real positive numerical result. The BCS universal weak-coupling gap
# ratio is a parameter-FREE first-principles prediction; it matches the
# 5-lab Nb consensus within tolerance → absorbed=true (GATE_CLOSED_MEASURED).
# This is the subject of the LANDED paper PAPERS/sample-nb-bcs-absorbed/.

@C nb_bcs_gap_ratio := "2Δ(0)/(k_B·T_c) = π·exp(-γ_E) = 3.52775 (parameter-free BCS weak-coupling ratio)" :: formula [slug=nb-bcs-absorbed group=ABSORPTION]
  method = "record"
  cmd    = "exports/material_attestation/nb_bcs_v1/lts_attestation_nb_bcs_20260521T162859Z.json"
  raw    = ".verdicts/nb-bcs-absorbed/nb_bcs_gap_ratio.txt"
  src    = "RTSC.md §8.2 LTS family · PAPERS/sample-nb-bcs-absorbed/main.tex"

@C nb_bcs_oracle_parity := "model 3.52775 vs 5-lab consensus 3.51688 — mean_rel_err 0.31% ≤ 5% → absorbed=true" :: run [slug=nb-bcs-absorbed group=ABSORPTION]
  method = "record"
  cmd    = "jq .measured_oracle exports/material_attestation/nb_bcs_v1/lts_attestation_nb_bcs_20260521T162859Z.json"
  raw    = ".verdicts/nb-bcs-absorbed/nb_bcs_oracle_parity.txt"
  src    = "measurement_gate=GATE_CLOSED_MEASURED · absorbed=true · gate_type=bcs-universal-ratio-attestation"

# ───────────────────────────────────────────────────────────────────────
# SYNTHESIS — cube-fullcycle-617s (slug · group=SYNTHESIS · paper-track)
# Toolchain-validation finding (Tier 1 simulation grade). GetDP 4.0.0 +
# life-hts H-formulation cube transient solve runs to completion on Apple
# Silicon native (no Linux pool) — closes RTSC.md §4.3 (s1) next-step caveat.
# absorbed=false PERMANENT (simulation-only-prediction) — but a real,
# verifiable toolchain finding, not an RTSC absorbed=true claim.

@C cube_hformulation_fullcycle := "GetDP H-formulation cube AC-cycle solve completes native arm64 — 617.6s wall, KSP ~1e-16/step" :: run [slug=cube-fullcycle-617s group=SYNTHESIS]
  method = "run"
  cmd    = "RTSC.md §4.2.1.d cube benchmark full-cycle run (macOS arm64 native, 2026-05-21)"
  raw    = ".verdicts/cube-fullcycle-617s/cube_hformulation_fullcycle.txt"
  src    = "PAPERS/cube-fullcycle-617s/main.tex · RTSC.md §4.2.1.d · §4.3 (s1)"
  status = "verdict PENDING — needs a persisted FEM-run record excerpt. STRUCTURAL STUB until .verdicts/cube-fullcycle-617s/ mirror is filled from the GetDP run log; gated OUT of /paper until terminal."

# ───────────────────────────────────────────────────────────────────────
# ARCH — open slot (group=ARCH · paper-track)
# Candidate canonical claim — the 7-verb meta-conductor framework paper
# (cs.SE). NOT yet verdict-persisted. List here so the audit surface tracks
# it; promote to paper only after d_claim_verify persists a terminal verdict.
#
# @C arch_<id> := "<claim>" :: run [slug=arch-<slug> group=ARCH]
#   method = "record"
#   cmd    = "exports/<domain>/<m>/*.json   # or hexa verify for a closed-form atom"
#   raw    = ".verdicts/arch-<slug>/<id>.txt"
#   src    = "ARCH.md §<n> · DESIGN.md Decision <n>"
