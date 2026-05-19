# rfc_012 — Project workbench (cockpit evolution: viewer → workbench)

> Status: **DRAFT / DISCUSSION** (2026-05-19) — NOT yet locked. No
> `design.md` decision, no governance, no code derives from this file
> yet. It is the running record of an in-progress layout/UX discussion
> so the thread is not lost. Open questions in §8 must be gated
> (one decision at a time) before any implementation.
> Builds-on: `rfc_009` / `rfc_010` / `rfc_011` (the cockpit so far —
> a read-only record viewer). This RFC is the discussion of turning it
> into a project workbench.

---

## 1. Purpose

Through `rfc_009`–`rfc_011` the cockpit is a **read-only viewer** of
existing `exports/**` records. The user (2026-05-19) redirected:

> "프로젝트 생성이 있어야 하고 / 어떤 것을 개발할건지 / 유저한테
> 프로젝트명 입력받아 생성 / + 버튼 필요 / 이 프로그램은 일반인도
> 이해하고 사용하기 쉬울 정도가 필요해"

So the cockpit must become a **project workbench**: the user creates
a named project, picks what to design, and runs it through the 7-verb
spine — and a non-expert must be able to understand and use it.

---

## 2. "Project" — a new concept

demiurge's data model so far = records · decisions · RFCs · domains
(all *pre-existing artifacts*). A **project** is a NEW unit — something
the *user creates*:

```
project = {
  name          유저 입력 (e.g. "우리 회사 칩")
  target        무엇을 설계 (도메인 / 목표)
  verbProgress  7-verb 진행 상태 (명세→…→인계 어디까지)
  records       이 프로젝트가 생성한 typed records
}
```

vs the hexa-family: a project is *scoped work inside demiurge*, not a
sibling repo. One project = one 7-verb run over one design target.

---

## 3. Single screen + in-place `+` button (user-resolved)

The user resolved: **NO separate "pick a project" screen.** There is
ONE screen (the workbench, "화면 B" below); the `+` button lives
*inside* it and both creates and switches projects.

`+` flow: click `+` → enter project name → choose what to design →
the workbench opens on that project's verb 1 (명세 / SPECIFY).

`+` button location = **OPEN QUESTION** (§8).

---

## 4. Plain-language layer (일반인용)

demiurge's thesis is honesty (`g3` — no claim before measurement),
but a non-expert does not read `GATE_OPEN` / `provenance` / `F1F2`.
The honesty stays; only the *wording* becomes plain:

| expert term            | plain wording (proposed)              |
| ---------------------- | ------------------------------------- |
| `GATE_OPEN`            | ⏳ "아직 측정 안 됨"                   |
| `GATE_CLOSED_MEASURED` | ✅ "측정으로 확인됨"                   |
| `GATE_B_PINNED_MET`    | 🔶 "일부만 측정됨"                     |
| `absorbed: false`      | "참고용 · 검증 전"                     |
| `provenance`           | "이 결과를 믿어도 되는 이유"           |
| 7-verb (명세→…→인계)   | "7단계: 무엇을→어떻게→설계→점검→만들기→검증→넘기기" |

→ honesty = a **signal light** (⏳ / 🔶 / ✅). Plain on the surface,
g3-honest underneath. An optional expert toggle could reveal the raw
terms — §8.

---

## 5. Layout — single workbench, 3 columns; ② is widest & split

User-resolved (2026-05-19, refined across several turns). Key insight:
**area ≠ driver.** The chat is narrow but DRIVES the project; ② is
the widest because it SHOWS the result.

- **① recipe rail (7-verb)** — NARROW, leftmost.
- **③ LLM chat (cooking teacher)** — NARROW, centre. The project
  advances *through this conversation*; honesty signal light (§6)
  renders inline in replies.
- **② work zone** — WIDEST, rightmost — split top / bottom:
  - **② top (short) = ingredient shelf** — plain UI option pick;
    "[냄비에 넣기]" feeds the selection into the next chat turn.
  - **② bottom (main, largest) = result visualization** — 3D
    rendering (RealityKit ComponentView3D), charts, record views —
    where the design's result is shown.

**Cooking metaphor (product voice):**
- **③ chat = the cooking teacher** — stands narrow at your side and
  *directs*; small on screen, but the dialogue is what *moves* the
  project.
- **② bottom = the big plate on the bench** — the largest area; the
  dish being cooked (3D render / work result) is laid out here.
- **② top = the ingredient shelf** — a short strip; pick ingredients
  (options) and drop them in.
- **① = the recipe card on the wall** — which of the 7 steps.

```
┌──────────── ④ 상단: 프로젝트명 + 7단계 진행바 ──────────────┐
│  [+]  칩 A ▾   [무엇을]─[어떻게]─[설계]─◉해석─[합성]─…      │
├──────┬────────────┬──────────────────────────────────────────┤
│ ①    │ ③ chat     │ ② work zone (widest) ★                  │
│narrow│ (narrow)   │ ┌─ ② top: ingredient shelf (short) ────┐ │
│recipe│ cooking    │ │ ○22nm ○7nm  ○mesh ●hex   [냄비에 넣기]│ │
│rail  │ teacher    │ └──────────────────────────────────────┘ │
│무엇✅│ (LLM)      │ ┌─ ② bottom: MAIN (largest) ────────────┐│
│어떻✅│ 👨‍🍳 …     │ │  🧊 3D render · charts · record views  ││
│설계◉│ 🙋 …       │ │     ┌──────┐                           ││
│해석  │ 👨‍🍳 …⏳   │ │     │ ╱╲   │  exploded 3D / 결과 시각화 ││
│합성  │ [입력…]    │ │     │ ╲╱   │                           ││
│검증  │            │ │     └──────┘                           ││
│인계  │            │ └────────────────────────────────────────┘│
└──────┴────────────┴──────────────────────────────────────────┘
  narrow   narrow              widest (top shelf + bottom main)
```

- **① (leftmost, narrow)** — 7-verb recipe; done ✅ / current ◉ /
  upcoming (grey).
- **③ (centre, narrow) — LLM chat** — the cooking teacher; rfc_011
  chat + θ Claude Code CLI; drives the project; ⏳/🔶/✅ inline.
- **② (rightmost, WIDEST) — work zone**, split:
  - *top strip* — ingredient shelf (option pick → next chat turn).
  - *bottom (largest)* — result visualization: 3D render
    (ComponentView3D), latency charts, record views, …
- **④ (top)** — `+` button · project switch · 7-step progress bar ·
  light/dark.

Why area≠driver: demiurge's GOAL is a *meta-conductor* — a conductor
works by *direction* (the narrow chat), while the orchestra's output
(the wide ② bottom) is what fills the hall. The cockpit is a place you
*converse a design into being*, and watch the result take shape on the
big plate.

---

## 6. Honesty preserved — the signal light

The plain-language layer (§4) MUST NOT weaken `g3`. Rules:
- the signal light is sourced from `provenance.measurement_gate`
  VERBATIM — the UI never upgrades ⏳ to ✅.
- "측정으로 확인됨 ✅" appears ONLY for `GATE_CLOSED_MEASURED`.
- a project with zero measured records shows ⏳ everywhere — honest.
- AI 도우미 reply asserting ✅ without a backing record = REJECTED
  (`@F f6`, rfc_011 §4.2).

---

## 7. Data model — where projects live

Proposed: `exports/projects/<name>/` — project manifest + the records
that project produced. This **touches `@D g_cockpit_isolation`**:
invariant (a) is currently read-only on `exports/**`. A workbench that
CREATES projects writes there. Reconciliation needed — likely the
D34 pattern (the AI agent is the producer; the cockpit triggers).
This is an OPEN QUESTION (§8) — NOT resolved.

---

## 8. Open questions (NOT decided — discussion ongoing)

Each must be gated separately (one decision at a time) before code:

1. **`+` button location** — ④ toolbar / ① sidebar top / floating?
2. **"무엇을 설계"** — pick from the 15 domains / free-text goal /
   both?
3. **expert mode** — plain-language only, or a toggle that reveals
   raw `GATE_*` / `provenance` / `F1F2`?
4. **① sidebar = 7-verb stages?** — replaces the current
   Chat/Artifacts tabs. Where do Chat (rfc_011 D37) and the Artifact
   browser go then?
5. **project data location + governance** — `exports/projects/<name>/`
   vs elsewhere; how `@D g_cockpit_isolation` (a) read-only is
   reconciled with project creation (the cockpit writing).
6. **project ↔ existing records** — does a project consume the 50
   existing F1F2 records, or only ones it generates?
7. **what "develop" means per verb** — at verb 5 합성/SYNTHESIZE,
   does the workbench invoke a real tool (θ-2 / AI agent), or just
   record intent?

---

## 9. What is NOT decided (g3 — discussion stage)

This RFC is a DRAFT. Nothing here is a `design.md` decision; no
governance changed; no code written. The current cockpit is still the
rfc_009–011 read-only viewer (commit `1a6da4c`). The project-workbench
direction is agreed in spirit (user directive) but every concrete
choice in §8 is open. Implementation begins only after §8 is gated.

---

## 10. Cross-references

- `rfc_009` / `rfc_010` / `rfc_011` — the cockpit as built so far
- `design.md` D22 / D27–D41 — cockpit decision audit trail
- `AGENTS.tape` `@D g_cockpit_isolation` (the read-only invariant this
  RFC's §7 must reconcile) · `@D g_ai_agent_action_surface` (D34 —
  the producer-mediation pattern §7 likely reuses)
- `GOAL.md` — 7-verb spine; honesty-as-feature (§6 must preserve)
- `cockpit/references/` — Quiver (rfc_010) + BIPV + the Electron
  news-app screenshot (icon-rail reference, now superseded by
  `.sidebarAdaptable` per commit `1a6da4c`)
