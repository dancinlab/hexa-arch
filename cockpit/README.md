# Demiurge cockpit

> macOS Swift cockpit for Demiurge — a read-only typed-consumer of
> `../exports/**` records. **rfc_009** product surface · **D22**
> design · **D27** monorepo placement · **D28** SwiftPM bootstrap.

## Status

Scaffold v0 (D28). **No features yet** — empty SwiftUI window. D29
(next gate) will pick the first slice (likely an F1F2 record viewer
with verbatim provenance / gate banner — honesty-as-feature per
`rfc_009` §4).

## Build / run

```
cd cockpit
swift build         # compile only
swift run           # build + launch the SwiftUI app
```

Requires Swift 5.9+ · macOS 13+. Xcode can open `Package.swift`
directly for full IDE (Previews / Instruments / debug).

## Boundary — `@D g_cockpit_isolation` (top-level AGENTS.tape)

This subdir is *logically outside* Demiurge's governance boundary
(rfc_009 §5). Four invariants enforce the boundary in a monorepo:

- **(a)** read ONLY `../exports/**` — typed records (D2 interface)
- **(b)** NO import of `hexa-lang/stdlib/*` or Demiurge's hexa-native
  core; cockpit is a pure SwiftUI / Foundation / AppKit consumer
- **(c)** build artifacts live in `.gitignore` — never enter records
  SSOT (`.build/`, `.swiftpm/`, `DerivedData/`, `*.xcodeproj/xcuserdata/`)
- **(d)** edit-direction is one-way — cockpit reads `exports/`,
  `exports/` never reads cockpit

## Native / canonical first — `@D g_swift_native`

Per **D26**: SwiftUI / Foundation / AppKit native idioms + Apple
canonical patterns FIRST. Third-party libraries / custom DSLs /
non-canonical structures require explicit per-PR justification —
they are not default.

## Reference

- `references/quiver-overview.png` — Palantir Foundry Quiver
  "Overview Analysis" GUI capture (2026-05-19, user-provided), kept
  as design inspiration for the honesty-as-feature UI.

## Cross-refs

- `../proposals/rfc_009_product_surface_macos_cockpit.md` — full spec
- `../design.md` D22 / D27 / D28 — decisions audit trail
- `../AGENTS.tape` `@D g_cockpit_isolation` · `@D g_swift_native`
