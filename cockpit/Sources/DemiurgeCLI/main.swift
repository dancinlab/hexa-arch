// DemiurgeCLI — phase α-3 minimum read-only scaffold (rfc_011 §10 / D34 / D38).
//
// Subcommands (v0, read-only):
//   demiurge --version | -v           Print version banner
//   demiurge --help    | -h           This help
//   demiurge list-records             List F1F2 records under ../exports/
//   demiurge show <path>              Show one record (path relative to pwd
//                                     under ../exports/** per invariant a)
//
// Action subcommands (rfc_011 §6, Phase θ — NOT here yet):
//   demiurge synth   <args>           AI-agent dispatch via Claude Code CLI
//   demiurge measure <args>           ↑
//   demiurge verify  <args>           ↑
//   demiurge analyze <args>           ↑
//
// All subcommands respect @D g_cockpit_isolation invariant (a): inputs that
// resolve outside ../exports/** are rejected with the same error path used
// by the GUI (RecordLoaderError.pathOutsideExports).
//
// Build: cd cockpit && swift build
// Run:   swift run DemiurgeCLI <subcommand> [args…]

import Foundation
import DemiurgeCore

let version = "0.0.1 (phase α-3, read-only — rfc_011 §10)"

func usage() {
    print("""
    demiurge — Demiurge cockpit CLI (read-only)

    USAGE:
      demiurge list-records           List F1F2 records under ../exports/
      demiurge show <path>            Show one record (relative path)
      demiurge --version              Print version
      demiurge --help                 This help

    NOTES:
      - Reads ONLY ../exports/** (@D g_cockpit_isolation invariant a).
      - Action subcommands (synth / measure / verify / analyze) land in
        Phase θ via Claude Code CLI dispatch (D34 / D38 / @D
        g_ai_agent_action_surface).
    """)
}

func printVersion() {
    print("demiurge \(version)")
}

func listRecords() -> Int32 {
    let root = RecordLoader.f1f2RecordsRoot
    let fm = FileManager.default
    var isDir: ObjCBool = false
    guard fm.fileExists(atPath: root.path, isDirectory: &isDir), isDir.boolValue else {
        FileHandle.standardError.write(Data("list-records: directory not found: \(root.path)\n".utf8))
        return 2
    }
    let urls: [URL]
    do {
        urls = try fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)
    } catch {
        FileHandle.standardError.write(Data("list-records: \(error.localizedDescription)\n".utf8))
        return 2
    }
    let jsonFiles = urls
        .filter { $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    print("F1F2 records (\(jsonFiles.count)) at \(root.path):")
    for f in jsonFiles {
        print("  \(f.lastPathComponent)")
    }
    return 0
}

func show(_ path: String) -> Int32 {
    let result = RecordLoader.load(relativePath: path)
    switch result {
    case .failure(let e):
        FileHandle.standardError.write(Data("show: \(e.errorDescription ?? "unknown error")\n".utf8))
        return 2
    case .success(let r):
        print("record_id:                  \(r.recordId)")
        print("interface:                  \(r.interface)")
        print("schema_version:             \(r.schemaVersion)")
        print("produced_at_utc:            \(r.producedAtUtc)")
        print("topology.kind:              \(r.topology.kind)")
        print("topology.degree:            \(r.topology.degree)")
        print("topology.node_count:        \(r.topology.nodeCount)")
        print("topology.routing:           \(r.topology.routing)")
        print("traffic:                    \(r.traffic)")
        print("verdict.f1:                 \(r.verdict.f1)")
        print("verdict.f2:                 \(r.verdict.f2)")
        print("verdict.rationale:          \(r.verdict.rationale)")
        print("provenance.measurement_gate:\(r.provenance.measurementGate.displayLabel)")
        print("provenance.absorbed:        \(r.provenance.absorbed)")
        print("provenance.sim_engine:      \(r.provenance.simEngine)")
        print("provenance.sim_commit:      \(String(r.provenance.simCommitHash.prefix(12)))")
        print("provenance.consumer_target: \(r.provenance.consumerTarget)")
        print("provenance.atlas_cite:      \(r.provenance.atlasCiteBlock)")
        print("provenance.gate_failures:   \(r.provenance.gateFailures.count)")
        for (i, gf) in r.provenance.gateFailures.enumerated() {
            print("  [\(i)] \(gf)")
        }
        print("provenance.scope_caveats:   \(r.provenance.scopeCaveats.count)")
        for (i, c) in r.provenance.scopeCaveats.enumerated() {
            print("  [\(i)] \(c)")
        }
        return 0
    }
}

let args = CommandLine.arguments

guard args.count >= 2 else {
    usage()
    exit(0)
}

let exitCode: Int32
switch args[1] {
case "--version", "-v":
    printVersion()
    exitCode = 0
case "--help", "-h":
    usage()
    exitCode = 0
case "list-records":
    exitCode = listRecords()
case "show":
    guard args.count >= 3 else {
        FileHandle.standardError.write(Data("show: missing <path> argument\n".utf8))
        usage()
        exit(2)
    }
    exitCode = show(args[2])
default:
    FileHandle.standardError.write(Data("unknown subcommand: \(args[1])\n".utf8))
    usage()
    exit(2)
}

exit(exitCode)
