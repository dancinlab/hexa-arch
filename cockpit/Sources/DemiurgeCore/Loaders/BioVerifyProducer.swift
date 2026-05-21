// BioVerifyProducer — θ-2 engine tool for `bio + verify`
// (D74 cohort, scan-only consumer for anima-physics bridge records).
//
// Producer (substrate side) = anima-physics
// hippocampus + memristor composite via
// `anima/anima-physics/tool/demiurge_bio_bridge.py`. Anima drops records
// at exports/bio/verify/<UTC>Z/anima_bio_*.json; demiurge witnesses.
//
// D17 / g_stdlib_ownership: anima-physics owns producer, demiurge consumer-only.
// HONEST (g3): GATE_OPEN / absorbed=false ALWAYS — hippocampus + memristor
// composite is hexa-lang reference sim NOT wet-lab; bio oracle parity TODO.

import Foundation

public struct BioVerifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum BioVerifyProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent(
            "bio/verify", isDirectory: true)

    public static func runVerify() -> BioVerifyResult {
        let fm = FileManager.default
        var lines: [String] = []
        lines.append("[bio+verify] scanning \(recordsRoot.path)")

        guard fm.fileExists(atPath: recordsRoot.path) else {
            lines.append("⏳ engine tool gap — exports/bio/verify/ 미존재. "
                + "anima-physics bridge "
                + "(anima-physics/tool/demiurge_bio_bridge.py) "
                + "가 record 를 dropping 했어야 함 (g3 — silent success 금지).")
            return BioVerifyResult(ok: false, lines: lines, newRecordID: nil)
        }

        var recordPaths: [URL] = []
        if let stamps = try? fm.contentsOfDirectory(at: recordsRoot,
                includingPropertiesForKeys: nil) {
            for stamp in stamps where stamp.hasDirectoryPath {
                if let kids = try? fm.contentsOfDirectory(at: stamp,
                        includingPropertiesForKeys: nil) {
                    for k in kids where k.pathExtension == "json" {
                        let name = k.lastPathComponent
                        if name.hasPrefix("anima_") || name.hasPrefix("bio_verify_") {
                            recordPaths.append(k)
                        }
                    }
                }
            }
        }

        if recordPaths.isEmpty {
            lines.append("⏳ engine tool gap — exports/bio/verify/<UTC>Z/ 안에 "
                + "anima_*.json / bio_verify_*.json record 0건. anima-physics "
                + "bridge 가 아직 한 번도 fire 되지 않은 상태 (g3).")
            return BioVerifyResult(ok: false, lines: lines, newRecordID: nil)
        }

        recordPaths.sort { $0.path < $1.path }
        let latest = recordPaths.last!

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
        lines.append("⏳ \(verdictGate) · absorbed=\(absorbed) — bio producer "
            + "oracle parity TODO (per record scope_caveats); demiurge 가 "
            + "측정한 게 아니라 anima bridge 결과를 witness 했을 뿐 (g3).")
        lines.append("📸 record → \(latest.path)")

        return BioVerifyResult(ok: true, lines: lines, newRecordID: recordId)
    }
}
