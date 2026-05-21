# PAPERS — demiurge / hexa-lang research paper repository

> arxiv-quality LaTeX papers, one per directory under this root. Compiled
> PDFs sit alongside their source for review. Sample target quality:
> arxiv:2409.00101 (NeuroLM, ICLR 2025) — single-column ~14-18 pages, with
> figures + tables + bibliography.
>
> opened: 2026-05-21 KST · status: drafting first sample

---

## Directory layout

```
PAPERS/
├── README.md                          ← this file (rules)
├── sample-nb-bcs-absorbed/            ← first sample (Nb BCS absorbed=true)
│   ├── main.tex
│   ├── references.bib
│   ├── Makefile
│   ├── figures/
│   │   ├── *.tikz / *.pdf / *.png
│   └── README.md                      ← paper-specific notes
└── <slug>-<topic>/                    ← future papers, same layout
```

`<slug>` 규칙: lowercase-kebab-case · short · 본문 영역 식별 가능
(예: `mp-cache-roadmap`, `tier4-falsifier-dispatch`, `cube-fullcycle-617s`).

---

## LaTeX rules

- **Class**: `\documentclass[11pt]{article}` + arxiv-style preamble
  (single-column, A4 or letter, 11pt). Larger conference templates (NeurIPS,
  ICLR, IEEE) 는 별 PR 에서 결정.
- **Bibliography**: BibTeX (`references.bib`) + `\bibliographystyle{plain}`
  또는 `unsrt`. 모든 인용은 source URL 또는 DOI 또는 arxiv ID 필수.
- **Figures**: vector (`.pdf` · `.eps`) 권장. 비트맵 (`.png`) 은 OpenAI-생성
  cover / 사진성 자료만. 모든 figure 는 `figures/<slug>.{pdf,png,tikz}`.
- **Compile**: `make` 또는 `pdflatex main.tex` × 3 (cross-ref + bibtex pass).

---

## g3 honest stance (RTSC.md / MP.md 와 정합)

- **measurement-oracle parity** 가 absorbed=true 의 유일 경로. paper 가
  주장하는 결과는 모두 동반 record JSON (exports/) 으로 검증 가능해야 함.
- **scope_caveats** 를 paper 본문 마지막에 별 §로 표기 — record 의
  caveat 와 word-for-word 일치 권장.
- **provenance**: 모든 측정값 / 식 / 인용 출처는 `\cite{}` + bibtex entry +
  URL/DOI 까지 추적 가능. 추적 불가능한 claim 은 paper 에 안 들어감.
- **absorbed=true 주장 paper** 는 동반 record 의 `measurement_gate =
  GATE_CLOSED_MEASURED` 필수.
- **claim-only 영역** (LK-99 / hexa-rtsc n=6 등 미재현 RTSC) 의 paper 는
  `absorbed=false · gate_type=empirically-unproven` 명시 + 'claim 자체'
  논의로 명확히 제한.

---

## Image generation

OpenAI 이미지 생성 API 사용 가능 (DALL-E 3):

```bash
OPENAI_API_KEY=$(secret get openai.api_key) curl https://api.openai.com/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model":"dall-e-3","prompt":"...","n":1,"size":"1024x1024"}'
```

- 적용: cover / teaser / 컨셉 schematic. 데이터 plot 은 matplotlib · 기술
  diagram 은 TikZ 권장 (OpenAI 는 정량성 보장 안 됨).
- 라이선스: OpenAI 생성 이미지는 사용자 소유. attribution 불필요. 단 paper
  내에 `% generated via OpenAI DALL-E 3, prompt: ...` 주석 권장.

## Compile pipeline

```bash
cd PAPERS/<slug>/
make            # pdflatex + bibtex + pdflatex × 2
# 또는 수동:
pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex
```

결과: `main.pdf` 같은 디렉터리 안. arxiv 제출 시 `main.tex` + `references.bib`
+ `figures/*` tarball 로 묶음.

---

## Submission categories (arxiv 기준)

본 repo 의 paper 가 arxiv 갈 때 주로 cross-list 후보:

| category | 범위 |
|---|---|
| `cond-mat.supr-con` | 초전도 (RTSC.md 작업 1순위) |
| `cond-mat.str-el` | 강상관 전자계 (cuprate · iron-based) |
| `physics.comp-ph` | 계산 물리 (FEM · DFT pipeline) |
| `physics.ins-det` | 측정 instrument (Tier 3 ingest) |
| `cs.SE` | software engineering · framework paper |

---

## Cross-reference

- `~/core/demiurge/RTSC.md` — RTSC 도메인 5축 + §8 4-tier
- `~/core/demiurge/MP.md` — Materials Project key-free 로드맵
- `~/core/demiurge/exports/material_attestation/` — absorbed=true 검증 record (paper 동반)
- `~/core/hexa-lang/stdlib/material/` — Tier 1-4 producer SSOT
- `~/core/hexa-lang/stdlib/rtsc/` — device-side FEM (Tier 0)

## Log

- **2026-05-21 KST** — opened. PAPERS/ 루트 + 첫 샘플 (Nb BCS absorbed=true attestation).
