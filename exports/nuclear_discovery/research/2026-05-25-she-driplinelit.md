# NUCLEAR 도메인 — SHE + drip-line 문헌 그라운딩 (2023–2026)

> ⚛️ **NUCLEAR** · 별칭 "초중핵 사냥(超重核 funnel)" · round-1 lit-grounding (@D d18)
> 대상: Phase 6 **N11 funnel** — accelerator beam-time 우선순위용 (Z,N) shortlist 랭킹.
> 작성일 2026-05-25 · read-only 리서치 (커밋 X) · NUCLEAR.md §1–§8 5-gate 분류 기준.

---

## §0. 한 줄 요약

```
   2023–2026 문헌 = "이론은 어디를 때릴지 안다, 단면적 절대값만 10× 안갯속"
   ─────────────────────────────────────────────────────────────────────
   Z=119 :  50Ti+249Bk · 51V+248Cm · 54Cr+243Am   → ER σ  ~12–200 fb (xn 합)
   Z=120 :  50Ti+249Cf · 51V+249Bk · 54Cr+248Cm   → ER σ  ~5–48 fb  (3-4n)
   ─────────────────────────────────────────────────────────────────────
   실험 현황 : RIKEN(51V+248Cm, 진행중) · Berkeley(50Ti→Z=120, 2025착수) · JINR(54Cr+243Am)
   가장 자주 인용되는 near-term 타깃 : 295Og→ 다음 줄 = (Z=120,N=175) 295-120, (Z=119,N=176) 295-119
```

NUCLEAR.md §8.1의 기존 인용은 대부분 2015–2022 (BSk32 1607.06961 · FRDM2012 1508.06294 · AME2020 2105.01035 · KEWPIE2-class 2208.11471). 아래는 **그와 겹치지 않는 2023+ 신규 문헌**만 정리.

---

## §1. Findings table

| 논문/결과 | 연도 | arxiv/DOI | 우리 5-gate 관련성 | 시사 (Z,N) |
|---|---|---|---|---|
| Synthesis of SHE beyond Og: extrapolating from ⁴⁸Ca to ⁵⁴Cr | 2025 | arXiv:2505.05754 | **(d)** σ 최적 빔에너지 · Ti/Cr 빔 전환 논거 | Z=119,120 (⁵⁰Ti/⁵⁴Cr 빔 필수) |
| Theoretical estimates for Z=119 with Ca,Ti,V,Cr projectiles (Q-value·mass-model dep.) | 2026 | arXiv:2604.19325 | **(d)** ER σ 절대값 + **mass-model→survival 1~수 자릿수 spread** | (119, N): ⁵⁰Ti+²⁴⁹Bk=206 fb, ⁵⁴Cr+²⁴³Am=38 fb, ⁵¹V+²⁴⁸Cm=33 fb |
| Synthesis mechanism of element 120: DNS w/ microscopic inputs (PC-PK1) | 2026 | arXiv:2604.09287 | **(d)** Z=120 4채널 σ + 최적 E*_CN | ²⁹⁵120=48.2 fb, ²⁹⁷120=12.3 fb, ²⁹⁹120=5.25 fb, ²⁹³120=0.47 fb |
| Optimal colliding energy for SHE Z=119 (⁵¹V+²⁴⁸Cm, DNS) | 2023 | arXiv:2311.07145 | **(d)** ⁵¹V+²⁴⁸Cm 4n σ_max=**12.3 fb @ E_cm=232 MeV** | (119, N=176) ²⁹⁵119 (4n) |
| Systematic SHE formation: ⁴⁸Ca/⁵⁰Ti/⁵¹V/⁵⁴Cr on actinides (5 mass models) | 2025 | arXiv:2511.18337 | **(d)** 6개 reaction × FRDM12/KTUY/LDM/SkyHFB/WS4 비교 | Z=119,120 전 reaction grid |
| Bayesian UQ for synthesizing SHE (DNS 파라미터 posterior) | 2024 | arXiv:2405.02839 | **(d)** ER σ에 **2σ 신뢰구간** 최초 부여 (a, E_d, a_f/a_n) | (119, N): 3 reaction OIE+CL |
| Assessing impact of nuclear mass models on synthesis σ (SHE) | 2024 | arXiv:2402.15304 | **(a)→(d)** mass-model이 fusion prob에 미치는 영향 정량화 | SHE 일반 (DNS) |
| High-Quality Microscopic Nuclear Masses of SHE | 2024 | arXiv:2402.11514 | **(a)** Q_α·Sn·Sp 정밀 mass → (c)(d) 입력 | SHE mass table |
| Production σ of SHE: DNS w/ high-quality microscopic masses | 2024 | arXiv:2405.08098 | **(a)+(d)** 위 mass를 DNS에 직접 투입 | SHE σ 재계산 |
| Survival Probabilities of Compound SHE Towards Element 119 | 2024 | arXiv:2408.07371 | **(d)** survival prob = ER σ의 지배 인자 | Z=119 compound |
| Examining potential synthesis of new elements with ²⁹⁴Og | 2024 | arXiv:2411.13095 | **(d)** ²⁹⁴Og를 2차 타깃 reaction으로 | Og 기반 경로 |
| Competing decay modes & stability of Z=120 (RMF/NL3, PCM) | 2026 | arXiv:2601.21317 | **(c)** α vs SF 경쟁, 256≤A≤304 | (120, N=136~184) α-dominant 영역 |
| Deformed magic N=178, Z=120,124 (Skyrme MF) | 2025 | arXiv:2506.02684 | **(a)(c)** deformed shell closure → 긴 T½ 후보 | (120, N=178) ²⁹⁸120 deformed magic |
| Shell structure odd-Z Z=117,119 (def. RHB in continuum) | 2024 | arXiv:2405.07704 | **(a)(b)** Z=119 변형·연속체 구조 N=170→dripline | (119, N=170~dripline) |
| Bridging Theory & Data: correcting mass models w/ interpretable ML (KAN) | 2026 | arXiv:2603.15203 | **(a)** mass-model 잔차 ML 보정 (BSk/FRDM 대체급) | mass table 전역 |
| Architecture as physical prior: cooperative NN for nuclear masses | 2026 | arXiv:2603.09747 | **(a)** 물리-prior NN mass model (2023+ ML) | mass table 전역 |
| Combined Garvey-Kelson + ML for mass determination | 2026 | arXiv:2603.07015 | **(a)** GK 관계식 + ML 하이브리드 | dripline 외삽 |
| High-Precision Binding Energies from Physics-Informed ML | 2024 | arXiv:2412.09504 | **(a)** PINN binding energy (AME 정밀도급) | mass table 전역 |
| Bayesian model mixing w/ multi-reference EDF | 2024 | arXiv:2411.15219 | **(a)** EDF(BSk/UNEDF급) 베이지안 혼합 + UQ | mass table + dripline UQ |
| Mass of ¹⁰¹Sn & Bayesian extrapolations to proton drip line | 2025 | arXiv:2510.11815 | **(a)+drip-line** Z=50 proton dripline 측정+외삽 | (50, N=51) ¹⁰¹Sn 근처 |
| Quantifying UQ in rare-isotope production σ (Bayesian mass-table avg) | 2026 | arXiv:2603.10403 | **(a)→(d)** mass-table 평균으로 σ UQ | drip-line 생성 σ |

> 참고(NUCLEAR.md §8.1 기존 인용과 겹쳐 본 표에서 제외): BSk32(1607.06961), FRDM2012(1508.06294), AME2020(2105.01035), HFBTHO 3.00(1810.10825), DRHBc dripline(2103.08142).

---

## §2. 실험 현황 (WebSearch · 2024–2026) — sim ≠ measurement 경계

| 기관 | reaction (빔+타깃) | 분리기 | 현황 (2024–2026) | 출처 |
|---|---|---|---|---|
| **RIKEN** (Nishina) | ⁵¹V + ²⁴⁸Cm → Z=119 | GARIS-III | **진행중** (2025년 5월 INPC 발표 "search underway"); nSHE 국제협력(JP/US/FR/PL/AU/CN); ⁵¹V 빔 6.5 MeV/u | C&EN, ACS Cent.Sci. 4c01266, IBS Indico INPC2025 |
| **LBNL Berkeley** | ⁵⁰Ti + ²⁴⁹Cf → Z=120 | 88-inch cyclotron / FIONA | **2025 착수 예정** (Cf-249 타깃 ORNL서 ~45 mg 제작 중); 선행으로 ⁵⁰Ti+²⁴⁴Pu→²⁹⁰Lv(Z=116) **2원자 22일간 합성 성공**(2024) — Z=120 향 디딤돌. Z=120은 Z=116보다 10–20× 어려움 | LBNL News 2024-07-23, arXiv:2407.16079, Chemistry World |
| **JINR Dubna** (FLNR) | ⁵⁴Cr + ²⁴³Am → Z=119 (및 ⁵⁰Ti+²⁴⁹Bk; Z=120: ⁵⁰Ti+²⁴⁹Cf, ⁵⁴Cr+²⁴⁸Cm) | DGFRS-2 | SHE Factory 가동; DGFRS-2 = 배경 ÷200, 투과효율 ×2; Z=110/112/114/115 재현 후 **Z=119(⁵⁴Cr+²⁴³Am) 진행중** 표명. 국제 협력은 지정학으로 제약 | JINR posts, NIMA S0168900222002078 |

**핵심: 2026-05 현재 Z=119 / Z=120 어느 것도 confirmed discovery 없음.** 모두 "진행중/착수예정"이며 IUPAC priority 미할당. 가장 가까운 confirmed milestone은 **²⁹⁰Lv (Z=116) via ⁵⁰Ti** (Berkeley 2024) — 이는 ⁴⁸Ca→⁵⁰Ti 빔 전환이 실제로 작동함을 보인 첫 사례(Z=120 경로의 검증).

---

## §3. 권장 N11 타깃 shortlist (ranked) — Q_α / 예측 T½ + 인용

> 랭킹 기준: **(d) ER σ 절대값** (가장 자주 인용되는 fb 값) × **실험 활성도(현재 빔타임 투입 여부)**.
> 모든 σ는 **이론 예측 (DNS / Langevin+statistical)** — §3.x 캐비엇 참조. Q_α/T½는 SHE 구조 문헌 합의 범위.

| 순위 | (Z, N) · 핵종 | reaction (채널) | 예측 ER σ | Q_α / 예측 T½ 범위 | 인용 |
|---|---|---|---|---|---|
| **1** | (119, 176) **²⁹⁵119** | ⁵⁰Ti+²⁴⁹Bk (3-4n 합) | **~206 fb** (xn 합, FRDM12) | Q_α ≈ 12.5–13.4 MeV; T½(α) ≈ **수십 µs–ms** | σ: 2604.19325; 구조/T½: 2405.07704, 1706.04068 |
| **2** | (119, 176) **²⁹⁵119** | ⁵¹V+²⁴⁸Cm (4n) | **12.3 fb @ E_cm=232 MeV** | 同上 (Q_α ≈ 12.5–13.4 MeV) | σ: 2311.07145; cross-check 2405.02839 |
| **3** | (119, 172–174) ²⁹¹⁻²⁹³119 | ⁵⁴Cr+²⁴³Am (xn 합) | **~38 fb** (FRDM12) | Q_α ≈ 12.8–13.6 MeV; T½ ≈ **µs–ms** | σ: 2604.19325, 2511.18337; UQ: 2405.02839 |
| **4** | (120, 175) **²⁹⁵120** | ⁵⁰Ti+²⁴⁹Cf (4n) | **48.2 fb @ E*_CN=41 MeV** | Q_α ≈ 13.0–13.7 MeV; T½(α) ≈ **µs 수준** (α-dominant) | σ: 2604.09287; T½: 2601.21317 |
| **5** | (120, 177) **²⁹⁷120** | ⁵¹V+²⁴⁹Bk (3n) | **12.3 fb @ E*_CN=34 MeV** | Q_α ≈ 12.9–13.5 MeV; T½ ≈ **µs–수십 µs** | σ: 2604.09287; T½: 2601.21317 |
| **6** | (120, 178) **²⁹⁸120** | ⁵⁴Cr+²⁴⁸Cm (3n) | **5.25 fb @ E*_CN=32 MeV** | **N=178 deformed magic** → α/SF 경쟁; T½ 상대적 ↑ | σ: 2604.09287; deformed magic: 2506.02684; 2601.21317 |
| **7** | (120, 173) ²⁹³120 | ⁵⁵Mn+²⁴³Am (5n) | **0.47 fb** (검출한계 근처) | Q_α 높음 → T½ 짧음 (sub-µs 위험) | σ: 2604.09287 |

### §3.1 Q_α / T½ honest-sourcing (§3.3 준수)

- **Q_α 값은 mass-model 의존**: FRDM2012 / WS4 / SkyHFB / KTUY05 / BSk 간 ΔQ_α ~0.3–1.0 MeV (2511.18337, 2402.15304). N11은 단일 값이 아닌 **mass-model 스프레드를 cited band로** 기록해야 함 (@D d7 "force a target number 금지").
- **T½ "µs–ms"는 SHE α-decay 합의 정성 범위** (1706.04068 4-model 계산: AKRA/ASAF/UNIV/semFIS; 2601.21317 PCM/RMF). 정확한 단일 µs 숫자는 N6→N7 chain(HFBTHO Q_α → WKB/Viola-Seaborg)으로 자체 재계산 권장 — 문헌은 cross-check oracle.
- **(d) ER σ는 절대값이 본질적으로 불확실**: 같은 ²⁹⁵119도 reaction(⁵⁰Ti+²⁴⁹Bk 206 fb vs ⁵¹V+²⁴⁸Cm 12.3 fb)·코드(DNS vs Langevin)·mass-model에 따라 **1자릿수 이상** 차이. 순위 1~2가 같은 핵종인데 σ가 17× 차이나는 게 그 증거.

---

## §4. drip-line 곁가지 (N10 ab-initio 입력)

- **¹⁰¹Sn (Z=50, N=51)** proton drip-line 측정 + 베이지안 외삽 (2510.11815) — N10 (A≤30 scope 밖이지만) proton dripline cross-validation 데이터.
- **mass-model ML 갱신군** (2603.15203 KAN · 2603.09747 cooperative NN · 2603.07015 GK+ML · 2412.09504 PINN · 2411.15219 Bayesian EDF mixing) — N6의 BSk/FRDM 단일 fallback을 **2023+ ML 보정 mass-table 앙상블**로 확장할 후보. UQ를 자체 탑재(2411.15219, 2603.10403)해 §3.5 citation rigor의 "2σ band"를 문헌에서 직접 가져올 수 있음.

---

## §5. 정직 캐비엇 (g3 · NUCLEAR.md §3)

1. **sim ≠ measurement**: 위 모든 (Z,N) σ·Q_α·T½는 **예측**. 2026-05 현재 Z=119·Z=120 **confirmed discovery 0건** (RIKEN/Berkeley/JINR 모두 "진행중/착수예정"). 표의 핵종은 "후보일 가능성"이지 "후보임"·"발견됨" 아님 (§7 R4).
2. **(d) cross-section 10× scatter는 실재**: ²⁹⁵119 한 핵종이 reaction·코드·mass-model에 따라 12.3–206 fb로 17× 흩어짐 (2311.07145 vs 2604.19325). N11 σ는 점추정 금지 — **band + 코드/mass-model provenance** 필수.
3. **예측 vs 확인 구분**:
   - 확인됨(2024): ²⁹⁰Lv (Z=116) via ⁵⁰Ti+²⁴⁴Pu @ Berkeley — ⁵⁰Ti 빔 작동 입증.
   - 예측만(이 노트 전부): Z=119, Z=120 모든 핵종.
4. **N=178 deformed magic (²⁹⁸120)**는 "island of stability" 주장 아님 — deformed shell closure로 **상대적** T½ 연장 가능성(2506.02684), Z=126 구면 magic 미확정. @D d7 "Z=126 found" 금지 준수.
5. **mass-model이 survival probability를 1~수 자릿수 흔든다** (2604.19325) — (a) gate의 ±MeV 불확실성이 (d) gate로 증폭 전파. N11은 (a)→(d) chain의 오차전파를 명시해야 함.
6. **(e) detection gate는 여전히 sim 불가** — DGFRS-2/GARIS-III recoil-separator + α-chain correlation은 물리 하드웨어. 본 노트는 (e)에 대해 아무 것도 주장하지 않음.

---

## §6. N11 funnel로 가는 한 줄 핸드오프

```
  top-2 즉시 랭킹 핵종 = ²⁹⁵119 (Z=119,N=176)  ·  ²⁹⁵120 (Z=120,N=175)
    → 둘 다 ⁵⁰Ti 빔 경로(²⁴⁹Bk / ²⁴⁹Cf 타깃), 현재 빔타임 실제 투입중/예정,
      σ 최댓값(206 / 48 fb)이 문헌서 가장 높음 → accelerator-priority hint 최상위.
    → §3.3대로 Q_α는 mass-model band, T½는 N6→N7 self-recompute + 문헌 cross-check.
```

---

### 인용 원문 링크 (arxiv)

2505.05754 · 2604.19325 · 2604.09287 · 2311.07145 · 2511.18337 · 2405.02839 · 2402.15304 · 2402.11514 · 2405.08098 · 2408.07371 · 2411.13095 · 2601.21317 · 2506.02684 · 2405.07704 · 2603.15203 · 2603.09747 · 2603.07015 · 2412.09504 · 2411.15219 · 2510.11815 · 2603.10403 · 1706.04068 · 2407.16079

웹: LBNL News(2024-07-23, ²⁹⁰Lv via ⁵⁰Ti) · ACS Cent.Sci. 10.1021/acscentsci.4c01266 (RIKEN Z=119) · IBS Indico INPC2025 (RIKEN status) · NIMA S0168900222002078 (DGFRS-2) · Chemistry World "element 120 may now be in reach"
