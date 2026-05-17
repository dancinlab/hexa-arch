# domains/ — per-domain shallow public-surface maps

> Cohort 1 (named, `design.md` Decision 3 hybrid): chip is the **deep**
> domain (mapped in `HANDOFF.md` §5 + `proposals/rfc_001_*`); these 6 are
> **shallow** public-surface maps — breadth over depth.
> Boundary: public-surface clean-room (`design.md` Decision 1). Pipeline =
> 7-verb spine (`HANDOFF.md` §4 · `design.md` Decision 5). Source: Agent-3
> survey output, cited per file.

## Files

- [`cern.md`](cern.md) — particle accelerator (CERN-class)
- [`antimatter.md`](antimatter.md) — antiproton / positron trap + PET cyclotron
- [`rtsc.md`](rtsc.md) — high-field / superconducting magnet & coil
- [`space.md`](space.md) — spacecraft / launch / mission (NASA-class)
- [`energy.md`](energy.md) — battery / nuclear / grid / fuel-cell
- [`brain.md`](brain.md) — implantable neural interface (Neuralink-class)

## Cross-domain synthesis (Agent-3 output, condensed)

1. **A recurring 5-stage tool-binding pattern holds across all 6 domains**
   (model → synthesize/size → layout → verify → simulate) — maps onto the
   7-verb spine as DESIGN, SYNTHESIZE+ANALYZE, SYNTHESIZE, VERIFY, ANALYZE
   respectively. The remaining 7-verb slots (SPECIFY, ARCHITECT, HANDOFF)
   are domain-specific processes without consistent OSS tooling.
2. **OSS is strongest at DESIGN / SYNTHESIZE-size** (MAD-X, GMAT, PyBaMM,
   OpenMC, FEMM, PyPSA — all credible open tools), and **weakest at
   high-fidelity 3-D multiphysics ANALYZE / VERIFY**, where proprietary
   tools (FLUKA, ANSYS / COMSOL, CST / OPERA, Sim4Life) dominate every
   domain.
3. **Two shared tool-classes appear in 5 of 6 domains**:
   **Monte-Carlo particle transport** (Geant4 / OpenMC / FLUKA) and
   **FEM EM/thermal** (FEMM / COMSOL / Maxwell). A single hexa-arch
   `transport` abstraction + `fem` abstraction would serve those 5 — a
   concrete lever for hexa-arch's "integration glue" niche (point 5).
4. **Proprietary gap by domain**: smallest in `space` (NASA's fully open
   GMAT / OpenMDAO / OpenVSP / Trick / Basilisk stack); largest in
   `brain` (regulatory-grade implant safety sim has no open equivalent);
   `cern` and `rtsc` sit in between (open 2-D / proprietary 3-D split).
5. **The consistent missing piece is integration glue** — every domain
   has strong point tools but weak open cross-stage / cross-domain
   coupling. **This is precisely hexa-arch's niche.**

## Flagged uncertainties (Agent-3)

- No single dominant open trap / non-neutral-plasma simulator confirmed
  for `antimatter` — most groups use custom codes.
- `KiCad` usage for neural probes is plausible / common but not directly
  evidenced in the retrieved sources for `brain`.
- `STK` named from general knowledge as the `space` proprietary
  counterpart, not from a retrieved source.
