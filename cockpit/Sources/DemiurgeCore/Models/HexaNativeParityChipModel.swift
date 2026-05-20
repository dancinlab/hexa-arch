// HexaNativeParityChipModel — pure-data render model for the cockpit
// `HexaNativeParityChip` SwiftUI view (D99).
//
// SwiftUI Views live in the CockpitApp target, but the 3-case branch
// (nil / absorbed / provisional) is pure logic over a
// `HexaNativeParityRef?` — so DemiurgeCore exposes the decision as
// data (`HexaNativeParityChipModel`) and the SwiftUI view paints it.
// This lets DemiurgeCoreTests exercise every text/color branch
// without pulling SwiftUI into the test target.
//
// D86 정합 (render-only, no data SSOT): the model carries NO state of
// its own — it is a pure projection of `HexaNativeParityRef?` +
// `HexaNativeParityRef.isHexaNativeAbsorbed`. Adding / removing /
// re-coloring chips never touches a `.demi` file.
//
// D80 honesty: "present but not absorbed" surfaces as a yellow
// "provisional" chip — not the green absorbed chip — so the analyst
// cannot mistake a planned-but-unverified kernel for one that has
// already passed parity.

import Foundation

/// Three-case chip render model for cell-record `hexaNativeParity`.
///
/// The cockpit's `HexaNativeParityChip` SwiftUI view paints this struct
/// directly: `label` is the visible chip text, `tone` selects the
/// background tint (mapped to SwiftUI `Color` in the view layer), and
/// `tooltip` is the on-hover detail (kernelPath / parityStatus when
/// available, or a one-line rationale when absent).
public struct HexaNativeParityChipModel: Equatable, Sendable {

    /// Visual tone — the chip view maps this to a concrete SwiftUI
    /// `Color` so DemiurgeCore stays SwiftUI-free.
    public enum Tone: String, Equatable, Sendable {
        /// `hexaNativeParity == nil` — no hexa-native port claimed.
        case absent       // → .gray
        /// `hexaNativeParity != nil` AND `isHexaNativeAbsorbed == true`.
        case absorbed     // → .green
        /// `hexaNativeParity != nil` AND `isHexaNativeAbsorbed == false`.
        case provisional  // → .yellow
    }

    public let tone: Tone
    public let label: String
    public let tooltip: String
    /// Stable accessibility identifier — also the SwiftUI
    /// `accessibilityIdentifier(...)` and the test-side branch key.
    public let accessibilityID: String

    public init(tone: Tone, label: String, tooltip: String,
                accessibilityID: String) {
        self.tone = tone
        self.label = label
        self.tooltip = tooltip
        self.accessibilityID = accessibilityID
    }

    /// Pure 3-case projection from a cell-record's optional parity ref
    /// to the chip render. The SwiftUI view calls this once per body
    /// render — no caching, no side effects.
    public static func from(_ ref: HexaNativeParityRef?)
        -> HexaNativeParityChipModel
    {
        guard let ref else {
            return HexaNativeParityChipModel(
                tone: .absent,
                label: "no hexa-native",
                tooltip: "이 cell record 에는 hexa-native parity ref "
                       + "가 첨부되지 않았습니다 (D80 — 첨부 = optional).",
                accessibilityID: "hexa-native-parity-chip.absent")
        }
        if ref.isHexaNativeAbsorbed {
            return HexaNativeParityChipModel(
                tone: .absorbed,
                label: "hexa-native \u{2713} \(shortSHA(ref.hexaLangSHA))",
                tooltip: "kernel: \(ref.kernelPath)\n"
                       + "parity: \(ref.parityStatus)\n"
                       + "hexa-lang SHA: \(ref.hexaLangSHA)",
                accessibilityID: "hexa-native-parity-chip.absorbed")
        }
        return HexaNativeParityChipModel(
            tone: .provisional,
            label: "hexa-native (provisional)",
            tooltip: "kernel: \(ref.kernelPath)\n"
                   + "parity: \(ref.parityStatus)\n"
                   + "hexa-lang SHA: \(ref.hexaLangSHA)\n"
                   + "(D80 honesty — parity 미통과: 흡수 아님)",
            accessibilityID: "hexa-native-parity-chip.provisional")
    }

    /// Short SHA prefix for chip labels — keeps the visible text
    /// compact while the full SHA stays in the tooltip.
    private static func shortSHA(_ sha: String) -> String {
        let trimmed = sha.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 8 { return trimmed }
        return String(trimmed.prefix(8))
    }
}
