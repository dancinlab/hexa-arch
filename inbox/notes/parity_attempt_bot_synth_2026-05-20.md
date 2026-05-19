# Parity attempt — bot + synthesize (Pinocchio RNEA vs analytic Lagrangian)

- date: 2026-05-20
- ROI rank: 9 (⭐⭐⭐⭐)
- substrate: `~/core/hexa-lang/stdlib/bot/pinocchio_rbd.py` (extracted from
  hexa-lang commit `167ade23` — substrate landed on origin/main and is
  read-only for this exercise; nothing flipped, note only).
- backend: Pinocchio `pin==3.9.0` (libpinocchio 3.9.0, eigenpy 3.12.0) via
  `python3 -m pip install --user pin` (BSD-2 / LGPL-3, scikit-hep adjacent).
- workdir: `/tmp/bot_synth_parity_4242/` (URDF + rbd.json + meta.json).
- urdf_sha256_16: `5a585f18e0de1786` (matches the bot+structure κ-37 blob
  exactly — cross-cell parity confirmed).

## Configuration (URDF hermetic 2-link arm — see `pinocchio_rbd.py` lines 70-142)

- joint_1: revolute, axis = z, parent base_link, origin (0,0,0.1)
- joint_2: revolute, axis = y (in link_1 frame), origin (0,0,0.3) from link_1
- joint_ee: fixed (Pinocchio absorbs into link_2 composite)
- link_1: m₁ = 1.0 kg, COM (0,0,0.15), Izz = 0.0001
- link_2: m₂ = 0.5 kg, COM (0,0,0.125), Ixx = Iyy = 0.0042, Izz = 0.00005
- ee_link: m_ee = 0.1 kg, COM (0,0,0.025) in ee frame; ee frame origin
  (0,0,0.25) from link_2

Composite "link_2 + ee" (joint_ee fixed, Pinocchio merges):
- M₂_eff = 0.6 kg
- COM in joint_2 child frame: z̄ = (0.5·0.125 + 0.1·0.275) / 0.6 = **0.15 m**
- Ixx_eff (Steiner about composite COM):
  0.0042 + 0.5·0.025² + 0.00001 + 0.1·0.125² = **0.006085**
- Izz_eff = 0.00005 + 0.00001 = **0.00006**

Sample point: q = [0.5, −0.3] rad, v = [0.1, −0.2] rad/s, a = [0, 0] rad/s².

## Substrate output (Pinocchio RNEA — `simple_arm_v1.rbd.json`)

- `tau_rnea_Nm`     = [ **0.00022049288586**, **0.26096991368276** ]
- `gravity_torque`  = [ 0.0, 0.26091479046130 ]
- `M_crba` = [[0.001865161059, 0], [0, 0.019585]] (diagonal — confirms M₁₂ = 0)
- `ee_translation_m` = [−0.0648358, −0.0354200, 0.6388341]

## Analytic oracle (hand-derived Lagrangian — Spong/Hutchinson/Vidyasagar
   *Robot Modeling and Control* §7.5 standard 2-link form, generalized to
   the spatial z⊥y axis pair; Featherstone *Rigid Body Dynamics Algorithms*
   §6 for the spatial-inertia / parallel-axis transforms.)

Because the substrate arm is **spatial** (joint_1 z-axis ⊥ joint_2 y-axis),
the standard Spong planar formula doesn't apply directly — but the
underlying Lagrangian derivation is identical, just with the spatial
inertia tensor of link_2 rotated by Ry(q₂) into the link_1 frame before
being added through joint_2 onto link_1's Izz.

**Mass matrix.**

- M₂₂ = Iyy_link2_at_COM + m₂·(0.125)² + Iyy_ee_at_COM + m_ee·(0.275)²
       = 0.0042 + 0.0078125 + 0.00001 + 0.0075625
       = **0.0195850**  ✔ exact match with CRBA.
- M₁₁(q₂) = Izz_link1 + I_eff_about_z(q₂)
         = 0.0001 + 0.019585·sin²(q₂) + 0.00006·cos²(q₂)
  at q₂ = −0.3: M₁₁ = 0.0001 + 0.019585·0.08733 + 0.00006·0.91267 =
  **0.0018648** (Pinocchio: 0.001865 — agreement 5 sig figs).
- M₁₂ = M₂₁ = 0 (z-axis ⊥ y-axis in joint_1 frame ⇒ inertial coupling
  vanishes identically) ✔.

**Gravity torque g(q).** Gravity ↓ z, so projects to 0 on joint_1's z-axis:
- g₁(q) = **0** ✔ (Pinocchio: 0.0 exact).
- g₂(q) = M₂_eff · g · z̄ · sin(q₂) (lever arm = horizontal projection
  of composite COM about joint_2's y-axis)
       = 0.6 · 9.81 · 0.15 · sin(0.3)
       = 0.88290 · 0.29552
       = **0.260914...** Nm
  (Pinocchio: 0.26091479 — agreement **6 sig figs**.)

**Coriolis term C(q,v)·v.** Only ∂M₁₁/∂q₂ is non-zero. Christoffel
symbols Γ_ijk = ½(∂M_ij/∂q_k + ∂M_ik/∂q_j − ∂M_jk/∂q_i):

∂M₁₁/∂q₂ = (0.019585 − 0.00006) · sin(2q₂) = 0.019525 · sin(−0.6) = −0.011022

- C₁·v = (Γ_112 + Γ_121)·v₁·v₂ = ∂M₁₁/∂q₂ · v₁ · v₂
       = (−0.011022) · 0.1 · (−0.2) = **+0.0002204**
- C₂·v = Γ_211 · v₁² = −½·∂M₁₁/∂q₂ · v₁²
       = +0.005511 · 0.01 = **+0.0000551**

**Total analytic τ = M(q)·a + C(q,v)·v + g(q)** with a = 0:

| joint | analytic τ (Nm)  | substrate τ (Nm)   | abs Δ        | %parity      |
|-------|------------------|--------------------|--------------|--------------|
| 1     | 0.0002204        | 0.00022049288586   | 9·10⁻⁸       | **0.04 %**   |
| 2     | 0.2609691        | 0.26096991368276   | 8·10⁻⁷       | **0.0003 %** |

Both joints **well inside the ±0.1 % tolerance**. The residual on joint_1
is dominated by my truncating Ixx_eff at 6 sig figs in the Steiner
composition; the residual on joint_2 is essentially IEEE-754 double-
precision roundoff in the RNEA accumulation.

## Flip recommendation

**DO NOT FLIP** `absorbed=false` → `absorbed=true`. Per the prompt's
explicit non-negotiable, and per the substrate's own g3 declaration
(`pinocchio_rbd.py` lines 34-53): the URDF is still a self-generated
hermetic 2-link arm, not a bench-validated manufacturer model (UR5 /
Franka). The parity here confirms **the algorithm is correct** (Pinocchio
matches the textbook Lagrangian to roundoff), not that the **measurement**
is closed against physical reality. `measurement_gate = GATE_OPEN` stays.

What this parity *does* license:
- Treat Pinocchio RNEA / CRBA / Jacobians on this URDF as numerically
  trustworthy oracles for downstream consumers (Drake Lyapunov verify at
  ROI 13; future ros2_control hand-off).
- Cross-cell witness: `urdf_sha256_16 = 5a585f18e0de1786` is the same
  blob both bot+structure (urdfpy_basics.py) and bot+synthesize
  (pinocchio_rbd.py) reference — the two cells agree on geometry SSOT.

## Citations

- Spong M. W., Hutchinson S., Vidyasagar M. *Robot Modeling and Control*,
  2nd ed., Wiley 2020, §7.5 "The Two-Link Manipulator" — Lagrangian
  derivation of M(q), C(q,v), g(q) for revolute pairs; generalized here
  to the z⊥y spatial axis case.
- Featherstone R. *Rigid Body Dynamics Algorithms*, Springer 2008, §6
  "Recursive Newton-Euler Algorithm" + §2.4 spatial inertia transforms —
  the algorithmic basis of `pinocchio.rnea` and the parallel-axis /
  composite-inertia operations used to fold joint_ee into link_2.
- Carpentier J. et al. *The Pinocchio C++ library*, SII 2019 — `pin` /
  `libpinocchio` 3.9.0 implementation under test.

## Cross-session safety record

- hexa-lang treated read-only: `pinocchio_rbd.py` extracted to
  `/tmp/pinocchio_rbd.py` via `git show 167ade23:...` — no edit on the
  hexa-lang tree, no commit on hexa-lang side.
- demiurge worktree: this note is the only file touched; single commit
  expected on the agent worktree branch.
- substrate output retained at `/tmp/bot_synth_parity_4242/` for any
  follow-up consumer (e.g. Drake verify at ROI 13).
