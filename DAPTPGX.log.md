# DAPTPGX — log

Append-only history sister of `DAPTPGX.md`. Each entry starts with `## <ISO timestamp> — <header>` (newest on top); body = `- [x]` (done) / `- [ ]` (pending) checkbox tasks.

## 2026-05-24T21:35:00Z — M2 · M4 · M5 cycle1 병렬 완료 (3 milestone)

- [x] **M2 pathway** (202 lines) — clopidogrel 2-step bioactivation · P2Y12 Cys17/Cys270 covalent · phenotype별 active AUC + PRU 정량 · 한국인 baseline · ABCB1/CES1/PON1 modifier
- [x] **M4 bleed** (225 lines) — PRECISE-DAPT · PARIS · ARC-HBR 14항목 · 한국인 calibration (KAMIR-NIH · K-ACTIVE · HOST-EXAM · TICAKOREA) · BARC/TIMI/GUSTO 비교 · LoF × HBR 교차표
- [x] **M5 PFT** (192 lines) — VerifyNow PRU 208 · LTA 46% · MEA 46U · 3-assay 상관 r 0.5-0.7 · GRAVITAS/ARCTIC/ANTARCTIC/TROPICAL-ACS/POPular Genetics/TAILOR-PCI 결과표 · 한국 보험급여
- [ ] 🟠 M3 switch tree (M2+M4 의존 ready)
- [ ] M6 next-gen P2Y12 · M7 통합 결정맵 · M8 econ

🔑 핵심 통찰 (cross-cutting):
- **PK→PD→임상 인과 사슬 확정** — CYP2C19 LoF → active AUC 25-70%↓ → PRU↑ → ST 2-5× · MACE 1.5-2× (Mega 2010 메타)
- **Asymmetric risk in LoF** — LoF는 효과만 깎고 출혈은 안 늘림 → 한국인 60% IM+PM에서 escalation net benefit 명확
- **한국인 dual jeopardy** — 출혈 ↑ (체중 65kg, ICH↑) + clopidogrel 무반응 (LoF 60%) → 서양 결정 트리 import 불가, KSC 2024는 clopidogrel-first + 단기 DAPT
- **PFT-guided escalation = no hard benefit** — GRAVITAS·ARCTIC·ANTARCTIC 모두 음성. PFT의 진짜 역할은 **de-escalation 안전 확인**(TROPICAL-ACS)
- **Genotype ≥ PFT** (POPular Genetics) — M3 결정 트리는 **CYP2C19 → 임상 risk → (선택적) PFT** 순서
- **High-stakes cell** — 한국인 PCI 100명 중 ~7-8명이 **PM × HBR⊕** → M3 + M5의 최대가치 cohort

## 2026-05-24T21:20:00Z — M1 CYP2C19 한국인 allele 완료

- [x] §1 clopidogrel 2-step CYP2C19 의존 ASCII
- [x] §2 `*1` / `*2` / `*3` / `*17` 기능 + 활성도
- [x] §3 한국인 vs 동아시아 vs 백인 vs 흑인 allele freq 표
- [x] §4 diplotype × phenotype × clopidogrel 반응 + ASCII (한국인 100명 모델)
- [x] §5 CPIC 2022 + 한국인 caveat (TICAKOREA · HOST-EXAM)
- [x] §6 ABCB1 · PON1 · ITGB3 · P2RY12 보조 polymorphism
- [x] 산출물 `DAPTPGX/M1_allele.md` (~125 lines)
- [ ] 🟠 platelet reactivity 정량 (M5 PFT cutoff)
- [ ] M2 pathway 정량 (active metabolite 감소율)

🔑 핵심 통찰:
- **한국인 LoF allele freq ~40% — 글로벌 최고** (백인의 ~2.5×)
- **한국인 IM+PM 합 ~60%** → PCI 환자 절반 이상이 clopidogrel 비-최적
- `*3` allele이 백인 대비 ~20-50× → 한국인 특이 결정 변수
- 단순 prasugrel/ticagrelor switch는 출혈위험 ↑ (동양인 체격) → M3 결정 트리 필요

## 2026-05-24T21:00:00Z — scaffold

- [x] @goal 확립 — 한국인 PCI DAPT PGx 결정맵
- [x] M1-M8 milestone 설계
- [x] M1 CYP2C19 한국인 allele 빈도
