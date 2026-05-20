// SiblingRepoSpawner — standardized spawn pattern for D17 sibling
// repos (G3 from ARCH.md §11.4).
//
// Domains whose substrate is too large for `hexa-lang/stdlib/<id>/`
// live in sibling repos under `~/core/hexa-<id>/`. Examples:
//   - matter   → ~/core/hexa-matter/        (D17 first precedent)
//   - ufo      → ~/core/hexa-ufo/           (HEXA-Disc atlas)
//   - aura     → ~/core/hexa-aura/          (post-aural BCI substrate)
//   - bio      → ~/core/hexa-bio/           (molecular toolkit, D81)
//   - chem     → ~/core/hexa-chem/          (chemistry substrate, D81)
//   - cern / antimatter / fusion / rtsc / space / brain — listed in
//     DomainCatalog.all with `substrateSSOT`.
//
// Each sibling repo carries its own CLI entrypoint
// (`~/core/hexa-<id>/cli/hexa-<id>` for the hexa-* family, or a
// hexa-lang aggregator script for D17 matter). This helper picks the
// right entrypoint by Domain.id and forwards arguments uniformly.
//
// D61 — demiurge stays a pointer / spawn wrapper only. This helper
// must NEVER carry compute logic; it only resolves a path and runs.
// D80 — every sibling-repo binary is a transitional pointer; the
// hexa-native ultimate-form port still has to land for absorbed=true
// non-provisional.

import Foundation

public struct SiblingRepoSpawnResult: Sendable {
    public let ok: Bool
    public let exitCode: Int32
    public let stdout: String
    public let scriptPath: String
    public let resolvedFromSSOT: String?

    public init(ok: Bool, exitCode: Int32, stdout: String,
                scriptPath: String, resolvedFromSSOT: String?) {
        self.ok = ok
        self.exitCode = exitCode
        self.stdout = stdout
        self.scriptPath = scriptPath
        self.resolvedFromSSOT = resolvedFromSSOT
    }
}

public enum SiblingRepoSpawner {

    /// Expand `~` and validate the path exists on disk; return nil if
    /// the sibling repo has not yet been cloned locally.
    private static func expand(_ path: String) -> String? {
        let p = NSString(string: path).expandingTildeInPath
        return FileManager.default.fileExists(atPath: p) ? p : nil
    }

    /// Look up a domain's substrate SSOT and resolve a canonical CLI
    /// entrypoint inside it. Conventions (in priority order):
    ///   1. `<repo>/cli/hexa-<id>`          — hexa-* family canonical
    ///   2. `<repo>/cli/main.hexa`          — alt hexa-native entry
    ///   3. `<repo>/<id>.hexa`              — top-level hexa entry
    ///   4. `<repo>/verify/run_all.hexa`    — D17 matter precedent
    ///   5. `<repo>/cli/hexa-<id>.hexa`     — D107 hexa-aura / hexa-ufo
    ///                                       actual CLI filename
    /// Returns nil if none exist (caller emits an honest skip record).
    public static func resolveEntrypoint(for domain: Domain) -> String? {
        guard let ssot = domain.substrateSSOT,
              let repo = expand(ssot) else { return nil }
        let candidates = [
            "\(repo)/cli/hexa-\(domain.id)",
            "\(repo)/cli/main.hexa",
            "\(repo)/\(domain.id).hexa",
            "\(repo)/verify/run_all.hexa",
            "\(repo)/cli/hexa-\(domain.id).hexa",
        ]
        return candidates.first(where: {
            FileManager.default.fileExists(atPath: $0)
        })
    }

    /// Spawn a sibling-repo entrypoint with the given verb and output
    /// directory. The entrypoint convention is:
    ///   <entrypoint> <verb> <output_dir>
    /// for hexa-* CLIs, and `hexa run <entrypoint> <output_dir>` for
    /// raw `.hexa` scripts (D17 matter uses this).
    public static func spawn(domain: Domain,
                              verb: String,
                              outDir: URL) -> SiblingRepoSpawnResult {
        guard let entrypoint = resolveEntrypoint(for: domain) else {
            return SiblingRepoSpawnResult(
                ok: false, exitCode: -1, stdout:
                    "sibling-repo entrypoint missing for domain "
                    + "'\(domain.id)' (substrateSSOT=\(domain.substrateSSOT ?? "nil"))",
                scriptPath: "",
                resolvedFromSSOT: domain.substrateSSOT)
        }
        let isHexaScript = entrypoint.hasSuffix(".hexa")
        let executable: String
        let args: [String]
        if isHexaScript {
            executable = "/usr/bin/env"
            args = ["hexa", "run", entrypoint, outDir.path]
        } else {
            executable = entrypoint
            args = [verb, outDir.path]
        }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: executable)
        proc.arguments = args
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        do { try proc.run() } catch {
            return SiblingRepoSpawnResult(
                ok: false, exitCode: -1,
                stdout: "spawn failed: \(error.localizedDescription)",
                scriptPath: entrypoint,
                resolvedFromSSOT: domain.substrateSSOT)
        }
        proc.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        return SiblingRepoSpawnResult(
            ok: proc.terminationStatus == 0,
            exitCode: proc.terminationStatus,
            stdout: out,
            scriptPath: entrypoint,
            resolvedFromSSOT: domain.substrateSSOT)
    }
}
