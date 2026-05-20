// SubstrateLinkIntegrityTests — 3-tier link-integrity verifier
// (D97 / Q3 picked A) covering the 5 substrate-bearing sibling repos.
//
// SSOT under test: `demiurge/domains/SUBSTRATE_LINKS.demi` (loaded via
// `SubstrateLinksLoader`) cross-checked against the 5 sibling repos on
// disk (`~/core/hexa-<id>/AGENTS.tape`) — READ-ONLY walk, no writes
// anywhere.
//
// The three tiers (per D97 design):
//
//   Tier ①  testTier1SubstrateSsotExistence
//     For each row, `sibling_path` resolves to a directory on disk.
//     FAIL with the concrete path on miss.
//
//   Tier ②  testTier2IdentityClaimConcord
//     For each row, `<sibling_path>/AGENTS.tape` contains a line that
//     matches `@I id001 := "<identity_key>"`. FAIL with expected vs
//     observed on miss / mismatch / file absence.
//
//   Tier ③  testTier3AdvisoryPrereqCoverage
//     For each row, every id in `advisory_prereqs` appears in this
//     domain's transitive closure inside the demiurge prereq DAG
//     (`DomainGraph.transitiveClosure(of:)`). Mismatches PRINT a
//     warning to stderr; **the test does NOT fail** — Q1 keeps the
//     two SSOTs independent, so an advisory drift is information, not
//     an error.
//
// Honesty contract (D80): if `SUBSTRATE_LINKS.demi` cannot be found,
// `SubstrateLinksLoader.loadAll()` returns []; the tests then iterate
// zero rows and pass trivially. The stderr warning from the loader
// surfaces the gap. Same shape as the rest of `DemiurgeCore` tests.

import XCTest
@testable import DemiurgeCore

final class SubstrateLinkIntegrityTests: XCTestCase {

    // Shared fixture — load once per test invocation. Empty array if
    // the SSOT is absent (loader emits stderr warning in that case).
    private static var entries: [SubstrateLinkEntry] {
        SubstrateLinksLoader.loadAll()
    }

    // MARK: Tier ① — substrate SSOT existence
    //
    // Walk every row, expand the tilde, confirm the result is an
    // existing directory. FAIL with the concrete path on miss so the
    // operator can fix the link (typo / moved repo / un-cloned host).

    func testTier1SubstrateSsotExistence() {
        let rows = Self.entries
        guard !rows.isEmpty else {
            // honesty: empty SSOT is surfaced by SubstrateLinksLoader's
            // stderr warning, not by an XCTFail here — the test passes
            // trivially and the caller sees the gap.
            return
        }
        for row in rows {
            let path = row.expandedSiblingPath()
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(
                atPath: path, isDirectory: &isDir)
            XCTAssertTrue(exists,
                "Tier ① miss [\(row.id)]: sibling_path '\(path)' "
                + "(from '\(row.siblingPath)') does NOT exist")
            XCTAssertTrue(isDir.boolValue,
                "Tier ① miss [\(row.id)]: sibling_path '\(path)' "
                + "exists but is NOT a directory")
        }
    }

    // MARK: Tier ② — identity-claim concord
    //
    // Read `<sibling_path>/AGENTS.tape`, scan for the `@I id001 :=
    // "<identity_key>"` declaration. FAIL on miss / mismatch / file
    // absence. The match is intentionally lenient on whitespace and
    // surrounding clauses (`:: identity-claim […]`) — we only assert
    // that the literal `@I id001 := "<expected>"` substring is on a
    // line that starts with `@I id001`.

    func testTier2IdentityClaimConcord() {
        let rows = Self.entries
        guard !rows.isEmpty else { return }
        for row in rows {
            let agentsPath = row.expandedSiblingPath() + "/AGENTS.tape"
            guard FileManager.default.fileExists(atPath: agentsPath)
            else {
                XCTFail("Tier ② miss [\(row.id)]: AGENTS.tape "
                        + "not found at '\(agentsPath)'")
                continue
            }
            guard let src = try? String(contentsOfFile: agentsPath,
                                        encoding: .utf8)
            else {
                XCTFail("Tier ② miss [\(row.id)]: cannot read "
                        + "'\(agentsPath)'")
                continue
            }
            let needle = "@I id001 := \"\(row.identityKey)\""
            var found = false
            var firstIdentityLine: String? = nil
            for rawLine in src.split(separator: "\n",
                                     omittingEmptySubsequences: false) {
                let line = String(rawLine)
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("@I id001") && firstIdentityLine == nil {
                    firstIdentityLine = trimmed
                }
                if trimmed.contains(needle) {
                    found = true
                    break
                }
            }
            XCTAssertTrue(found,
                "Tier ② miss [\(row.id)]: expected '\(needle)' in "
                + "'\(agentsPath)' — first @I id001 line seen: "
                + "'\(firstIdentityLine ?? "<none>")'")
        }
    }

    // MARK: Tier ③ — advisory prereq coverage (warn-only)
    //
    // For each row, compute the demiurge prereq transitive closure of
    // `row.id` and confirm every id in `advisory_prereqs` is in it.
    // Mismatches emit a stderr warning but do NOT XCTFail — Q1 keeps
    // the two SSOTs independent (sibling-side advisory mention is a
    // different dimension than demiurge-side prereq DAG; a drift is
    // information, not an error).

    func testTier3AdvisoryPrereqCoverage() {
        let rows = Self.entries
        guard !rows.isEmpty else { return }
        for row in rows {
            guard !row.advisoryPrereqs.isEmpty else { continue }
            let closure = DomainGraph.transitiveClosure(of: row.id)
            let closureIds = Set(closure.map { $0.id })
            // Closure includes the start node itself; the advisory
            // list is meant to mention *other* domains, so we subtract
            // the row id from both sides for the diagnostic but use
            // the full closure for the membership check (a sibling
            // that lists itself in advisory_prereqs is harmless).
            var missing: [String] = []
            for adv in row.advisoryPrereqs {
                if !closureIds.contains(adv) {
                    missing.append(adv)
                }
            }
            if !missing.isEmpty {
                let warn =
                    ("Tier ③ advisory drift [\(row.id)]: "
                     + "advisory_prereqs contains "
                     + "\(missing) which is NOT in INDEX.demi "
                     + "transitive closure "
                     + "\(closureIds.sorted()) "
                     + "— advisory only, NOT a failure (Q1 keeps "
                     + "the two SSOTs independent)\n")
                FileHandle.standardError.write(Data(warn.utf8))
                print(warn, terminator: "")
            }
        }
        // Always passes — Tier ③ is advisory by design.
        XCTAssertTrue(true)
    }
}
