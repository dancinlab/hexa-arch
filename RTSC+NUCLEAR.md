# RTSC+NUCLEAR — current state

@goal: Unify the two sibling discovery funnels — NUCLEAR (elemental: superheavy/drip-line nuclides) + RTSC (compositional: new SC materials) — under one shared R4 invariant family (absorbed=false 영구, sim != measurement); formalize the elemental<->compositional bridge + cross-domain gate/invariant consistency

두 자매 발견 깔때기(NUCLEAR=원소 · RTSC=조성)의 교차점 전담 메타도메인. 공유 R4 불변식: `absorbed=false 영구` · sim ≠ measurement.

- [x] NUCLEAR x RTSC honest-exception bridge — SHE/isomer → RTSC bulk = NO (벽=생산량 not 반감기) · single-atom 상대론 화학은 예외. exports/nuclear_discovery/bridge/2026-05-25-nuclear-rtsc-bridge.md
- [x] Shared R4 invariant parity audit — NUCLEAR §3.1 ↔ RTSC §9.10 parity PASS (8축 중 7 MATCH · gate_type `nuclear-` prefix는 §3.1 명시 mirror 의도 DRIFT) · producer 12/12 `absorbed` literal false 하드코드 (조건부/runtime flip 0건) · @D d6 measured-oracle helper record-agnostic (MeasuredOracleRef.swift:104), sim-only는 oracle path 부재 → 영구 false. exports/nuclear_discovery/parity/2026-05-25-r4-parity-audit.md
- [x] Unified discovery-funnel formalism — elemental (a-e) <-> compositional (a-e) gate-mapping table + shared sim.hexa kernel inventory (본문 §F1-§F3)

---

## §F. Unified discovery-funnel formalism

> 두 자매 깔때기는 **같은 5-슬롯 게이트 골격**을 다른 discovery axis 에 입힌 것이다.
> NUCLEAR = *elemental* (Z,N 핵종) · RTSC = *compositional* (화학식 물질). 본 §F 는
> ① 슬롯별 의미 매핑 ② 공유 sim.hexa 커널 인벤토리 ③ 공유 R4 불변식을 박는다.
> SSOT — gate 정의: NUCLEAR.md §2·§2.1 + RTSC.md §8.9·§9.6·§9.7 · 커널: hexa-lang
> `stdlib/{nuclear,material}/sim.hexa`.

### §F1. Gate-slot 매핑 테이블 (elemental ↔ compositional)

핵심 평행구조: **두 funnel 모두 (a)(b)(c) = sim-sufficient → (d)(e) = wet-lab 영구의존.**
슬롯 번호는 NUCLEAR.md §2 의 (a-e) 와 RTSC.md §8.9 의 (a-e) 를 같은 행에 정렬한다
(두 도메인의 a-e 가 *우연히* 같은 글자가 아니라, 본 테이블이 **discovery 슬롯 의미**로
재정렬한 것이다 — RTSC 원본 a-e 라벨은 ⟨ ⟩ 안에 병기).

| 슬롯 | NUCLEAR (원소: Z,N 핵종) | RTSC (조성: 화학식 물질) | NUCLEAR sim 충분? | RTSC sim 충분? | 공유 honest 평결 |
|------|---------------------------|---------------------------|:-----------------:|:--------------:|------------------|
| **(a) 존재/안정** | mass + binding E + deformation (HFB/RMF/FRDM) · bound state 예측 | ⟨a⟩ 합성가능성: convex-hull stability + CSP 구조 (CALYPSO/USPEX/MP) | ✅ sim 충분 (±0.5–1.5 MeV) | ✅ sim 충분 (formation E + 안정성) | **sim PASS = "존재할 만함" — 존재 아님** |
| **(b) 분광/특성구조** | spectroscopy: shell-model 준위 · B(E2)·B(M1) (KSHELL/BIGSTICK) | ⟨b⟩ Tc 예측: BCS/McMillan/Allen-Dynes/Eliashberg + BETE-NET ML | ✅ sim 충분 (valence-space tractable) | ✅ sim 충분 (예측 · 측정 아님) | **sim PASS = 특성 *예측* — 측정 아님** |
| **(c) 거동/임계** | decay: α/β/SF 반감기 (WKB+Geiger-Nuttall · NC1·NC2·NC3) | ⟨c⟩ 압력조건: ambient/저압 안정 SC 거동 (QE+EPW P-sweep) | ✅ sim 충분 (scatter ~10×/0.5-1 dex) | ✅ sim 충분 (예측) | **sim PASS = 거동 *예측* — 실측 미확인** |
| **(d) 생산/재현** | ★ fusion-evap σ — SHE 생산단면적 (HIVAP/DNS/KEWPIE2, ~10× scatter) | ⟨d⟩ ≥3 독립 lab 재현 (cross-code 3-way 는 *유사물*일 뿐) | ⚠ **wet-lab 영구의존** (sim ~10×, 확정 불가) | ⚠ **wet-lab 영구의존** (epistemic 독립 substitute 불가) | **(d) = 영구 wet-lab — sim 우선순위 hint 만** |
| **(e) 검출/오라클** | ★ detection: SHIP/DGFRS/GARIS recoil-separator (sim 無) | ⟨e⟩ measurement-oracle parity: model↔측정 Δ<5% (sim↔sim 은 parity 아님) | ⚠ **wet-lab 영구의존** (beam-line 자체가 측정) | ⚠ **wet-lab 영구의존** (측정 오라클 부재) | **(e) = 영구 wet-lab — sim 대체 불가** |

```
   discovery slot:   (a)존재  (b)특성  (c)거동  │  (d)생산/재현  (e)검출/오라클
                     ───────────────────────────┼──────────────────────────────
   NUCLEAR(원소):    HFB질량  shell모델 α반감기  │  fusion-σ       recoil-separator
   RTSC(조성):       안정성   Tc예측    압력안정  │  ≥3 lab 재현    measure-oracle
                     ◄─────  sim-sufficient ───►│◄── wet-lab 영구의존 ──►
                          gate_type per-domain  │   absorbed=false 영구 강제
```

→ **두 funnel 의 절단선이 (c)|(d) 사이에 정확히 일치**한다. (a)(b)(c) 는 closed-form/
DFT/ML 로 sim PASS 가능 = *후보 우선순위*. (d)(e) 는 어느 쪽도 sim 으로 못 넘는 물리적
hardware 벽 (가속기 빔타임 ↔ 합성+측정 lab). 이 절단선이 두 도메인이 *parallel funnel*
이지 *통합 supply 경로*가 아닌 이유다 (NUCLEAR.md §3.4 bridge 평결 · RTSC.md §8.9 NUCLEAR×RTSC bridge).

### §F2. 공유 sim.hexa 커널 인벤토리

두 도메인의 Path-A microkernel 은 `hexa-lang/stdlib/{nuclear,material}/sim.hexa` 에 산다
(libm-only closed-form · 외부 binary/install gate 없음 · D72 thin-adapter 패턴의 hexa-native
예외). Python orchestrator (`wkb_alpha_decay.py` · `sim_adapter.py`) 가 record-level
gate_type/absorbed/skip-cascade 정책을 소유하고, sim.hexa 는 **숫자만** 반환한다.

| 커널 | 도메인 | 계산 내용 | 슬롯 | tier | 공유 패턴 |
|------|--------|-----------|:----:|:----:|-----------|
| `viola_seaborg_log10_t` (NC1) | nuclear | α-반감기 log₁₀T = (aZ+b)/√Q + (cZ+d) | (c) | 🟢 | Geiger-Nuttall family closed-form |
| `royer_log10_t` (NC2) | nuclear | α-반감기 질량의존 refit (A^⅙·√Z) | (c) | 🟢 | NC1 의 자매 fit (ensemble member) |
| `consensus_alpha` → `ConsensusAlpha` (NC3) | nuclear | unweighted mean/min/max/spread_dex | (c) | 🟢 | ★**MIRROR** of material `Consensus` |
| `c_gate_window_score` + `n11_alpha_cell` → `NuclideScore` (N11) | nuclear | (c)-gate 삼각창 priority score + funnel cell | (c→funnel) | 🟢 | ★**MIRROR** of RTSC N5 funnel |
| `bcs_weak_tc` | material | BCS 약결합 Tc = 1.13·Θ_D·e^(−1/λ) | (b) | 🔵 | closed-form 항등식 |
| `mcmillan_tc` | material | McMillan 중간결합 Tc | (b) | 🔵 | AD 의 base kernel |
| `allen_dynes_tc` / `allen_dynes_full` | material | 강결합 f1·f2 보정 Tc | (b) | 🔵 | 본 도메인 default predictor |
| `eliashberg_moments_from_a2f` | material | α²F(ω) → (λ, ω_log, ω̄₂) 적분 | (b) | 🔵 | 🟢→🔵 escalation prereq (RTSC #4) |
| `morel_anderson_mustar` · `coherence_length` · `isotope_exponent` · `gl_parameter_kappa` · `london_penetration_depth` · `thermo_critical_field` · `condensation_energy` · `bcs_gap_zero` · `pippard_coherence` | material | μ*·ξ·α·κ·λ_L·Hc(T)·U·Δ(0)·ξ₀ — SC 부가 closed-form | (b) | 🔵 | BCS/GL 표준 항등식 패널 |
| `sigma_from_spread` | material | 불편표본 stdev (Bessel n−1), σ_default floor | (d-analog) | 🔵 | cross-code consensus 보조 |
| `inverse_variance_consensus` → `Consensus` (NC3 원본) | material | 1/σ² 가중 mean · combined σ · pairwise rel_err | (d-analog) | 🔵 | ★**MIRROR** source of nuclear NC3 |

#### ★ MIRROR 관계 (핵심 — 두 stack 의 구조적 동형)

```
material/sim.hexa  Consensus { mean, combined_sigma, n_sources, rel_err_max_pairwise }
                          │  inverse-variance (1/σ² 가중) — 더 일반적 커널
                          ▼  σ=1 대입 시 → unweighted mean 으로 환원
nuclear/sim.hexa   ConsensusAlpha { mean, min, max, spread_dex, n }
                          │  unweighted mean + raw spread(max−min) — N7 의도된 *다른* shape
```

- 두 struct 는 **의도적으로 다른 shape** — material 은 inverse-variance combined σ, nuclear 은
  raw spread(max−min). nuclear NC3 가 material 을 *wrap* 하지 않고 **전용 struct+kernel** 로
  구현한 이유 = 두 자매 stdlib 모듈 간 semantic coupling 회피 (nuclear/sim.hexa §3 NC3 주석 ·
  "do NOT collapse"). 산술은 독립 · code-drift risk 는 MIRROR 주석으로 명시.
- 같은 funnel 패턴: nuclear **N11** (`n11_alpha_cell` → top-K JSON) = RTSC **N5**
  (`novel_material_funnel.py` → top-K JSON) 의 elemental transpose. 둘 다 enumerate →
  (a)(b)(c) sim score → rank by composite → emit `top_k.json` (accelerator/wet-lab 우선순위).
- tier 비대칭: material kernel = 🔵 SUPPORTED-FORMAL (BCS/McMillan/AD/WHH/GL 은 닫힌 물리
  항등식) · nuclear kernel = 🟢 SUPPORTED-NUMERICAL (Geiger-Nuttall family 는 ~400 known
  α-emitter 에 대한 *semi-empirical fit* — 항등식 아님, 그래서 한 tier 아래). 둘 다 sim PASS
  ≠ measurement 는 동일.
- 버전: nuclear `sim.hexa` v0.2.0 · material `sim.hexa` v0.3.0 (BCS GL 부가 커널 9종으로 v0.2.0→v0.3.0 확장).

### §F3. 공유 R4 불변식 (single statement)

```
┌─ R4 INVARIANT (두 funnel 공통) ──────────────────────────────────────────────┐
│                                                                              │
│  1.  absorbed = false  영구                                                   │
│      어떤 record 도 sim 만으로 absorbed=true 로 flip 못한다. 하드코드 —        │
│      producer 안에 박힌 상수이지 runtime 결정이 아니다 (no runtime flip).      │
│                                                                              │
│  2.  sim PASS  =  wet-lab 우선순위 (NOT discovery)                            │
│      (a)(b)(c) 5-gate sim PASS → "이 후보가 빔타임/합성+측정 우선순위 상위"     │
│      ≠ "이 핵종/물질이 존재/발견됨". "가능성" ≠ "임" (R4 Pattern 1 회피).      │
│                                                                              │
│  3.  gate_type  per-domain (slot 의미는 §F1 로 통일, 라벨은 도메인별)          │
│      NUCLEAR : gate_type = nuclear-novel-discovery-simulation                 │
│      RTSC    : gate_type = novel-discovery-simulation                         │
│                          / simulation-only-prediction (Tier-1 §8.7)          │
│                                                                              │
│  4.  절단선 (c)|(d) 영구 — (d)(e) 는 hardware 벽 (가속기 빔 ↔ 합성+측정 lab)    │
│      두 funnel 은 같은 R4 family 의 PARALLEL funnel — 물질 supply 통합 아님    │
│      (NUCLEAR.md §3.4 · RTSC.md §8.9 bridge 평결: SHE→bulk 벽=생산량).         │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

- 코드-레벨 강제: material `MaterialAttestationRecord` Codable decoder 가 `domain=="rtsc"`
  sim record 의 absorbed=true 를 reject (RTSC §8.10 R4 Stage 1) · nuclear 은
  `NuclearVerifyRecord` 추가 시 @D d6 4-carrier audit 가 auto-extend (NUCLEAR.md §3.0).
- 정직 정정 선례: RTSC §8.10 Nb attestation (domain "rtsc"→"lts", LTS≠RTSC) — 어떤 sim-only
  record 가 absorbed=true 면 g3 위반으로 producer reject.
