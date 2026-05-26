# 🧪 LENS + ECOPAD in silico + CRO/OEM RFQ 템플릿 — 2026-05-27

> **이전**: SCALP Phase 1 (#274) + Phase 2 Vina docking (#281)
> **이번**: LENS·ECOPAD ligand 분자 특성 + CRO/OEM RFQ 발송용 템플릿 (3 도메인 통합)
> **다음**: Atlas 등록 + 실측 RFQ 발송 (사용자 영역)

---

## 1. 👁 QD-LENS — Ligand 분자 특성 (RDKit + Lipinski)

| 화합물 | MW | logP | HBD | HBA | TPSA | RotB | Ro5 | 평가 |
|---|---|---|---|---|---|---|---|---|
| PHMB n=4 (mimic) | 482.7 | +0.86 | 12 | 4 | 219.6 | 21 | 3 | 박테리아 막 결합 (큰 분자, 안구 흡수 X) |
| Polyquat-1 unit | 245.2 | -4.81 | 0 | 0 | 0.0 | 5 | 4 | 양이온 polymer, 매우 polar (안구 안전) |
| **★ MPDA** (Acanthamoeba) | 312.5 | **+4.76** | 1 | 2 | 32.3 | 16 | 4 | Acanthamoeba 세포막 침투 최적 |
| Poloxamer (PEG-PPG) | 456.6 | +0.27 | 2 | 10 | 114.3 | 25 | 4 | 세척·점도 (큰 분자) |
| EDTA | 292.2 | -2.07 | 4 | 6 | 155.7 | 11 | 4 | 금속 킬레이션 (TiO2 보호) |
| α-Tocopherol | 430.7 | **+8.84** | 1 | 2 | 29.5 | 12 | 3 | 강한 lipophilic — 막 안정·항산화 |
| Hyaluronic acid unit | 397.3 | -5.16 | 8 | 11 | 215.5 | 5 | 2 | 점막 친화 보습 (큰 polar) |
| Citric acid | 192.1 | -1.25 | 4 | 4 | 132.1 | 5 | 4 | pH 완충 |

### 핵심 발견 (LENS)

```
★ MPDA logP +4.76 — Acanthamoeba 세포막 lipophilic 침투
   → Acanthamoeba 살균 시판 4종 약점 보강 first-principles 근거

★ α-Tocopherol logP +8.84 — TiO2 색소 산화 방지 (Lipinski 1점 위반은 의도적)
   → 컬러렌즈 색소 보호 화이트스페이스 핵심

PHMB (logP +0.86, HBD 12) — 박테리아 막 결합 OK·각막 흡수 어려움 (안구 안전 정합)
PQ-1 (logP -4.81) — 매우 polar → 안구 흡수 X (자극↓)
```

---

## 2. 🌱 QD-ECOPAD — Ligand 분자 특성

| 화합물 | MW | logP | HBD | HBA | TPSA | RotB | Ro5 | 평가 |
|---|---|---|---|---|---|---|---|---|
| Cellobiose (셀룰로오스) | 342.3 | -5.40 | 8 | 11 | 189.5 | 4 | 2 | 흡수체 (큰 polar — 물 결합 강함) |
| Glycerin | 92.1 | -1.67 | 3 | 3 | 60.7 | 2 | 4 | 보습·swelling 가속 (small polar) |
| CMC (mimic) | 222.2 | -2.70 | 5 | 6 | 127.5 | 3 | 4 | 셀룰로오스 보조·점도 |
| **★ Chitosan** monomer | 179.2 | -3.25 | 5 | 6 | 116.2 | 1 | 4 | 항균 + 락토바실러스 친화 (양이온성) |
| Lactic acid | 90.1 | -0.55 | 2 | 2 | 57.5 | 1 | 4 | pH 4.5-5.5 (마이크로바이옴 보호) |
| Citric acid (eco) | 192.1 | -1.25 | 4 | 4 | 132.1 | 5 | 4 | pH 완충 |
| **★ Terpinen-4-ol** (차나무) | 154.3 | **+2.36** | 1 | 1 | 20.2 | 1 | 4 | 항균 lipophilic — 피부 친화 |
| Xylitol | 152.1 | -2.95 | 5 | 5 | 101.2 | 4 | 4 | 보습 + swelling 가속 |

### 핵심 발견 (ECOPAD)

```
★ Terpinen-4-ol (차나무) logP +2.36 — 항균 + 피부 침투 OK
   → 키토산 + 차나무 듀얼 항균 (광범위 + 자연 유래)

★ Glycerin + Xylitol + Lactic acid — small polar 트리오
   → 셀룰로오스 SAP swelling 가속 + pH 4.5-5.5 유지 + 보습

★ Chitosan logP -3.25, polar 양이온
   → 음전하 박테리아 막 결합 (광범위 항균) + 락토바실러스 보호
```

---

## 3. 📊 3-도메인 in silico 통합 처방 결정

| 도메인 | Pilot D 핵심 활성성분 | 근거 |
|---|---|---|
| 💆 SCALP | 6대 + **Adenosine 0.5-1%** (Vina -8.47) + Procapil 3% + Caffeine 0.5% + 80nm 나노에멀젼 | PR #281 in silico |
| 👁 LENS | PHMB 0.0001% + 폴락사머 + **MPDA 0.0005%** (Acanthamoeba logP +4.76) + EDTA + **α-Tocopherol** + 시트르산 | 본 분석 |
| 🌱 ECOPAD | 셀룰로오스 SAP + **Glycerin+Xylitol+CMC** swelling 가속 + **Chitosan+Terpinen-4-ol** 듀얼 항균 + Lactic acid 약산성 | 본 분석 |

---

## 4. 📨 CRO RFQ 템플릿 (한국 기관 발송용)

### 4-1. SCALP CRO RFQ (디티앤씨알오·엘리드·GMRC)

```
[제목] 두피케어 기능성 화장품 24주 인체적용시험 견적 요청

[배경]
- 기능성 화장품 (탈모완화) 6대 자동허가 + 보조성분 (Adenosine·Procapil·Caffeine) 처방
- 시판 6대 단독 대비 24주 head-to-head 우위 입증 목표 (모근 +15%p)

[요청 항목]
1. 인체적용시험 패키지
   - 디자인: 무작위·이중맹검·평행군 (자체 처방 vs 시판 대조군, n=44/군)
   - 시간: 24주
   - 측정: TrichoScan 4축 (모근 밀도·모발 두께·anagen%·성장률)
   - 보조 측정: 두피 환경 (pH·피지·각질·홍반)
2. HET-CAM 안자극 + 48h 첩포 (자극성)
3. 두피 마이크로바이옴 16S rRNA (n=44 × 0주·24주, 옵션)
4. 통계 패키지 (paired t-test, ANCOVA)
5. IRB·CRIS 등록 비용 포함

[예산] 7,000-12,000만원
[시간] 6-8개월
[연락처] [본인 정보]
```

### 4-2. LENS CRO RFQ (KCL·KTR·KOTITI)

```
[제목] 의약외품 콘택트렌즈 관리용액 시험 견적 요청

[배경]
- PHMB + 폴락사머 + MPDA + EDTA + 토코페롤 처방
- 시판 대비 Acanthamoeba 살균 + 컬러렌즈 색소 보호 + 저자극 차별

[요청 항목]
1. ISO 14729 stand-alone (5균주: P.aeruginosa·S.aureus·S.marcescens·C.albicans·F.solani)
2. ★ Acanthamoeba castellanii ATCC 30010+30234 (trophozoite + cyst) 살균력 (자체 시험)
3. 증발 저항 시험 (2× · 4× 농축 후 ISO 14729 재시험, 자체 SOP)
4. L929 마우스 fibroblast cytotoxicity (USP·ISO 10993-5)
5. HET-CAM 안자극
6. 컬러렌즈 색소 유지 시험 (한국 시판 TOP 3 × 30회 침지 ΔE, 자체 SOP)

[예산] 1,000-2,000만원
[시간] 3-4개월
```

### 4-3. ECOPAD CRO RFQ (KOTITI·KCL·KTL)

```
[제목] 친환경 의약외품 생리대 시험 견적 요청

[배경]
- 유기농 코튼 + 셀룰로오스 SAP + Chitosan/Terpinen 항균 + 사탕수수 PLA 처방
- 시판 대비 VOC 1/3 + 외음부 마이크로바이옴 락토바실러스 우세 12일 + 생분해 차별

[요청 항목]
1. VOC 84종 GC-MS (mfds 표준)
2. 알러지 26종 LC-MS (EU 2003/15/EC Annex III)
3. 다이옥신·퓨란 HRGC-HRMS (mfds 시험법)
4. 흡수량·재습윤 (표준 시험)
5. ★ 5초 swelling 시험 (자체 SOP, 시판 대비 +30% 목표)
6. ★ 외음부 마이크로바이옴 16S rRNA (n=44 cross-over × 2 timepoint)
7. ★ 톱시트 pH 4.5-5.5 8h 유지 시험 (자체 SOP)
8. 48h 첩포 (산후 특수성)
9. 생분해 ASTM D5511 (별도, ECOPAD-2차)

[예산] 1,500-3,000만원
[시간] 2-3개월
```

---

## 5. 🏭 OEM RFQ 템플릿

### 5-1. SCALP OEM (코스맥스파마·한국콜마)

```
[배경] 기능성 화장품 (탈모완화) 자체 처방 R&D 출시
[처방]
- 6대 자동허가 조합②: 나이아신아마이드 0.3% + 덱스판테놀 0.5% + 비오틴 0.06% + 징크피리치온액(50%) 2%
- 보조: Adenosine 0.5-1% (기능성 인증 성분) + Procapil 3% + Caffeine 0.5%
- 전달체계: 80nm 나노에멀젼 캡슐화 (Caffeine·Procapil·Adenosine polar 그룹)
- pH: 5.0-5.5 약산성
[MOQ] 5,000 ~ 10,000개 (200ml 튜브)
[필요] CGMP 시설 + 기능성 화장품 신고 지원
```

### 5-2. LENS OEM (한국알콘 또는 의약외품 OEM)

```
[배경] 의약외품 콘택트렌즈 관리용액 자체 처방
[처방]
- 보존제: PHMB 0.0001% + MPDA 0.0005% (Acanthamoeba 보조)
- 세척: Poloxamer 407 1%
- 보습: 히알루론산 0.05%
- 색소 보호: EDTA 0.05% + α-Tocopherol 0.01% + 시트르산
- pH: 7.2, 290 mOsm
[MOQ] 10,000 ~ 50,000 병 (300ml)
[필요] 의약외품 GMP + MFDS 27295 시험 지원
```

### 5-3. ECOPAD OEM (Inertia·OCBON·중소 OEM)

```
[배경] 친환경 의약외품 생리대 자체 처방
[처방]
- 톱시트: 유기농 코튼 GOTS 인증
- 흡수체: 셀룰로오스 SAP + Glycerin 5% + CMC 2% (swelling 가속)
- 항균: Chitosan 0.5% 코팅 + Terpinen-4-ol 0.1%
- 백시트: 사탕수수 PLA (생분해 180일)
- pH 처리: Lactic acid + Citric acid (pH 4.5-5.5 8h 유지)
[MOQ] 50,000 ~ 100,000 매
[필요] 의약외품 GMP + 비건·GOTS·EWG 인증 OEM
```

---

## 6. 🗂 Atlas 등록 후보 노드

| 노드 ID | 도메인 | 내용 |
|---|---|---|
| F:srd5a2_adenosine_vina_2026 | SCALP | Adenosine × SRD5A2 Vina docking -8.47 kcal/mol |
| F:srd5a2_procapil_vina_2026 | SCALP | Procapil × SRD5A2 -6.66 |
| F:mpda_acanthamoeba_logp_2026 | LENS | MPDA logP +4.76 (Acanthamoeba 침투 first-principles) |
| F:chitosan_terpinen_dual_2026 | ECOPAD | Chitosan + Terpinen-4-ol 듀얼 항균 처방 |

→ `hexa atlas register --from-verify <fn> <args> <value>` 또는 manual atlas SSOT entry 검토

---

## 7. 🚀 다음 단계 권고

| 우선순위 | 작업 |
|---|---|
| ★ 1 | 실측 CRO RFQ 발송 (사용자 영역) — KCL·KTR·KOTITI·디티앤씨알오 |
| ★ 2 | 실측 OEM RFQ 발송 (사용자 영역) — 코스맥스파마·한국콜마·Inertia·OCBON |
| 3 | Atlas 등록 (hexa CLI) — drug discovery 노드 4건 |
| 4 | SCALP Pilot A (자동허가 BASIC) OEM 직발주 → 1-3개월 즉시 출시 |
| 5 | Phase 3 in silico — GROMACS 분자동역학 (PHMB-각막막·셀룰로오스-물) — 옵션 |

## 출처

- 본 분자 특성 — RDKit + Lipinski 직접 계산 (pool ubu-1)
- PR #251·256·259·262·265·267·269·271·272·274·281 (세션 누적)
- RND-STDLIB.md (시험·기관·견적 표준)
