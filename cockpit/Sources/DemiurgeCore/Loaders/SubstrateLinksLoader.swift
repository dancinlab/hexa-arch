// SubstrateLinksLoader — load `demiurge/domains/SUBSTRATE_LINKS.demi`
// (D97 / Q3 = 3-tier verifier) into typed `SubstrateLinkEntry` rows.
//
// SSOT: `demiurge/domains/SUBSTRATE_LINKS.demi` — declarative SSOT
// for the 5 substrate-bearing sibling repos (`~/core/hexa-<id>/`).
// Each row records the sibling repo path on disk, the expected
// identity-key the sibling's `AGENTS.tape @I id001` must declare,
// and an optional advisory list of demiurge prereq ids the sibling
// implicitly assumes.
//
// HONESTY (D80, same contract as PilotLoader / DependenciesLoader):
// when the file is absent the loader emits a stderr warning and
// returns an empty array. No crash, no silent hardcoded fallback.
// The 3-tier link-integrity tests then degenerate to "no rows, no
// checks" — caller's responsibility to notice the missing SSOT.
//
// SCHEMA — see head-of-file comment in `domains/SUBSTRATE_LINKS.demi`.
// Four fields per section, each mapped 1:1 to a SubstrateLinkEntry
// property.

import Foundation

/// One row from `domains/SUBSTRATE_LINKS.demi` — a substrate-bearing
/// sibling repo link record. The `id` is the demiurge domain id
/// (e.g. `"fusion"`); the body fields point at the sibling repo on
/// disk and declare what that repo claims about itself.
public struct SubstrateLinkEntry: Sendable, Equatable {

    /// Row id — `[<demiurge-id>]` in the .demi file (matches an
    /// `INDEX.demi` domain id, e.g. `"rtsc"`, `"fusion"`, `"ufo"`).
    public let id: String

    /// `sibling_path` — path to the sibling repo. Tilde is preserved
    /// verbatim from the .demi (`"~/core/hexa-<id>/"`); call
    /// `expandedSiblingPath()` to get a FileManager-usable absolute
    /// path.
    public let siblingPath: String

    /// `identity_key` — the expected value of the sibling's
    /// `AGENTS.tape @I id001 := "<...>"` declaration. Used by Tier ②
    /// of the link-integrity verifier.
    public let identityKey: String

    /// `advisory_prereqs` — optional list of demiurge domain ids the
    /// sibling implicitly assumes (Tier ③, advisory only). Empty list
    /// is fine (e.g. `rtsc` is a root in the prereq DAG).
    public let advisoryPrereqs: [String]

    /// `notes` — one-line free-text. Often the most informative field
    /// at a glance.
    public let notes: String

    public init(id: String,
                siblingPath: String,
                identityKey: String,
                advisoryPrereqs: [String],
                notes: String) {
        self.id              = id
        self.siblingPath     = siblingPath
        self.identityKey     = identityKey
        self.advisoryPrereqs = advisoryPrereqs
        self.notes           = notes
    }

    /// Tilde-expand `siblingPath` to a FileManager-usable absolute
    /// path. The .demi keeps `~/core/hexa-<id>/` verbatim for
    /// human readability; this helper substitutes
    /// `FileManager.homeDirectoryForCurrentUser.path` for the leading
    /// `~`. Strips trailing slashes so the result is a clean path
    /// suitable for `fileExists(atPath:isDirectory:)`.
    public func expandedSiblingPath() -> String {
        var p = siblingPath
        if p.hasPrefix("~") {
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            p = home + String(p.dropFirst())
        }
        while p.hasSuffix("/") && p.count > 1 {
            p = String(p.dropLast())
        }
        return p
    }
}

public enum SubstrateLinksLoader {

    /// Resolve the canonical path for `demiurge/domains/SUBSTRATE_LINKS.demi`
    /// (D87 — `.demi` lives in demiurge, NOT hexa-lang). Priority:
    /// 1. `$DEMIURGE_REPO/domains/SUBSTRATE_LINKS.demi`
    /// 2. `$PWD/domains/SUBSTRATE_LINKS.demi`
    /// 3. `~/core/demiurge/domains/SUBSTRATE_LINKS.demi` (last resort)
    public static func substrateLinksPath() -> String? {
        let env = ProcessInfo.processInfo.environment
        if let repo = env["DEMIURGE_REPO"] {
            let p = "\(repo)/domains/SUBSTRATE_LINKS.demi"
            if FileManager.default.fileExists(atPath: p) { return p }
        }
        let cwd = FileManager.default.currentDirectoryPath
        let pwdPath = "\(cwd)/domains/SUBSTRATE_LINKS.demi"
        if FileManager.default.fileExists(atPath: pwdPath) { return pwdPath }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let homePath = "\(home)/core/demiurge/domains/SUBSTRATE_LINKS.demi"
        if FileManager.default.fileExists(atPath: homePath) { return homePath }
        return nil
    }

    /// Load + parse + project. Returns empty array + stderr warning
    /// when the file is missing (D80 honesty: no silent hardcoded
    /// fallback — the 3-tier verifier then runs zero checks and
    /// callers see the gap surfaced in stderr).
    public static func loadAll() -> [SubstrateLinkEntry] {
        guard let path = substrateLinksPath() else {
            FileHandle.standardError.write(
                Data(("SubstrateLinksLoader: SUBSTRATE_LINKS.demi "
                      + "not found (tried $DEMIURGE_REPO/domains, "
                      + "$PWD/domains, ~/core/demiurge/domains) — "
                      + "returning [] (D80)\n").utf8))
            return []
        }
        guard let src = try? String(contentsOfFile: path, encoding: .utf8)
            else {
            FileHandle.standardError.write(
                Data(("SubstrateLinksLoader: cannot read \(path) "
                      + "— returning [] (D80)\n").utf8))
            return []
        }
        let sections = DemiParser.parse(src)
        return sections.compactMap { project($0) }
    }

    /// Project one `DemiSection` into a `SubstrateLinkEntry`. Tolerant
    /// — returns nil on missing required fields (logged to stderr).
    public static func project(_ s: DemiSection) -> SubstrateLinkEntry? {
        guard let siblingPath = s.string("sibling_path"),
              let identityKey = s.string("identity_key") else {
            FileHandle.standardError.write(
                Data(("SubstrateLinksLoader: section '\(s.id)' "
                      + "missing required field (sibling_path / "
                      + "identity_key) — skipped\n").utf8))
            return nil
        }
        let advisoryPrereqs = s.list("advisory_prereqs")
        let notes = s.string("notes") ?? ""
        return SubstrateLinkEntry(
            id: s.id,
            siblingPath: siblingPath,
            identityKey: identityKey,
            advisoryPrereqs: advisoryPrereqs,
            notes: notes)
    }

    /// Lookup by row `id` — the demiurge domain id (e.g. `"fusion"`).
    /// Returns nil if no row matches.
    public static func find(id: String,
                            in entries: [SubstrateLinkEntry]? = nil)
        -> SubstrateLinkEntry?
    {
        let rows = entries ?? loadAll()
        return rows.first(where: { $0.id == id })
    }
}
