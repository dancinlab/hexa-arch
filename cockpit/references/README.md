# cockpit/references/ — design inspiration + validation assets

> Reference assets cited by `proposals/rfc_009_product_surface_macos_cockpit.md`
> (`rfc_009`), `proposals/rfc_010_cockpit_architecture.md` (`rfc_010`), and
> `proposals/rfc_011_cockpit_control_surface.md` (`rfc_011`). Two kinds:
> **design inspiration** (external prior art the cockpit borrows visual
> patterns from) and **measured validation** (screenshots from the
> cockpit's own user-side runs that prove the design renders as designed).

## Index

| File | Kind | Cited by | Source | Note |
| ---- | ---- | -------- | ------ | ---- |
| `quiver-overview.png` | inspiration | rfc_010 §2 | Palantir Foundry Quiver "Overview Analysis" capture, 2026-05-19 (user-provided) | 3-pane SplitView + `$<id>` card tokens + selection-bound inspector pattern that rfc_010 mirrors. NOT a copy: the cockpit adds honesty-mode (gate chips, REJECTED cards, Provenance verbatim) which Quiver does not have. |
| `screenshot-2026-05-19-0347.png` | validation | PLAN.md, design.md D29 supersede-forward | user-side `swift run` capture of D29 + Phase α landing on Mac Mini, 2026-05-19 03:47 KST | First *visual proof* that honesty-as-feature renders correctly: orange GATE_OPEN chip + `absorbed: false` + 5 `scope_caveats` verbatim, matching D29's design.md prediction. |
| `bipv-module-exploded-isometric.jpg` | inspiration | rfc_011 §7 (`ComponentMode` canvas mode) | aluminiummagazine.com BIPV (Building-Integrated PhotoVoltaic) module construction diagram | Exploded-isometric "feel" the user wants for the `component` domain (D21) canvas mode: glass face / PV cells / corrosion-proof frame / thermal sink / structural mount visibly stacked with annotated layers. RealityKit (D35) renders this style; mouse-drag rotates the stack. |

## Provenance discipline (`@D g_cockpit_isolation` invariant a)

These assets live under `cockpit/references/`, NOT `../exports/**`. They are
**design references**, not committed *measured records* — the cockpit reads
them only as static images shown in docs/RFCs and (eventually) as
in-app "inspiration" credits. They MUST NOT be treated as provenance-bearing
records (no gate state, no `absorbed` field, no atlas citation). The
honesty-mode rules (`rfc_009` §4) apply to `../exports/**` records only.

## How to add a new reference

1. Copy the file into this directory with a descriptive lowercase-hyphen name
   (avoid spaces / non-ASCII for git portability).
2. Add a row to the Index above.
3. Cite it from the appropriate RFC section.
4. If it is a measured validation screenshot, cross-reference the
   corresponding `design.md` decision and PLAN.md log entry.

## Cross-references

- `../proposals/rfc_009_product_surface_macos_cockpit.md` — product-surface spec
- `../proposals/rfc_010_cockpit_architecture.md` — 3-pane info-arch + phases α..ζ
- `../proposals/rfc_011_cockpit_control_surface.md` — control surface (chat + AI agent + 4-zone tabbed layout + canvas modes + 3D viewer)
- `../design.md` D22 / D27 / D28 / D29 / D30 / D31 / D32..D40 — decision audit trail
- `../AGENTS.tape` `@D g_cockpit_isolation` / `g_swift_native` / `g_ai_agent_*` — governance
