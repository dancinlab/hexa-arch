// SiblingRepoSpawnerTests — D107 5-candidate fallback verification.
//
// `SiblingRepoSpawner.resolveEntrypoint(for:)` walks 5 conventional
// filenames inside a domain's `substrateSSOT` directory and returns
// the first one that exists on disk. The candidates (in priority
// order) are:
//
//   1. `<repo>/cli/hexa-<id>`            — hexa-* family canonical
//   2. `<repo>/cli/main.hexa`            — alt hexa-native entry
//   3. `<repo>/<id>.hexa`                — top-level hexa entry
//   4. `<repo>/verify/run_all.hexa`      — D17 matter precedent
//   5. `<repo>/cli/hexa-<id>.hexa`       — D107 hexa-aura / hexa-ufo
//                                          actual CLI filename
//
// This test exercises each slot in isolation (write one file, expect
// the spawner to return that exact path) and confirms the priority
// order (when slots ① and ⑤ both exist, ① wins).
//
// Honesty contract (D80): when no candidate exists the spawner returns
// `nil` and the caller emits a skip record — this test also pins that
// behaviour.

import XCTest
@testable import DemiurgeCore

final class SiblingRepoSpawnerTests: XCTestCase {

    // MARK: helpers

    /// Build a throw-away domain whose `substrateSSOT` points at a
    /// fresh temp directory. Each call creates a unique directory so
    /// tests can run in parallel without colliding on filenames.
    private func makeFixture(id: String,
                             file: StaticString = #file,
                             line: UInt = #line) throws -> (Domain, URL) {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("SiblingRepoSpawnerTests-\(id)-\(UUID().uuidString)",
                                    isDirectory: true)
        try FileManager.default.createDirectory(
            at: tmp, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: tmp.appendingPathComponent("cli"),
            withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: tmp.appendingPathComponent("verify"),
            withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: tmp)
        }
        let domain = Domain(
            id: id,
            label: id,
            canvasMode: .matter,
            keywords: [],
            prerequisites: [],
            facets: DomainFacets(scale: .system,
                                 clusters: [.matter],
                                 hostility: .macosClean),
            substrateSSOT: tmp.path)
        return (domain, tmp)
    }

    private func touch(_ url: URL) throws {
        try Data().write(to: url)
    }

    // MARK: candidates ①..④ (regression — unchanged by D107)

    func testCandidate1CliHexaIdWinsWhenPresent() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let target = repo.appendingPathComponent("cli/hexa-matter")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    func testCandidate2CliMainHexa() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let target = repo.appendingPathComponent("cli/main.hexa")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    func testCandidate3TopLevelIdHexa() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let target = repo.appendingPathComponent("matter.hexa")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    func testCandidate4VerifyRunAllHexa() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let target = repo.appendingPathComponent("verify/run_all.hexa")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    // MARK: candidate ⑤ — D107 new fallback

    /// When ONLY `cli/hexa-<id>.hexa` exists the spawner must still
    /// resolve. This is the actual on-disk shape of `~/core/hexa-aura/`
    /// and `~/core/hexa-ufo/` — without slot ⑤ those sibling repos
    /// would silently return nil and the cockpit would emit an
    /// (incorrect) "entrypoint missing" skip record.
    func testCandidate5CliHexaIdDotHexa_aura() throws {
        let (domain, repo) = try makeFixture(id: "aura")
        let target = repo.appendingPathComponent("cli/hexa-aura.hexa")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    func testCandidate5CliHexaIdDotHexa_ufo() throws {
        let (domain, repo) = try makeFixture(id: "ufo")
        let target = repo.appendingPathComponent("cli/hexa-ufo.hexa")
        try touch(target)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       target.path)
    }

    // MARK: priority order

    /// When slot ① and slot ⑤ both exist the spawner must pick slot ①
    /// (the canonical hexa-* family entrypoint). This protects against
    /// a future regression that re-orders the array.
    func testPriorityOrder_slot1BeatsSlot5() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let slot1 = repo.appendingPathComponent("cli/hexa-matter")
        let slot5 = repo.appendingPathComponent("cli/hexa-matter.hexa")
        try touch(slot1)
        try touch(slot5)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       slot1.path,
                       "slot ① (cli/hexa-<id>) must win over slot ⑤")
    }

    /// Slot ⑤ wins over slot ④ — D107 explicitly places the new
    /// candidate AFTER `verify/run_all.hexa` so D17 matter (which uses
    /// slot ④) keeps its precedence. This test pins that.
    func testPriorityOrder_slot4BeatsSlot5() throws {
        let (domain, repo) = try makeFixture(id: "matter")
        let slot4 = repo.appendingPathComponent("verify/run_all.hexa")
        let slot5 = repo.appendingPathComponent("cli/hexa-matter.hexa")
        try touch(slot4)
        try touch(slot5)
        XCTAssertEqual(SiblingRepoSpawner.resolveEntrypoint(for: domain),
                       slot4.path,
                       "slot ④ (verify/run_all.hexa) must win over slot ⑤")
    }

    // MARK: honesty floor

    /// When no candidate exists the spawner returns nil — the caller
    /// (ProducerRegistry+Sibling) emits a skip record per D80.
    func testNoCandidate_returnsNil() throws {
        let (domain, _) = try makeFixture(id: "matter")
        XCTAssertNil(SiblingRepoSpawner.resolveEntrypoint(for: domain))
    }

    /// A domain without `substrateSSOT` returns nil unconditionally.
    func testNilSubstrateSSOT_returnsNil() {
        let domain = Domain(
            id: "chip",
            label: "chip",
            canvasMode: .chip,
            keywords: [],
            prerequisites: [],
            facets: DomainFacets(scale: .device,
                                 clusters: [.engineering],
                                 hostility: .macosClean),
            substrateSSOT: nil)
        XCTAssertNil(SiblingRepoSpawner.resolveEntrypoint(for: domain))
    }
}
