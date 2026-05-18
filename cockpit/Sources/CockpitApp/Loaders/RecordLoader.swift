// RecordLoader — read a F1F2 JSON record from ../exports/** and decode it.
//
// @D g_cockpit_isolation invariants enforced here:
//   (a) reads ONLY ../exports/** (typed records — D2) — `pathOutsideExports`
//       error returned at runtime if the caller (e.g. NSOpenPanel) hands us
//       a URL outside the exports/ subtree. Defense-in-depth on top of the
//       picker's `directoryURL = exportsRoot` default.
//   (b) no imports from hexa-lang/stdlib/* nor demiurge hexa-native core
//   (d) edit-direction one-way: cockpit reads exports, never the reverse
//
// Apple-canonical (D26 g_swift_native): Foundation's URL + Data + JSONDecoder
// with .convertFromSnakeCase. No third-party deps.

import Foundation

enum RecordLoaderError: LocalizedError {
    case fileNotFound(path: String)
    case readFailed(path: String, underlying: Error)
    case decodeFailed(path: String, underlying: Error)
    case pathOutsideExports(path: String)

    var errorDescription: String? {
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

enum RecordLoader {
    /// `../exports/` resolved against the cockpit/ package directory (the
    /// pwd when launched via `swift run`). The ONLY directory the cockpit
    /// may read from per @D g_cockpit_isolation (a).
    static let exportsRoot: URL = {
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath,
                      isDirectory: true)
        return cwd.appendingPathComponent("../exports").standardizedFileURL
    }()

    /// Default picker location for F1F2 records — what D29 hardcoded.
    static let f1f2RecordsRoot: URL =
        exportsRoot.appendingPathComponent("chip/noc/f1f2/records")

    /// Load by package-relative path (used on first launch / D29 default).
    static func load(relativePath: String) -> Result<F1F2Record, RecordLoaderError> {
        load(url: URL(fileURLWithPath: relativePath))
    }

    /// Load by URL (used by NSOpenPanel / file picker). Runtime-enforces
    /// invariant (a) — the URL must canonicalize to a path under exportsRoot.
    static func load(url: URL) -> Result<F1F2Record, RecordLoaderError> {
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
