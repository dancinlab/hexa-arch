# TTR — log

## 2026-05-24T05:34Z — M6 off-target safety landed + M2/M6 reconcile

- [x] M6 — 6 off-target × 4 chemistry = 24-cell first-principles risk matrix (`TTR/research/off_target_safety.md`, ~700 lines)
  - 🔴 critical 3 pair: Melanocyte×Oxidation · Melanocyte×Photo · Collagen×Oxidation
  - Therapeutic Index 추산: naive Fenton ≈ 10⁻⁹ → ascorbate scavenger ≈ 10⁻⁵ → enzyme mediator ≥ 1
  - chemistry 우선순위 (M3 constraint): F5 효소 > F3 chelation > F2 reductive ≫ (F1 oxidation 단독 · F4 photo 단독 금지)
  - molecule X 제약: MW > 60 kDa 또는 ink-surface affinity group
  - M9 endpoint: HMB-45/Fontana-Masson · multiphoton SHG · cutometer · LC-MS · 5yr melanoma registry

🔀 **M2/M6 reconcile (M3 진입 전 결정사항)**:
  - M2 default F1(Fenton) → M6 결과로 **demote** (Mel×Ox + Col×Ox 🔴). 살리려면 mitigation 필수: Fe surface-bind + ascorbate scavenger 적층 + depth-targeting
  - M2 default F4(UV-A+TiO₂) → M6 결과로 **demote** (Mel×Photo 🔴). 살리려면 site-localized MN-tip photo (광역 조사 금지)
  - M2 d2 wall path "Photo-Fenton hybrid" → MN-tip 국소화 조건부 OK, 광역 조사 form 금지
  - M3 in-silico screening 우선순위: F5 효소 mediator (AzoR · DyP · peroxidase) → F3 chelation (DFO · siderophore) → F2 reductive (Ascorbate+DFO)
  - F1/F4은 M3 후순위 (mitigation 입증된 candidate만)

## 2026-05-24T05:32Z — M2 MoA short-list landed

- [x] M2 — 8 표적 × 5 MoA family feasibility 매트릭스 (`TTR/research/moa_shortlist.md`, 563 lines)
  - 5 family default: F1 Fenton · F2 Ascorbate+DFO · F3 DFO · F4 UV-A+TiO₂ · F5 AzoR
  - 62 unique candidate handles (CAS + Sigma reachable + thermodynamic 수치) → M3 입력
  - 시장 60-70% (azo + Fe oxide + QA) = F2+F3+F5 단일 family 직접 cleavage
  - 🧱 d2 wall (Cu-Pc + Cr₂O₃) breakthrough 4 paths: Photo-Fenton hybrid · staged 3-pass · macrophage re-engage · DyP engineered
  - Cr₂O₃ band gap 3.4 eV ≡ UV-A 365 nm photon (3.40 eV) thermodynamic 정합
  - ⚠ unknowns: Cr⁶⁺ 형성 risk · 방향족 아민 carcinogenic (M6 1순위 표적)

## 2026-05-24T05:18Z — M4 진피 전달 메커니즘 설계 landed

- [x] M4 — transdermal 4-mechanism 비교 (`TTR/research/transdermal_delivery.md`, 269 lines)
  - 피부 단면 (SC 20μm · 표피 100μm · 진피 500-2000μm 잉크 거주) ASCII
  - 4 메커니즘 first-principles 운반물리 비교: Liposome (50-150μm) · nano-emulsion (200-500μm) · iontophoresis (~500μm) · microneedle (1000-1500μm)
  - 🪡 우승: dissolving microneedle (L = needle 길이 = 도달 깊이, payload-agnostic)
  - 보조: LNP+MN co-delivery (Vaxxas mRNA-MN 선례)
  - M3 활성성분 선택과 decoupled — 어떤 family든 호환

## 2026-05-24T05:15Z — M1 잉크 클래스 inventory landed

- [x] M1 — first-principles 분자 구조 inventory (`TTR/research/ink_classes.md`, 309 lines)
  - 8 표적 결합 카테고리 × 4 공격 화학 (oxidation · reductive · chelation · photo) 매트릭스
  - top 3 cleavable: Azo N=N (BDE 167 kJ/mol) · Fe³⁺ chelation (log K~30) · Quinacridone H-bond
  - 🧱 wall 식별: Cu-Pc + Cr₂O₃ (시장 10-15%) — @D d2 breakthrough path 필요
  - 정직한 천장: 시장 가중 ~85% (90% goal에 5% 갭)

Append-only history sister of `TTR.md`. Each entry starts with `## <ISO timestamp> — <header>` (newest on top); body = `- [x]` (done) / `- [ ]` (pending) checkbox tasks.

