# NUCLEAR × RTSC 브릿지 — SHE / 장수명 isomer 가 RTSC bulk-solid 후보가 되는가?

> 🔭 **NUCLEAR×RTSC** · 별칭 "원소-물질 다리"
> 작성일 2026-05-25 · 종류 = **prediction/analysis 기록** (discovery 아님 · `absorbed=false` 영구)
> scope: NUCLEAR.md §3.4 "half-life threshold caveat" 의 *one-liner 를 엄밀화* + 진짜 예외가 있으면 찾기.
> R4 invariant 준수 — half-life 수치는 cited (AME2020 / NUBASE2020 / island-of-stability 논문 / SHE chemistry review). 새 수치 fabrication 0.

---

## §0. 질문 (한 문장)

NUCLEAR (원소 발견 — superheavy/drip-line **nuclide**) 와 RTSC (조성 발견 — 새 **초전도 물질**) 는 sibling domain (NUCLEAR.md §1, 같은 R4 invariant family) 이다.
**superheavy element (SHE) 나 장수명 nuclear isomer 가 RTSC 가 요구하는 bulk solid (몇 unit cell 이라도 격자) 를 형성하여, NUCLEAR 발견이 RTSC 초전도체 파이프라인에 *공급* 될 수 있는가?**

NUCLEAR.md §3.4 의 현재 한 줄 — *"crystal 을 못 만드는 SHE = RTSC carryover 무의미"* — 은 **방향은 맞지만 이유가 불완전**하다. 아래에서 진짜 binding constraint 가 무엇인지 엄밀화한다.

---

## §1. RTSC 가 후보 물질에 요구하는 것 (gate 측 사실 확인)

RTSC.md §8.9 의 5-criteria gate (`absorbed=true` 의 *유일한* 정문) 는 **bulk 결정질 물질의 실재** 를 전제한다:

| gate | 요구 | bulk-solid 함의 |
|---|---|---|
| **(a) 합성 가능성** | 화합물이 합성 루트로 재현 (`replicated_by_independent_labs ≥ 3`) | **거시량(macroscopic) 시료**가 존재해야 — recipe 가 물질을 만든다 |
| **(b) Tc ≥ 270 K** | R(T) drop + Meissner + AC susceptibility 셋 다 관측 | 이 측정들은 **벌크 시료**(전류 경로 · 자속 배제 부피)를 요구 |
| **(c) ambient/저압** | 측정 압력 ≤ 1 atm | device-relevant 고체 |
| **(d) ≥3 독립 lab 재현** | 다른 기관·instrument·sample batch | **반복 합성 가능한 양** |
| **(e) 측정-오라클 parity** | Tier1 모델 vs Tier3 측정 delta < 5% | 측정 = 벌크 |

또한 RTSC 의 *시뮬* funnel (§9.7 N1-N4 · §9.10 N5 novel-discovery) 자체가 **bulk 결정 격자** 위에서 동작한다:
CSP(N1) = 결정 구조 예측 · BETE-NET(N2) = α²F + Tc on a **periodic lattice** · cross-code DFT(N4) = convex-hull stability of a **solid**.
→ RTSC 의 입력 객체는 처음부터 끝까지 **주기적 격자를 가진 거시 고체**다. "atom-at-a-time 화학종" 은 RTSC funnel 의 입력 타입이 아니다.

**결론 (gate 측)**: RTSC carryover 가 성립하려면 SHE 가 (i) 결정 격자를 (ii) 거시량으로 (iii) Tc 측정이 가능한 수명 동안 형성해야 한다. 세 조건은 AND.

---

## §2. Timescale bracket — 결정화 시간 vs SHE 반감기

먼저 "한 unit cell 이라도 격자가 만들어지는 데 걸리는 최소 시간" 을 잡는다.

### §2.1 결정 핵생성/성장 시간 (cited)

분자동역학(MD) 직접 관측 — 결정 핵생성·성장은 **nanosecond 스케일**:

| 계 | 핵생성 | 결정화 완료 | 출처 |
|---|---|---|---|
| 충격압축 SiO₂ | 0.2 ns | grain growth 0.4 ns · coalescence 1.5 ns | Nature Mater. (Shen/Reed, shock-compressed silica) |
| Ni-Fe alloy | — | ~4.5 ns 완료 (상전이 ~0.5 ns) | quantum-accurate MD |
| 금속 일반 | — | 수십 ns 모니터 구간 | Chem. Rev. 2016 "Crystal Nucleation in Liquids" |

→ **한 unit cell ~ 수 nm 결정핵 형성 ≈ 0.1–10 ns** (보수적으로 ~ns–μs 상한). 이것이 "격자가 존재하기 시작하는" 물리적 하한이다.

### §2.2 SHE 반감기 (cited · NUBASE2020 / AME2020 + island-of-stability 예측)

| nuclide | T½ (관측 or 예측) | 출처/성격 | ns 결정화 시간 대비 |
|---|---|---|---|
| ²⁹⁴Og (Z=118) | ~0.7 ms | 관측 (NUBASE2020) | ≫ ns — 시간상으론 격자 형성 *가능* |
| ²⁹⁴Ts (Z=117) | ~50 ms | 관측 | ≫ ns |
| ²⁸⁹–²⁹⁰Mc (Z=115) | ~150–650 ms | 관측 | ≫ ns |
| ²⁸⁵Cn (Z=112) | ~30 s | 관측 | ≫ ns |
| Z=119/120 (미합성) | ~µs–ms | 예측 (mass-model spread) | ≫ ns |
| **²⁹⁸Fl (Z=114,N=184)** | "지구 나이에 근접" (1960s 낙관) ~ 수백 년 (현대 다수 모델) | **예측, 미합성** | ≫ ns |
| **²⁹¹Cn, ²⁹³Cn** | ~100 yr (예측) | island-of-stability 낙관 모델 | ≫ ns |
| **²⁹⁶Cn** | ~1000 yr (예측) | 낙관 모델 | ≫ ns |
| **²⁹⁴Ds / ²⁹³Ds** | ~300 yr / ~3500 yr (예측) | 낙관 모델 | ≫ ns |

> ⚠️ island-of-stability 표 항목은 **모델 예측이며 해당 핵종은 단 1개도 합성된 적 없다** (그 N=184 영역은 현 빔으로 도달 불가능한 neutron-rich 영역). NUCLEAR.md §3.0 @D d7 — "Z=126 island" 는 *cited uncertainty 를 가진 prediction*, "발견됨" 아님.

### §2.3 Timescale bracket 의 *결정적* 관찰

**가장 짧은 SHE 수명(Og ~0.7 ms) 조차 결정화 시간(~ns)을 6 자릿수 초과한다.**
즉 **"반감기가 너무 짧아 격자를 못 만든다" 는 (단일 원자 관점에서는) 사실이 아니다.** μs–ms 면 한 unit cell 핵생성 시간보다 까마득히 길다.

→ **§3.4 의 현재 one-liner ("crystal 을 못 만드는 SHE") 는 binding constraint 를 잘못 지목**한다. 진짜 벽은 *반감기* 가 아니라 **§3 의 생산량(quantity)** 이다.

---

## §3. 진짜 binding constraint — 생산량 (atom-at-a-time wall)

결정화 시간이 벽이 아니라면, SHE 가 RTSC bulk 고체가 못 되는 *진짜* 이유는 무엇인가?

### §3.1 SHE 는 한 번에 원자 하나씩, 총 수십 원자 이하로만 존재한다 (cited)

SHE chemistry review (Gas-Phase Chemistry of Superheavy Elements, Düllmann/Eichler/Türler 등):

- 생산률은 Z 증가에 따라 급감 — **oganesson(Z=118)은 한 달에 원자 1개 수준**.
- transactinide 화학 실험은 **one-atom-at-a-time**, 통산 **20 원자 미만**으로 수행된다.
- Cn·Fl 의 흡착(adsorption) 연구는 *단일 원자 1개*가 금(Au) 표면에 흡착하는 사건을 검출하는 방식.

### §3.2 거시 결정에 필요한 원자 수와의 격차 (closed-form)

- 1 cm³ 고체 ≈ **~10²² 원자**. "몇 unit cell" (RTSC 최소) 도 ~10²–10³ 원자.
- Tc 측정 가능한 최소 박막/마이크로 시료조차 ~**10¹⁵–10¹⁸ 원자** 필요 (전류 경로 + 자속 배제 부피).
- SHE 가용량 = **~10⁰–10¹ 원자, 한 달에 1개꼴, 각자 ms 내 붕괴.**

격차: 필요량 / 가용량 ≈ **10¹⁵ ~ 10²² 배.** 게다가 그 원자들은 **동시에 같은 장소에 존재하지 않는다** (한 달 간격 생산 · 각자 ms 수명). 격자를 이루려면 N 개 원자가 *동시에 같은 격자점 이웃*이어야 하는데, atom-at-a-time 생산에서는 2개가 동시에 존재하는 일조차 사실상 없다.

→ **이것이 진짜 벽이다.** "반감기" 가 아니라 "거시량을 동시에 모을 수 없다" 가 SHE→RTSC bulk 를 막는 일급 제약이다. island-of-stability 의 낙관적 수백~수천 년 수명(②.2)을 다 인정해도, **그 핵종은 0개 합성되었고 생산량 벽은 오히려 더 크다** (N=184 영역은 현 빔 도달 불가).

---

## §4. Single-atom 예외 — 진짜 과학이지만 RTSC scope 밖

honest nuance: **SHE *화학* 은 실재하는 진짜 과학이다. 다만 그것은 bulk-material 이 아니라 single-atom 상대론적 화학이다.**

| 차원 | single-atom 상대론적 화학 (REAL) | RTSC bulk 초전도체 (SHE 로는 불가) |
|---|---|---|
| 대상 | 원자 1개의 기체상 흡착 거동 | 거시 결정질 고체의 협동(collective) 전자상태 |
| 관측량 | 흡착 엔탈피 ΔH_ads (Cn·Fl–Au 결합) · 휘발성 · 산화수 | Tc · R=0 · Meissner · 비열 도약 · λ(el-ph) |
| 방법 | gas thermochromatography · isothermal gas chromatography (one-atom-at-a-time) | R(T)·χ(T) on bulk · DFT el-ph on **periodic lattice** |
| 물리 | 상대론적 7s/7p orbital 수축 → Cn·Fl noble-gas-like 경향 | Cooper pair·격자 phonon·band structure (협동 현상) |
| 검증된 사례 | Cn(112)·Fl(114)·Nh(113)·Mc(115) 기체 크로마토그래피 (Frontiers Chem. 2024 등) | **없음** — SHE bulk SC 측정 0건 (시료 자체 부재) |
| RTSC §8.9 gate | (b) bulk Tc 측정 *불가* — 협동 현상은 1 원자에 정의 안 됨 | — |

핵심 구분:
- **초전도는 본질적으로 *many-body collective* 현상** — Cooper pair, phonon-mediated 인력, off-diagonal long-range order 모두 *다수 원자의 격자*를 전제한다. **원자 1개에는 Tc 가 정의되지 않는다.**
- SHE single-atom 화학(흡착 엔탈피·휘발성)은 RTSC.md §8.9 의 어떤 gate 도 채우지 못한다 — gate (b)는 bulk 측정을 요구하기 때문.

→ "SHE 화학이 존재한다" 는 사실이 "SHE 가 RTSC 후보가 된다" 를 함의하지 *않는다.* 두 명제는 깔끔히 분리된다.

---

## §5. Isomer 각도 — 장수명 isomer 가 평결을 바꾸는가?

K-isomer / shape-isomer 가 비정상적으로 긴 T½ 를 가지면 timescale 이 더 여유로워진다. honest 체크:

| isomer | T½ | 핵종 (Z) | bulk crystal 형성? | 평결 영향 |
|---|---|---|---|---|
| **¹⁸⁰ᵐTa** | **> 2.9×10¹⁷ yr** (자연계 최장수 isomer · 붕괴 미관측) | Ta (Z=73) | ✓ — Ta 는 *이미* 일상적 bulk 금속 결정 | **무관** — SHE 아님 |
| **¹⁷⁸ᵐ²Hf** | **31 yr** (대표적 장수명 K-isomer · 2.45 MeV) | Hf (Z=72) | ✓ — Hf 도 일상 bulk 금속 | **무관** — SHE 아님 |
| SHE shape/K-isomer | 일부 모델서 ground state 보다 SF 안정화 예측 (μs–min 규모) | Z>112 | ✗ — 여전히 atom-at-a-time | **변화 없음** |

결정적 관찰:
1. **장수명 isomer 가 *실재하는* 핵종(Ta·Hf)은 모두 일상 원소**로, 이미 bulk 결정을 만든다 — RTSC 입장에서 새로울 게 없고 NUCLEAR "elemental discovery" 도 아니다.
2. SHE 영역에서 isomer 가 T½ 를 늘린다는 예측이 있어도(K-isomerism 이 SF 를 hinder), **§3 의 생산량 벽은 그대로**다 — 더 긴 수명이 원자를 *더 많이* 만들어 주지 않는다.
3. ¹⁸⁰ᵐTa(10¹⁷ yr) 같은 극단 수명을 SHE 가 가진다 해도, 생산이 atom-at-a-time 인 한 거시 결정은 불가능. **isomer 는 timescale 축만 건드리며, binding constraint(quantity)는 안 건드린다.**

→ **isomer 는 평결을 바꾸지 못한다.**

---

## §6. 평결 (honest bridge conclusion)

```
┌─────────────────────────────────────────────────────────────────────┐
│  NUCLEAR (SHE/drip-line nuclide)  ──✗──>  RTSC (bulk 초전도 물질)      │
│                                                                       │
│   timescale 벽?   ✗ 아님  (Og 0.7 ms ≫ 결정화 ~ns; 6 자릿수 여유)     │
│   생산량 벽?      ✓ 일급제약 (atom-at-a-time · <20 원자 · 격차 10¹⁵+) │
│   single-atom 화학? ✓ 실재 (진짜 과학) — 그러나 bulk SC 아님 (scope 밖)│
│   isomer 구제?    ✗ 못함 (장수명 isomer = Ta·Hf, SHE 아님; 양 불변)   │
│                                                                       │
│   → NO bulk-solid bridge.  근거 = 생산량(quantity), not 반감기.        │
└─────────────────────────────────────────────────────────────────────┘
```

**한 문단 평결:**
어떤 현재/예측 가능한 SHE 도 RTSC 가 요구하는 bulk 초전도 고체를 공급할 수 없다 — 단, **그 이유는 반감기가 아니다.** 가장 짧은 SHE 수명(Og ~0.7 ms)조차 결정 핵생성 시간(~ns)을 6 자릿수 초과하므로 "single atom 이 격자에 들어갈 시간" 자체는 충분하다. 진짜 binding constraint 는 **생산량**이다: SHE 는 한 번에 원자 하나씩, 통산 수십 원자 미만, oganesson 은 한 달에 1개꼴로만 만들어지고 각자 ms 내 붕괴한다 — 거시 결정/Tc 측정에 필요한 ~10¹⁵–10²² 원자를 *동시에* 한 자리에 모으는 것은 10¹⁵배 이상의 격차다. island-of-stability 의 낙관적 수백~수천 년 수명(²⁹⁸Fl·²⁹⁶Cn 등)을 다 인정해도 그 핵종은 0개 합성되었고 생산 벽은 오히려 더 크다. SHE *화학*은 실재하는 진짜 과학이지만, 그것은 single-atom 상대론적 기체상 화학(흡착 엔탈피·휘발성)이지 many-body collective 현상인 초전도가 아니며 — 원자 1개에는 Tc 가 정의되지 않는다 — RTSC.md §8.9 의 어떤 gate 도 채우지 못한다. 장수명 isomer(¹⁸⁰ᵐTa 10¹⁷ yr · ¹⁷⁸ᵐ²Hf 31 yr)는 모두 Ta·Hf 같은 일상 원소로 이미 bulk 결정을 만들며 SHE 가 아니고, SHE isomer 가 수명을 늘려도 생산량 축은 불변이다. **따라서 SHE→RTSC bulk bridge 는 없다 (NO).** NUCLEAR 와 RTSC 는 같은 R4 invariant family 의 *parallel funnel* 일 뿐, 물질 공급 경로로 통합되지 않는다.

### §6.1 Breakthrough-path 단서 (@D d2 — flat "불가능" 금지)

"무관" 이 아니라 *무엇이 바뀌면 평결이 바뀌는가* 를 명시한다:

| 무엇이 바뀌어야 하나 | 현재 거리 (honest) |
|---|---|
| **island-of-stability 핵종을 거시량으로 생산** (예: 분(min) 단위 수명 SHE 를 mg 규모로) | 천문학적으로 멂. (i) N=184 neutron-rich 영역 자체가 현 빔(fusion-evaporation)으로 도달 불가 — neutron-rich beam factory(FRIB-class 차세대 · multi-nucleon transfer) 가 선행 필요. (ii) 도달해도 cross-section ~pb–fb → 거시량까지 ~10¹⁵+ 배 생산률 향상 필요. (iii) 둘 다 만족해도 그제서야 §3 양 벽 해소 *착수* 가능. |
| **macroscopic-quantity 다분(多分) 수명 nuclide** 가 등장 → 그때 RTSC funnel(N1 CSP → N2 BETE-NET → N4 DFT)에 *처음으로* SHE 조성 입력 가능 | 위 (i)(ii) 선결 후. 그 시점엔 NUCLEAR (d)(e) wet-lab gate 통과 + RTSC (a) 합성 recipe 가 *둘 다* 필요 — 현 물리학 지평 밖. |
| (가설적) SHE 합금/화합물의 상대론적 band structure 가 새 SC 메커니즘 시사 | 이론적 흥미는 가능하나 §1 처럼 **bulk 시료 부재** 로 (b)(c)(d)(e) 영구 OPEN — 시뮬-only Tier 1 한계(RTSC §8.7). |

요약: out-of-scope ≠ impossible. 바뀌는 트리거는 **"분 단위 수명 island-of-stability 핵종의 거시량 생산"** 하나로 환원되며, 그것은 차세대 가속기·neutron-rich beam 인프라 + 10¹⁵배 생산률 도약이라는 *이중* 천문학적 전제를 요구한다. 현 NUCLEAR 스택의 R4 invariant(`absorbed=false` 영구)와 RTSC §8.9 gate 는 그대로 유지된다.

---

## §7. Citations

**SHE 반감기 / mass model:**
- AME2020 — Wang/Huang/Kondev/Audi/Naimi, `arxiv:2105.01035` · https://www-nds.iaea.org/amdc/
- NUBASE2020 — half-life + decay-mode evaluation (AME2020 companion) · https://www-nds.iaea.org/amdc/
- Island of stability 예측 (²⁹⁸Fl·²⁹¹⁻²⁹⁶Cn·²⁹³⁻²⁹⁴Ds 수명) — Oganessian, "Discovery of the Island of Stability for Superheavy Elements" (IPAC2017 proceedings, jacow.org) · Wikipedia "Island of stability" (모델 spread 종합: 100 yr ²⁹¹/²⁹³Cn · 1000 yr ²⁹⁶Cn · 300/3500 yr ²⁹⁴/²⁹³Ds) · Samanta "Superheavy Elements in the Magic Islands" `arxiv:0803.4151`
- BSk family / HFB mass (NUCLEAR.md §8.1) — Goriely et al. `arxiv:1607.06961` · FRDM2012 Möller et al. `arxiv:1508.06294`

**SHE single-atom 화학 (relativistic chemistry):**
- Düllmann/Eichler/Türler 등, "Gas-Phase Chemistry of Superheavy Elements" (Springer, The Chemistry of Superheavy Elements) — one-atom-at-a-time · <20 원자 · Og ~1 atom/month
- "Manifestation of relativistic effects in the chemical properties of nihonium and moscovium revealed by gas chromatography studies", Frontiers in Chemistry 2024 (PMC11464923)
- "Superheavy Element Flerovium (Element 114) Is a Volatile Metal", Inorg. Chem. (Fl–Au 흡착)

**결정 핵생성/성장 시간:**
- "Crystal Nucleation in Liquids: Open Questions and Future Challenges in MD Simulations", Chem. Rev. 2016 (PMC4919765) — 핵생성 ns·nm 스케일
- "Nanosecond homogeneous nucleation and crystal growth in shock-compressed SiO₂", Nature Materials (Shen/Reed) — 핵생성 0.2 ns · 성장 0.4 ns · coalescence 1.5 ns
- "Crystal nucleation and growth dynamics of aluminum via quantum-accurate MD" (ScienceDirect) — 금속 ns 결정화

**Nuclear isomer:**
- ¹⁸⁰ᵐTa T½ > 2.9×10¹⁷ yr — Isotopes of tantalum (Wikipedia) · DOE "Searching for the Decay of Nature's Rarest Isotope: Tantalum-180m"
- ¹⁷⁸ᵐ²Hf T½ = 31 yr (K-isomer · 2.45 MeV) — "Ups and Downs of Nuclear Isomers", Physics Today

**Cross-stack (이 repo):**
- RTSC.md §8.9 (5-criteria gate) · §8.7 Tier 1 (sim-only 한계) · §9.7/§9.10 (compositional funnel = bulk lattice 입력)
- NUCLEAR.md §1 (sibling 관계) · §1.1 (DFT scale 구분) · §3.0 @D d2/d7 · §3.4 (본 분석이 엄밀화하는 caveat)

---

> **R4 honest 라벨**: 본 문서는 *prediction/analysis 기록* 이며 discovery claim 이 아니다. 인용된 반감기·생산률·결정화 시간은 모두 published source 로, 본 분석에서 새 수치를 만들지 않았다. SHE→RTSC bridge 평결 "NO" 는 *현 물리학·예측 지평* 기준이며, §6.1 의 breakthrough trigger 가 충족되면 재평가 대상이다 (`absorbed=false` 영구는 불변).
