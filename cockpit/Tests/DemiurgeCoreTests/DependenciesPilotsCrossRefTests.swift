// DependenciesPilotsCrossRefTests — dual-source consistency CI for
// the two declarative SSOTs that live side-by-side in
// `demiurge/domains/`:
//
//   * DEPENDENCIES.demi (44 rows) — external-dependency audit per
//     substrate kernel + domain producer, with `portable_status`
//     (already-ported / in-flight / portable-next / heavy-port /
//     nonportable).
//   * PILOTS.demi      (11 rows) — D80 pilot kernel parity SSOT
//     (8-field schema, 1:1 with HexaNativeParityRef).
//
// CROSS-REF CONTRACT (the rule this file enforces):
//
//   For each row of DEPENDENCIES.demi with `portable_status =
//   "already-ported"`, there must be a corresponding row in
//   PILOTS.demi reachable by either `kernel-<X>` id match against
//   `pilot-<X>` id OR `path` match against `kernel_path` (with the
//   `.py` / `.hexa` swap absorbed). The mapping is one-direction
//   only — PILOTS.demi rows for born-hexa-native kernels (plasma /
//   circuit / noc_sim / logic_synth) are allowed to anchor onto
//   `trivial`-weight `already-ported` rows whose `path` is the
//   kernel directory.
//
// HONESTY (D80, same shape as DependenciesLoaderTests /
// PilotLoaderTests / SubstrateLinkIntegrityTests): when either
// SSOT is unreachable, the loaders return [] + stderr warning and
// the tests skip via XCTSkip (a vacuous cross-ref assertion would
// silently pass — D80 forbids that pattern).
//
// Foundation-only XCTest — same dependency surface as the rest of
// DemiurgeCore.

import XCTest
@testable import DemiurgeCore

final class DependenciesPilotsCrossRefTests: XCTestCase {

    // MARK: — fixture helpers ──────────────────────────────────────
    //
    // Note: this suite relies on parent-shell DEMIURGE_REPO /
    // HEXA_LANG_REPO env vars. DependenciesLoaderTests and
    // PilotLoaderTests both save+restore DEMIURGE_REPO around
    // their fixture-driven cases (D80 test-hygiene fix landed
    // alongside this file) — so by the time this class runs the
    // parent-shell value is still intact.

    /// Skip-or-load helper. Returns (deps, pilots) when both SSOTs
    /// are reachable on this host; throws XCTSkip otherwise.
    private func loadBothSSOTsOrSkip() throws
        -> (deps: [DependencyEntry], pilots: [PilotEntry])
    {
        guard DependenciesLoader.dependenciesPath() != nil else {
            throw XCTSkip(
                "DEPENDENCIES.demi not reachable on this host "
                + "(tried $DEMIURGE_REPO/domains, $PWD/domains, "
                + "~/core/demiurge/domains) — cross-ref CI is "
                + "vacuous without both SSOTs; skipping (D80).")
        }
        guard PilotLoader.pilotsPath() != nil else {
            throw XCTSkip(
                "PILOTS.demi not reachable on this host "
                + "(tried $DEMIURGE_REPO/domains, $PWD/domains, "
                + "~/core/demiurge/domains) — cross-ref CI is "
                + "vacuous without both SSOTs; skipping (D80).")
        }
        let deps = DependenciesLoader.loadAll()
        let pilots = PilotLoader.loadAll()
        guard !deps.isEmpty, !pilots.isEmpty else {
            throw XCTSkip(
                "DEPENDENCIES.demi (\(deps.count) rows) or "
                + "PILOTS.demi (\(pilots.count) rows) loaded "
                + "empty — cross-ref CI cannot run.")
        }
        return (deps, pilots)
    }

    /// Match a DEPENDENCIES.demi `kernel-<X>` id to a PILOTS.demi
    /// row. Returns the matching `PilotEntry` or nil.
    ///
    /// Strategy:
    ///   1. id-suffix match — `kernel-solar` ↔ `pilot-solar`.
    ///   2. path-stem match — DEPENDENCIES `path` shares a
    ///      directory with PILOTS `kernel_path` (e.g. both under
    ///      `stdlib/kernels/solar/`). Handles the `.py` / `.hexa`
    ///      file-extension swap and the "path is a directory"
    ///      born-hexa-native case (plasma / circuit / noc_sim /
    ///      logic_synth — kernel folder, multiple pilots).
    private func matchPilot(
        for dep: DependencyEntry,
        in pilots: [PilotEntry]
    ) -> PilotEntry? {
        // Strategy 1 — id-suffix match.
        if dep.id.hasPrefix("kernel-") {
            let suffix = String(dep.id.dropFirst("kernel-".count))
            let pilotId = "pilot-\(suffix)"
            if let hit = PilotLoader.find(id: pilotId, in: pilots) {
                return hit
            }
        }
        // Strategy 2 — path-stem (directory) match.
        let depDir = Self.directoryOf(dep.path)
        for p in pilots {
            let pilotDir = Self.directoryOf(p.kernelPath)
            if !depDir.isEmpty, depDir == pilotDir {
                return p
            }
        }
        return nil
    }

    /// Strip a path to its directory (everything up to the last
    /// `/`). For a path that's already a directory (trailing `/`
    /// or no `.`), return as-is sans trailing slash.
    private static func directoryOf(_ path: String) -> String {
        let trimmed = path.hasSuffix("/")
            ? String(path.dropLast())
            : path
        if let slash = trimmed.lastIndex(of: "/") {
            // If the segment after the last slash contains a `.`,
            // treat it as a filename and return the parent dir.
            let last = trimmed[trimmed.index(after: slash)...]
            if last.contains(".") {
                return String(trimmed[..<slash])
            }
        }
        return trimmed
    }

    // MARK: — Test 1: already-ported → matching pilot ──────────────
    //
    // Every DEPENDENCIES.demi row whose `portable_status` is
    // `already-ported` must resolve to a PILOTS.demi row via the
    // id-or-path matcher above. The reverse direction is NOT
    // asserted (D93 — born-hexa-native pilots may anchor onto
    // trivially-already-ported deps; PILOTS row is the field-level
    // authority).
    //
    // Concrete mappings expected on origin/main (sanity-checked
    // against domains/{DEPENDENCIES,PILOTS}.demi at SHA on test
    // landing):
    //
    //   kernel-solar        → pilot-solar
    //   kernel-mc_transport → pilot-mc_transport (also pilot-
    //                         transport_kinematics by dir match)
    //   kernel-plasma       → pilot-plasma_metrics (dir match —
    //                         born-hexa-native, kernel folder path)
    //   kernel-circuit      → pilot-breaker_trace_reduce (dir match)
    //   kernel-noc_sim      → pilot-event_queue (dir match)
    //   kernel-logic_synth  → (no PILOTS row yet — Yosys/ABC
    //                         absorption is older than D80 pilot
    //                         scheme; born hexa-native, the kernel
    //                         folder is its own substrate)
    //
    // The Yosys case is a known gap (port pre-dates D80 pilot SSOT)
    // so the test allowlists `kernel-logic_synth` explicitly rather
    // than failing — D80 honesty over false-positive failure.

    /// Known-and-documented gaps where `already-ported` rows have
    /// NO matching PILOTS.demi entry because the absorption pre-
    /// dates the D80 pilot SSOT scheme. Adding to this list is a
    /// design-gate event — document the rationale in design.md.
    private static let allowlistAlreadyPortedNoPilot: Set<String> = [
        // Yosys / ABC absorption (rfc_006 iter 11+) landed before
        // PILOTS.demi was introduced (D90). The hexa-native substrate
        // is the whole `stdlib/kernels/logic_synth/` directory; no
        // single-kernel pilot row exists.
        "kernel-logic_synth",
    ]

    func testEveryAlreadyPortedDependencyHasMatchingPilot() throws {
        let (deps, pilots) = try loadBothSSOTsOrSkip()

        var unresolved: [(String, String)] = []
        for dep in deps where dep.portableStatus == .alreadyPorted {
            // Only kernel-rows can carry a pilot — domain producer
            // rows reach into kernels indirectly; skip them.
            guard dep.kind == .kernel else { continue }
            if Self.allowlistAlreadyPortedNoPilot.contains(dep.id) {
                continue
            }
            if matchPilot(for: dep, in: pilots) == nil {
                unresolved.append((dep.id, dep.path))
            }
        }
        XCTAssertTrue(
            unresolved.isEmpty,
            "already-ported DEPENDENCIES.demi rows with no "
            + "matching PILOTS.demi entry: \(unresolved) — "
            + "either add a [pilot-<id>] section to PILOTS.demi "
            + "or extend `allowlistAlreadyPortedNoPilot` with a "
            + "design.md rationale (D80 / D90 / D93).")
    }

    // MARK: — Test 2: pilot kernel_path exists on hexa-lang disk ───
    //
    // For each PILOTS.demi row, the `kernel_path` must exist as a
    // real file under the sibling hexa-lang clone. Honesty contract:
    // the hexa-lang sibling repo may be absent / unreadable on a
    // host (CI without the sibling clone, restricted user). In that
    // case we XCTSkip — same pattern as the rest of the suite.
    //
    // Env vars consulted (first match wins):
    //   1. $HEXA_LANG_REPO          — explicit sibling repo override
    //   2. ~/core/hexa-lang/         — dev-box default location
    //
    // D101 (this PR): the legacy `$DEMIURGE_HEXA_LANG` fallback was
    // removed. After D3/D88 made demiurge the SSOT for `.demi` files,
    // the demiurge codebase no longer needs a demiurge-prefixed env
    // var to reach hexa-lang — the canonical, non-prefixed
    // `HEXA_LANG_REPO` is the single cross-repo override.
    //
    // Tier ① of D97 already covers the 5 substrate-bearing siblings
    // (rtsc / cern / antimatter / fusion / ufo); this test is the
    // analogous coverage for hexa-lang itself (the substrate that
    // hosts every D80 pilot file).

    private func hexaLangRepoPath() -> String? {
        let env = ProcessInfo.processInfo.environment
        if let p = env["HEXA_LANG_REPO"],
           FileManager.default.fileExists(atPath: p) { return p }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let homePath = "\(home)/core/hexa-lang"
        if FileManager.default.fileExists(atPath: homePath) {
            return homePath
        }
        return nil
    }

    /// Resolve `HEAD` of the hexa-lang clone — short branch name
    /// (e.g. "main"), `"(detached)"` for a detached HEAD (the normal
    /// `git worktree add origin/main` shape — treated as
    /// equivalent-to-main since PILOTS.demi anchors there), or nil
    /// when the .git layout can't be parsed (unusual setup → caller
    /// proceeds optimistically rather than skipping by accident).
    ///
    /// Handles both the conventional `.git/` directory and the
    /// worktree case where `.git` is a file pointing at
    /// `gitdir: <commondir>/worktrees/<name>` (the `HEAD` lives at
    /// the gitdir target, not at `<repo>/.git/HEAD`).
    private func currentBranch(at repo: String) -> String? {
        let dotGit = "\(repo)/.git"
        var headPath = "\(dotGit)/HEAD"
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: dotGit,
                                          isDirectory: &isDir),
           !isDir.boolValue {
            // `.git` is a file → worktree. Read `gitdir: <path>`.
            if let payload = try? String(contentsOfFile: dotGit,
                                          encoding: .utf8) {
                for line in payload.split(separator: "\n") {
                    let trimmed = line.trimmingCharacters(
                        in: .whitespaces)
                    if trimmed.hasPrefix("gitdir: ") {
                        let gitdir = String(
                            trimmed.dropFirst("gitdir: ".count))
                        headPath = "\(gitdir)/HEAD"
                        break
                    }
                }
            }
        }
        guard let head = try? String(contentsOfFile: headPath,
                                     encoding: .utf8) else {
            return nil
        }
        let trimmed = head.trimmingCharacters(
            in: .whitespacesAndNewlines)
        // Detached HEAD = literal SHA on a single line. The
        // canonical `git worktree add origin/main` shape lands here
        // — we treat it as main-equivalent rather than skipping.
        if !trimmed.hasPrefix("ref: ") { return "(detached)" }
        // `ref: refs/heads/<name>` → extract `<name>`.
        let prefix = "ref: refs/heads/"
        if trimmed.hasPrefix(prefix) {
            return String(trimmed.dropFirst(prefix.count))
        }
        return nil
    }

    func testEveryPilotKernelPathExistsAsHexaLangFile() throws {
        // Skip if either SSOT is missing (cross-ref vacuous) OR
        // the sibling hexa-lang clone is missing on this host.
        let (_, pilots) = try loadBothSSOTsOrSkip()
        guard let repo = hexaLangRepoPath() else {
            throw XCTSkip(
                "hexa-lang sibling repo not reachable on this "
                + "host (tried $HEXA_LANG_REPO, "
                + "~/core/hexa-lang) — "
                + "kernel_path on-disk check is vacuous; "
                + "skipping (D80).")
        }
        // Honesty: PILOTS.demi anchors onto hexa-lang origin/main
        // SHAs (D90 `hexa_lang_sha` field). If the local sibling
        // clone is checked out on a non-main branch (developer
        // working tree, RFC feature branch, etc.) the working
        // tree's file set is transient — we can't fairly compare
        // it against PILOTS.demi's origin/main anchor. XCTSkip
        // with a clear note rather than emit a false-positive
        // failure. Per task spec: 'hexa-lang 측이 read-only /
        // non-main branch 일 가능성 → XCTSkip'.
        if let branch = currentBranch(at: repo),
           branch != "main",
           branch != "(detached)" {
            throw XCTSkip(
                "hexa-lang sibling clone at '\(repo)' is on "
                + "branch '\(branch)' (not 'main' / detached) — "
                + "PILOTS.demi anchors onto origin/main, so the "
                + "working tree's file set is a transient state. "
                + "Re-run with the sibling on main, or set "
                + "HEXA_LANG_REPO at a main-checkout clone. "
                + "Skipping (D80 honesty).")
        }

        var missing: [(String, String)] = []
        for p in pilots {
            let kernelOnDisk = "\(repo)/\(p.kernelPath)"
            let testOnDisk = "\(repo)/\(p.parityTest)"
            if !FileManager.default.fileExists(atPath: kernelOnDisk) {
                missing.append((p.id, kernelOnDisk))
            }
            // Also check the parity test file — it's part of the
            // pilot's contract (D90 schema), so a missing parity
            // test is the same severity as a missing kernel.
            if !FileManager.default.fileExists(atPath: testOnDisk) {
                missing.append((p.id + " (parity_test)", testOnDisk))
            }
        }
        XCTAssertTrue(
            missing.isEmpty,
            "PILOTS.demi rows whose kernel_path / parity_test "
            + "does NOT exist under '\(repo)': \(missing) — "
            + "either the file was moved on hexa-lang origin/main "
            + "(update PILOTS.demi) or the sibling clone is stale "
            + "(git pull). (D80 honesty: this is a hard FAIL, not "
            + "a warn — a missing kernel breaks every downstream "
            + "Producer that calls PilotLoader.find(kernelPath:).)")
    }

    // MARK: — Test 3: pilot schema completeness ────────────────────
    //
    // Every PILOTS.demi row must populate all 8 required schema
    // fields (D90). The PilotLoader.project() function already
    // skips rows missing required fields with a stderr warning, so
    // a row that survives loadAll() implicitly has all required
    // fields populated — but the loader allows `scope_notes` to be
    // empty (it's the only soft field). This test re-asserts the
    // full 8-field contract at the loaded-row level + adds a
    // length sanity floor so an empty-string survivor is caught.

    func testEveryPilotSchemaHasAllRequiredFields() throws {
        let (_, pilots) = try loadBothSSOTsOrSkip()

        var violations: [(String, String)] = []
        for p in pilots {
            // 7 hard fields (must be non-empty after loader project).
            if p.kernelPath.isEmpty {
                violations.append((p.id, "kernel_path empty"))
            }
            if p.parityTest.isEmpty {
                violations.append((p.id, "parity_test empty"))
            }
            if p.parityMethod.isEmpty {
                violations.append((p.id, "parity_method empty"))
            }
            if p.parityTolerance.isEmpty {
                violations.append((p.id, "parity_tolerance empty"))
            }
            if p.parityStatus.isEmpty {
                violations.append((p.id, "parity_status empty"))
            }
            if p.hexaLangSha.isEmpty {
                violations.append((p.id, "hexa_lang_sha empty"))
            }
            if p.algorithmRef.isEmpty {
                violations.append((p.id, "algorithm_ref empty"))
            }
            // scope_notes is the 8th field (D90); loader permits
            // empty (default "") because some pilots may genuinely
            // have no caveat. Warn-only via stderr — NOT XCTFail.
            if p.scopeNotes.isEmpty {
                let warn =
                    "PILOTS.demi [\(p.id)]: scope_notes empty "
                    + "(D90 field #8) — soft field, but every "
                    + "pilot has at least one g3 caveat; "
                    + "consider documenting.\n"
                FileHandle.standardError.write(Data(warn.utf8))
            }
            // Sanity: SHA must look like a 7-12 char hex token.
            if !p.hexaLangSha.isEmpty {
                let isHex = p.hexaLangSha.allSatisfy {
                    "0123456789abcdefABCDEF".contains($0)
                }
                if !isHex || p.hexaLangSha.count < 7
                          || p.hexaLangSha.count > 12 {
                    violations.append(
                        (p.id,
                         "hexa_lang_sha '\(p.hexaLangSha)' is "
                         + "not a 7-12 char hex token"))
                }
            }
        }
        XCTAssertTrue(
            violations.isEmpty,
            "PILOTS.demi rows violating the D90 8-field schema "
            + "contract: \(violations) — every pilot row must "
            + "populate kernel_path / parity_test / parity_method "
            + "/ parity_tolerance / parity_status / hexa_lang_sha "
            + "/ algorithm_ref non-empty; hexa_lang_sha must be "
            + "a 7-12 char hex token.")
    }
}
