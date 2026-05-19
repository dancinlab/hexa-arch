// ProvenanceBanner — rfc_009 §4 honesty-as-feature, the cockpit's
// differentiator. Renders rfc_002 §4 provenance fields VERBATIM, never
// upgrading a claim. The visible gate color + absorbed flag IS the contract
// the cockpit makes with the user: "what you see is what was measured."
//
// Color semantics — derived from the gate state, NOT chosen by the app:
//   GATE_OPEN              -> orange (no claim, treat as scaffold)
//   GATE_B_PINNED_MET      -> blue   (partial — pinned only, full not done)
//   GATE_CLOSED_MEASURED   -> green  (full parity measured)
//   GATE_FAILED            -> red    (explicit failure)
//   absorbed=true          -> tint reinforced
//   absorbed=false         -> tint muted (default shape — see CHARTER)
//
// Apple-canonical (D26 g_swift_native): SwiftUI tokens (.orange/.green/...),
// `LabeledContent` / `GroupBox`, system fonts. No custom Color literals.

import SwiftUI
import DemiurgeCore

struct ProvenanceBanner: View {
    let provenance: F1F2Record.Provenance

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                gateRow
                Divider()
                LabeledContent("engine",   value: provenance.simEngine)
                LabeledContent("commit",   value: String(provenance.simCommitHash.prefix(12)))
                LabeledContent("consumer", value: provenance.consumerTarget)
                LabeledContent("atlas",    value: provenance.atlasCiteBlock)
                if !provenance.gateFailures.isEmpty {
                    Divider()
                    Text("gate failures (\(provenance.gateFailures.count))")
                        .font(.caption).foregroundColor(.red)
                    ForEach(provenance.gateFailures, id: \.self) { f in
                        Text("• \(f)").font(.callout).foregroundColor(.red)
                    }
                }
                if !provenance.scopeCaveats.isEmpty {
                    Divider()
                    Text("scope caveats (\(provenance.scopeCaveats.count))")
                        .font(.caption).foregroundColor(.secondary)
                    ForEach(provenance.scopeCaveats, id: \.self) { c in
                        Text("• \(c)")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(8)
        } label: {
            Text("provenance (verbatim · rfc_002 §4)")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(tint, lineWidth: 1)
        )
    }

    private var gateRow: some View {
        HStack(spacing: 10) {
            Circle().fill(tint).frame(width: 12, height: 12)
            Text(provenance.measurementGate.displayLabel)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(tint)
            Spacer()
            Text("absorbed: \(provenance.absorbed ? "true" : "false")")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(provenance.absorbed ? .green : .secondary)
        }
    }

    private var tint: Color {
        switch provenance.measurementGate {
        case .open:             return .orange
        case .bPinnedMet:       return .blue
        case .closedMeasured:   return .green
        case .failed:           return .red
        }
    }
}
