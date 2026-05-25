# MERGE INTO project.tape AFTER: sidecar sign project
#
# Adapted from anima a_paper_* / a_claim_* (itself a port of hexa-codex cx_paper_*).
# Prefix = `d_` (matches demiurge's d1-d17 directive family).
# demiurge does NOT mint a new oracle — the typed record IS the verdict:
#   exports/material_attestation/<m>/*.json  (measurement_gate · absorbed)
#   exports/material_verdict/<m>/*.json        (aggregate_verdict · absorbed)
# Groups = ABSORPTION · SYNTHESIS · ARCH (one canonical paper each).
#
# LINT: every `do =` / `dont =` value is ≤100 chars (verified pre-merge).
#
# Paste the block below between d17 and the philosophy/closing section.

# ── PAPER auto-generation flow (ported from anima a_paper_* · cx_paper_* lineage) ──
# research result → typed record (attestation/verdict) → .verdicts/<slug>/<id>.txt → CLAIMS.tape → /paper

@D d_claim_manifest := "CLAIMS.tape — single audit index of verifiable demiurge claims" :: workflow [required active]
  do   = "every verifiable claim in root CLAIMS.tape — id · text · method · slug · group · record pointer"
  dont = "scatter claims across domain logs without a CLAIMS.tape index — no audit surface"

@D d_claim_verify := "every claim closed by a typed record, excerpt persisted verbatim" :: workflow [required active]
  do   = "close each CLAIMS.tape entry with a typed record (attestation/verdict) or `hexa verify` (g5)"
  do   = "mirror the record's field excerpt verbatim into `.verdicts/<slug>/<id>.txt`"
  dont = "LLM self-judge correctness (g3) · paraphrase the record · hide an INCONCLUSIVE / unfenced claim"

@D d_paper_gate := "/paper gated on terminal verdict AND significance" :: workflow [required active]
  do   = "`/paper new <slug>` only when every section claim is terminal AND significance satisfied"
  do   = "terminal = 🔵 formal / 🟢 GATE_CLOSED_MEASURED / 🔴 CLOSED-negative — not 🟠 INCONCLUSIVE / 🟡 citation"
  dont = "scaffold w/ any 🟠 INCONCLUSIVE / MISSING-INPUT · 🟡 citation-only · ⚪ speculation · trivial recheck"

@D d_paper_significance := "paper requires a falsifiable hypothesis + real measurement + a finding" :: workflow [required active]
  do   = "trigger only on a pre-registered falsifier + real measurement (record / sim / FEM / DFT / verify)"
  do   = "finding = Δ vs baseline OR a closed-negative ruling out an axis"
  dont = "paper for a bookkeeping closure · known identity · unverified prediction · 🟠 residual"

@D d_paper_negative_ok := "closed-negative findings are publishable" :: workflow [required active]
  do   = "a 🔴 FALSIFIED record that deterministically rules out a path is a valid paper"
  do   = "frame as a negative result — the falsifier + the ruled-out space (e.g. an axis ⊥ the target)"
  dont = "treat a closed-negative as a non-finding · bury a falsification · publish 🟠 as if closed"

@D d_paper_format := "paper sections — hypothesis · method · measurement · finding" :: workflow [required active]
  do   = "§hypothesis (falsifier) · §method · §measurement (real record) · §finding (Δ OR ruled-out axis)"
  do   = "commons g51 — compile ≥10 pages + ≥1 fal.ai figure"
  dont = "narrative-only · measurement substitute for hypothesis · skip §finding · vague claims"

@D d_paper_sections := "every paper section claim links to its record mirror" :: workflow [required active]
  do   = "every section claim links to its `.verdicts/<slug>/<id>.txt` record excerpt (verbatim)"
  do   = "an `RTSC absorbed=true` literal also passes `_tools/check_rtsc_claim.sh` (5-gate ALL_PASS)"
  dont = "ship paper with any unresolved residual section · treat the verdict matrix as optional"

@D d_paper_violation := "violating paper immediately revoked" :: workflow [required active]
  do   = "violating paper (gate / significance fail) revoked immediately — PAPERS/<slug>/ removed"
  dont = "keep a violating paper as draft · mark WIP · defer revocation · allow a residual"

@D d_paper_one_per_group := "one canonical paper per group — ABSORPTION · SYNTHESIS · ARCH" :: workflow [required active]
  do   = "one paper per group — ABSORPTION absorbed=true attestation · SYNTHESIS FEM/DFT toolchain"
  do   = "ARCH 7-verb meta-conductor framework (cs.SE) · replace in place when a stronger finding lands"
  dont = "multiple papers per group · accumulate a backlog · fork same-group narratives"
