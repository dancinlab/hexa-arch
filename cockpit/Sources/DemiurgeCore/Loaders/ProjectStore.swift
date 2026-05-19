// ProjectStore — persistence for workbench projects (rfc_012 §7, D45).
//
// A project manifest is the cockpit's OWN app-state, NOT an exports/
// record (rfc_012 §7). Per @D g_cockpit_isolation clause (e) it lives
// under the macOS app-data standard location, explicitly OUTSIDE
// exports/ — so the records-honesty boundary is untouched.
//
//   ~/Library/Application Support/lab.dancin.demiurge/projects/
//       <uuid>/manifest.json
//
// D45 §7 names `projects/<name>/`; the per-project directory uses the
// project's UUID rather than its display name — user-typed names can
// collide or carry path-hostile characters, while the UUID is stable
// and unique. The manifest.json itself carries the display name.
//
// DemiurgeCore stays pure Foundation (Package.swift contract) — no
// SwiftUI / AppKit.

import Foundation

public enum ProjectStore {
    /// `~/Library/Application Support/lab.dancin.demiurge/projects/`.
    public static var projectsRoot: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport
            .appendingPathComponent("lab.dancin.demiurge", isDirectory: true)
            .appendingPathComponent("projects", isDirectory: true)
    }

    private static func directory(for project: Project) -> URL {
        projectsRoot.appendingPathComponent(project.id.uuidString, isDirectory: true)
    }

    private static var encoder: JSONEncoder {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return enc
    }

    private static var decoder: JSONDecoder {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }

    /// Write (or overwrite) a project's manifest.json.
    public static func save(_ project: Project) throws {
        let dir = directory(for: project)
        try FileManager.default.createDirectory(
            at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("manifest.json")
        try encoder.encode(project).write(to: url, options: .atomic)
    }

    /// Load every project manifest, oldest-created first. Unreadable or
    /// malformed manifests are skipped (a partial read beats a crash).
    public static func loadAll() -> [Project] {
        let fm = FileManager.default
        guard let dirs = try? fm.contentsOfDirectory(
            at: projectsRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]) else {
            return []
        }
        var result: [Project] = []
        for dir in dirs {
            let url = dir.appendingPathComponent("manifest.json")
            guard let data = try? Data(contentsOf: url),
                  let project = try? decoder.decode(Project.self, from: data) else {
                continue
            }
            result.append(project)
        }
        return result.sorted { $0.createdAt < $1.createdAt }
    }

    /// Remove a project's directory (manifest + any future app-state).
    public static func delete(_ project: Project) throws {
        let dir = directory(for: project)
        if FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.removeItem(at: dir)
        }
    }
}
