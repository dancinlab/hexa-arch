// FirmwareVerifyProducer — θ-2 engine tool for `firmware + verify`
// (D73, 16th domain). Spawns ~/core/hexa-lang/stdlib/firmware/verify.py
// for QEMU mps2-an385 (Cortex-M3) boot smoke test of the synthesize bin.
// g3: GATE_OPEN / absorbed=false; qemu-system-arm missing → skip.

import Foundation

public struct FirmwareVerifyResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    /// All record IDs cited by this run: canonical first (if any), then
    /// foreign bridge records (anima_*, etc.) found via scan-foreign.
    public let newRecordIDs: [String]
    public init(ok: Bool, lines: [String], newRecordIDs: [String]) {
        self.ok = ok; self.lines = lines; self.newRecordIDs = newRecordIDs
    }
    /// Backward-compat: first cited record (canonical when present).
    public var newRecordID: String? { newRecordIDs.first }
    public var text: String { lines.joined(separator: "\n") }
}

public enum FirmwareVerifyProducer {
    public static let recordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("firmware/verify", isDirectory: true)

    /// scan-foreign: foreign record prefixes the consumer auto-cites
    /// alongside canonical `firmware_verify_*` records. Add new bridge
    /// substrates here (e.g. hexa-aura_, hexa-sense_) — single point of
    /// extension.
    public static let foreignRecordPrefixes: [String] = [
        "anima_",       // anima-side bridge records (HEXAD physics, etc.)
        // future: "hexa-aura_", "hexa-sense_", ...
    ]

    public static func runVerify() -> FirmwareVerifyResult {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let scriptPath = "\(home)/core/hexa-lang/stdlib/firmware/verify.py"
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            return FirmwareVerifyResult(ok: false,
                lines: ["verify.py substrate missing at \(scriptPath)"],
                newRecordIDs: [])
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
            return FirmwareVerifyResult(ok: false,
                lines: ["spawn failed: \(error.localizedDescription)"],
                newRecordIDs: [])
        }
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        var lines = out.split(separator: "\n").map(String.init)

        // Canonical record: the python script just wrote firmware_verify_*.json
        // into outDir (this run's stamped dir).
        let canonical = scanCanonicalRecords(in: outDir)

        // scan-foreign: look across ALL timestamped dirs under recordsRoot
        // for bridge records (anima_* etc.) — anima-side producers may have
        // dropped records into sibling stamped dirs that the cockpit
        // consumer should auto-cite. Deduped + sorted for deterministic
        // output (D26 g_swift_native).
        let foreign = scanForeignRecords(under: recordsRoot)

        if !foreign.isEmpty {
            lines.append("[firmware+verify] scan-foreign cited \(foreign.count) "
                + "bridge record(s): "
                + foreign.joined(separator: ", "))
        }

        let cited = canonical + foreign
        return FirmwareVerifyResult(ok: proc.terminationStatus == 0,
            lines: lines + ["[firmware+verify] record dir: \(outDir.path)",
                            "GATE_OPEN / absorbed=false (g3)"],
            newRecordIDs: cited)
    }

    /// Canonical `firmware_verify_*` records inside the freshly-produced
    /// run dir.
    private static func scanCanonicalRecords(in runDir: URL) -> [String] {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: runDir, includingPropertiesForKeys: nil)) ?? []
        return urls.compactMap { url -> String? in
            let name = url.lastPathComponent
            guard url.pathExtension == "json",
                  name.hasPrefix("firmware_verify_") else { return nil }
            return String(name.dropLast(".json".count))
        }.sorted()
    }

    /// Foreign bridge records (any timestamp dir under `root`) — single
    /// shallow walk: `root/<stamp>/<prefix>*.json`.
    private static func scanForeignRecords(under root: URL) -> [String] {
        let fm = FileManager.default
        guard let stampDirs = try? fm.contentsOfDirectory(
                at: root, includingPropertiesForKeys: [.isDirectoryKey])
        else { return [] }
        var ids: [String] = []
        for stampDir in stampDirs {
            let isDir = (try? stampDir.resourceValues(forKeys: [.isDirectoryKey]))?
                .isDirectory ?? false
            guard isDir,
                  let files = try? fm.contentsOfDirectory(
                    at: stampDir, includingPropertiesForKeys: nil)
            else { continue }
            for url in files {
                let name = url.lastPathComponent
                guard url.pathExtension == "json" else { continue }
                if foreignRecordPrefixes.contains(where: { name.hasPrefix($0) }) {
                    ids.append(String(name.dropLast(".json".count)))
                }
            }
        }
        return Array(Set(ids)).sorted()
    }
}
