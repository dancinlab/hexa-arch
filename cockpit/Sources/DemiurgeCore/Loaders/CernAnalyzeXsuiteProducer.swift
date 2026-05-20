// CernAnalyzeXsuiteProducer — alternative producer for `cern + analyze`.
// Spawns `~/core/hexa-lang/stdlib/cern/elegant_tracking.py` (Xsuite
// 100-turn FODO tracking, real physics). Selected via
// ProducerRegistry; CLI flag `--producer xsuite-tracking` or default.
//
// D61: substrate SSOT in hexa-lang/stdlib/, demiurge witnesses only.
// D72: accelerator-optics single-domain; kernels/accelerator_optics/
//      promotion at 2nd consumer.
// g3:  GATE_OPEN / absorbed=false; install-gated skip on Xsuite
//      ImportError. Distinct from the pylhe round-trip producer
//      (synthetic LHE parser test) — this one runs actual particle
//      tracking on a toy FODO cell.

import Foundation

public struct CernAnalyzeXsuiteResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum CernAnalyzeXsuiteProducer {

    public static let analyzeRecordsRoot: URL =
        RecordLoader.exportsRoot
            .appendingPathComponent("cern/analyze/xsuite", isDirectory: true)

    public static func runAnalyze() -> CernAnalyzeXsuiteResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/cern/elegant_tracking.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return CernAnalyzeXsuiteResult(
                ok: false,
                lines: ["elegant_tracking.py substrate missing at \(scriptPath)"],
                newRecordID: nil)
        }
        let stamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let outDir = analyzeRecordsRoot.appendingPathComponent(stamp)
        try? FileManager.default.createDirectory(
            at: outDir, withIntermediateDirectories: true)
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["python3", scriptPath, outDir.path]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        do { try proc.run() } catch {
            return CernAnalyzeXsuiteResult(
                ok: false,
                lines: ["spawn failed: \(error.localizedDescription)"],
                newRecordID: nil)
        }
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        let lines = out.split(separator: "\n").map(String.init)
        let jsons = (try? FileManager.default.contentsOfDirectory(
            at: outDir, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension == "json" } ?? []
        let recordID = jsons.first?.lastPathComponent
            .replacingOccurrences(of: ".json", with: "")
        return CernAnalyzeXsuiteResult(
            ok: proc.terminationStatus == 0,
            lines: lines + [
                "[cern+analyze · xsuite-tracking] record dir: \(outDir.path)",
                "GATE_OPEN / absorbed=false (g3)",
            ],
            newRecordID: recordID)
    }
}
