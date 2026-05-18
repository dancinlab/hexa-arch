// Demiurge cockpit — entry point.
// rfc_009 macOS Swift cockpit · D22 design · D27 monorepo · D28 SwiftPM
// · D29 first slice: F1F2 record viewer + provenance banner.
//
// Honesty-as-feature (rfc_009 §4): this app renders producer provenance
// VERBATIM; it never upgrades a claim. Missing provenance -> REJECTED.
//
// D29 first-slice scope (intentionally narrow):
//   - load ONE hardcoded F1F2 record path (file picker = next slice)
//   - render record header + topology summary + verdict + ProvenanceBanner
//   - on any load/decode failure, render the REJECTED card

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
    /// First-slice fixed record (D29). Relative to the cockpit/ package dir
    /// (SwiftPM `swift run` sets pwd to the package root). Future slices
    /// will replace this with a file picker bound to ../exports/**.
    private static let firstSliceRecord =
        "../exports/chip/noc/f1f2/records/2026-05-18_d8_king_tornado_7nm_1ghz.json"

    @State private var result: Result<F1F2Record, RecordLoaderError>?

    var body: some View {
        Group {
            if let result {
                RecordView(result: result)
            } else {
                ProgressView("loading record …")
            }
        }
        .frame(minWidth: 720, minHeight: 560)
        .onAppear {
            self.result = RecordLoader.load(relativePath: Self.firstSliceRecord)
        }
    }
}
