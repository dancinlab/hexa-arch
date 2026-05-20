// PilotProducerWireTests — covers the D80 / D94 / T7 Producer ↦
// PilotLoader wire path:
//
//   (1) PilotEntry.toParityRef() field projection — id-keyed
//       parityMethod enum mapping + tolerance string → (Double?,
//       String?) split.
//   (2) PilotLoader.parityRef(forId:) end-to-end fixture load
//       returns a HexaNativeParityRef with the expected fields.
//   (3) EnergyVerifyProducer.injectHexaNativeParity(into:pilotId:)
//       and FusionVerifyProducer.injectHexaNativeParity(...) round-
//       trip — given a stub JSON written by the python script, the
//       Swift producer injects the `hexa_native_parity` block from
//       PILOTS.demi and the result decodes as a typed
//       EnergyVerifyRecord / FusionVerifyRecord with hexaNativeParity
//       non-nil.
//   (4) D80 honesty path — when no pilot row matches, inject is a
//       no-op (returns false) and the JSON is unchanged.
//
// Foundation-only XCTest — sibling-style with PilotLoaderTests.

import XCTest
@testable import DemiurgeCore

final class PilotProducerWireTests: XCTestCase {

    // MARK: helpers

    /// Mini fixture covering 3 pilots that exercise distinct
    /// `parityMethod` enum mappings (substrate / python-companion /
    /// heapq) and tolerance patterns (numeric / bit-exact / non-
    /// numeric).
    private static let fixture = """
    # fixture for PilotProducerWireTests

    [pilot-solar]
    kernel_path       = "stdlib/kernels/solar/solar_kernel.hexa"
    parity_test       = "stdlib/kernels/solar/solar_kernel_test.hexa"
    parity_method     = "pvlib 0.13.0 substrate parity at 6 timestamps"
    parity_tolerance  = "<=1e-13 rel (D80 ceiling 1e-3; ~5e6x tighter)"
    parity_status     = "21/21 PASS at rel_err <=1e-13"
    hexa_lang_sha     = "122620de"
    algorithm_ref     = "Hughes 1985 ephemeris + Haurwitz 1945"
    scope_notes       = "fixture row — solar pilot"

    [pilot-mc_transport]
    kernel_path       = "stdlib/kernels/mc_transport/mc_slab_demo.hexa"
    parity_test       = "stdlib/kernels/mc_transport/mc_slab_demo_test.hexa"
    parity_method     = "python-companion (same LCG seed) bit-identical"
    parity_tolerance  = "~1e-3 rel @ N=1e5"
    parity_status     = "8/8 PASS at ~1e-3 rel @ N=1e5"
    hexa_lang_sha     = "dd3dad19"
    algorithm_ref     = "1-D slab MC, Beer-Lambert oracle"
    scope_notes       = "fixture row — mc_transport pilot"

    [pilot-event_queue]
    kernel_path       = "stdlib/kernels/noc_sim/event_queue.hexa"
    parity_test       = "stdlib/kernels/noc_sim/event_queue_test.hexa"
    parity_method     = "python-companion heapq parity, FIFO tiebreaker"
    parity_tolerance  = "exact (discrete data structure — pop-order match)"
    parity_status     = "36/36 PASS exact"
    hexa_lang_sha     = "f8cd27c8"
    algorithm_ref     = "Binary min-heap discrete-event scheduler"
    scope_notes       = "fixture row — event queue pilot"
    """

    /// Write fixture → tmp/domains/PILOTS.demi, set DEMIURGE_REPO=tmp.
    /// Caller must `unsetenv("DEMIURGE_REPO")` in defer.
    @discardableResult
    private func installFixture() throws -> String {
        let tmp = NSTemporaryDirectory()
            + "pilot-producer-wire-\(UUID().uuidString)"
        let domainsDir = "\(tmp)/domains"
        try FileManager.default.createDirectory(
            atPath: domainsDir,
            withIntermediateDirectories: true)
        let demiPath = "\(domainsDir)/PILOTS.demi"
        try Self.fixture.write(toFile: demiPath,
                               atomically: true,
                               encoding: .utf8)
        setenv("DEMIURGE_REPO", tmp, 1)
        return tmp
    }

    // MARK: (1) PilotEntry.toParityRef() field projection

    func testToParityRefIdKeyedEnumMapping() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()
        let rows = PilotLoader.loadAll()
        let byId = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })

        let solar = try XCTUnwrap(byId["pilot-solar"])
        let solarRef = solar.toParityRef()
        XCTAssertEqual(solarRef.parityMethod, .substrateToSubstrate)
        XCTAssertEqual(solarRef.kernelPath,
                       "stdlib/kernels/solar/solar_kernel.hexa")
        XCTAssertEqual(solarRef.hexaLangSHA, "122620de")
        XCTAssertEqual(solarRef.parityTolerance, 1e-13)
        XCTAssertTrue(solarRef.parityToleranceNote?.contains("1e-13") ?? false)
        XCTAssertEqual(solarRef.parityStatus,
                       "21/21 PASS at rel_err <=1e-13")

        let mct = try XCTUnwrap(byId["pilot-mc_transport"])
        let mctRef = mct.toParityRef()
        XCTAssertEqual(mctRef.parityMethod, .pythonCompanionSeedMatch)
        XCTAssertEqual(mctRef.parityTolerance, 1e-3)

        let eq = try XCTUnwrap(byId["pilot-event_queue"])
        let eqRef = eq.toParityRef()
        XCTAssertEqual(eqRef.parityMethod, .heapqOracleExact)
        // Non-numeric tolerance ("exact (discrete data structure)")
        // → numeric nil, note carries the raw string.
        XCTAssertNil(eqRef.parityTolerance)
        XCTAssertEqual(eqRef.parityToleranceNote,
                       "exact (discrete data structure — pop-order match)")
    }

    func testDeriveToleranceBitExactCase() {
        let (num, note) = PilotEntry.deriveTolerance(
            "rel_err = 0.0 (literal IEEE-754 bit-exact)")
        XCTAssertEqual(num, 0.0)
        XCTAssertEqual(note,
                       "rel_err = 0.0 (literal IEEE-754 bit-exact)")
    }

    func testDeriveParityMethodFreeTextFallback() {
        // Unknown id, free-text keyword should win.
        XCTAssertEqual(
            PilotEntry.deriveParityMethod(
                id: "pilot-unknown-future",
                freeText: "idft∘dft roundtrip identity check"),
            .roundtripIdentity)
        XCTAssertEqual(
            PilotEntry.deriveParityMethod(
                id: "pilot-unknown-future",
                freeText: "hand-mirrored Python math closed-form"),
            .handMirroredPython)
        // Total fallback.
        XCTAssertEqual(
            PilotEntry.deriveParityMethod(
                id: "pilot-unknown-future",
                freeText: "something entirely novel"),
            .other)
    }

    // MARK: (2) PilotLoader.parityRef(forId:) end-to-end

    func testParityRefForIdReturnsTypedStruct() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()

        let ref = try XCTUnwrap(
            PilotLoader.parityRef(forId: "pilot-solar"))
        XCTAssertEqual(ref.kernelPath,
                       "stdlib/kernels/solar/solar_kernel.hexa")
        XCTAssertEqual(ref.hexaLangSHA, "122620de")
        XCTAssertEqual(ref.parityMethod, .substrateToSubstrate)

        // Absent id → nil (D80 honesty: no silent fallback).
        XCTAssertNil(PilotLoader.parityRef(forId: "pilot-nonexistent"))
    }

    // MARK: (3) injection round-trip — Energy + Fusion verify

    /// Stub JSON matching the EnergyVerifyRecord schema as written by
    /// `~/core/hexa-lang/stdlib/energy/openmc_keff.py` (no
    /// `hexa_native_parity` field yet — that's what we inject).
    private static let stubEnergyJson = """
    {
      "domain": "energy",
      "verb": "verify",
      "kind": "openmc_keff_criticality",
      "stamp": "20260520T120000Z",
      "producer": "openmc@absent",
      "measurement_gate": "GATE_OPEN",
      "absorbed": false,
      "scope_caveats": ["stub"],
      "citations": ["stub"],
      "skipped_reason": "openmc_import_failed",
      "kernel_reuse": "kernels/mc_transport/ (D72 — 3rd consumer)"
    }
    """

    private static let stubFusionJson = """
    {
      "domain": "fusion",
      "verb": "verify",
      "kind": "openmc_tbr_neutronics",
      "stamp": "20260520T120000Z",
      "producer": "openmc@absent",
      "measurement_gate": "GATE_OPEN",
      "absorbed": false,
      "scope_caveats": ["stub"],
      "citations": ["stub"],
      "skipped_reason": "openmc_import_failed",
      "kernel_reuse": "kernels/mc_transport/ (D72 — 2nd consumer)"
    }
    """

    func testEnergyVerifyProducerInjectsHexaNativeParity() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("energy_verify_\(UUID().uuidString).json")
        try Self.stubEnergyJson.write(to: url, atomically: true,
                                      encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        // Inject pilot-solar.
        let ok = EnergyVerifyProducer.injectHexaNativeParity(
            into: url, pilotId: "pilot-solar")
        XCTAssertTrue(ok)

        // Decode as typed record — hexaNativeParity now non-nil.
        let data = try Data(contentsOf: url)
        let rec = try JSONDecoder().decode(EnergyVerifyRecord.self, from: data)
        let parity = try XCTUnwrap(rec.hexaNativeParity)
        XCTAssertEqual(parity.kernelPath,
                       "stdlib/kernels/solar/solar_kernel.hexa")
        XCTAssertEqual(parity.hexaLangSHA, "122620de")
        XCTAssertEqual(parity.parityMethod, .substrateToSubstrate)
        XCTAssertEqual(parity.parityTolerance, 1e-13)
    }

    func testFusionVerifyProducerInjectsHexaNativeParity() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("fusion_verify_\(UUID().uuidString).json")
        try Self.stubFusionJson.write(to: url, atomically: true,
                                      encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        let ok = FusionVerifyProducer.injectHexaNativeParity(
            into: url, pilotId: "pilot-mc_transport")
        XCTAssertTrue(ok)

        let data = try Data(contentsOf: url)
        let rec = try JSONDecoder().decode(FusionVerifyRecord.self, from: data)
        let parity = try XCTUnwrap(rec.hexaNativeParity)
        XCTAssertEqual(parity.kernelPath,
                       "stdlib/kernels/mc_transport/mc_slab_demo.hexa")
        XCTAssertEqual(parity.hexaLangSHA, "dd3dad19")
        XCTAssertEqual(parity.parityMethod, .pythonCompanionSeedMatch)
        XCTAssertEqual(parity.parityTolerance, 1e-3)
    }

    // MARK: (4) D80 honesty — absent pilot → no inject, JSON unchanged

    func testInjectNoopWhenPilotAbsent() throws {
        defer { unsetenv("DEMIURGE_REPO") }
        _ = try installFixture()

        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("energy_verify_\(UUID().uuidString).json")
        try Self.stubEnergyJson.write(to: url, atomically: true,
                                      encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }

        // Pilot id absent in fixture → false, JSON byte-unchanged.
        let originalData = try Data(contentsOf: url)
        let ok = EnergyVerifyProducer.injectHexaNativeParity(
            into: url, pilotId: "pilot-does-not-exist")
        XCTAssertFalse(ok)
        let afterData = try Data(contentsOf: url)
        XCTAssertEqual(originalData, afterData)
    }
}
