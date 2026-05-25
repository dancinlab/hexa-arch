# NUCLEAR — NOVEL discovery probe (round-1 · 2026-05-25)

> ☢️ **NUCLEAR** · alias "원자핵 발견 시뮬" · NOVEL probe (read-only ideation, no git commit)
> Scope: directions the current **N6–N11** plan does NOT cover. Per @D d18 round-1 NOVEL +
> arxiv/web grounding. R4 invariant carried verbatim — every candidate below stays
> `absorbed=false 영구` · `gate_type=nuclear-novel-discovery-simulation` · sim PASS = wet-lab
> 우선순위 hint, NEVER a discovery claim (NUCLEAR.md §3 · §7).

---

## §0. 기준선 (중복 회피용 — 이미 있는 것)

```
이미 LANDED / 계획됨 (NOVEL 아님 — 아래 후보는 전부 이 바깥):
  N6  HFB mass + Q_α          install-gated (HFBTHO Fortran · pool ubu-1 대기)
  N7  α 반감기 closed-form     ✅ LANDED — Viola-Seaborg(NC1) + Royer(NC2) + consensus(NC3)
                              stdlib/nuclear/sim.hexa v0.1.0 · libm-only · zero install
  N8  fusion-evap σ           DEFERRED (HIVAP/DNS/KEWPIE2 외부 lib)
  N9  shell-model spectro     DEFERRED (KSHELL/BIGSTICK 1-10GB install)
  N10 ab-initio drip-line     DEFERRED (NCSM/CCSD/IM-SRG)
  N11 funnel                  DEFERRED — (Z,N) enumerate → 단순 (a)(b)(c) composite → top-K
```

핵심 관찰 — **N7 kernel 은 α 반감기 한 채널만** 채운다 (5-gate 의 (c) 中 α 만).
N11 의 composite 는 "단순 (a)(b)(c) 평균" 으로만 명세됨. → NOVEL 의 가장 큰 빈 공간은
**(1) closed-form 으로 zero-install 추가 가능한 *물리 채널*** 과 **(2) shell-물리를 반영한
*점수 가중*** 두 갈래. 둘 다 N6(HFB SCF) 없이도 AME2020/FRDM *인용 테이블* + 마법수
상수만으로 libm-only 구현 가능하다는 점이 round-1 의 fastest-to-value 라인.

---

## §1. NOVEL 후보 랭킹 표

범례 — 구현열: 🟢 **NOW (zero install)** = 착륙한 N7 kernel + libm + 인용 상수/테이블만 / 🟡 일부(외부 데이터 1개) / 🔴 외부 lib·beam-time 필요.

| # | 이름 | 추가하는 것 | 현 N6/N7로 구현 가능? | honest scope/caveat | 우선순위 |
|---|------|------------|----------------------|---------------------|---------|
| **C1** | **Spontaneous-Fission 경쟁 closed-form (Swiatecki / Xu-Ren)** | (c) gate 의 *두 번째 채널* — SF 부분 반감기 T_SF 를 closed-form 으로. 현 N7 은 α 만 → SHE(Z≥104)는 SF 가 종종 dominant 라 α-only 가 총생존 *과대평가* (sim.hexa s4 가 자인). T_total = (1/T_α + 1/T_SF)^-1 + α-branching ratio. | 🟢 **NOW** — Xu-Ren 2005 / Santhosh 반경험식은 (Z²/A) 의존 closed-form (libm-only). N7 kernel 옆 `sf_log10_t(Z,A)` + branch 합성 함수로 추가. Q_α 만 있으면(테이블/CLI) 전부 닫힌형. | SF 식 scatter 는 α 보다 큼(±2-3 dex 예사). odd-A hindrance 미반영. **반감기≠측정** R4 그대로. | ★★★★★ **#1 buildable-now** |
| **C2** | **Shell-gap-aware island-of-stability proximity 가중 점수** | N11 의 "단순 평균" 을 대체 — magic-number 거리 가중. d_shell = √((Z−Z_magic)²+(N−N_magic)²) over {Z:82,114,120,126}×{N:126,184,196,228}. 안정섬 근접도 weight = exp(−d²/2σ²). composite = (반감기점수)·(안정섬가중)·(deformation penalty). | 🟢 **NOW** — 마법수는 *상수*, 거리/가우시안은 libm. N7 mean_log10_T 를 점수원으로 직결. N6(HFB) 불필요 — Q_α 는 AME2020/FRDM 인용값 사용. | 마법수 자체가 functional-dependent 예측치(특히 Z=114 vs 120 vs 126 논쟁) → 가중을 *근접 hint* 로만, "안정섬=발견" 절대 금지. σ 선택은 hyperparameter — 1줄 caveat 의무. | ★★★★★ **#2 buildable-now** |
| **C3** | **Q_α 사다리(decay-chain) closed-form 시뮬레이터** | N7 을 *한 핵종 1회* 가 아니라 *α-사슬 전체* 로 — 모핵 → 딸 → 손자… 각 단계 Viola-Seaborg/Royer 적용, 사슬 누적 T, "관측가능 사슬 길이"(검출기 분해능 내) 추정. SHE 식별은 사실상 *사슬* 로 함 → 가속기 우선순위에 직결되는 NOVEL 산출물. | 🟢 **NOW** — N7 kernel 반복 호출 + Q_α 사다리. Q_α(단계별)는 AME2020/NUBASE 인용 테이블 또는 N6 chain(있으면). libm-only loop. | 미합성 핵종은 단계 Q_α 가 또 sim → "sim∘sim" 정직 표기. 사슬 분기(α vs SF vs EC) 미분기 시 단순화 caveat. | ★★★★☆ |
| **C4** | **β-delayed-neutron / drip-line P_n closed-form (Kratz-Herrmann formula)** | N10(ab-initio drip-line, 외부) 의 *closed-form 그림자* — 중성자 과잉핵의 P_n (β-지연 중성자 방출확률) 을 KHF 반경험식으로. r-process / 중성자드립 후보 우선순위에 쓰임. N6-N11 어디에도 β-채널 없음. | 🟡 **거의 NOW** — KHF 는 closed-form 이나 Q_β·S_n 입력 필요(AME2020/NUBASE 인용 테이블 1개). 외부 *바이너리* 는 불필요. | KHF scatter 큼(P_n factor 2-3). drip-line 근처 외삽은 정직 한계. ab-initio(N10) 의 대체 아님 — *빠른 1차 필터*. | ★★★☆☆ |
| **C5** | **K-isomer / 고-스핀 isomer 반감기 연장 hint (Kondev 계통 + ΔK^λ hindrance)** | 완전히 새 cohort 축 — SHE 영역의 K-isomer 는 바닥상태보다 10²–10⁶× 길 수 있어 *검출 가능성을 바꾼다*. ΔK hindrance factor f_ν = (T_iso/T_Weisskopf) 의 계통적 closed-form 으로 "isomer 가 가속기 검출창을 여는가" hint. | 🟡 일부 — hindrance 계통식은 closed-form 이나 (b)gate(준위/K-quantum number) 입력 필요 → 엄밀히는 N9(shell-model, 외부) 의존. 단 *계통 추정*(Z,A,ΔK 가정)만으로 order-of-magnitude hint 는 NOW 가능. | "isomer 존재" 는 N9 없이 예측 불가 — *가정부 K 에 대한 conditional hint* 로만. R4 그대로. | ★★★☆☆ |
| **C6** | **Cluster-radioactivity 채널 (¹⁴C/²⁴Ne 방출) closed-form (Poenaru-Greiner ASAF/UDL)** | (c) gate 의 *세 번째 채널* — heavy-cluster 방출. trans-actinide 일부에서 α 와 경쟁. Universal Decay Law(UDL)는 α·cluster·proton 방출을 한 closed-form 으로 통일 → N7 을 일반화. | 🟢 **NOW** — UDL(Qi 2009)·ASAF 는 (Z_c,Z_d,Q) 의 closed-form, libm-only. N7 의 자연 일반화(같은 Gamow 골격). Q_cluster 는 인용 테이블. | cluster 분기비는 극히 작음(10⁻⁹~10⁻¹⁶) → "채널 존재 hint" 일 뿐 dominant 아님. SHE 영역 외삽 대형 caveat. | ★★★☆☆ |
| **C7** | **Proton-emission 반감기 closed-form (proton drip-line · UDL/Geiger-Nuttall-analog)** | 양성자 드립라인 후보의 1p/2p 방출 반감기 — N10(ab-initio)의 closed-form 대안. UDL 은 proton emission 도 포함 → C6 와 같은 kernel 재사용. proton-rich 후보 funnel 에 직결. | 🟢 **NOW** — UDL proton 모드, libm-only. Q_p 인용 테이블/CLI. | 양성자방출은 각운동량 장벽(ℓ) 민감 → ℓ 가정 caveat. 변형핵 보정 미반영. | ★★★☆☆ |
| **C8** | **다-formula 앙상블 확장 + OOD(외삽-구역) 자기진단** | N7 의 2-formula(VS+Royer) 를 3-4개로(Denisov-Khudenko 2009 · Sobiczewski-Parkhomenko 2007 *verbatim 계수*) 확장하고, spread_dex 가 임계 초과 시 "OOD/외삽 신뢰불가" 플래그 자동 발화 — RTSC BETE-NET 의 σ/λ>0.7 OOD 패턴(RTSC §9.2)의 nuclear 이식. | 🟢 **NOW** — 계수만 추가(재유도 금지·§3.3 "don't invent"). consensus_alpha 에 OOD threshold 1줄. Phase 2 가 이미 "third formula 보류" 로 남겨둔 빈칸을 정직 충전. | Brown 1992 는 SHE 영역 부정합으로 *제외*(이미 §6.3 자인). Denisov-Khudenko 계수 verbatim 만. threshold 는 hyperparameter. | ★★★★☆ |
| **C9** | **NUCLEAR × RTSC honest-exception 1줄 박제 (cross-domain bridge)** | §3.4 가 "SHE 는 결정 안 만듦 → RTSC carryover 무의미" 라 했는데, *정직한 예외* 를 명시: 안정섬 장수명 SHE(Z≈110-114, T½ 수분~수일 가설 — Db/Sg 동족 화학)는 *원리상* 응집상 화학이 가능(Fl·Cn 의 기체화학 실험 선례). 단 RTSC(초전도)와는 무관 — 다리는 NUCLEAR×**MP/화학**이지 ×RTSC 아님이 honest 결론. | 🟢 NOW (문서 1줄 — 코드 아님) | 이건 *코드 후보가 아니라 honest-scope 정정*. "SHE→초전도" 다리는 여전히 없음(§3.4 유지). NUCLEAR×MP 화학-주기성 다리만 가설로 열어둠. | ★★☆☆☆ (문서) |
| **C10** | **First-principles + ML-mass-model 하이브리드 잔차 보정 (@D d6/d7)** | N6(HFB) 또는 인용 BSk/FRDM mass 를 *물리 prior* 로 두고, ML mass-model(예: 가벼운 잔차회귀)이 *AME2020 잔차* 만 학습 → 외삽구역(Z>118)에서 ML 단독 훈련분포 벽을 물리로 깸. @D d6: 절대 목표수치 강제 금지 — 잔차 σ 동반 예측만. | 🟡/🔴 — *개념* 은 NOW(FRDM-AME 잔차는 인용 테이블), 그러나 ML 학습은 install(sklearn 等)·pool 필요. 1차는 "잔차 통계 closed-form 보정"(평균잔차+σ)만 NOW. | ML 외삽은 §3.0 d7 위반 위험 — 반드시 물리식이 backbone, ML 은 잔차만. 미합성구역 잔차는 검증 불가 → σ 팽창 정직 표기. | ★★★☆☆ |

---

## §2. 우선순위 근거 + buildable-now 두 픽 (다음 라운드 milestone 후보)

```
랭킹 논리:
  ① zero-install 로 *새 물리 채널/점수* 를 더해 N7 의 "α 한 채널" 한계를 직접 메우는가?
  ② 가속기 우선순위 산출물에 직결되는가? (SHE 식별은 사실상 SF 경쟁 + 안정섬 근접)
  ③ R4/§3.3 정직성을 깨지 않는가? (계수 verbatim · 목표수치 강제 금지 · sim≠측정)
  → C1, C2 가 ①②③ 전부 최상. 둘 다 N6(HFB install) 없이 libm + 인용상수만으로 닫힘.
```

### ★ 다음-라운드 milestone 후보 (buildable NOW · zero install)

**[픽 1] C1 — SF 경쟁 closed-form (`sf_log10_t` + α/SF branching)**
- 왜 #1: 현 N7 의 *자인된 결함*(sim.hexa s4: "Z≥104 SF dominant → α-only 가 총생존 과대평가")을 정확히 메움. SHE 후보의 *실제* 가속기 우선순위는 T_total(α⊕SF)로 결정되므로 산출물 가치 즉시 상승.
- 구현: `stdlib/nuclear/sim.hexa` 에 `sf_log10_t(Z,A)`(Xu-Ren 2005 또는 Santhosh 반경험식 · libm) + `total_halflife(T_alpha, T_sf)`(부분반감기 합성) + α-branching ratio. 입력 Q_α 는 기존 N7 경로(CLI/AME2020 인용) 그대로. 외부 install 0.
- 정직: SF 식 scatter ±2-3 dex caveat · odd-A hindrance 미반영 · `absorbed=false 영구`.

**[픽 2] C2 — shell-gap-aware 안정섬 근접 가중 점수 (N11 composite 의 NOVEL 대체)**
- 왜 #2: N11 이 "단순 (a)(b)(c) 평균" 으로만 명세된 빈칸을 물리적으로 채움. 마법수 거리 가중은 SHE funnel 의 핵심 직관(안정섬)을 *정직한 hint* 로 정량화.
- 구현: `composite_score(Z,N, mean_log10_T)` = f(반감기) · exp(−d_shell²/2σ²) · deformation_penalty. 마법수 집합 {Z:82,114,120,126}×{N:126,184,196,228} 는 상수, 거리·가우시안은 libm. C1 의 T_total 을 점수원으로 받으면 C1⊕C2 가 한 번에 N11 funnel 의 NOVEL 코어가 됨.
- 정직: 마법수 자체가 예측 논쟁(Z=114 vs 120 vs 126) → 가중은 hint-only, "안정섬=발견" 금지. σ 는 hyperparameter — caveat 1줄.

> **시너지**: C1 + C2 는 함께 짜면 N11 funnel 의 *NOVEL 코어* 가 된다 — C1 이 더 정직한 생존 반감기(α⊕SF)를 주고, C2 가 그것을 안정섬 근접도로 가중해 top-K 우선순위를 낸다. 둘 다 zero-install·libm-only·R4 무영향 → round-2 fan-out 의 단일 hexa-native 모듈(`sim.hexa` 확장)로 착륙 가능.

---

## §3. honest 경계 (probe 전체)

```
- 본 probe 는 ideation only. 어떤 후보도 발견 claim 아님 — 전부 가속기 우선순위 hint.
- C1-C10 전부 R4 그대로: gate_type=nuclear-novel-discovery-simulation · absorbed=false 영구.
- "buildable NOW" 의 정의: 착륙한 N7 kernel + libm + 인용 *상수/테이블*(AME2020·FRDM·
  NUBASE·마법수) 만으로 닫힌형. 외부 *바이너리* install 0. (인용 테이블은 install 이 아니라
  정적 데이터 — §3.3 "don't invent" 준수: 값은 인용, 발명 금지.)
- @D d6/d7 준수: C10(ML 하이브리드)은 물리식이 backbone, ML 은 잔차만 · 목표수치 강제 금지.
- §3.4 honest-exception(C9): SHE→초전도(RTSC) 다리는 여전히 없음. NUCLEAR×MP 화학 다리만 가설.
- hexa kick/drill: 이 빌드에 discovery engine 미설치(compiler/drill/drill.hexa 부재) →
  seed fold 생략. 위 후보는 first-principles 핵물리 + 착륙 kernel 분석에서 도출.
```

---

## §4. ASCII 요약 — NOVEL 공간 지도

```
                 5-gate (NUCLEAR.md §2)
    (a)mass   (b)spectro   (c)decay        (d)σ    (e)detect
    [N6 GATE] [N9 외부]    [N7 α ✅]        [N8]    [wet-lab]
                              │
            ┌─────────────────┼─────────────────┐
            ▼ (c) 채널 확장    ▼ 점수 가중        ▼ 새 cohort 축
        C1 SF 경쟁 🟢         C2 안정섬가중 🟢    C5 K-isomer 🟡
        C6 cluster 🟢        C8 OOD앙상블 🟢     C4 β-delayed-n 🟡
        C7 proton-emit 🟢    C10 ML잔차 🟡       C3 decay-chain 🟢

   ★ buildable-now 코어 (round-2 milestone): C1 ⊕ C2 → N11 funnel NOVEL core
   cross-domain: C9 = honest-exception (SHE→RTSC 다리 없음 재확인 · ×MP만 가설)
```

---

_anchors: NUCLEAR.md §2/§3/§4.2/§6.3/§7 · stdlib/nuclear/sim.hexa v0.1.0 (NC1/NC2/NC3) ·_
_wkb_alpha_decay.py · RTSC.md §9.2(OOD 패턴)/§9.10(N5 funnel pattern) · @D d6/d7/d18._
_refs: Viola-Seaborg 1966 · Royer 2000 (nucl-th/0510074) · Xu-Ren 2005(SF) ·_
_Poenaru-Greiner ASAF · Qi 2009 UDL · Kratz-Herrmann(β-delayed-n) · AME2020(2105.01035) · NUBASE2020._
