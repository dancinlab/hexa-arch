// HexaNativeParityChip — cockpit chip for cell-record
// `hexaNativeParity: HexaNativeParityRef?` (D99).
//
// Renders one of three branches via `HexaNativeParityChipModel`
// (DemiurgeCore, D99):
//   1. ref == nil                  → gray   "no hexa-native"
//   2. ref.isHexaNativeAbsorbed    → green  "hexa-native \u{2713} <SHA>"
//   3. ref present, not absorbed   → yellow "hexa-native (provisional)"
//
// D86 정합 (render-only, no data SSOT): the chip is a pure projection of
// `HexaNativeParityRef?` + `isHexaNativeAbsorbed` (D95). The 3-case
// label/color logic lives in `HexaNativeParityChipModel` (DemiurgeCore,
// SwiftUI-free) so the cockpit-side test target can branch-test it.
//
// D80 honesty: "present but not absorbed" paints yellow (provisional),
// NOT green — so an analyst cannot mistake a ref-attached-but-unverified
// kernel for one that has passed parity.

import SwiftUI
import DemiurgeCore

struct HexaNativeParityChip: View {
    let ref: HexaNativeParityRef?

    /// Compact form for dense rows (SkippedCellRow). Default = true.
    var compact: Bool = true

    private var model: HexaNativeParityChipModel {
        HexaNativeParityChipModel.from(ref)
    }

    var body: some View {
        let m = model
        Text(m.label)
            .font(.caption2.monospaced())
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(background(for: m.tone))
            .foregroundStyle(foreground(for: m.tone))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(stroke(for: m.tone), lineWidth: 0.5)
            )
            .cornerRadius(3)
            .help(m.tooltip)
            .accessibilityIdentifier(m.accessibilityID)
            .accessibilityLabel(Text(m.label))
            .accessibilityHint(Text(m.tooltip))
    }

    // MARK: — tone → SwiftUI Color (kept in the view, not the model)

    private func background(for tone: HexaNativeParityChipModel.Tone)
        -> Color
    {
        switch tone {
        case .absent:      return Color.gray.opacity(0.18)
        case .absorbed:    return Color.green.opacity(0.20)
        case .provisional: return Color.yellow.opacity(0.22)
        }
    }

    private func foreground(for tone: HexaNativeParityChipModel.Tone)
        -> Color
    {
        switch tone {
        case .absent:      return .secondary
        case .absorbed:    return .green
        case .provisional: return .orange
        }
    }

    private func stroke(for tone: HexaNativeParityChipModel.Tone)
        -> Color
    {
        switch tone {
        case .absent:      return Color.gray.opacity(0.30)
        case .absorbed:    return Color.green.opacity(0.45)
        case .provisional: return Color.yellow.opacity(0.50)
        }
    }
}
