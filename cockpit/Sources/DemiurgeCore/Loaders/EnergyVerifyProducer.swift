// EnergyVerifyProducer — θ-2 engine tool for `energy + verify` (ROI 12).
// OpenMC k-eff criticality via kernels/mc_transport/ (D72 3rd consumer).
// g3: GATE_OPEN / absorbed=false; install + data gated.
//
// D80 / D94 / T7 — Producer ↦ PilotLoader.find(id:) auto-lookup.
// energy+verify's primary hexa-native pilot is the solar kernel
// (stdlib/kernels/solar/solar_kernel.hexa, 21/21 PASS rel_err<=1e-13
// vs pvlib 0.13.0 — the cell's solar-clearsky path). The k-eff
// Monte-Carlo path itself leaves the ref nil (mc_slab_demo.hexa is
// pattern-proof only, NOT a k-eff OpenMC replacement — see
// EnergyVerifyRecord.swift header for the rationale). The python
// script `openmc_keff.py` writes the JSON record; this Swift
// producer post-processes the JSON to inject `hexa_native_parity`
// from PILOTS.demi (D86 g_no_hardcoded_data — Swift owns the wire,
// data lives in .demi).

import Foundation

public struct EnergyVerifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum EnergyVerifyProducer {
    public static let verifyRecordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("energy/verify", isDirectory: true)

    public static func runVerify() -> EnergyVerifyResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/energy/openmc_keff.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return EnergyVerifyResult(ok: false,
                lines: ["openmc_keff.py substrate missing at \(scriptPath)"],
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
            return EnergyVerifyResult(ok: false,
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
            if injectHexaNativeParity(into: url, pilotId: "pilot-solar") {
                injected += 1
            }
        }
        let recordID = jsons.first?.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        var tail = ["[energy+verify] record dir: \(outDir.path)",
                    "GATE_OPEN / absorbed=false (g3)"]
        if injected > 0 {
            tail.append("hexa_native_parity ↩ pilot-solar (injected \(injected) record)")
        }
        return EnergyVerifyResult(ok: proc.terminationStatus == 0,
            lines: lines + tail,
            newRecordID: recordID)
    }

    /// D80 / D94 / T7 — read a python-written JSON record, decode as
    /// `EnergyVerifyRecord`, inject the `hexa_native_parity` field
    /// from `PilotLoader.parityRef(forId:)`, write back. Returns true
    /// if a row was injected; false otherwise (no pilot row, decode
    /// failure, etc. — D80 honesty: silent no-op on absence, never
    /// invents data).
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
