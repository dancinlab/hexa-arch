// ProducerLoaderTests — covers the D85 / D86 sibling-repo dispatch
// SSOT (`domains/PRODUCERS.demi`) → ProducerRegistry wire:
//
//   (1) Fixture parse — a tiny PRODUCERS.demi with just [aura-verify]
//       + [ufo-verify] sections projects to exactly 2 ProducerEntry
//       rows, each keyed by the correct (Verb, domain) and carrying
//       the declared id as defaultID + single variant.
//   (2) End-to-end registry — ProducerRegistry.hasAlternatives(.verify,
//       "aura") == true and the same for "ufo" when the canonical live
//       PRODUCERS.demi (or the test fixture) is reachable. Both rows
//       are loaded via ProducerLoader.loadAll() — Swift code unchanged.
//   (3) Malformed-section tolerance — a section missing `kind="sibling"`
//       is skipped with a stderr note, not crashed (D86 honesty path).
//
// Foundation-only XCTest — same sibling style as PilotProducerWireTests.

import XCTest
@testable import DemiurgeCore

final class ProducerLoaderTests: XCTestCase {

    // MARK: helpers

    /// Mini fixture mirroring the D85 production sections for aura +
    /// ufo verify. Exact field shape ProducerLoader expects: verb /
    /// domain / kind="sibling" / id / display.
    private static let fixture = """
    # fixture for ProducerLoaderTests

    [aura-verify]
    verb    = "verify"
    domain  = "aura"
    kind    = "sibling"
    id      = "hexa-aura"
    display = "hexa-aura verify (F-AURA-{1..4} state)"

    [ufo-verify]
    verb    = "verify"
    domain  = "ufo"
    kind    = "sibling"
    id      = "hexa-ufo"
    display = "hexa-ufo verify (13 falsifier state)"
    """

    /// Write fixture → tmp/domains/PRODUCERS.demi, set DEMIURGE_REPO=
    /// tmp so ProducerLoader.producersPath() resolves to the fixture.
    /// Caller must `unsetenv("DEMIURGE_REPO")` in defer.
    @discardableResult
    private func installFixture(_ src: String = fixture) throws -> String {
        let tmp = NSTemporaryDirectory()
            + "producer-loader-\(UUID().uuidString)"
        let domainsDir = "\(tmp)/domains"
        try FileManager.default.createDirectory(
            atPath: domainsDir,
            withIntermediateDirectories: true)
        let demiPath = "\(domainsDir)/PRODUCERS.demi"
        try src.write(toFile: demiPath,
                      atomically: true,
                      encoding: .utf8)
        setenv("DEMIURGE_REPO", tmp, 1)
        return tmp
    }

    // MARK: (1) Fixture parse — [aura-verify] + [ufo-verify]

    func testFixtureParsesAuraAndUfoVerifySections() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()

        let rows = ProducerLoader.loadAll()
        // Exactly 2 rows from the fixture.
        XCTAssertEqual(rows.count, 2,
            "fixture has 2 sibling sections; got \(rows.count)")

        let byKey = Dictionary(uniqueKeysWithValues: rows.map { ($0.0, $0.1) })

        // aura-verify projection.
        let auraKey = ProducerCellKey(verb: .verify, domain: "aura")
        let aura = try XCTUnwrap(byKey[auraKey],
            "expected (verify, aura) row in fixture projection")
        XCTAssertEqual(aura.defaultID, "hexa-aura")
        XCTAssertNotNil(aura.variants["hexa-aura"],
            "default variant 'hexa-aura' must be in variants map")
        XCTAssertEqual(aura.variants["hexa-aura"]?.displayName,
            "hexa-aura verify (F-AURA-{1..4} state)")

        // ufo-verify projection.
        let ufoKey = ProducerCellKey(verb: .verify, domain: "ufo")
        let ufo = try XCTUnwrap(byKey[ufoKey],
            "expected (verify, ufo) row in fixture projection")
        XCTAssertEqual(ufo.defaultID, "hexa-ufo")
        XCTAssertNotNil(ufo.variants["hexa-ufo"],
            "default variant 'hexa-ufo' must be in variants map")
        XCTAssertEqual(ufo.variants["hexa-ufo"]?.displayName,
            "hexa-ufo verify (13 falsifier state)")
    }

    // MARK: (2) End-to-end ProducerRegistry.hasAlternatives

    /// ProducerRegistry.entries is a stored-property `let` initialised
    /// once at first access. Since `installFixture` mutates env-vars
    /// AFTER the registry might have been touched by another test, we
    /// instead assert against the live production SSOT — which on a
    /// dev-box has [aura-verify] + [ufo-verify] sections committed
    /// (this PR's deliverable). If the live SSOT is reachable, both
    /// must be alternatives; otherwise we skip with a clear note (D80
    /// honesty path — no silent pass).
    func testRegistryHasAuraAndUfoVerifyAlternatives() throws {
        // Sanity: the live PRODUCERS.demi is reachable from this test
        // host. On a dev-box this is true; in clean CI without
        // ~/core/demiurge symlinked it might not be — skip honestly.
        guard ProducerLoader.producersPath() != nil else {
            throw XCTSkip(
                "PRODUCERS.demi not reachable on this host — "
                + "ProducerRegistry will fall back to empty sibling "
                + "tier; hasAlternatives assertion would be vacuous")
        }
        XCTAssertTrue(
            ProducerRegistry.hasAlternatives(verb: .verify,
                                             domain: "aura"),
            "aura+verify must be registered via PRODUCERS.demi "
            + "(D85 sibling-repo SSOT)")
        XCTAssertTrue(
            ProducerRegistry.hasAlternatives(verb: .verify,
                                             domain: "ufo"),
            "ufo+verify must be registered via PRODUCERS.demi "
            + "(D85 sibling-repo SSOT)")

        // Also verify the registered entries use the documented IDs
        // as their default variant — guard against schema drift.
        let auraEntry = ProducerRegistry.entries[
            ProducerCellKey(verb: .verify, domain: "aura")]
        XCTAssertEqual(auraEntry?.defaultID, "hexa-aura")
        let ufoEntry = ProducerRegistry.entries[
            ProducerCellKey(verb: .verify, domain: "ufo")]
        XCTAssertEqual(ufoEntry?.defaultID, "hexa-ufo")
    }

    // MARK: (3) Malformed-section tolerance

    func testMalformedKindIsSkippedNotCrashed() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        // One valid section + one with kind="not_yet_implemented".
        let mixed = """
        [aura-verify]
        verb    = "verify"
        domain  = "aura"
        kind    = "sibling"
        id      = "hexa-aura"
        display = "hexa-aura verify"

        [future-cell]
        verb    = "verify"
        domain  = "future"
        kind    = "swift-class"
        id      = "future-variant"
        display = "not yet supported"
        """
        _ = try installFixture(mixed)
        let rows = ProducerLoader.loadAll()
        // Only the sibling section projects; the swift-class kind is
        // skipped per ProducerLoader.project's guard.
        XCTAssertEqual(rows.count, 1,
            "only kind='sibling' projects; got \(rows.count)")
        XCTAssertEqual(rows.first?.0,
            ProducerCellKey(verb: .verify, domain: "aura"))
    }
}
