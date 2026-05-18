// RecordLoader — read a F1F2 JSON record from ../exports/** and decode it.
//
// @D g_cockpit_isolation invariants:
//   (a) reads ONLY ../exports/** (typed records — D2)
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

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let p):
            return "Record file not found: \(p)"
        case .readFailed(let p, let e):
            return "Read failed (\(p)): \(e.localizedDescription)"
        case .decodeFailed(let p, let e):
            return "Decode failed (\(p)): \(e.localizedDescription)"
        }
    }
}

enum RecordLoader {
    /// Load a F1F2 record from a path relative to the current working dir
    /// (typically the cockpit/ package dir when launched via `swift run`).
    static func load(relativePath: String) -> Result<F1F2Record, RecordLoaderError> {
        let url = URL(fileURLWithPath: relativePath)
        return load(url: url)
    }

    static func load(url: URL) -> Result<F1F2Record, RecordLoaderError> {
        let path = url.path
        guard FileManager.default.fileExists(atPath: path) else {
            return .failure(.fileNotFound(path: path))
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            return .failure(.readFailed(path: path, underlying: error))
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let record = try decoder.decode(F1F2Record.self, from: data)
            return .success(record)
        } catch {
            return .failure(.decodeFailed(path: path, underlying: error))
        }
    }
}
