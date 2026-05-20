// FirmwareSynthesizeProducer — θ-2 engine tool for `firmware + synthesize`
// (D73, 16th domain). Spawns ~/core/hexa-lang/stdlib/firmware/synthesize.py
// for arm-none-eabi-gcc Cortex-M3 cross-compile of hello.c → ELF + bin.
// g3: GATE_OPEN / absorbed=false; gcc missing → install-gated skip.

import Foundation

public struct FirmwareSynthesizeResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok; self.lines = lines; self.newRecordID = newRecordID
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum FirmwareSynthesizeProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("firmware/synthesize", isDirectory: true)

    public static func runSynthesize() -> FirmwareSynthesizeResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/firmware/synthesize.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return FirmwareSynthesizeResult(ok: false,
                lines: ["synthesize.py substrate missing at \(scriptPath)"],
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
            return FirmwareSynthesizeResult(ok: false,
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
                && $0.lastPathComponent.hasPrefix("firmware_synthesize_")
            } ?? []
        let recordID = jsons.first?.lastPathComponent.replacingOccurrences(of: ".json", with: "")
        return FirmwareSynthesizeResult(ok: proc.terminationStatus == 0,
            lines: lines + ["[firmware+synthesize] record dir: \(outDir.path)",
                            "GATE_OPEN / absorbed=false (g3)"],
            newRecordID: recordID)
    }
}
