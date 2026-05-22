# MONDALOY — combustion-resistant superalloy verification target

> **Status**: spec / discovery-target framing · `absorbed=false` ·
> `gate_type=simulation-only-prediction` — no composition claim, no
> measured-oracle (MondAloy composition is SpaceX trade secret).
>
> opened: 2026-05-22 KST (demiurge domain doc) ·
> upstream draft: `hexa-space/mondaloy/mondaloy.md` (2026-05-07,
> n=6-lattice structural-pattern framing) ·
> historical log: [`./MONDALOY.log.md`](./MONDALOY.log.md)
>
> sibling of `RTSC.md` (compositional superconductor discovery) ·
> `NUCLEAR.md` (elemental discovery) — those discover/verify *novel*
> materials; MONDALOY.md tracks a **known proprietary target** whose
> structural-property envelope can be bounded by first-principles /
> thermodynamic modelling without the proprietary composition.

This document is the demiurge materials-domain doc for **MondAloy** —
SpaceX's combustion-resistant nickel-based superalloy. It frames the
non-wet-lab verification pipeline (d1) for a MondAloy-*class* alloy:
what a first-principles or CALPHAD-grade study could predict, and the
honest boundary where the proprietary composition makes the verdict
structural-pattern only.

---

## §1. What MondAloy is (public surface only)

MondAloy is SpaceX's proprietary nickel-based combustion-resistant
superalloy, publicly disclosed (by SpaceX statements / press) as the
material of:

- the **Raptor 3 combustion chamber**, and
- the **oxygen-rich preburner lining**.

Its design failure mode is **oxygen-rich high-temperature combustion**
— the regime that historically destroyed ox-rich staged-combustion
engines (the same regime the Soviet RD-170 family fought with
specialized coatings). MondAloy's claimed niche is holding integrity
against ox-rich hot gas without a separate ceramic coating.

**The composition is a SpaceX trade secret.** No public chemistry
disclosure is assumed. Everything below is either public-surface fact
or an explicitly-labelled structural-pattern model — never a chemistry
claim (governance D1 clean-room · d6 measured-oracle invariant).

## §2. Why this is a demiurge domain doc

demiurge is the meta-conductor of a materials → chip → component
program. MondAloy sits squarely in the **materials verb** for the
space domain: a combustion-chamber superalloy is the SYNTHESIZE-stage
material a rocket-engine design pass must specify and verify.

RTSC.md asks "can a novel composition reach a target Tc"; MONDALOY.md
asks the dual question — "given a *known* target alloy class, how far
can the non-wet-lab pipeline bound its high-temperature / oxidation
envelope **without** the proprietary composition?" That is a legitimate
d1 exercise: drive the *bounding* analysis to completed-form, and name
the proprietary-composition wall as the honest `not yet` boundary.

## §3. Non-wet-lab verification pipeline (d1 — what CAN be driven to done)

A MondAloy-*class* Ni-base superalloy (Ni + ~5 strengtheners — public
superalloy practice, e.g. Inconel/Hastelloy/René families) admits a
real first-principles + thermodynamic pipeline that needs *no*
proprietary data:

| stage | method | what it bounds | proprietary-free? |
|---|---|---|---|
| phase stability | CALPHAD (Thermo-Calc / OpenCALPHAD + TCNI database) | γ/γ′ phase fractions vs T for a *candidate* composition | ✓ (uses public Ni-superalloy databases) |
| oxidation kinetics | parabolic-rate / Wagner theory + DFT O-vacancy formation | NiO/Cr₂O₃/Al₂O₃ scale growth rate vs T, pO₂ | ✓ |
| el./thermal transport | DFT + Boltzmann transport (как RTSC el-ph pipeline) | thermal conductivity, used as a *low-conductivity* design lever | ✓ |
| creep / thermomech | crystal-plasticity FEM (e.g. via `hexa-lang/stdlib` fem kernel) | creep life vs stress/T for a candidate microstructure | ✓ |
| service ceiling | combine the above → T_max envelope | upper bound on service temperature for a candidate | ✓ |

Each of these is a Tier-1 *prediction* (`gate_type=simulation-only-
prediction`, exactly like RTSC DFT). None flips `absorbed=true` — that
would need a measured oracle against the *actual* MondAloy, which is
proprietary and unavailable (d6).

## §4. The honest wall (d2 framing — not a concession)

The proprietary composition is an empirically-demonstrated wall: we
cannot verify *MondAloy itself*. Per d2, the breakthrough framing is
**not** "impossible" — it is to redefine the deliverable:

1. **Bound the class, not the instance.** Drive a CALPHAD + DFT study
   of the *public* Ni-base ox-resistant superalloy envelope to
   completed-form; report the predicted T_max / oxidation-rate band
   that any Ni+5 alloy in that family can occupy. MondAloy then sits
   *somewhere in that band* — a verified bound, not a guessed point.
2. **Inverse-design a MondAloy-class candidate.** Use the same
   compositional-sweep machinery RTSC uses for hydrides (DFT screen +
   CALPHAD filter) to *propose* a Ni+5 composition that meets the
   public-spec envelope (ox-rich, ~2200 K class, low conductivity).
   That candidate is a novel demiurge prediction — publishable,
   `absorbed=false`, and entirely proprietary-free.
3. **Measure a non-proprietary analog.** A lab-castable Ni-base
   ox-resistant alloy (public composition) can be the measured-oracle
   carrier — the pipeline is then validated on the analog, exactly as
   the RTSC pipeline was validated on H₃S before being applied to
   novel H₃X.

## §5. n=6 structural-pattern note (numerology — NOT measurement)

The upstream `hexa-space/mondaloy/mondaloy.md` maps MondAloy counts to
the n=6 lattice (6 alloying elements, 12 chamber zones, 4 thermal
regimes, σ·φ = n·τ = 24, etc.). Per demiurge governance (d6/d7, and
the §8.8 hexa-atlas-witnessed stance in `RTSC.md`):

> **The n=6 mapping is a counting coincidence / mnemonic, NOT a
> physical prediction.** It carries `gate_type` nothing — it is not a
> simulation, not a measurement, not a Tier-1 prediction. It must
> never be cited as evidence for any thermomechanical property of
> MondAloy. `verify_mondaloy.hexa` tests the *count-lattice* only and
> explicitly "does NOT model thermomechanical behavior" (upstream §4).

This doc records the n=6 framing only to mark it as **out of scope**
for any `absorbed`/gate decision — the same carve-out RTSC.md applies
to hexa-atlas n6 "Tc 300K" being a *target*, not a measurement.

## §6. Status

- v0.1 — demiurge domain doc opened (this file). No pipeline run yet.
- `absorbed=false` · no measured oracle · composition proprietary.
- No demiurge `exports/` record emitted for MondAloy. When the §3
  pipeline runs (CALPHAD or DFT), records land in
  `exports/material_discovery/` with `gate_type=simulation-only-
  prediction`, exactly like the RTSC H₃X records.
- Upstream `hexa-space/mondaloy/` remains `SPEC_ONLY` v1.0.0.

## §7. Design ideas — forward (설계 아이디어, arxiv/web deep-research)

> **Naming note**: the publicly-disclosed SpaceX alloy is **SX500** (the
> SX250 → SX300 → SX500 lineage). "MondAloy" is the upstream
> `hexa-space` draft's label; treat the two as the same target. SX500 is
> publicly characterised as a "modern Inconel-derivative" rated for
> **~800 atm (810 bar) hot oxygen-rich gas** with "extreme oxidation
> resistance", castable **and** 3D-printable, used in the Raptor
> ox-rich turbopump / preburner / chamber.

How demiurge would *design* an SX500/MondAloy-class alloy from scratch —
a concrete 7-verb pass, every step proprietary-free:

1. **SPECIFY — the ox-rich envelope.** Unlike turbine superalloys
   (fuel-side, reducing), this alloy faces **hot oxygen** at 810 bar.
   The design target is therefore *not* peak creep strength but a
   **slow-growing, self-healing, well-adherent oxide scale with no
   separate coating** — SX500's public claim is a *bare* alloy, a
   deliberate break from the RD-170/RD-180 solution (inert **enamel
   coating** on every hot-oxygen surface). Coating-free is the headline
   design constraint.
2. **ARCHITECT — the composition space.** Ni-base + ~5 strengtheners.
   Public Ni-superalloy practice bounds the menu: Cr (Cr₂O₃ former),
   Al (α-Al₂O₃ former, the better scale in ox-rich), Co (γ′ solvus +
   stacking-fault control), Mo/W/Ta/Re (solid-solution + γ′
   strengthening), Ti/Nb (γ′ formers), and reactive elements
   **Y/Hf/Zr** (scale adhesion — the "reactive-element effect").
3. **DESIGN — CALPHAD funnel.** Mirror the published precedent that
   narrowed **779,625 composition combinations → 12 alloys** via
   Thermo-Calc / OpenCALPHAD (TCNI database): filter on γ/γ′ phase
   fraction, freezing range, density, castability, processing window.
   For the ox-rich target, *add an oxidation criterion*: bias toward
   **alumina-forming** compositions (Al activity high enough to sustain
   a continuous α-Al₂O₃ layer — the classic "third-element effect"
   needs Cr to getter O before Al, then Al takes over).
4. **ANALYZE ⟲ — DFT + ML.** (a) DFT O-vacancy formation energy +
   oxide-scale adhesion energy → rank candidates for ox-rich survival
   (same el-ph/DFPT machinery as the RTSC pipeline, different
   observable). (b) Physics-descriptor ML for creep strength
   (arxiv:2212.06755 — superalloy microchemistry → creep from physical
   descriptors). (c) Hybrid CNN-LSTM for oxidation-kinetics prediction
   (recent literature). Iterate composition back into DESIGN.
5. **SYNTHESIZE — printability gate.** SX500 is cast *and* additively
   manufactured. The design must pass a hot-cracking / weldability
   window — this prunes the highest-γ′ (highest-strength) compositions,
   a real trade SX500's metallurgy team must have made. demiurge models
   this as a hard constraint, not an afterthought.
6. **VERIFY — analog measurement.** Cast a *public-composition*
   alumina-forming Ni alloy (e.g., a Haynes-282-class or René-N5-class
   reference) and measure ox-rich scale growth; this validates the
   pipeline on an analog before any SX500-class claim (the same
   discipline RTSC used — validate on H₃S, then predict novel H₃X).
7. **HANDOFF — to the chip/component meta-conductor.** A verified
   alloy envelope feeds the component-domain FEM (chamber-wall thermal
   + creep life), closing the materials → component seam.

**The single biggest design lever** (deep-research synthesis): ox-rich
combustion rewards an **α-Al₂O₃-forming** alloy over a Cr₂O₃-forming
one — Cr₂O₃ volatilises as CrO₃/CrO₂(OH)₂ above ~1300 K in the presence
of O₂/H₂O, while α-Al₂O₃ is stable far higher. SX500's "extreme
oxidation resistance" almost certainly rests on a reactive-element-
stabilised alumina scale. That is a *proprietary-free, physically
derivable* design conclusion.

## §8. Reverse-engineering ideas — 역설계 (public-surface only, D1)

How to bound / infer the SX500-MondAloy composition **without** the
trade secret — clean-room, public-surface only (governance D1: no
trade-secret extraction, no closed-binary RE; this is *constraint
triangulation*, which is legitimate):

1. **Constraint triangulation.** Intersect every public spec — 810 bar
   burst · hot O₂ · "modern Inconel-derivative" · castable +
   3D-printable · bare-alloy (coating-free) ox resistance · Raptor-3
   chamber service temperature class. Each constraint carves the
   Ni-Cr-Al-Co-(refractory) space; the *intersection* is a small
   region. SX500 lives in it — a verified **bounding box**, not a
   single guessed point.
2. **Patent forensics.** Search USPTO / Espacenet for assignee
   **"Space Exploration Technologies"** (and known SpaceX metallurgist
   inventor names) in CPC class **C22C19/05** (Ni-base alloys) filed
   ~2017-2025. Alloy patents routinely disclose **composition ranges**
   even when the commercial product name stays secret — the published
   range *is* a reverse-engineering result, fully legal to cite.
3. **Oxide-scale forensics on public hardware.** Raptor 3 chamber /
   bell photographs after hot-fire: oxide-scale **colour** discriminates
   the protective oxide — green/dark = Cr₂O₃-dominant, pale-grey/white
   = Al₂O₃-dominant. This is a free, public, non-destructive read on
   the Al-vs-Cr balance of the scale (and hence of the alloy).
4. **Process-of-elimination via the §7 forward pipeline.** Run the
   CALPHAD + DFT + ML design funnel against *all* public SX500
   constraints simultaneously. Whichever composition family *uniquely*
   satisfies all of them is the reverse-engineered envelope — SX500 is
   "somewhere in that family". This converts RE into a forward
   simulation problem (no secret needed).
5. **Analog benchmarking against declassified prior art.** SX500 is an
   *evolution* of public Ni-superalloy science, not a discontinuity.
   Bracket it with: Inconel 625/718, Haynes 282, René N5/N6, and the
   declassified RD-170/RD-180 ox-rich materials literature. The public
   alumina-forming-superalloy envelope upper-bounds SX500's novelty.
6. **ML inverse design as the RE engine.** Feed the public performance
   spec into a generalist inverse-design model — e.g. **MATAI**
   (arxiv:2511.10108, generalist ML property-prediction + inverse
   design for advanced alloys), the neural-network Ni-superalloy
   designer (arxiv:1803.03039), or generative DL for refractory alloys
   (arxiv:2108.12019). The model **outputs composition candidates that
   meet the spec**. Those candidates are a *de facto* reverse
   engineering — not the trade secret, but **functionally equivalent**,
   and entirely proprietary-free.
7. **The honest boundary (d6).** RE yields a *candidate matching the
   public spec*, never SX500 itself. With no measured oracle against
   the actual SpaceX alloy, the verdict stays
   `gate_type=simulation-only-prediction`, `absorbed=false`. **But this
   is the d2 breakthrough**: a functionally-equivalent *open* alloy
   sidesteps the trade-secret wall entirely — demiurge's deliverable is
   an open SX500-class superalloy, publishable, not a stolen secret.

> **Why RE here is legitimate (not a violation):** governance D1 bans
> closed-binary decompilation, license/DRM circumvention, and
> trade-secret *extraction*. Constraint triangulation, patent reading,
> public-photo forensics, and forward simulation are all **public-
> surface clean-room** — the same standard every demiurge
> absorption-RFC already meets. The output is an *independently
> derived* open alloy, not a copy.

## §9. Cross-references

- `hexa-space/mondaloy/mondaloy.md` — upstream n=6 structural-pattern
  draft (2026-05-07) + `verify_mondaloy.hexa` count-lattice script
- `hexa-space/falcon/falcon.md` — Merlin engine (non-MondAloy variant)
- `hexa-space/spaceship/spaceship.md` — Raptor 3 combustion path
- `RTSC.md` — sibling materials-discovery doc (the d6/d7 governance
  pattern this doc reuses)
- `NUCLEAR.md` — sibling elemental-discovery doc
- `project.tape` d1 (drive non-wet-lab verification to done) · d2
  (wall → breakthrough paths) · d6 (absorbed ⇔ measured oracle) ·
  d7 (report only converged values, no forced target)

---

Historical log entries are in [`./MONDALOY.log.md`](./MONDALOY.log.md).
