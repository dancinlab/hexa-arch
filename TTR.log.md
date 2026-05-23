# TTR — log

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

