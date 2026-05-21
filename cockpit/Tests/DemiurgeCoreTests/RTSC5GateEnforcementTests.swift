// RTSC5GateEnforcementTests — constitution.md v1.4.0 R4 Stage 1.
//
// Validates the MaterialAttestationRecord Codable decoder's R4
// (RTSC absorbed=true twin-error invariant) Stage 1 enforcement:
//   (1) existing Nb attestation record (`nb_bcs_v1`) is now INVALID
//       per the new invariant — by design (migration trigger);
//   (2) any future RTSC record with `aggregate != ALL_PASS` is
//       rejected at decode time;
//   (3) non-rtsc domain records (energy / solar pyranometer pattern)
//       remain unconstrained — invariant does not over-reach.
//
// Cross-refs:
//   - constitution.md R4
//   - RTSC.md §8.9 (5-criteria gate) · §8.10 (Nb correction)
//   - inbox/notes/2026-05-21-r4-stage1-enforcement.md (migration plan)

import XCTest
@testable import DemiurgeCore

final class RTSC5GateEnforcementTests: XCTestCase {

    // MARK: Test 1 — existing Nb attestation is now INVALID (expected fail)

    /// HONEST-FAIL by design — validates the *current state* of the
    /// landed Nb attestation record (`exports/material_attestation/
    /// nb_bcs_v1/...json`). Record has `domain: "rtsc"` + `absorbed:
    /// true` but NO `rtsc_5_gate_evaluation` field → MUST throw under
    /// the R4 Stage 1 invariant. This test asserts the throw — passing
    /// means the invariant *catches* the migration target.
    func testNbAttestationDomainRTSCRequires5GateField() throws {
        // #filePath = .../demiurge/cockpit/Tests/DemiurgeCoreTests/<this>.swift
        // exports root lives at .../demiurge/exports/ (sibling of cockpit/).
        let path = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // DemiurgeCoreTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // cockpit
            .deletingLastPathComponent() // demiurge
            .appendingPathComponent("exports")
            .appendingPathComponent("material_attestation")
            .appendingPathComponent("nb_bcs_v1")
            .appendingPathComponent("rtsc_attestation_nb_bcs_20260521T111656Z.json")

        let data = try Data(contentsOf: path)

        // Sanity precondition — the record IS domain=rtsc + absorbed=true.
        // (Use a minimal pass-through decoder to read these two fields
        // without triggering the invariant.)
        struct Peek: Codable {
            let domain: String
            let absorbed: Bool
            let rtsc_5_gate_evaluation: RTSC5GateEvaluation?
        }
        let peek = try JSONDecoder().decode(Peek.self, from: data)
        XCTAssertEqual(peek.domain, "rtsc",
            "Nb attestation record IS in the rtsc namespace (Pattern 1 root)")
        XCTAssertTrue(peek.absorbed,
            "Nb attestation record IS absorbed=true (current state)")
        XCTAssertNil(peek.rtsc_5_gate_evaluation,
            "Nb attestation record does NOT yet carry rtsc_5_gate_evaluation (migration target)")

        // R4 Stage 1 invariant MUST reject the decode.
        XCTAssertThrowsError(
            try JSONDecoder().decode(MaterialAttestationRecord.self, from: data),
            "R4 invariant MUST reject Nb attestation: domain=rtsc + absorbed=true + no 5-gate field"
        ) { err in
            guard case DecodingError.dataCorrupted(let ctx) = err else {
                XCTFail("Expected DecodingError.dataCorrupted, got \(err)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("R4 invariant"),
                "Error message must cite R4 invariant; got: \(ctx.debugDescription)")
        }
    }

    // MARK: Test 2 — future RTSC attestation w/ ANY_FAIL is rejected

    func testFutureRTSCAttestationRequiresAllPass() throws {
        // Synthetic future record — domain=rtsc + absorbed=true but
        // 5-gate aggregate = ANY_FAIL → decoder MUST throw.
        let json = """
        {
          "domain": "rtsc",
          "verb": "verify",
          "kind": "synth_future_rtsc_candidate",
          "stamp": "20260601T000000Z",
          "producer": "synth_future_producer.py@v1",
          "measurement_gate": "GATE_CLOSED_MEASURED",
          "absorbed": true,
          "gate_type": "rtsc-5-gate-attestation",
          "provisional": false,
          "rtsc_5_gate_evaluation": {
            "a_synthesis_replicated": "PASS",
            "b_tc_above_270k": "PASS",
            "c_ambient_pressure": "FAIL",
            "d_independent_lab_replication": "PASS",
            "e_measurement_oracle_parity": "PASS",
            "aggregate": "ANY_FAIL",
            "evidence": ["synth fixture · (c) pressure FAIL trigger"],
            "rtsc_absorbed_eligible": false
          },
          "scope_caveats": ["synth fixture for R4 invariant"],
          "citations": []
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(
            try JSONDecoder().decode(MaterialAttestationRecord.self, from: json),
            "R4 invariant MUST reject: aggregate=ANY_FAIL is incompatible with absorbed=true"
        ) { err in
            guard case DecodingError.dataCorrupted(let ctx) = err else {
                XCTFail("Expected DecodingError.dataCorrupted, got \(err)")
                return
            }
            XCTAssertTrue(ctx.debugDescription.contains("ALL_PASS"),
                "Error message must cite ALL_PASS requirement; got: \(ctx.debugDescription)")
        }
    }

    // MARK: Test 3 — non-RTSC domain unconstrained (no over-reach)

    func testNonRTSCDomainNoConstraint() throws {
        // domain=energy + absorbed=true → R4 invariant must NOT
        // require rtsc_5_gate_evaluation. Mirrors the existing solar-
        // pyranometer absorbed=true precedent (D110 / κ-68 G29 land).
        let json = """
        {
          "domain": "energy",
          "verb": "verify",
          "kind": "solar_pyranometer_attestation",
          "stamp": "20260521T030739Z",
          "producer": "nrel_midc_pyranometer@v1",
          "measurement_gate": "GATE_CLOSED_MEASURED",
          "absorbed": true,
          "gate_type": "measured-oracle-attestation",
          "provisional": false,
          "scope_caveats": ["clear-sky filter applied"],
          "citations": ["NREL MIDC SRRL"]
        }
        """.data(using: .utf8)!

        let rec = try JSONDecoder().decode(MaterialAttestationRecord.self, from: json)
        XCTAssertEqual(rec.domain, "energy")
        XCTAssertTrue(rec.absorbed)
        XCTAssertNil(rec.rtsc_5_gate_evaluation,
            "non-rtsc domain MUST NOT require rtsc_5_gate_evaluation (invariant does not over-reach)")
    }

    // MARK: Bonus — round-trip + ALL_PASS happy path

    func testRTSCAttestationAllPassRoundTrip() throws {
        let gate = RTSC5GateEvaluation(
            a_synthesis_replicated: .pass,
            b_tc_above_270K: .pass,
            c_ambient_pressure: .pass,
            d_independent_lab_replication: .pass,
            e_measurement_oracle_parity: .pass,
            aggregate: .allPass,
            evidence: [
                "(a) 3-lab synthesis replication · synth fixture",
                "(b) Tc=295K · synth fixture",
                "(c) ambient · synth fixture",
                "(d) 3 indep lab Meissner · synth fixture",
                "(e) model-vs-measured rel_err 0.02 < 0.05 · synth fixture"
            ],
            rtsc_absorbed_eligible: true)

        let rec = MaterialAttestationRecord(
            domain: "rtsc",
            verb: "verify",
            kind: "synth_future_rtsc_allpass",
            stamp: "20260701T000000Z",
            producer: "synth_allpass@v1",
            measurementGate: .closedMeasured,
            absorbed: true,
            gateType: "rtsc-5-gate-attestation",
            provisional: false,
            rtsc_5_gate_evaluation: gate,
            scopeCaveats: ["synth"],
            citations: [])

        let enc = JSONEncoder()
        let dec = JSONDecoder()
        let data = try enc.encode(rec)
        let back = try dec.decode(MaterialAttestationRecord.self, from: data)
        XCTAssertEqual(back, rec, "ALL_PASS round-trip must be lossless")
        XCTAssertEqual(back.rtsc_5_gate_evaluation?.aggregate, .allPass)
        XCTAssertTrue(back.absorbed)
    }

    // MARK: Bonus — deriveAggregate helper sanity

    func testDeriveAggregateHelper() {
        XCTAssertEqual(
            RTSC5GateEvaluation.deriveAggregate(.pass, .pass, .pass, .pass, .pass),
            .allPass)
        XCTAssertEqual(
            RTSC5GateEvaluation.deriveAggregate(.pass, .fail, .pass, .pass, .pass),
            .anyFail)
        XCTAssertEqual(
            RTSC5GateEvaluation.deriveAggregate(.pass, .skipped, .pass, .pass, .pass),
            .insufficient)
        XCTAssertEqual(
            RTSC5GateEvaluation.deriveAggregate(.skipped, .skipped, .skipped, .skipped, .skipped),
            .insufficient)
    }
}
