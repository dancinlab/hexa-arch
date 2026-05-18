# rfc_011 — Cockpit control surface (4-zone tabbed layout + Chat + AI-agent + canvas modes + 3D viewer)

> Status: **DESIGN** (`design.md` D32..D40) · 2026-05-19
> Builds-on: `rfc_009` (cockpit product-surface spec) · `rfc_010` (3-pane
> info-arch + phases α..ζ). This RFC extends rfc_010 with the **control
> surface** (chat + AI-agent action), **per-domain canvas modes**, **3D
> viewer** for mechanical/exploded artifacts, and the explicit **sibling-
> hexa-bio** boundary clarification.
> Reference UI: `cockpit/references/quiver-overview.png` (Quiver-mirror —
> rfc_010 §2), `cockpit/references/bipv-module-exploded-isometric.jpg`
> (ComponentMode aesthetic target — this RFC §7).
> Validation evidence on record: `cockpit/references/screenshot-2026-05-19-0347.png`
> (D29 + Phase α user-side render — rfc_010 §6 phase-α "measured-green").
> Boundary: **logical** (`@D g_cockpit_isolation` a/b/c/d) STILL HOLDS;
> this RFC introduces TWO new governance entries (`g_ai_agent_action_surface`,
> `g_ai_agent_chat_surface`) without violating any existing invariant.
> Build status: spec only. Implementation lands as Phase α-2 (4-zone
> tabbed shell) + Phases η/θ/ι (chat / agent dispatch / 3D ComponentMode)
> commits with measured-green build gates (D26/D28 idiom).

---

## 1. Purpose

`rfc_010` specified a 3-pane `NavigationSplitView` shell with placeholder
LEFT tree, single CENTER canvas, and placeholder RIGHT inspector. Phase α
of that plan landed and was user-side-validated (`screenshot-2026-05-19-
0347.png`). After Phase α, the user surfaced four additional design
requirements that don't fit cleanly into rfc_010's existing phase plan:

1. **AI agent integration** — "실제 합성 등 여기서 진행할수 있는거야???? cli
   도 함께 만들자, ai agent 이용해서, 작업도 가능하게, AGENTS.tape 에도
   기록" (2026-05-19, user directive). Cockpit must be able to trigger
   real engineering work (synthesis / measurement) via an AI agent, with
   the CLI doubling as the agent's headless surface.

2. **3D modeling** — "합성에 대해 3D 모델링도 필요한데" + "기존것에서 벗어난"
   (paradigm-breaking framing) + "3D 애니메이션 = 마우스로 클릭후 긁으면
   회전기능만". A 3D viewer is required for at least the `component`
   domain (D21 — FEM/EM/thermal/mechanical), interactive rotate only,
   no auto-animation.

3. **In-cockpit chat** — "레이아웃 안에 AI 대화형 진행도 가능해야해 / LLM
   대화형". The AI agent must be reachable through a chat surface that
   lives inside the cockpit layout, not only via the CLI.

4. **hexa-bio sibling clarification** — "bio 는 hexa-bio 이야기 하는거".
   `hexa-bio` is a *sibling* repo (D2 typed-interface-consumed, like
   `hexa-matter` after D17), not an internal demiurge domain. The cockpit
   must not pretend to own bio data — it only consumes bio-emitted seam
   records.

`rfc_011` is the spec that addresses all four together: a single coherent
extension of the rfc_010 cockpit, picked through the gates D32..D40 in
`design.md`.

---

## 2. The reference-asset triangle

The cockpit's design draws from three reference assets (all in
`cockpit/references/`, indexed by `cockpit/references/README.md`):

```
quiver-overview.png            screenshot-2026-05-19-0347.png        bipv-module-exploded-isometric.jpg
─────────────────────          ─────────────────────────────        ──────────────────────────────────
external prior art             cockpit's own user-side render        external prior art
3-pane SplitView idiom         (validation evidence — rfc_010        ComponentMode aesthetic target —
+ $<id> card tokens            phase α measured-green, D29           exploded-isometric stack +
+ selection-bound inspector    honesty-banner verbatim render)       per-layer annotation labels +
                                                                      mouse-drag rotate (D35 RealityKit)
                ↘                            │                                       ↙
                 ↘                           ↓                                      ↙
                  ↘                      keeps the                                ↙
                   ↘                     boundary                                ↙
                    ↘                    honest                                 ↙
                     ↘                                                         ↙
                      ↘                                                       ↙
                       ↘──────────── demiurge cockpit ───────────────────────↙
                                       4-zone tabbed layout
                                       + chat + agent + modes + 3D
```

---

## 3. 4-zone tabbed layout (extends rfc_010 §4)

`rfc_010`'s `NavigationSplitView` 3-pane is the *base shell*. `rfc_011`
upgrades two of those panes (LEFT, RIGHT) into **tabbed pages** while the
shell itself stays unchanged. A persistent **TOP toolbar** is added for
session-wide actions.

### 3.1 Layout

```
┌─────────────────────── TOP toolbar ───────────────────────────────────┐
│ Demiurge ▾  File Help  [+ Synthesize] [+ Measure] [Open]    🔍 Search │
├────────────┬──────────────────────────────────────────┬───────────────┤
│ LEFT       │           CENTER (canvas)                │ RIGHT         │
│ TABS       │                                          │ TABS          │
│            │   record cards · 3D viewer · chain       │               │
│ [Chat][?]  │   canvas · latency curves · …            │ [Insp][?]…    │
│ [Artifact] │                                          │               │
│ [History]  │   (mode chosen per artifact / domain —   │ Provenance    │
│ [Search]   │    §7 Canvas modes)                      │ Inspector     │
│            │                                          │ as RIGHT      │
│ Chat       │                                          │ default       │
│ (1st)      │                                          │ (1st)         │
│            │                                          │               │
│ Claude     │                                          │ + Action      │
│ Code       │                                          │ + 7-verb      │
│ CLI + API  │                                          │ + Chain       │
│            │                                          │ + Atlas       │
└────────────┴──────────────────────────────────────────┴───────────────┘
```

### 3.2 LEFT tabs

| # | Tab | Phase | Content |
| --- | --- | --- | --- |
| 1 | **Chat** ✓ default | η | Claude Code CLI + API dispatcher; chat history with provenance-banner replies; intent classifier (slash-command / LLM); input area |
| 2 | **Artifacts** | β (rfc_010) | tree by type — Records / Decisions / RFCs / Domains / Parameters (D33) |
| 3 | History | ζ+ | past chat threads + action queue snapshots |
| 4 | Search | ζ+ | corpus-wide text + condition search |

### 3.3 RIGHT tabs

| # | Tab | Phase | Content |
| --- | --- | --- | --- |
| 1 | **Inspector / Provenance verbatim** ✓ default | δ (rfc_010) | sub-tabs: Provenance / Data / Citations / Raw JSON / DEPENDENCIES — selection-bound to canvas/tree click |
| 2 | Action queue / agent status | θ | running synth/measurement jobs + progress + result-record links |
| 3 | 7-verb tracker | ι+ | current artifact's location on the 명세→구조→설계→해석⟲→합성→검증→인계 spine |
| 4 | Chain mini-map | ι+ | materials→chip→component meta-conductor (D11, rfc_004 §4) view |
| 5 | Atlas / citations viewer | ι+ | resolved `provenance.atlas_cite_block` references (arXiv / DOI / OSS) |

### 3.4 TOP toolbar

- Window title bar embedded (`navigationTitle("Demiurge Cockpit")` from rfc_010).
- Primary action buttons (selection-aware): `+ Synthesize`, `+ Measure`,
  `Open Record…` (D30), `Search`.
- File/Help/Edit menu via SwiftUI `.commands` (canonical macOS).

### 3.5 Invariant preservation

The 4-zone upgrade adds no new coupling. Reading still flows
LEFT-or-canvas-or-RIGHT → exports/. Writing still requires AI agent
mediation (§6). `@D g_cockpit_isolation` (a/b/c/d) holds.

---

## 4. Chat tab (LEFT default, phase η)

### 4.1 Visual

```
LEFT (240–320 px, resizable)
┌──────────────────────────────┐
│ [Chat] [Artifacts] [History] │ ← tab bar
├──────────────────────────────┤
│ ┌── chat scroll ─────────┐   │
│ │ user:                  │   │
│ │  synthesize d4 router  │   │
│ │  on sky130             │   │
│ │                        │   │
│ │ AI: Synthesis done.    │   │
│ │  new record: $R106     │   │
│ │  ┌─ provenance ──────┐ │   │
│ │  │🟠 GATE_OPEN        │ │   │
│ │  │absorbed: false     │ │   │
│ │  │engine: yosys 0.48  │ │   │
│ │  │caveats: 3          │ │   │
│ │  └────────────────────┘ │   │
│ └────────────────────────┘   │
│                              │
│ ┌────[ type a message… ]──┐  │
│ │                          │  │
│ └──────────────────────────┘  │
│ [Send]    (or Cmd+Return)     │
└──────────────────────────────┘
```

### 4.2 Honesty integration (the unique differentiator)

Every AI reply that produces a record MUST render the new record's
`provenance` block inline in the chat (not a flat text reply). The reply
contains:

- a short summary sentence,
- the new artifact's `$<id>` (D32) and `displayKind`,
- an embedded `ProvenanceBanner` (tinted by `measurement_gate`),
- a click target opening the record card in CENTER + Inspector in RIGHT.

Replies that produce **no** record (pure Q&A) carry no provenance banner;
they are typographically distinguished (no border, no chip).

If the AI replies asserting a measurement / parity / absorption WITHOUT a
backing record's `measurement_gate` ∈ {`GATE_B_PINNED_MET`,
`GATE_CLOSED_MEASURED`}, the chat surface renders a red REJECTED banner
on that reply (the `@F f2`/`f4` mirror in chat).

### 4.3 Backend dispatch — Claude Code CLI + API (D38)

```
user input → intent classifier
              │
       ┌──────┴──────┐
       ↓             ↓
  conversational    action-bearing
  (Q&A about        (synth / measure /
   records,          analyze / verify)
   citations,
   caveats)
       ↓             ↓
   API stream      CLI subprocess
   (low latency,   `claude --headless
    streaming        -p "<prompt>"
    tokens)          --allowedTools …`
       │             │
       │             ↓
       │           tool calls (e.g.,
       │            `swift run`,
       │            `yosys -p …`,
       │            `openroad -no_init`)
       │             │
       │           new record(s)
       │            emitted to
       │            ../exports/**
       │             │
       └──────┬──────┘
              ↓
   chat panel renders reply
   (+ provenance banner if action)
   (+ side effect: new card appears
      in CENTER canvas)
```

Intent classifier (phase η v0): slash-command prefix routing (`/synth`,
`/measure`, `/verify` → CLI; everything else → API). Phase ι: LLM-based
classifier with explicit dispatch reasoning logged in the chat.

### 4.4 Phase plan

- **η-1** Chat tab UI (LEFT TabView, message bubbles, input area, no
  backend yet) — ~80 LoC
- **η-2** API streaming wired (light Q&A only) — ~100 LoC
- **θ** CLI subprocess wired with intent classifier (action capable) —
  ~150 LoC
- **θ+1** Provenance-banner inline rendering in chat for action results —
  ~50 LoC

---

## 5. Inspector tab (RIGHT default, phase δ — extends rfc_010)

### 5.1 Sub-tabs

`rfc_010` §5.1 mentioned an `inspectorView()` per artifact. `rfc_011`
pins the sub-tab order with **Provenance as the default first tab**
(rfc_009 §4 honesty thesis):

```
[Provenance] [Data] [Citations] [Raw JSON] [DEPENDENCIES]
       ↓
   gate chip (tinted)
   absorbed flag
   engine + commit
   consumer_target
   atlas_cite_block (parsed)
   gate_failures (red, if any)
   scope_caveats (full list)
```

Quiver defaults `Data` first; demiurge defaults `Provenance` first
(rfc_009 §4). Tab order is **not** user-customizable in v0.

### 5.2 Phase plan

Already covered by `rfc_010` §6 phase δ (~100 LoC). `rfc_011` only fixes
the default-tab order.

---

## 6. AI agent action surface — governance (D34)

### 6.1 Boundary

```
       user        AI agent             engine
        │           (Claude              (Yosys,
        │ types      Code)               OpenROAD,
        ▼ command    │                   hexa-matter,
   cockpit chat tab  │ invokes           Elmer, …)
        │            │                   │
        └─trigger──▶ │                   │ writes records
                     │ subprocess        │
                     └─CLI─▶ tool use ───┴───▶ exports/**
                                                │
                                                │ read-only consume
                                                ▼
                                           cockpit canvas
                                           (new card appears)
```

- AI agent acts as a **producer** in the D7 sense — it writes new records
  to `../exports/**` on behalf of the engine tools it invokes.
- Cockpit/CLI never write to `exports/` directly. `g_cockpit_isolation
  (d)` holds.
- Engine tools (Yosys, OpenROAD, hexa-matter, Elmer, openEMS, …) are
  invoked via subprocess by the AI agent, NOT by the cockpit/CLI
  directly.

### 6.2 Two new governance entries

```
@D g_ai_agent_action_surface  (D34)
  cockpit/CLI may invoke an AI agent to perform actual synthesis /
  measurement / analysis. The agent is the producer of any resulting
  records; cockpit/CLI never mutate exports/ directly.

@D g_ai_agent_chat_surface   (D37 + D38)
  cockpit's LEFT Chat tab routes user messages to Claude Code API
  (conversational) or Claude Code CLI (action-bearing). All action
  results render their full provenance / gate / citations VERBATIM in
  the chat reply.
```

Both entries are formalized in `AGENTS.tape` and cross-referenced from
`design.md` D34 / D37 / D38.

### 6.3 Phase plan

- **θ** governance-conformant agent invocation (CLI subprocess with
  tool-permissions, output piped + parsed for new record IDs) — ~150 LoC
- **θ+2** action queue / agent status panel (RIGHT 2nd tab) — ~100 LoC

---

## 7. Canvas modes — domain-aware center pane

The CENTER canvas renders different *modes* depending on what the user
selected (or what the chat just produced). All modes share the same card
chrome (rfc_010 §5.3) — `$<id>` header + gate chip + close button +
provenance footer — but the body differs.

### 7.1 Mode registry (v0 — phase ε, extended phase ι)

| Mode | Domain | Body composition | Phase |
| ---- | ------ | ---------------- | ----- |
| **ChipMode** | chip (rfc_001/002/006) | F1F2 record card · latency curve · records table · synthesis cards | γ–ε (rfc_010) |
| **ComponentMode** | component (D21) | **3D exploded-isometric viewer (RealityKit, mouse-drag rotate)** + FEM/EM/thermal cards | ι |
| **MatterPointer** | matter (D17 pointer) | single pointer card to `hexa-lang/stdlib/matter` + link to SSOT | ε |
| **CohortShallow** | cern / antimatter / rtsc / space / energy / brain / grid / mobility / … | shallow domain card with `domains/*.md` summary + cited-research links | ε |
| **ChainMode** | meta-conductor (D11) | rfc_004 §4 chain canvas — materials→chip→component nodes + seam record edges | ε+ |
| **SeamConsumerMode** | seam records (rfc_007/008, bio↔chip etc.) | typed-consumer view of producer-side records (incl. hexa-bio outputs — §8) | ε |

`HexaBioMode` is **deliberately absent**. Bio data enters demiurge only
as seam records, rendered in SeamConsumerMode. See §8.

### 7.2 ComponentMode aesthetic target

```
       ╲╱
     ─────────              ┌─ Glass Face       (top layer card)
       ▱▱▱▱
     ─────────              ┌─ PV Cells         (record + ProvBanner)
       ▱▱▱▱
     ─────────              ┌─ Corrosion-Proof Frame
       ▩▩▩▩                                     (FEM stress field)
     ─────────              ┌─ Thermal Sink
       ▢▢▢▢                                     (thermal map record)
     ─────────              ┌─ Structural Mount
       ╳╳╳╳                                     (mechanical CAD)

mouse-drag rotates the stack (RealityKit orbit camera, §9).
each layer carries its OWN ProvenanceBanner — the rfc_009 §4
honesty contract is per-layer, not per-stack.
```

Reference: `cockpit/references/bipv-module-exploded-isometric.jpg`.

---

## 8. hexa-bio = sibling, not internal domain (D36)

`hexa-bio` is a **sibling repo** of demiurge under the `hexa-*` family
(`AGENTS.tape` `@D g_decouple` D2). It is typed-interface-consumed,
NEVER absorbed into demiurge.

### 8.1 What this means for the cockpit

- The cockpit does NOT render hexa-bio internals (no atom-bond 3D viewer,
  no sequence editor, no binding-curve native cards).
- The cockpit DOES render `seams/bio_to_chip/` and `seams/bio_to_component/`
  records when hexa-bio emits them (`SeamConsumerMode`, §7).
- A future `hexa-bio-cockpit` sibling repo MAY exist (Phanes ⇄ Demiurge
  pattern); its design is **out of scope** for this RFC and any other
  demiurge RFC.

### 8.2 Decision-resolved alternatives (rejected)

- **B** "demiurge cockpit owns BioMode" — rejected (violates D2 / D11 /
  D17 sibling pattern).
- **C** "federated cockpit shell across hexa-* repos" — deferred (P5+
  scope, governance not yet specified).

### 8.3 What demiurge `domains/` looks like under §7

`domains/matter/README.md` is a **pointer-only** card (`MatterPointer`
mode) — D17 made hexa-lang the absorption SSOT. The same pattern would
apply if a `domains/bio/` pointer ever lands (NOT planned by this RFC).

---

## 9. 3D viewer = RealityKit, mouse-drag rotate only (D35)

### 9.1 Picked

- Framework: **RealityKit** (Apple-canonical, modern, macOS 13+,
  AR/VR-ready, ~30 LoC orbit-camera setup).
- Interaction: **mouse click + drag rotates the model**. NO auto-spin,
  NO keyframe animation, NO ambient camera path.
- Loaded formats: USDZ (Apple-native), STL (FreeCAD / KiCad export),
  glTF (via RealityKit bridge if available).

### 9.2 Why not SceneKit (rejected)

SceneKit has a one-line `allowsCameraControl = true` orbit camera and
shorter LoC, but SceneKit is the older Apple 3D framework with limited
ongoing development. RealityKit is where Apple's investment is
(visionOS / spatial). D26 `g_swift_native` "canonical first" → modern
canonical. ~+15 LoC over SceneKit, accepted.

### 9.3 Why not custom SwiftUI 3D / Metal (rejected)

Custom = more LoC, more bug surface, no canonical bonus. Reserved for
future if RealityKit lacks a needed primitive.

### 9.4 Phase plan

- **ι-1** RealityKit ARView wrapper in SwiftUI + simple test scene
  (rotating cube) — ~50 LoC
- **ι-2** USDZ / STL loader from `../exports/**` paths + per-layer
  selection — ~70 LoC
- **ι-3** ComponentMode wiring (BIPV exploded stack + per-layer
  ProvenanceBanner) — ~80 LoC

---

## 10. Phase plan additions to rfc_010

`rfc_010` defined α..ζ (shell, tree, card, inspector, variety,
filters/deps). `rfc_011` adds:

| Phase | Scope | Est. LoC | Build gate |
| ----- | ----- | -------- | ---------- |
| α-2 | LEFT TabView (Chat placeholder + Artifacts) + RIGHT TabView (Inspector default) + TOP toolbar | ~80 | `swift run` clean + tabs switch |
| η | Chat tab UI + API streaming Q&A | ~180 | clean + Q&A reply renders |
| θ | CLI dispatch + action result with provenance banner in chat | ~200 | clean + a `/synth` command produces a measurable record |
| ι | RealityKit ComponentMode (3D viewer + USDZ/STL loader + per-layer banner) | ~200 | clean + BIPV exploded stack renders + mouse-drag rotates |
| | **Total (new phases)** | **~660** | |

Combined with rfc_010's α..ζ (~730), the full cockpit estimate is
**~1390 LoC** Swift — still tractable, still Apple-canonical (D26).

---

## 11. Open decision gates (for D41+ in `design.md`)

These are real fork-in-the-road points this RFC intentionally does not
pre-commit. They will open as the phases arrive.

1. **D41 — Chat history persistence** — A) `@AppStorage` per launch only;
   B) on-disk JSON in `cockpit/chat-history/` (outside `exports/`, not a
   record); C) git-tracked transcripts. Recommended: A for η-1; B for θ.

2. **D42 — Slash-command vocabulary** — `/synth`, `/measure`, `/verify`,
   `/analyze` are obvious; full set deferred to phase θ when actual
   tool subprocess invocations are wired.

3. **D43 — RealityKit format priority** — USDZ vs STL vs glTF — pick
   based on which `../exports/**` records will actually contain 3D
   geometry data. Likely USDZ (Apple-native, FreeCAD now exports).

4. **D44 — Action queue persistence** — across launches? Across machine
   restarts? Recommended: in-memory for v0, on-disk JSON in θ+2 if
   demanded.

5. **D45 — Federated cockpit shell** — `hexa-bio-cockpit` / hexa-matter /
   etc. shared shell, vs separate apps per repo. Deferred P5+.

---

## 12. What is NOT built (g3 — explicit)

- **No tabs landed yet** — Phase α-2 commit will land the tabbed shell.
- **No chat backend** — Phase η wires API; Phase θ wires CLI. Until
  then, the Chat tab will be a UI placeholder.
- **No AI-agent record emission** — Phase θ. Until then, ALL records in
  `../exports/**` are producer-emitted by humans / scripts / NOT this
  cockpit.
- **No 3D viewer** — Phase ι. Until then, ComponentMode renders as
  text-only cards (no exploded stack).
- **No `hexa-bio-cockpit`** — out of scope (§8.1).
- **No federation** — deferred (D45).
- **No action result has shipped through chat → exports** — Phase θ
  build gate is the first measured-green claim point.
- **No claim that the cockpit performs synthesis** — UNTIL Phase θ's
  build gate is met with a cited record showing a real Yosys / OpenROAD
  / hexa-matter invocation, the cockpit is a *trigger + viewer*, not a
  *synthesis tool* (g3 / `@F f2`).

---

## 13. Cross-references

- `proposals/rfc_009_product_surface_macos_cockpit.md` — product-surface spec (parent)
- `proposals/rfc_010_cockpit_architecture.md` — 3-pane info-arch + phases α..ζ
- `cockpit/references/README.md` — design-inspiration + measured-validation index
- `cockpit/references/quiver-overview.png` — 3-pane idiom source
- `cockpit/references/bipv-module-exploded-isometric.jpg` — ComponentMode aesthetic target
- `cockpit/references/screenshot-2026-05-19-0347.png` — Phase α validation
- `design.md` D22 / D27 / D28 / D29 / D30 / D31 / **D32..D40** — decision audit trail
- `AGENTS.tape` `g_cockpit_isolation` / `g_swift_native` / **`g_ai_agent_action_surface`** / **`g_ai_agent_chat_surface`** — governance
- `CHARTER.md` Mission — meta-conductor (D11)
- `GOAL.md` — north-star: honesty-as-feature
