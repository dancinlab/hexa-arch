# demiurge Spec Kit

> Spec Kit (`spec-kit` 0.8.13) governance scaffold for demiurge's
> 7-verb meta-conductor architecture. Specs flow:
> `/speckit-specify → /speckit-plan → /speckit-tasks → /speckit-implement`.

## Pipeline

```
/speckit-specify  →  specs/<###-feature-name>/spec.md     (what + why · user-shaped)
/speckit-plan     →  specs/<###-feature-name>/plan.md     (design artifacts · 7-verb-aware)
/speckit-tasks    →  specs/<###-feature-name>/tasks.md    (dependency-ordered todo)
/speckit-implement →  code lands · gates close
/speckit-checklist →  per-feature checklist (validation)
/speckit-clarify  →  up to 5 targeted clarifications back into spec
/speckit-analyze  →  cross-artifact consistency (spec / plan / tasks)
/speckit-constitution → amend `memory/constitution.md` (this kit's authority root)
```

## Authority — read these FIRST

1. **`memory/constitution.md`** — 6 Core Principles + 2 Governance Rows (R1 Measured-Oracle · R2 Generic Verb-Cell Dispatch). The kit's authoritative ruleset · semver-gated · MAJOR/MINOR/PATCH.
2. **`../design.md`** — Decision audit-trail SSOT (D1..D111+). Every direction lands here before code moves (Principle VI Step-by-Step Decision Gate · NON-NEGOTIABLE).
3. **`../ARCH.md`** — Narrative architecture SSOT. §4.5 carries the D111 generic dispatch target shape.
4. **`../CLAUDE.md`** — Project-level operating instructions (defers to `~/core/wilson/AGENTS.md` for wilson-related work).

## Key architectural commitments (D-block anchored)

These shape how Spec Kit feature specs must wire into demiurge:

### D14 / D18 / §0 — hexa-only ultimate form (NON-NEGOTIABLE)

Every producer, kernel, record schema, and verify oracle's ultimate destination is **hexa-native** (hexa-lang). Python adapters, Swift cockpit, external CLI, and sibling-repo binaries are *transitional pointers (bridges)* — not endpoints. A cell can only be flipped to `absorbed=true` non-provisionally when its hexa-native parity port exists AND matches the transitional implementation to a cited tolerance. **Specs MUST cite the hexa-native destination** even when the transitional bridge is the immediate scope.

### D74 / D80 — Producer alternatives + endpoint compliance

A cell may carry alternative substrates (e.g. `(cern, analyze)` has both `pylhe` legacy and `xsuite-tracking` default). The cockpit's `ProducerRegistry` consults first. D80 endpoint rule: ultimate form = hexa-native. Alternatives are demoted as ports complete.

### D103 — `absorbed` vs `isHexaNativeAbsorbed` dimension separation

The measurement axis (`absorbed`) and the substrate-parity axis (`hexa_native_parity`) are **orthogonal**. Conflation is forbidden. R1 enforces measurement-axis; substrate-parity is a different field.

### D106 — `.illustrativePhysics` carve-out

Cells gated by `GateType.illustrativePhysics` (RFC 013 §6.12) are exempt from R1 (no `MeasuredOracleRef` can attach). Anti-conflation cyan tone in cockpit. Specs covering illustrative cells must declare the carve-out explicitly.

### **D111 — Generic verb-cell dispatch (cellrun.hexa + .demi manifest)** *2026-05-21*

> *This is the active architectural shift Spec Kit features MUST respect from D111 forward.*

**Picked**: Verb-cell dispatch (18 domain × 7 verb = 126 cell grid) flows through a **hexa-native generic dispatcher** (`~/core/hexa-lang/stdlib/cockpit/cellrun.hexa`) reading per-domain `.demi` manifests (`domains/<id>.demi` with `[cell.<verb>]` sections). New domains, new cells, new verbs all wire by editing the manifest — **never by adding new Swift code**.

**Implication for new feature specs**:

- A spec that adds a new domain → ships `domains/<id>.demi` (NOT a new `*Producer.swift` class)
- A spec that adds a new cell to existing domain → adds `[cell.<verb>]` section to existing `.demi` file
- A spec that adds a new substrate type (e.g. `rust-binary`) → extends `cellrun.hexa` substrate dispatch logic (single point of change · NOT scattered per-producer)
- A spec touching the 46 transitional `*Producer.swift` classes must cite the D111 migration plan (Phase A..E) — `*Producer.swift` is on the deprecation track
- `record_kind` stays a Swift symbol pointer (typed-record schema reference) → compile-time safety on consumer side preserved
- `substrate = scan_only` for witness producers (no-spawn cells · 5 currently)
- `unwired = true` for honest-skip stub cells (g3 typed-by-config · no ad-hoc fallthrough)

**Authority**: `memory/constitution.md` R2 (governance row · narrative anchor) · `../design.md` D111 (full rationale + rejected alternatives + Phase A..E exit criterion) · `../ARCH.md` §4.5 (target shape diagram + cost reduction table + migration path).

**Status (2026-05-21)**: Phase A scaffold LANDED on hexa-lang branch `cellrun-generic-dispatcher-scaffold` (cellrun.hexa 684 line + selftest 15/15 PASS · commit `cc1ad85`). Phase B (`domains/sscb.demi` PoC + sscb cells migrate) in progress this cycle. Phase C (46-producer migration) = 6-8 focused sessions.

**Anti-pattern (forbidden by R2)**: any spec proposing "add a new `*Producer.swift` class for cell X" without first checking whether the manifest path covers it. If the manifest doesn't yet cover the substrate, **extend `cellrun.hexa` + `.demi` schema · NOT cockpit Swift**.

## Workflow integration

`/speckit-specify` and `/speckit-plan` MUST cross-reference:
- the relevant `design.md` D-block (Principle VI)
- any applicable R-row from `memory/constitution.md`
- D111 cellrun manifest path when the feature touches verb-cell dispatch

`/speckit-tasks` MUST surface:
- whether implementation touches `cellrun.hexa` / `.demi` manifest (preferred D111 path)
- whether it touches `*Producer.swift` (transitional bridge · only if Phase A..E migration not yet covering)

`/speckit-implement` enforces the gates:
- no merge with absorbed claim without recorded measurement (Principle V · R1)
- new domain spec → manifest first, code second (R2)

## File map

```
.specify/
├── README.md                    # this file · spec kit intro + D111 commitment
├── memory/
│   └── constitution.md          # 6 Principles + R1 + R2 · semver-gated
├── templates/
│   ├── spec-template.md         # /speckit-specify output schema
│   ├── plan-template.md         # /speckit-plan output schema
│   ├── tasks-template.md        # /speckit-tasks output schema
│   ├── checklist-template.md    # /speckit-checklist output schema
│   └── constitution-template.md # /speckit-constitution amendment template
├── workflows/
│   └── speckit/workflow.yml     # pipeline definition
├── integrations/
│   ├── claude.manifest.json     # Claude integration metadata
│   └── speckit.manifest.json    # Spec Kit metadata
├── scripts/bash/                # /speckit-* implementation
├── init-options.json            # kit-level options
└── integration.json             # integration registry
```

## Cross-link

- `../CHARTER.md` — scope & governance (authoritative · supersedes this introduction in case of conflict)
- `../ARCH.md` §4.5 — D111 target shape diagram
- `../design.md` D111 — full Decision audit trail (picked + rationale + rejected + axis + exit criterion)
- `../HANDOFF.md` — self-contained next-session pickup brief
- `../PLAN.md` — append-only progress log (κ-N phase entries)

---

**Spec Kit version**: 0.8.13.dev0 · **demiurge integration**: claude · **Last updated**: 2026-05-21 (D111 ratification)
