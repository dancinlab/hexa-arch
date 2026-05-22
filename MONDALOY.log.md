# MONDALOY — historical log

Spec at [`./MONDALOY.md`](./MONDALOY.md). Entries below preserve the
session-by-session evolution; the spec file holds only the current
confirmed state.

## Log

- **2026-05-22 KST** — **§7 Design ideas + §8 Reverse-engineering ideas
  added** (arxiv + web deep-research). Naming resolved: the publicly-
  disclosed SpaceX alloy is **SX500** (SX250→SX300→SX500 lineage,
  ~810 bar hot-O₂, "modern Inconel-derivative", cast + 3D-printed) —
  "MondAloy" is the upstream `hexa-space` draft label; same target.
  §7 = a concrete 7-verb forward design pass (CALPHAD funnel mirroring
  the published 779,625→12 precedent · DFT O-vacancy + scale-adhesion ·
  physics-descriptor ML creep arxiv:2212.06755 · CNN-LSTM oxidation ·
  printability gate); biggest design lever = an α-Al₂O₃-forming
  (reactive-element-stabilised) scale beats Cr₂O₃ in ox-rich because
  Cr₂O₃ volatilises as CrO₃/CrO₂(OH)₂ above ~1300 K. §8 = clean-room
  reverse-engineering (constraint triangulation · USPTO/Espacenet
  patent forensics on assignee "Space Exploration Technologies" CPC
  C22C19/05 · oxide-scale colour forensics on public Raptor-3 photos ·
  process-of-elimination via the §7 forward pipeline · analog
  benchmarking vs Inconel 625/718 · Haynes 282 · René N5 + declassified
  RD-170/180 · ML inverse design via MATAI arxiv:2511.10108 /
  arxiv:1803.03039 / arxiv:2108.12019). d6 boundary held: RE yields a
  spec-matching *candidate*, never SX500 itself; d2 breakthrough = an
  open functionally-equivalent alloy sidesteps the trade-secret wall.
  Sources: teslarati/nextbigfuture/fabbaloo (SX500 public surface) ·
  RD-170 grokipedia/astronautix · USPTO oxidation-resistant-coating
  patents · ScienceDirect Ni-superalloy computational-design papers.
- **2026-05-22 KST** — **demiurge `MONDALOY.md` domain doc opened.**
  Located the upstream draft `hexa-space/mondaloy/mondaloy.md`
  (combustion-resistant superalloy verb, operations group 16/16,
  drafted 2026-05-07). Promoted to a demiurge materials-domain doc as
  the sibling of `RTSC.md`/`NUCLEAR.md`: MondAloy = SpaceX-proprietary
  Ni-base combustion-resistant superalloy (Raptor 3 combustion chamber
  + ox-rich preburner lining). Composition is a SpaceX trade secret —
  demiurge doc is framed as a *discovery-target / bounding* exercise
  (§3 CALPHAD + DFT pipeline that needs no proprietary data; §4 d2
  breakthrough framing — bound the class, inverse-design a candidate,
  or measure a public analog). The upstream n=6 lattice mapping
  (σ·φ = n·τ = 24) is recorded in §5 explicitly as numerology /
  count-coincidence — **out of scope** for any `absorbed`/gate
  decision (d6/d7, same carve-out RTSC.md applies to hexa-atlas n6
  "Tc 300K"). `absorbed=false` · no measured oracle · no `exports/`
  record emitted yet.

- **2026-05-07 KST** (upstream, hexa-space) — `hexa-space/mondaloy/`
  drafted: `mondaloy.md` (v1.0.0 SPEC_ONLY) + `verify_mondaloy.hexa`
  (n=6 count-lattice invariant calculator · sentinel
  `__HEXA_MONDALOY_VERIFY__ PASS`). Upstream §4 explicitly states the
  verify script "does NOT model thermomechanical behavior" — count
  lattice only. `@canonical: pending-upstream`.
