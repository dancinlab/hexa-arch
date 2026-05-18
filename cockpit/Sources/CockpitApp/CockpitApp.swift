// Demiurge cockpit — entry point.
// rfc_009 macOS Swift cockpit · D22 design · D27 monorepo · D28 SwiftPM
//
// Honesty-as-feature (rfc_009 §4): this app renders producer
// provenance VERBATIM (absorbed / measurement_gate / citations);
// it never upgrades a claim. Missing provenance -> red REJECTED card.
//
// D28 scaffold has NO features yet — D29 will pick the first slice.

import SwiftUI

@main
struct CockpitApp: App {
    var body: some Scene {
        WindowGroup("Demiurge Cockpit") {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Demiurge Cockpit")
                .font(.system(size: 32, weight: .light))
            Text("DRAFT — scaffold v0")
                .font(.callout)
                .foregroundColor(.secondary)
            Text("rfc_009 · D22 / D27 / D28 · no features yet (D29 picks first slice)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(minWidth: 640, minHeight: 400)
    }
}
