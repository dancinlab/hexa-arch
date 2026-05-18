// Demiurge cockpit — entry point.
// rfc_009 macOS Swift cockpit · D22 design · D27 monorepo · D28 SwiftPM
// · D29 first slice (F1F2 viewer + ProvenanceBanner)
// · D30 NSOpenPanel file picker restricted to ../exports/**.
//
// Honesty-as-feature (rfc_009 §4): renders producer provenance VERBATIM,
// never upgrades a claim, REJECTED card on parse/path failure.
//
// D30 added: NSOpenPanel toolbar action with directoryURL pinned to the
// F1F2 records dir; Loader runtime-enforces @D g_cockpit_isolation (a).

import SwiftUI
import AppKit
import UniformTypeIdentifiers

@main
struct CockpitApp: App {
    var body: some Scene {
        WindowGroup("Demiurge Cockpit") {
            ContentView()
        }
    }
}

struct ContentView: View {
    /// First-slice default record (D29). Relative to the cockpit/ package
    /// dir (SwiftPM `swift run` sets pwd to package root). Used on launch
    /// before the user picks a different record via D30's toolbar.
    private static let firstSliceRecord =
        "../exports/chip/noc/f1f2/records/2026-05-18_d8_king_tornado_7nm_1ghz.json"

    @State private var result: Result<F1F2Record, RecordLoaderError>?
    @State private var currentDisplayPath: String = firstSliceRecord

    var body: some View {
        Group {
            if let result {
                RecordView(result: result)
            } else {
                ProgressView("loading record …")
            }
        }
        .frame(minWidth: 720, minHeight: 560)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Open Record…") { presentPicker() }
                    .help("Open an F1F2 JSON record from ../exports/**")
            }
            ToolbarItem(placement: .navigation) {
                Text(currentDisplayPath)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .onAppear {
            self.result = RecordLoader.load(relativePath: Self.firstSliceRecord)
        }
    }

    /// NSOpenPanel pinned to `RecordLoader.f1f2RecordsRoot`. The picker is
    /// the canonical Apple way to choose a file; the Loader still runtime-
    /// validates (`g_cockpit_isolation a`) so even if the user navigates
    /// out of the default directory, paths outside `../exports/**` are
    /// rejected with a visible error card.
    private func presentPicker() {
        let panel = NSOpenPanel()
        panel.title = "Open F1F2 record"
        panel.message = "Select a record under ../exports/** (typed-consumer scope, @D g_cockpit_isolation)."
        panel.directoryURL = RecordLoader.f1f2RecordsRoot
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        self.currentDisplayPath = url.path
        self.result = RecordLoader.load(url: url)
    }
}
