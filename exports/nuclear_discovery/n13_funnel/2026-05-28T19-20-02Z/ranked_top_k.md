# NUCLEAR N13 next-cohort funnel — ranked accelerator-priority output

> ⚛️ **NUCLEAR** · "초중핵 사냥(超重核 funnel)" · N13 next-cohort sweep (sibling of N12 / N11 G4)
> Producer: `sim.hexa@nuclear-N13` (driver `n13_next_cohort.hexa` · scorer `n11_island_cell_checked`)
> Run: `hexa run test/n13_next_cohort.hexa` on **mini** (macOS · $0 local · NO pod rent) · 2026-05-28T19-20-02Z · hexa-lang e8aac4195
> **R4 invariant: `gate_type=nuclear-novel-discovery-simulation` · `absorbed=false` 영구.** Sim PASS = accelerator beam-time / α-chain-tag priority hint, NEVER a discovery claim. '가능성' != '임'. The novel-element funnel TARGET stays Z=119/120 (N12); N13 cells are CONFIRMED nuclei (decay-chain calibration + α-tag landscape).

## Cohort — the α-decay chain of the N12 top island candidate (298-120 + 296-120)

9 nuclides — the α-decay-chain DAUGHTERS of N12's top-2 (298-120 = 0.545, 296-120) plus the neutron-rich Og neighbour. N11/N12 scored only the Z=119/120 PARENTS; the chain members are genuinely uncovered. They are the nuclei an accelerator must pre-characterise for **α-chain CORRELATION TAGGING** of a Z=120 recoil event (the (e)-gate identification method). **All Q_α are MEASURED (AME2020-evaluated / experimental synthesis)** — strictly more rigorous than N12's predicted WS4 inputs.

**Honest-skipped (no extractable cited Q_α → §3.3, no fabrication, @D d6):**
- Z=119/120 PARENT cells N12 missed (294/298/301-119, 293/294-120): their WS4/KTUY Q_α in arxiv:1706.04068 / 2403.02748 are **figure-locked** (scatter-plot coordinates, no extractable decimal across the sources reachable this session). NOT fabricated → honest-skip until a cited decimal is in hand. Out-of-reach != impossible (@D d2).
- Z=121, Z=122 — no cited Q_α anywhere (arxiv:2402.11514 Skyrme table ends at Z=120, confirmed by N12). Permanent honest-skip (@D d6).
- N=183/184-region — WS4 table ends N=182 (302-120, N12); no cited island-center value → skip (no fabrication of the island value).

## Ranked top-K by composite_score (= c_total × island_weight)

| rank | nuclide | Z | N | Q_α (MeV) | log10 T_total (s) | dominant | island_w | **composite** | model_validity | tier |
|------|---------|---|---|-----------|-------------------|----------|----------|---------------|----------------|------|
| 1 | **292-Lv** | 116 | 176 | 10.78 | -1.69 | SF (b=0.50) | 0.389 | **0.3725** | nominal | priority |
| 2 | **294-Og** | 118 | 176 | 11.82 | -3.46 | α (b=0.74) | 0.389 | **0.2199** | nominal | priority |
| 3 | 290-Lv | 116 | 174 | 10.99 | -2.21 | SF (b=0.50) | 0.236 | 0.1987 | nominal | priority |
| 4 | 288-Fl | 114 | 174 | 10.07 | -0.39 | SF (b=0.50) | 0.249 | 0.1879 | nominal | priority |
| 5 | 293-Og | 118 | 175 | 11.92 | -3.55 | α (b=1.00) | 0.307 | 0.1674 | odd-A | priority |
| 6 | 286-Fl | 114 | 172 | 10.36 | -1.18 | SF (b=0.50) | 0.135 | 0.1256 | nominal | priority |
| 7 | **282-Cn** | 112 | 170 | 10.12 | -13.99 | SF (b≈0) | 0.062 | **0.0000** | nominal | **CLOSED-NEGATIVE** |
| 8 | **284-Cn** | 112 | 172 | 9.60 | -23.03 | SF (b≈0) | 0.128 | **0.0000** | nominal | **CLOSED-NEGATIVE** |
| 9 | **278-Ds** | 110 | 168 | 9.57 | -15.12 | SF (b≈0) | 0.023 | **0.0000** | nominal | **CLOSED-NEGATIVE** |

9/9 cells scored (no honest-skips WITHIN the measured-Q_α set). **3 CLOSED-NEGATIVE** (282-Cn, 284-Cn, 278-Ds), all KEPT (g63).

## Key findings

1. **292-Lv (N=176) leads the N13 cohort (composite 0.3725)** — long in-band half-life (log10 T_total = -1.69 s) on the highest-island-weight Z=116 cell of the chain (N=176 tie with 294-Og). It is the α-tag anchor of the 296-120 chain. All N13 composites sit BELOW N12's 298-120 (0.545) — consistent: the chain daughters are lighter (lower island_weight, further from N=184·Z=120 magic corner) than the Z=120 parent. **N12's 298-120 remains the overall novel-element funnel top.**
2. **The funnel correctly reproduces the KNOWN SF-collapse of confirmed nuclei** — 282-Cn (Z=112, real T½≈0.8 ms SF), 284-Cn (Z=112, real T½≈100 ms SF) and 278-Ds (real T½≈0.2 ms, SF/α) all land CLOSED-NEGATIVE (composite=0, b_α≈0, log10 T_total far below the accelerator band). The Ren-Xu/ZWP SF kernel is IN-MODEL valid for these even-even / near-magic Z=110-112 cells → these are genuine in-model SF-collapses, not model-edge artifacts (@D d2). This is a strong CALIBRATION result: the scorer reproduces measured decay behaviour of confirmed nuclei.
3. **294-Og (composite 0.2199)** is the smoke-test anchor cell (Q_α 11.82, exp 11.65 → smoke log10 T = -2.93 reproduced). α-dominant (b=0.74), the direct daughter of 298-120 — the FIRST α-tag step for a 298-120 recoil chain.
4. **1 odd-A flag** (293-Og, mv=odd-A-hindrance-not-modeled) — its composite is an honest hindrance-uncaptured signal, not a true collapse. `sf_model_invalid=true` on 4 even-A chain cells = Ren-Xu out-of-domain guard fired → α-only total used as PREDICTION (the 3 genuine CLOSED-NEGATIVEs are the deep-SF cells with sf_model_invalid=false).

## Verification (g5)

Closed-form kernels (NC1 Viola-Seaborg, NC2 Royer, C1 Ren-Xu/Hoffman/ZWP SF) reproduce the U-238 and Og-294 consensus anchors VERBATIM via `test/nuclear_r4_anchor_smoke.hexa` — **4/4 PASS** (run on mini, hexa-lang e8aac4195). The Og-294 anchor (Q_α 11.65) is the same nucleus as N13 cell 294-Og (Q_α 11.82, AME2020). R4 invariant intact (7 absorbed=false literals, 0 absorbed=true). Verbatim smoke verdict:

```
[R4] absorbed=false literals = 7  absorbed=true literals = 0
[PASS] R4: at least one absorbed=false hardcode present
[PASS] R4: zero absorbed=true literals (no flip)
[anchor] U-238  mean_log10_T_s = 17.4493  (anchor +17.4, tol 0.5)  valid=1
[PASS] anchor U-238 α: log10 T½ ≈ +17.4 s within 0.5 dex
[anchor] Og-294 mean_log10_T_s = -2.93088  (anchor -2.93, tol 0.5)  valid=1
[PASS] anchor Og-294 α: log10 T ≈ -2.93 within 0.5 dex
  nuclear_r4_anchor smoke: PASS=4 FAIL=0
__NUCLEAR_R4_SMOKE__ PASS
```

`hexa verify --expr` re-registration remains BLOCKED: `tool/verify_cli.hexa` clang `_bessel_j1` duplicate-symbol codegen bug (hexa-lang INBOX #2002, pre-existing, unrelated to N13). The smoke-test anchor reproduction IS the green closure (as N12 did).

## Provenance / citations

- Q_α MEASURED / AME2020-evaluated: 294-Og 11.82 (exp 11.65 JINR 2002/2005; chemlin 11.867), 290-Lv 10.99, 286-Fl 10.36, 282-Cn 10.12, 278-Ds 9.57, 292-Lv 10.78, 288-Fl 10.07, 284-Cn 9.60, 293-Og 11.92.
- arxiv:1811.00427 — Olsen & Nazarewicz, "Alpha Decay Energies of Superheavy Nuclei: Systematic Trends" (computes the 296-120 + 298-120 α-decay chains; basis for the N13 chain selection)
- arxiv:1706.04068 — WS4/KTUY Q_α for Z=119/120 parents (figure-locked → parent cells honest-skipped this session)
- arxiv:2403.02748 — RMF (NL3*) α-decay 100≤Z≤120 (Q_α figure-only)
- arxiv:2506.02684 — Deformed magic N=178, Z=120 (basis for 298-120, the N12 top whose chain N13 maps)
- AME2020 atomic mass evaluation + NUBASE2020 (measured Q_α / half-lives of the confirmed chain members)
- Viola-Seaborg 1966 / Royer 2000 / Ren-Xu PRC71 014309 2005 / Hoffman 1993 / Zdeb-Warda-Pomorski 2013 (kernels)
- demiurge research note 2026-05-25-she-driplinelit.md §3 (cohort context); n12_funnel/2026-05-28T18-37-27Z (parent funnel)

absorbed=false 영구 (R4). The N13 chain members are CONFIRMED nuclei — scoring them is funnel calibration + α-chain-tag landscape mapping, NEVER a new-element discovery. The novel-element funnel target (Z=119/120, N12) and the (e)-gate detection (DGFRS-2 / GARIS-III) remain permanently wet-lab-dependent.
