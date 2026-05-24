# NUMB — log

## 2026-05-25T18:15Z — N7 NOVEL probe — pH gradient bilayer cream (round-2 d18 정합 · sister of N6)

격리 worktree `/private/tmp/numb-n7-efc4be5c` (브랜치 `numb-n7-ph-gradient-efc4be5c` from origin/main · @D d9 정합) — N5/N6 와 **다른 mechanistic axis** 로 round-2 NOVEL 확장.

- [x] **N7** (`NUMB/research/N7_pH_gradient.md` + `NUMB/sim/n7_ph_gradient.hexa`) — 🟠 INSUFFICIENT/DEFERRED
  - **mechanism**: lid pKa 7.9 / tet pKa 8.5 — 상부 alkaline layer (pH 8.5 carbonate buffer) 가 Henderson-Hasselbalch 평형 시프트 → **lid f_free 0.40% → 80%**, tet 0.10% → 50% → Hadgraft 1985 ΔlogP +2.1 ceiling → **K_sc partition multiplier**
  - **hexa-native HH closed-form (🟢 GREEN)**: lid f_free hexa-output = 0.00397 / 0.240 / 0.799 @ pH 5.5/7.4/8.5 — closed-form HH 정확 매치
  - **3 bilayer 후보** flux × hexa-LAC v1: A=2-step apply **4×** (V1 TOP · safest · 2-SKU 분리) · B=laminated peel-film **6×** (V2 · 안정성 wall) · C=NaCO3 microcap **5×** (V3 · GMP novelty)
  - **honest framing (N1·N6 학습 흡수 · @D d6)**: f_free·K_sc 는 J_ss flux **PREFACTOR** (steady-state) · `t_lag = h²/(6D)` 무관 → **onset 가속 ✗**, **unit-area delivery + depth + duration**만 ↑. "alkaline → 5min onset" 추측 ✗.
  - **🚨 wall (정량 anchor 확실)**:
    - **W3 epi pH 8.5 분해** — Sciencedirect 1990 (S0196064405822814): **30% loss @ 30min, 100% @ 2wks** → bilayer 물리적 분리 mandatory
    - **W4 lid amide 가수분해** — Powell 1987 Pharm Res (PMID 3508528): max stability pH 3-6 → laminated 24mo shelf risk
    - **W1 alkaline skin tolerance** — pH 8.5 단시간 (<30min) OK (dental NaHCO3 임상 precedent), 장시간 SC degradation → N7 indication = procedure 30min only (만성 신경통 ✗)
  - **deep research (d18 정합 · arxiv + web)**:
    - arxiv **2001.03058 Pontrelli 2019** = pH-responsive 2-layer drug delivery PDE 모델 → N7 architecture **직접 grounding** (interface flux continuity eigenvalue 해석해)
    - arxiv 1601.03074 Pontrelli 2016 iontophoretic multi-layer · arxiv 1405.1413 Pontrelli/de Monte 2014 2-phase 2-layer SC+epi (사촌)
    - web Onpharma + PMC12742648 — buffered lid **INJECTION** (NaHCO3 8.4% 9:1) onset 단축 = 임상 표준 but transdermal 무관
    - web SD S0022354915469308 — lid micelle phase pH 5/7.8/9 = 0%/55%/80% → HH empirical 검증 anchor
    - **2025 search**: "pH-gradient topical anesthetic cream" published clinical study **ZERO** → N7 freedom-to-operate ✅
  - **IP FTO**: N7-A (2-SKU drug-drug combo no fixed-dose) = 가장 자유 · LMX-5/Pliaglis RLD 505(b)(2) feasible
  - **breakthrough min-spend ~$1000-2100, 1 month**:
    - P1 Franz cell 1-point lid flux pH 5.5 vs 8.5 ($500-1000)
    - P2 DSC alkaline lid 안정성 ($200-500)
    - P3 epi-HPLC bilayer 분리 효율 ($300-600)
    - P4 USPTO/EPO FTO search (model · $0)
  - **LAST envelope** (N6 와 동급): EPI co-admin mandatory · area cap <200cm² · duration cap <30min · 1000cm² sleeve → 3.5+3.5% derate
  - **cross-axis stacking**: N1 + N6-C + N7-A triple = **10-15× flux** (depth+duration+unit-area triple-stack) but LAST envelope 10× tighten → V3 hexa-LAC v3 spec 후보

## 2026-05-25T17:30Z — /cycle round-2 완결 (d18 정합): G2 regulatory + G3 pediatric + N6 ion-pair eutectic — 3개 milestone CLOSED

round-2 fan-out 결과 통합 entry. 3 agent 모두 d18 정합 (NOVEL + arxiv + web deep research 내장).

- [x] **G2** (`G2_regulatory_pathway.md` + `g2_regulatory_matrix.hexa`) — 🟡 cite-based
  - **선례 9건 매핑**: Pliaglis NDA 21-717 · EMLA 1984 SE national · LMX-4/5 · Synera NDA 21-623 · DESCRIBE 510(k)+drug · LET/BLT compounded · 국내 리도카겔 5% · 엠마오플러스 9.6%
  - **Rx variant path 확정**: US 505(b)(2) (Pliaglis 직접 RLD, $15-50M·5-7yr) · EU national→MRP (EMLA 1984 SE 선례, $0.5-1.5M·1.5-3yr) · KR 자료제출의약품 전문 (~$1.5-7.5M·3-5yr)
  - 🚨 **OTC variant WALL**: 21 CFR 348.10 lid 0.5-4% / tet 1-2% → G1 round-1 OTC 5+5% 가정 + 2.5+2.5 *둘 다* tet 한도 초과 → **flagship OTC 재정의 = lid 4% 단독** (LMX-5/Aspercreme class)
  - 4 OTC workaround: A=lid-only 4% (✓ $2-5M·1-2yr) · B=lid 4+tet 2 한도내 ($10-30M·4-6yr) · C=OTC switch NDA ($30-60M·6-8yr) · D=compounded
  - **SHORTEST commercial path**: KR 일반의약품 (리도카겔 5% 선례, ~$2M·2-4yr) · MFDS 2025 reform 420→295일·fee ₩410M
  - **device-drug 결정**: HPC peel-film = 수동 carrier = drug PMOA → CDER NDA 단일 path (Synera 선례, 별도 510(k) 불필요)
  - **deep research** (d18): 21 CFR 348 정확 한도 fetch (Cornell LII), Pliaglis Phase 3 n=50/indication, EMA Article 30 EMLA referral
  - **G1→G2 보정**: OTC 5+5% 가정 US monograph 불가 → G4 spec 재조정 트리거 (G-track fix-introduces-axis)

- [x] **G3** (`G3_pediatric_LAST.md` + `g3_pediatric_LAST.hexa`) — 🟢 numerical
  - **체중 기반 closed-form**: `Cmax(ng/mL) = 0.1834 × A(cm²)` (G1 inheritance) · age-adjusted threshold = 5000 × (CL_age/CL_adult × AAG_adult/AAG_age) → 신생아 2500 · 영아<6mo 2500 · 6-12mo 3500 · 1-3y 4200 · 3-6y 4500 · ≥6y 5000 ng/mL
  - **6 연령대 envelope** (모두 ≥10× spec ✅): 신생아 (3.5kg/7cm²/60min · margin 1947× **BORDERLINE clinical-defer**) · 영아 1-6mo (6kg/20cm² · 682×) · 6-12mo (8.5kg/20cm² · 954×) · 유아 1-3y (12.5kg/100cm² · 229×) · 학령전 3-6y (18kg/100cm² · 245×) · 학령 6-12y (28kg/200cm² · 136×) · 청소년 12-18y (55kg/400cm² · 68×)
  - **+epi 50% Cmax reduction** = dominant headroom (Pliaglis k=0.0533 × f_epi 0.5 anchor)
  - **prilocaine-free 정합**: NUMB v1 (lid 7%+tet 7%) → o-toluidine MetHb path 자체 없음 → EMLA <37wk preterm 금기 + <12mo MetHb-inducer 병용금기 wall composition 으로 제거 (FDA DailyMed 019941s021)
  - **MetHb 우위 정량**: EMLA pediatric pooled >3% MetHb rate ~10% (Essink-Tjebbes/Brisman/Frey) vs NUMB v1 ~0.1% (Ametop UK 20yr surveillance proxy) = **100× 우위**
  - **honest framing**: 신생아 수치 margin 1947× 이지만 PK 미성숙 (AAG 0.5×·CL 0.5×) + 임상 데이터 부족 → "권고 사용은 ≥1mo + clinical confirmation" 명시
  - **deep research** (d18): 9 clinical (Brisman 1998 · Essink-Tjebbes 1999 · Frey 1998 · Jain 2000 · Lemyre 2006 · Reis 2003 · Lander 2005 · PMC9746881 SR · LMX-4) + 3 arxiv (Sopasakis 2019 fractional PK · Saffaran 2025 neonate digital twin · Wesolowski 2021 gamma-Pareto)

- [x] **N6** ion-pair / ternary eutectic (`N6_ion_pair_eutectic.md` + `n6_ion_pair_eutectic.hexa`) — 🟠 INSUFFICIENT/DEFERRED · **PR #110 MERGED**
  - Schröder-Van Laar framework + Yuan 2015 PMC4444629 anchor (lid+tet 1:1 measured 29.95°C)
  - 3 후보: A=BLT-ternary (lid+tet+benzo 8:4:20) 1.1× flux · B=lid+tet+LA (0.4:0.4:0.2) 5× · **C=lid+tet+capric (0.4:0.4:0.2) 6× (TOP · N1 PCM cross-axis triple-stack)**
  - **honest framing (N1 학습 적용 · @D d6)**: a (활동도) + K_sc 는 `J_ss = D·K·a` flux multiplier → **steady-state** · `t_lag = h²/(6D)` D-driven UNCHANGED → **onset 무관, depth + duration + SC delivery 효율**, NOT onset 가속
  - 🚨 **safety wall**: BLT compounded 임상 corneal damage → 안와 사용 contraindicated (JCAD 2016 PMC4896822)
  - **IP freedom-to-operate**: WO2004103260A2 (Pliaglis family) prilocaine 중심 4-mer 청구 → BLT + lid+tet+capric/LA 회피 여지 ✅
  - **breakthrough min-spend**: DSC $200-500 + Franz 1-point $500-1000 = **$700-1500** → 🟠→🟡 승격 (cheapest NOVEL probe)
  - **deep research** (d18): arxiv Pontrelli 2014 · Potticary 2019 DES · web Yuan 2015 anchor · BLT compounded JCAD · Tatara 2021 sucrose laureate 11.95× flux · IP WO2004103260A2

**round-2 종합 cross-finding**:

```
G2 OTC-wall (tet 한도 2%)  ──┐
G3 prilocaine-free 우위    ──┼──→ G4 SKU split 재설계:
N6 N1 cross-axis 가능        ──┘    OTC = lid 4% 단독 (소아 1순위 후보 · prilocaine-free)
                                    Rx = hexa-LAC v1 · hexa-LAC v2 (+ capric ternary N6-C)
```

G-track 진행 = **3/7 closed** (G1·G2·G3) · NOVEL = **3 active** (N1·N5·N6). 잔여 = G4·G5·G6·G7·oracle.

## 2026-05-25T07:05Z — G3 agent 보고 (worktree → main untracked · roundup 통합 흡수됨)

(상기 17:30Z entry 의 G3 row 가 본 entry 를 흡수. 격리 위반 cleanup: 본 entry 의 원본 untracked 파일은 roundup PR 에서 정리 commit 으로 land.)

## 2026-05-25T01:00Z — /cycle round-1 완결: G1 hair-removal anchor + N1·N5 NOVEL (정직 재포지셔닝)

- [x] G1 (`G1_indication_map.md` + sim) — laser hair removal anchor ($1.4-1.6B 2025·95% topical 사용) → 스펙: onset ≤30min·100-400cm²·LAST ≥10× margin·+epi mandatory. 8 indication 매핑: hexa-LAC v1 **7/8 단일 SKU 커버** (예외: 타투 *제작* sleeve 1000cm²×120min Cmax 826ng/mL 6× margin → 5+5% derate+split → 16.9× margin). 🎯 gap = **OTC 5+5% ↔ Rx 7+7%+epi+peel-film 듀얼 SKU**. tier 🔵/🟢/🟡/🟠. (🚨 round-2 G2 에서 OTC monograph WALL 로 보정 — lid 4% 단독으로 재설계)
- [x] N1 phase-change peel-film — 🚨 **정직 재포지셔닝**. Pliaglis(water-evap)와 trigger 축 다름(body-T 32-35°C PCM carrier melt · capric+palmitic 32.17°C·lauric+myristic 34.28°C 후보). **그러나 첫 가설 "onset 가속" Fick first-principles로 반증** (activity a는 lag-time 무관, 정상상태 flux만 ×). 진짜 가치 = a 2→5 (2.5×) **flux multiplier @ steady-state** → C_surf 낮춰도 동일 depth → **G3 소아 / G4 OTC 저농도 SKU 기여** (onset이 아니라 depth/duration). wall = latent-heat 28min full-melt 100μm sub-layer 우회.
- [x] N5 Mg multi-modal — 🟠. NMDA+VGCC 직렬 + Na-channel(lid) 시너지. r_mg=0.30(IV/perineural 25-40% 외삽), lid 7→4.9% depth-matched, **A_max +43%, 타투 sleeve 400-800cm² 단일세션 unlock**. 🚨 토픽 Mg+lido MEC shift 임상 ZERO (deep research 4 RCT 모두 *주사형*). 1-point Franz cell ED50 study가 🟠 결정.
- 🔬 **deep research synthesis** (병렬 진행 · 본 세션):
  - Mg+lido 시너지: 임상 RCT 4건 견고 (IANB·femoral·brachial·dental) but 전부 주사형 — *토픽* unverified
  - N1 prior art: Pliaglis(Alster 2007 lid7+tet7 peel) + USPTO 9186334(heat-assisted 35-47°C lid+tet) — N1은 body-T(32-35°C)·PCM trigger로 차별화
  - 🚨 **소아 EMLA prilocaine wall**: o-toluidine → MetHb. 신생아<37주 금기·체중<20kg 면적시간 제한 → **NUMB 소아 SKU = prilocaine-free 필수 (lid+tet만)** 권고 — hexa-LAC v1이 이미 정합 ✅
  - arxiv SC 물리 5건 (2510.14606 등): MD 기반 SC permeation diffusivity 1자릿수 변동 = A5 honest gap 정합
- 종합 round-1 insight: hexa-LAC v1이 7/8 indication 커버 (✅) · 듀얼 SKU OTC/Rx gap 식별 · N1은 onset 아닌 depth/duration 기여 · N5는 large-area unlock but topical 실측 필요 · 소아 SKU prilocaine-free 정합.

## 2026-05-25T00:35Z — 도메인 생성 (TTR-LAC A 트랙 spinoff · 범용 마취 크림)

- [x] M0 — domain scaffold (사용자 지시: "마취크림만 추가진행하자 · 범용으로 많이 쓰이니까")
  - **스핀오프 모델**: TTR-LAC 의 A 트랙(A1·A2+A3·A4·A5)은 *레이저 타투제거 세션 한정* 컨텍스트였으나 — SC permeation/D-boost/depth/LAST 모델은 **procedure-agnostic 일반 자산**. NUMB 가 이 자산을 상속해 범용 indication·regulatory·OTC/Rx 듀얼·소아 안전으로 확장.
  - **핵심 상속**: t_lag=h²/(6D) · CPE 42×→in-vivo 5-10× · C(z) depth · Pliaglis LAST · hexa-LAC v1 제형. 본 도메인은 새 화학 *재발견 X* — 제형 최적화 + 다용도 매핑 + 규제 path 만.
  - **확장 7 milestone (G-track)**: G1 indication map · G2 regulatory pathway · G3 소아 LAST · G4 OTC/Rx variant · G5 포장/안정성 · G6 인접 토픽 양립성 · G7 사용자 가이드.
  - **honest framing (@D d5/d6)**: 마취 chemistry 는 수십 년 임상 well-established — 본 도메인 *새 발견 가능성 낮음*, *제품화*가 목표. 과대 약속 금지.
  - **시장 정합 신호**: EMLA(Rx) · LMX-4(OTC) · BLT(compounded) · Pliaglis(Rx peel-film) · DESCRIBE(PFD patch) 등 다양한 form factor 가 이미 존재 — gap = *범용 빠른 onset + LAST 안전 면적·소아 envelope* 의 한 제품군.

Append-only history sister of `NUMB.md`. `## <ISO timestamp> — <header>` (newest on top).
