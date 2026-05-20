// FirmwareHandoffProducer — θ-2 engine tool for `firmware + handoff`
// (D73, 16th domain). Spawns ~/core/hexa-lang/stdlib/firmware/handoff.py
// for CycloneDX SBOM + release.tar.gz bundle + MCUboot imgtool probe.
// g3: GATE_OPEN / absorbed=false; imgtool missing → install-gated skip.

import Foundation

public struct FirmwareHandoffResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum FirmwareHandoffProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("firmware/handoff", isDirectory: true)

    public static func runHandoff() -> FirmwareHandoffResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/firmware/handoff.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return FirmwareHandoffResult(ok: false,
                lines: ["handoff.py substrate missing at \(scriptPath)"],
                newRecordID: nil)
        }
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let outDir = recordsRoot.appendingPathComponent(stamp)
        try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["python3", scriptPath, outDir.path]
        let pipe = Pipe()
        proc.standardOutput = pipe; proc.standardError = pipe
        do { try proc.run() } catch {
            return FirmwareHandoffResult(ok: false,
                lines: ["spawn failed: \(error.localizedDescription)"],
                newRecordID: nil)
        }
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        let lines = out.split(separator: "\n").map(String.init)
        let jsons = (try? FileManager.default.contentsOfDirectory(at: outDir,
            includingPropertiesForKeys: nil))?.filter {
                $0.pathExtension == "json"
                && $0.lastPathComponent.hasPrefix("firmware_handoff_")
            } ?? []
        let recordID = jsons.first?.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        return FirmwareHandoffResult(ok: proc.terminationStatus == 0,
            lines: lines + ["[firmware+handoff] record dir: \(outDir.path)",
                            "GATE_OPEN / absorbed=false (g3)"],
            newRecordID: recordID)
    }
}
