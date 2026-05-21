// BrainVerifyProducer — θ-2 engine tool for `brain + verify`
// (D74 cohort, scan-only consumer for anima-physics bridge records).
//
// Architectural distinction from BrainAnalyzeProducer (BrainAnalyzeProducer.swift):
//   • BrainAnalyzeProducer SPAWNS `~/core/hexa-lang/stdlib/brain/lif_brian2.py`
//     (brian2 LIF single-neuron textbook firing-rate verification).
//   • BrainVerifyProducer SCANS exports/brain/verify/<UTC>Z/anima_*.json —
//     records that the anima-physics bridge
//     (`anima/anima-physics/hw/kuramoto_neuromorphic/src/demiurge_brain_bridge.py`)
//     has ALREADY dropped from the hexa-native kuramoto neuromorphic substrate
//     run. demiurge witnesses + aggregates, NEVER re-measures (g3).
//
// D17 / g_stdlib_ownership: hexa-lang (anima-physics) owns the producer,
// demiurge is consumer-only — no Python spawn here. The anima bridge is
// itself the producer; this Swift cell only enumerates dropped records.
//
// HONEST (g3 — non-negotiable):
//   • measurement_gate stays GATE_OPEN, absorbed=false ALWAYS. The
//     bridged kuramoto sim is reference numpy NOT silicon spike-event;
//     brain producer oracle parity not yet authored — the dropped record's
//     own provenance.scope_caveats already say so. demiurge witnesses.
//   • If no records exist under exports/brain/verify/, returns
//     ok=false / GATE_FAILED with the honest "no anima bridge record yet"
//     gap message. Silent success is forbidden.

import Foundation

public struct BrainVerifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum BrainVerifyProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent(
            "brain/verify", isDirectory: true)

    /// Scan `exports/brain/verify/<UTC>Z/anima_*.json` (or `brain_verify_*.json`),
    /// aggregate the latest record's verdict, return GATE_OPEN witness.
    public static func runVerify() -> BrainVerifyResult {
        let fm = FileManager.default
        var lines: [String] = []
        lines.append("[brain+verify] scanning \(recordsRoot.path)")

        guard fm.fileExists(atPath: recordsRoot.path) else {
            lines.append("⏳ engine tool gap — exports/brain/verify/ 미존재. "
                + "anima-physics bridge "
                + "(anima-physics/hw/kuramoto_neuromorphic/src/demiurge_brain_bridge.py) "
                + "가 record 를 dropping 했어야 함 (g3 — silent success 금지).")
            return BrainVerifyResult(ok: false, lines: lines, newRecordID: nil)
        }

        // Enumerate <UTC>Z/anima_*.json (or brain_verify_*.json).
        var recordPaths: [URL] = []
        if let stamps = try? fm.contentsOfDirectory(at: recordsRoot,
                includingPropertiesForKeys: nil) {
            for stamp in stamps where stamp.hasDirectoryPath {
                if let kids = try? fm.contentsOfDirectory(at: stamp,
                        includingPropertiesForKeys: nil) {
                    for k in kids where k.pathExtension == "json" {
                        let name = k.lastPathComponent
                        if name.hasPrefix("anima_") || name.hasPrefix("brain_verify_") {
                            recordPaths.append(k)
                        }
                    }
                }
            }
        }

        if recordPaths.isEmpty {
            lines.append("⏳ engine tool gap — exports/brain/verify/<UTC>Z/ 안에 "
                + "anima_*.json / brain_verify_*.json record 0건. anima-physics "
                + "bridge 가 아직 한 번도 fire 되지 않은 상태 (g3).")
            return BrainVerifyResult(ok: false, lines: lines, newRecordID: nil)
        }

        // Sort by lastPathComponent (timestamped) — latest last.
        recordPaths.sort { $0.path < $1.path }
        let latest = recordPaths.last!

        // Parse the latest record's verdict + provenance for the witness banner.
        var verdictGate = "GATE_OPEN"
        var absorbed = false
        var recordId: String? = nil
        var producer: String = "anima-physics-bridge"
        if let data = try? Data(contentsOf: latest),
           let obj = try? JSONSerialization.jsonObject(with: data)
               as? [String: Any] {
            if let v = obj["verdict"] as? [String: Any],
               let gs = v["gate_state"] as? String {
                verdictGate = gs
            }
            if let p = obj["provenance"] as? [String: Any] {
                if let a = p["absorbed"] as? Bool { absorbed = a }
                if let s = p["producer"] as? String { producer = s }
            }
            if let rid = obj["record_id"] as? String { recordId = rid }
        }

        lines.append("scanned \(recordPaths.count) anima bridge record(s); "
            + "latest = \(latest.lastPathComponent)")
        lines.append("producer = \(producer) (anima-physics owns substrate; "
            + "demiurge witnesses)")
        lines.append("⏳ \(verdictGate) · absorbed=\(absorbed) — brain producer "
            + "oracle parity TODO (per record scope_caveats); demiurge 가 "
            + "측정한 게 아니라 anima bridge 결과를 witness 했을 뿐 (g3).")
        lines.append("📸 record → \(latest.path)")

        return BrainVerifyResult(ok: true, lines: lines, newRecordID: recordId)
    }
}
