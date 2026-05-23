# HERPES — current state

@goal: HSV-1 입술물집 + HSV-2 성기물집 완치법 확립 — 잠복 재활성화 차단 + 신경절 reservoir 제거까지 둘 다 달성 (sterilizing cure)

## milestones

- [x] HSV-1/2 게놈 구조 + LAT locus 매핑 → `HERPES/M1_genome_lat.md`
- [x] 신경절 reservoir 정량화 — per-neuron 게놈 copy → `HERPES/M2_reservoir.md`
- [x] 잠복기 chromatin 상태 모델링 — H3K9me3 · CTCF → `HERPES/M3_chromatin.md`
- [x] 재활성화 트리거 네트워크 시뮬 — HCF-1 · JNK · DLK → `HERPES/M4_reactivation.md`
- [x] CRISPR/메가뉴클레아제 게놈 절단 설계 — Jerome Lab 노선 → `HERPES/M5_crispr.md`
- [x] shock-and-kill — LRA로 잠복 깨우고 면역으로 정리 → `HERPES/M6_shock.md`
- [x] block-and-lock — LAT 영구 침묵화 → `HERPES/M7_lock.md`
- [x] T-cell exhaustion 역전 — PD-1 · LAG-3 신경절 침투 → `HERPES/M8_tcell.md`
- [x] 치료적 mRNA 백신 — BNT163 · mRNA-1608 후속 → `HERPES/M9_mrna.md`
- [x] sterilizing cure 임상 엔드포인트 정의 + 검증 프로토콜 → `HERPES/M10_clinical_protocol.md`

## verify (🔵 SUPPORTED-FORMAL push · per @D g5 · demiurge 자산 필수)

- [x] V1 HERPES claim inventory + tier triage → `HERPES/verify/V1_claim_inventory.md` (248 claims · 25🔵 / 44🟢 / 144🟡 / 35🟠 / 0🔴)
- [x] V2 🔵 push — Poisson · LAT · CRISPR · decay · Hill → `HERPES/verify/V2_formal_identities.md` (5/5 ⚪ fence — hexa verify CLI는 NT-only · 해결 inbox patch 필요)
- [x] V3 🟢 push → `HERPES/verify/V3_numerical_recompute.md` (2/4 🟢: LAT Markov on ubu-1 + 3-comp PK on ubu-2 · 2/4 🟠: cas-offinder/GRCh38 + bio toolchain 미설치)
- [x] V4 final tier ledger → `HERPES/verify/V4_tier_ledger.md` (25🔵 / 44🟢 / 144🟡 / 35🟠 / 0🔴 + 5⚪ · 26 compute-promotable · 9 wet-lab essential)
