// swift-tools-version: 5.9
// Demiurge cockpit — rfc_009 macOS Swift cockpit
// design.md D22 (spec) · D27 (monorepo placement) · D28 (SwiftPM bootstrap)
//
// Logical-boundary invariants — AGENTS.tape @D g_cockpit_isolation:
//   (a) read ONLY ../exports/** (typed records, D2 interface)
//   (b) MUST NOT import hexa-lang/stdlib/* nor demiurge hexa-native core
//   (c) build artifacts in .gitignore
//   (d) edit-direction is one-way: cockpit reads exports, never reverse
//
// Build:  cd cockpit && swift build
// Run:    cd cockpit && swift run

import PackageDescription

let package = Package(
    name: "CockpitApp",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "CockpitApp",
            path: "Sources/CockpitApp"
        )
    ]
)
