# Demiurge CHARTER

> Standalone repo `~/core/demiurge`. Authoritative scope/governance.
> Kept self-contained with `HANDOFF.md` (continuable anywhere).

## Mission

A hexa-native, domain-pluggable **technical-design architecture program**:
**SPECIFY → ARCHITECT → DESIGN → ANALYZE ⟲ → SYNTHESIZE → VERIFY
(+VALIDATE) → HANDOFF** for *any* engineered system (7-verb cited spine —
see `design.md` Decision 5). Chip design is the first/lead domain; the
named cohort spans cern (가속기) · antimatter · rtsc (초전도) · space ·
energy · brain (BCI) — `design.md` Decision 3 — **plus the chain-stage
domain `component` (part/package/system, FEM/EM/thermal)** added as
a new top-level domain by `design.md` Decision 21 to host the
meta-conductor's 3rd pass. **Typed-interface consumer**, NOT
absorber, of `hexa-matter` (물질·소재) and `hexa-bio` (화학분자)
(`design.md` Decision 2) — and per `design.md` Decision 17,
hexa-matter's *absorption SSOT is hexa-lang* (`stdlib/`), so
demiurge is the consumer-pointer side (`domains/matter/` = pointer,
not a copy). demiurge is the **meta-conductor** of a *chained*
materials→chip→component program: the 7-verb spine applied in
series, each pass's HANDOFF feeding the next's SPECIFY via a typed
seam contract (`rfc_007` materials→chip · `rfc_008` chip→component);
sibling science repos stay typed-interface-consumed (`design.md`
Decision 11 · `proposals/rfc_004_e2e_design_program.md`).

## Universal pipeline (domain-neutral 7 verbs — cited)

명세 **SPECIFY** → 구조 **ARCHITECT** → 설계 **DESIGN** → 해석 **ANALYZE**
⟲ → 합성 **SYNTHESIZE** → 검증 **VERIFY** (+VALIDATE bound) → 인계
**HANDOFF**. ANALYZE iterates back into DESIGN/SYNTHESIZE (gate, not
terminal). Spine grounded in 9 cited lifecycles (ISO/IEC/IEEE 15288 ·
V-model · NASA SE · FDA design controls · EDA RTL→GDSII · MBSE/OOSEM ·
PLM · accelerator · spacecraft) — see `design.md` Decision 5. Full
per-stage chip-domain external map: `HANDOFF.md` §5.

## Domain plugin model

Each domain absorbs the **public surface** of external prior art via a
`proposals/rfc_0NN_<tool>_absorption.md`: open-source code/specs · arxiv &
papers · patents (public reverse-engineering disclosure) · standards ·
datasheets · proprietary tools' *public documentation* (capability/gap
mapping + clean-room re-derivation only). The same absorption-RFC
pattern hexa-matter/hexa-bio used (⟵ ASE/pymatgen, AlphaFold/RDKit);
demiurge reuses the pattern but **consumes** those siblings typed-only
(Decision 2). **Re-derived reusable modules land in `hexa-lang/stdlib/`,
not under demiurge** (Decision 15 — stdlib is hexa-lang's exclusively;
demiurge is the consumer that references the hexa-lang location).
Python-0 · measured · no fake progress. See `design.md` Decisions 1, 15.

## Non-goals (governance)

- **No actual fab/FPGA** — chip domain = tapeout-ready *design* only.
- **No over-claim (g3)** — "absorbed/parity/resolved" only at a measured
  gate, filed with cited numbers; SKIP-mode regression banned (lattice-
  is-tool · measured-only · `AGENTS.tape @F f2/f4`).
- **hexa-native-only (g5)** — absorbed substrate runs as hexa intrinsics;
  re-derived reusable modules belong in **`hexa-lang/stdlib/`**, NOT
  under demiurge (`design.md` Decision 15; demiurge carries no
  `stdlib/` tree — `AGENTS.tape @F f1`). The rfc_048-precedented
  **bounded exception** is permitted: verbatim foreign substrate
  invoked as a documented fail-loud subprocess (e.g. ABC inside the
  Yosys flow per `design.md` Decision 18), with re-derivation as the
  scheduled follow-on.
- **No closed-binary RE** — public-surface clean-room only: no decompilation
  of closed binaries, no license/DRM circumvention, no trade-secret
  extraction (`design.md` Decision 1).
- **No big-bang** — incremental, per-domain absorption-RFC; full measured
  parity (per-flit DES, §B/§D full-curve, the `absorbed=true` flip) is
  gated by g3 measurement, never asserted. (The previous "design-only"
  framing of Decision 10 was **RESCINDED by Decision 12** — full scope
  incl. execution/absorption is in-scope; the gate discipline, not the
  scope cap, is what enforces honest progress.)
- **Not comb** — comb (hexa-lang, n=6 fabric) is a *consumer* of the chip
  domain, not the EDA absorber. Decoupled by design.

## Current state (snapshot, g3 — *category* only; numbers in PLAN.md)

4-Phase forward roadmap is **design-complete at the contract/spec
level** AND the macOS Swift cockpit **workbench is live**
(`/Applications/demiurge.app`). What is NOT done: wired / absorbed /
measured-records-zero, per the honest core gap below.

- Absorption RFCs land re-derived modules in `hexa-lang/stdlib/`
  (D15). booksim done (commit `d5a63a82`, unpushed in a hexa-lang
  session). Yosys design done (D18 bounded-subprocess), modules
  unimplemented (D19, hexa-lang session). matter SUPERSEDED to
  hexa-lang (D17).
- Typed-interface seams v0 (rfc_007 materials→chip · rfc_008
  chip→component) — `records/` intentionally empty (no fabrication).
- chip NoC §B = `GATE_B_PINNED_MET` — pinned baseline only; full-
  curve / §D not measured; `absorbed=false`.
- macOS cockpit workbench built — rfc_009 / 010 / 011 / 012 spec →
  `cockpit/` SwiftPM package: 3-column 7-verb workbench, θ-2 action
  skeleton, §4.2 REJECTED guard, domain-aware canvas mode, CLI ↔
  cockpit parity. Live progress = `PLAN.md` κ-phase log.

**Honest core gap (g3):** **engine tool 0** — θ-2 has no real
measurement tool yet (Yosys §4 unimplemented · booksim now in
`hexa-lang/stdlib`), so every workbench project carries **0 measured
records** and **no verb is ✅**. Seam records 0. No domain
`absorbed=true`.

Progress / measured distance = `PLAN.md`; decision audit = `design.md`
(SSOT); cross-repo / post-completion handoffs = `NEXT_SESSIONS.md`.

## Related repos

- `~/core/hexa-lang` — substrate + the **sole SSOT** for stdlib /
  tools / absorbed modules (D15 / D17 + 2026-05-19 user directive
  "hexa-lang 이 유일 SSOT"). Every domain's reusable tooling
  (booksim · matter · component · …) lives inside this single repo;
  demiurge consumes only. First consumer `comb/`.
- `~/core/hexa-*` (hexa-chip · hexa-space · hexa-component · …) —
  exist on disk but are **NOT SSOT** (κ-17 correction). The
  canonical stdlib home for each domain is `hexa-lang/<domain>`
  (booksim / matter pattern).
- **macOS Swift cockpit** (D16 / rfc_009·010·011·012) — `cockpit/`
  SwiftPM package, **built and installed** as
  `/Applications/demiurge.app`. The product surface is now live;
  the κ-phase build log lives in `PLAN.md`.
