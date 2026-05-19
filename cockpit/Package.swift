// swift-tools-version: 6.2
// Demiurge cockpit + CLI — rfc_009 / rfc_010 / rfc_011 product surface.
// design.md D22 (spec) · D27 (monorepo) · D28 (SwiftPM only) ·
// D34 (control surface = split, GUI 직접 + CLI = AI-agent surface) ·
// D38 (Claude Code CLI+API dual dispatch in chat) ·
// D40 (4-zone tabbed layout) ·
// Phase α-3 (this restructure) = library + two executables.
//
// Three targets:
//   DemiurgeCore  — library, the shared typed-interface consumer of
//                   ../exports/** (F1F2Record + RecordLoader). Pure
//                   Foundation; no SwiftUI / AppKit imports.
//   CockpitApp    — SwiftUI/AppKit macOS GUI executable; depends on
//                   DemiurgeCore. User-facing (D34).
//   DemiurgeCLI   — Foundation-only headless executable; depends on
//                   DemiurgeCore. AI-agent surface (D34/D38) — phase α-3
//                   lands minimum read-only subcommands; action
//                   subcommands (synth / measure / verify / analyze)
//                   land in phase θ via Claude Code CLI dispatch.
//
// Logical-boundary invariants — AGENTS.tape @D g_cockpit_isolation:
//   (a) read ONLY ../exports/** (typed records, D2 interface)
//   (b) MUST NOT import hexa-lang/stdlib/* nor demiurge hexa-native core
//   (c) build artifacts in .gitignore
//   (d) edit-direction is one-way: cockpit reads exports, never reverse
//
// Build:
//   cd cockpit && swift build
// Run:
//   swift run CockpitApp                  # GUI
//   swift run DemiurgeCLI --version       # CLI version
//   swift run DemiurgeCLI list-records    # CLI: list F1F2 records
//   swift run DemiurgeCLI show <path>     # CLI: dump one record

import PackageDescription

let package = Package(
    name: "Demiurge",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "DemiurgeCore",
            targets: ["DemiurgeCore"]
        ),
        .executable(
            name: "CockpitApp",
            targets: ["CockpitApp"]
        ),
        .executable(
            name: "DemiurgeCLI",
            targets: ["DemiurgeCLI"]
        )
    ],
    targets: [
        .target(
            name: "DemiurgeCore",
            path: "Sources/DemiurgeCore"
        ),
        .executableTarget(
            name: "CockpitApp",
            dependencies: ["DemiurgeCore"],
            path: "Sources/CockpitApp"
        ),
        .executableTarget(
            name: "DemiurgeCLI",
            dependencies: ["DemiurgeCore"],
            path: "Sources/DemiurgeCLI"
        )
    ]
)
