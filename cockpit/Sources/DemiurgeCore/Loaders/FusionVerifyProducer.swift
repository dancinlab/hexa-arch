// FusionVerifyProducer — θ-2 engine tool for `fusion + verify` (ROI 11).
// OpenMC TBR neutronics via kernels/mc_transport/ (D72 2nd consumer).
// g3: GATE_OPEN / absorbed=false; install + data gated.
//
// D80 / D94 / T7 — Producer ↦ PilotLoader.find(id:) auto-lookup.
// fusion+verify's primary hexa-native pilot is the mc_transport
// kernel (stdlib/kernels/mc_transport/mc_slab_demo.hexa) — the
// MC pattern-proof (Beer-Lambert + bit-identical python companion
// at same LCG seed). The pilot is ALWAYS provisional for this cell
// (illustrative single-energy-group MC, NOT a Li-blanket TBR
// replacement — see FusionVerifyRecord.swift header). The python
// script `openmc_tbr.py` writes the JSON record; this Swift
// producer post-processes the JSON to inject `hexa_native_parity`
// from PILOTS.demi (D86 g_no_hardcoded_data — Swift owns the wire,
// data lives in .demi).

import Foundation

public struct FusionVerifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum FusionVerifyProducer {
    public static let verifyRecordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("fusion/verify", isDirectory: true)

    public static func runVerify() -> FusionVerifyResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/fusion/openmc_tbr.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return FusionVerifyResult(ok: false,
                lines: ["openmc_tbr.py substrate missing at \(scriptPath)"],
                newRecordID: nil)
        }
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let outDir = verifyRecordsRoot.appendingPathComponent(stamp)
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["python3", scriptPath, outDir.path]
        let pipe = Pipe()
        proc.standardOutput = pipe; proc.standardError = pipe
        do { try proc.run() } catch {
            return FusionVerifyResult(ok: false,
                lines: ["spawn failed: \(error.localizedDescription)"],
                newRecordID: nil)
        }
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        let lines = out.split(separator: "\n").map(String.init)
        let jsons = (try? FileManager.default.contentsOfDirectory(at: outDir,
            includingPropertiesForKeys: nil))?.filter { $0.pathExtension == "json" } ?? []
        // D80 / D94 / T7 — inject hexa_native_parity into the JSON
        // record(s) written by the python script. nil-on-absent is
        // honest (PILOTS.demi missing → no inject → record unchanged).
        var injected = 0
        for url in jsons {
            if injectHexaNativeParity(into: url, pilotId: "pilot-mc_transport") {
                injected += 1
            }
        }
        let recordID = jsons.first?.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        var tail = ["[fusion+verify] record dir: \(outDir.path)",
                    "GATE_OPEN / absorbed=false (g3)"]
        if injected > 0 {
            tail.append("hexa_native_parity ↩ pilot-mc_transport (injected \(injected) record)")
        }
        return FusionVerifyResult(ok: proc.terminationStatus == 0,
            lines: lines + tail,
            newRecordID: recordID)
    }

    /// D80 / D94 / T7 — read a python-written JSON record, inject the
    /// `hexa_native_parity` field from `PilotLoader.parityRef(forId:)`,
    /// write back. Returns true if a row was injected; false otherwise
    /// (no pilot row, decode failure, etc. — D80 honesty: silent no-op
    /// on absence, never invents data).
    static func injectHexaNativeParity(into url: URL,
                                       pilotId: String) -> Bool {
        guard let parity = PilotLoader.parityRef(forId: pilotId) else {
            return false
        }
        guard let data = try? Data(contentsOf: url),
              var dict = try? JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else { return false }
        let enc = JSONEncoder()
        enc.outputFormatting = [.sortedKeys]
        guard let pData = try? enc.encode(parity),
              let pObj = try? JSONSerialization.jsonObject(with: pData)
        else { return false }
        dict["hexa_native_parity"] = pObj
        guard let outData = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys])
        else { return false }
        return (try? outData.write(to: url)) != nil
    }
}
