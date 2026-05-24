# `exports/conductor/n6_claim_only/` — hexa-rtsc n=6 claim-only RT-SC family slot

> **Milestone**: RTSC.md M471 (line 469)
> `- [x] hexa-rtsc n=6 후보를 absorbed=false · provisional=true · gate_type=empirically-unproven 로 import (claim-only 영역 명시 · claim-only RT-SC family slot 동일 contract)`
>
> **Schema**: `conductor-handoff/0.1.0` (same family as PR #90)
> **Gate type**: **`empirically-unproven`** (NOT `hexa-rtsc-derived`)
> **R4 invariant**: `absorbed=false · provisional=true` — 영구 lock

---

## 1. 이 폴더는 무엇인가

RTSC.md §8.2 가 정의하는 8-family material matrix 의 **`hexa-rtsc n=6 candidate`** 행 (claim-only RT-SC sibling slot) 을 typed JSON 으로 import 한다. 본 폴더의 모든 record 는 **algebra (n=6 perfect-number lattice closed-form) 로 *주장만 된* RT-SC 후보** — 합성 루트도 없고, DFT 도 없고, 측정도 없는 *순수 algebraic claim*.

PR #90 의 sibling 폴더 `exports/conductor/hts_rebco/` 와는 **gate_type 으로 구분**된다:

| 폴더 | gate_type | 무엇이 들어있나 |
|------|-----------|----------------|
| `exports/conductor/hts_rebco/` (PR #90) | `hexa-rtsc-derived` | **시뮬레이션-derived** 숫자 — 측정된 REBCO family 의 closed-form/BCS lineage 예측. 물리적으로 reproducible. |
| `exports/conductor/n6_claim_only/` (이 폴더, M471) | **`empirically-unproven`** | **algebraic-claim-only** — n=6 perfect-number identity 로 *주장만 된* 타겟. 측정 없음, recipe 없음, DFT corpus entry 없음. |

**gate_type 의 구분이 본 milestone 의 전부**다. 같은 `hexa-rtsc-derived` lineage 라도, sim-derived numeric 과 algebraic claim 은 *gate semantics 가 다르며* schema 가 그것을 명시한다.

---

## 2. 본 폴더에 들어있는 candidate

| candidate_id | compound | Tc (claim) | Hc2 (claim) | pressure | 출처 |
|--------------|----------|-----------|------------|----------|------|
| `n6_master_sigma_tau` | (named compound 없음 — master algebraic spec) | 300 K | 48 T (σ·τ) | ambient (0 GPa) | hexa-rtsc n=6 perfect-number identity |
| `n6_mk2_lcyscH24` | (La,Ce,Y,Sc)H₂₄ | 300 K | 48 T | ambient (0 GPa) | hexa-rtsc 14-paper DSE Pareto rank 1, Mk.II seed |
| `n6_y_ca_h6_predicted` | (Y,Ca)H₆ | 210 K (predicted) | n/a | 185 GPa | hexa-rtsc Mk.I 6 P-T path #3 (Y-substituted CaH₆) |

각 candidate 의 schema 는 `<candidate_id>/<UTC-stamp>/conductor_<candidate_id>.json` 으로 들어있다.

### 2.1 왜 (La,Ce,Y,Sc)H₂₄ 만 named-compound RT-SC slot 인가

hexa-rtsc paper §6 의 Mk.I 6 P-T path:

1. H₃S (200 GPa, Tc=203 K) — Drozdov 2015 **MEASURED** → not claim-only
2. LaH₁₀ (170 GPa, Tc=250 K) — Somayazulu 2019 **MEASURED** → not claim-only
3. (Y,Ca)H₆ (185 GPa, Tc=210 K) — **PREDICTED** → `n6_y_ca_h6_predicted` (이 폴더)
4. CaH₆ (172 GPa, Tc=215 K) — Ma 2022 **MEASURED** → not claim-only
5. ThH₁₀ (100 GPa, Tc=161 K) — Semenok 2021 **MEASURED** → not claim-only
6. **(La,Ce,Y,Sc)H₂₄ (ambient, Tc=300 K) — Pareto rank 1 Mk.II SEED** → `n6_mk2_lcyscH24` (이 폴더)

측정된 4개 (1·2·4·5) 는 §8.2 matrix 의 `Hydride` 행 — 본 폴더의 claim-only 슬롯이 *아니다*. 예측된 1개 (#3) + ambient Mk.II (#6) + master algebraic spec → **3건 import**.

---

## 3. 영구 invariant (RTSC.md §8.8)

**RTSC 가설은 never absorbed=true.** 본 폴더의 어떤 record 도 `absorbed=true` 로 flip 될 수 없다 — RTSC.md §8.9 의 5-gate matrix 가 막는다:

| §8.9 gate | n=6 master | Mk.II (La,Ce,Y,Sc)H₂₄ | (Y,Ca)H₆ predicted |
|-----------|-----------|----------------------|--------------------|
| (a) synthesis 가능성 (≥3 lab) | ✗ no recipe | ✗ no recipe | ✗ no recipe |
| (b) Tc measurement triad | ✗ | ✗ | ✗ |
| (c) ambient pressure | (claimed but no measurement) | (claimed but no measurement) | ✗ 185 GPa |
| (d) ≥3 lab replication | ✗ | ✗ | ✗ |
| (e) long-term stability | ✗ | ✗ | ✗ |

→ 모든 row 의 verdict: **`never`** (a 단독 FAIL 만으로도 lock). RTSC.md §8.9 line 572 `hexa-rtsc n=6 — ✗ no recipe — never` 와 일치.

**§8.8 honest stance + governance @D d1/d5/d6 모두 일관**:
- @D d5 (`absorbed=true ⇔ all non-wet-lab gates PASS`) — RT-SC family 는 §8.9 가 wet-lab gate 를 *명시적으로* 요구하므로 algebraic claim 만으로는 영구 fail
- @D d6 (`first-principles physics breaks ML wall`) — algebraic n=6 identity 는 first-principles 가 아니라 *number-theoretic numerology* (RTSC.md line 1034: hexa atlas 7448 nodes' SC content = n6 numerology, measured-oracle Tc = ZERO)
- @D d1 (`drive non-wet-lab to completed-form`) — claim-only 는 *non-wet-lab 만으로 완결되지 않는* 영역. completed-form 은 §8.9 의 5-gate 전부 통과를 의미

---

## 4. 사용 금지 (device producer 입력 금지)

RTSC.md §8.2 마지막 줄:

> 본 producer 의 `conductor=rebco_hts_linear_mu1` default 는 위 표의 **HTS Cuprates** 행. RTSC 가설 (claim-only RT-SC · hexa-rtsc n=6) 은 **실제 device 권선의 입력으로 사용 금지** — empirical proof 가 없음. demiurge 가 가설 물질을 `absorbed=true` 로 기록하면 그 자체가 g3 위반.

→ 본 폴더의 어떤 JSON 도 `getdp_hts.py` 또는 ConductorLoader Swift surface 의 *runtime input* 으로 사용해서는 안 된다. 본 폴더는 *typed claim record* 의 archive — Tier 1-3 도달 가능한 schema slot 이지, Tier 4 absorbed device input 이 아니다.

---

## 5. 향후 update 정책

- 어떤 candidate 든 *측정* 이 land 하면 (synthesis + Tc + R=0 + Meissner triad + ≥3 lab replication), **새 candidate_id 의 새 record** 로 supersede 한다 — 본 record 는 algebraic-anchor 로 그대로 보존 (history).
- 새 hexa-rtsc n=6 algebraic candidate 가 추가되면 새 sub-folder 추가, 동일 contract (gate_type=empirically-unproven · absorbed=false · provisional=true · family=rtsc_hypothetical · scope_caveats 에 `claim-only — algebraic / lattice-derived (n=6)` 명시).
- RTSC.md §8.9 5-gate matrix 가 진화하면 본 README §3 표를 동기화.

---

## 6. cross-ref

- **RTSC.md §8.2** — 8-family matrix (claim-only RT-SC / hexa-rtsc n=6 candidate 두 인접 행의 contract)
- **RTSC.md §8.5 / §8.6** — handoff schema · ConductorMaterial enum · gate_type 사전 (`{ vendor-datasheet | hexa-rtsc-derived | external-paper | empirically-unproven }`)
- **RTSC.md §8.7** — 4-tier expansion (claim-only families → Tier 1-3 max, Tier 4 absorbed ✗)
- **RTSC.md §8.8** — g3 honest stance (`RTSC 가설은 never absorbed=true` invariant)
- **RTSC.md §8.9** — 5-gate matrix (hexa-rtsc n=6 row = `never`)
- **RTSC.md line 1034** — atlas mining 2026-05-22 (atlas SC content = n6 numerology, measured-oracle Tc = ZERO; 본 폴더의 atlas-provenance 근거)
- **PR #90** (`exports/conductor/hts_rebco/20260525T000000Z/conductor_rebco_hts_baseline.json`) — sibling derived record (`gate_type=hexa-rtsc-derived`); 본 폴더의 gate-distinction 비교 anchor

---

*M471 — 2026-05-25 import (UTC stamp 20260524T214329Z) · gate_type=empirically-unproven 명시 · never absorbed invariant locked*
