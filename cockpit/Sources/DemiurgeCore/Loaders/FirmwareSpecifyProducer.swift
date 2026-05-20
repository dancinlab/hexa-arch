// FirmwareSpecifyProducer — θ-2 engine tool for `firmware + specify`
// (D73, 16th domain). Spawns ~/core/hexa-lang/stdlib/firmware/specify.py
// and witnesses the requirements.json template emit. g3: GATE_OPEN /
// absorbed=false (template skeleton, never an absorption claim).

import Foundation

public struct FirmwareSpecifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum FirmwareSpecifyProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("firmware/specify", isDirectory: true)

    public static func runSpecify() -> FirmwareSpecifyResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/firmware/specify.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return FirmwareSpecifyResult(ok: false,
                lines: ["specify.py substrate missing at \(scriptPath)"],
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
            return FirmwareSpecifyResult(ok: false,
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
                && $0.lastPathComponent.hasPrefix("firmware_specify_")
            } ?? []
        let recordID = jsons.first?.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        return FirmwareSpecifyResult(ok: proc.terminationStatus == 0,
            lines: lines + ["[firmware+specify] record dir: \(outDir.path)",
                            "GATE_OPEN / absorbed=false (g3)"],
            newRecordID: recordID)
    }
}
