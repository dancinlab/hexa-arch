// RecordLoader — read a F1F2 JSON record from ../exports/** and decode it.
//
// Phase α-3 (rfc_011 §10): moved into DemiurgeCore so both CockpitApp (GUI)
// and DemiurgeCLI (headless) share one loader / one invariant check.
// All public members allow cross-module use.
//
// @D g_cockpit_isolation invariants enforced here:
//   (a) reads ONLY ../exports/** — `pathOutsideExports` error returned at
//       runtime if the caller (NSOpenPanel, CLI argv, …) hands us a URL
//       outside the exports/ subtree. Defense-in-depth on top of the
//       picker's `directoryURL = exportsRoot` default.
//   (b) no imports from hexa-lang/stdlib/* nor demiurge hexa-native core
//   (d) edit-direction one-way: cockpit reads exports, never the reverse
//
// Apple-canonical (D26 g_swift_native): Foundation's URL + Data + JSONDecoder
// with .convertFromSnakeCase. No third-party deps.

import Foundation

public enum RecordLoaderError: LocalizedError {
    case fileNotFound(path: String)
    case readFailed(path: String, underlying: Error)
    case decodeFailed(path: String, underlying: Error)
    case pathOutsideExports(path: String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let p):
            return "Record file not found: \(p)"
        case .readFailed(let p, let e):
            return "Read failed (\(p)): \(e.localizedDescription)"
        case .decodeFailed(let p, let e):
            return "Decode failed (\(p)): \(e.localizedDescription)"
        case .pathOutsideExports(let p):
            return "Refused (@D g_cockpit_isolation invariant a): path is outside ../exports/**: \(p)"
        }
    }
}

public enum RecordLoader {
    /// The exports directory the cockpit / CLI reads records from
    /// (@D g_cockpit_isolation a). Resolution order:
    ///   1. `$DEMIURGE_REPO/exports` if the env var is set — used by the
    ///      installed `/Applications/demiurge.app` (Info.plist LSEnvironment
    ///      bakes the repo path, since an installed app's cwd is not the
    ///      repo).
    ///   2. else `<cwd>/../exports` — the `swift run` case (pwd = cockpit/).
    public static let exportsRoot: URL = {
        let env = ProcessInfo.processInfo.environment
        if let repo = env["DEMIURGE_REPO"], !repo.isEmpty {
            return URL(fileURLWithPath: repo, isDirectory: true)
                .appendingPathComponent("exports").standardizedFileURL
        }
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath,
                      isDirectory: true)
        return cwd.appendingPathComponent("../exports").standardizedFileURL
    }()

    /// Default location for F1F2 records.
    public static let f1f2RecordsRoot: URL =
        exportsRoot.appendingPathComponent("chip/noc/f1f2/records")

    /// Load by package-relative path (used on first GUI launch / CLI argv).
    public static func load(relativePath: String) -> Result<F1F2Record, RecordLoaderError> {
        load(url: URL(fileURLWithPath: relativePath))
    }

    /// Load by URL (used by NSOpenPanel / file picker / CLI). Runtime-
    /// enforces invariant (a) — the URL must canonicalize to a path under
    /// `exportsRoot`.
    public static func load(url: URL) -> Result<F1F2Record, RecordLoaderError> {
        let canonical = url.standardizedFileURL
        let exportsPath = exportsRoot.path
        let canonicalPath = canonical.path
        if !canonicalPath.hasPrefix(exportsPath) {
            return .failure(.pathOutsideExports(path: canonicalPath))
        }
        guard FileManager.default.fileExists(atPath: canonicalPath) else {
            return .failure(.fileNotFound(path: canonicalPath))
        }
        let data: Data
        do {
            data = try Data(contentsOf: canonical)
        } catch {
            return .failure(.readFailed(path: canonicalPath, underlying: error))
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let record = try decoder.decode(F1F2Record.self, from: data)
            return .success(record)
        } catch {
            return .failure(.decodeFailed(path: canonicalPath, underlying: error))
        }
    }
}
