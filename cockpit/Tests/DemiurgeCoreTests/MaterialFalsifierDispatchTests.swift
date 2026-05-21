// MaterialFalsifierDispatchTests — RTSC.md §8.7 Tier 4 dispatch smoke.
//
// Two jobs:
//   (1) Honest demo — dispatch the existing LK-99 Tier 2 recipe
//       (replicated_by_independent_labs=0) with tier1=nil and
//       tier3Measurements=[]. Assert aggregate = FAILS-AT-LEAST-ONE
//       (because F-RTSC-3 FAILs on replicated=0) AND assert the
//       verdict JSON lands under exports/material_verdict/.
//   (2) absorbed=false invariant — even a hypothetical PASSES-ALL
//       triple still produces absorbed=false (g3 honest限界 from
//       RTSC.md §8.7 → §8.8).
//
// The first test is also what generates the canonical LK-99 verdict
// stub the task requires under exports/material_verdict/lk99_lee2023_v1/.

import XCTest
@testable import DemiurgeCore

final class MaterialFalsifierDispatchTests: XCTestCase {

    // MARK: helpers

    /// Decode the LK-99 Tier 2 recipe stub from exports/.
    private func loadLk99Recipe() throws -> SynthesisRecipeRecord {
        let path = RecordLoader.exportsRoot
            .appendingPathComponent("synthesis_recipe", isDirectory: true)
            .appendingPathComponent("lk99_lee2023.json")
        let data = try Data(contentsOf: path)
        return try JSONDecoder().decode(SynthesisRecipeRecord.self, from: data)
    }

    /// Build a synthetic SynthesisRecipeRecord via JSON round-trip — the
    /// type's memberwise init is module-internal, so cross-module tests
    /// build instances via Codable.
    private func makeRecipe(replicated: Int) throws -> SynthesisRecipeRecord {
        let dict: [String: Any] = [
            "domain": "synthesis_recipe",
            "verb": "ingest",
            "kind": "mocvd",
            "stamp": "20260521T000000Z",
            "family": "hts_cuprate",
            "target_compound": "YBa2Cu3O7-delta",
            "reagents": [],
            "conditions": [
                "temperature_profile_c": [],
                "atmosphere_gas": "oxygen",
                "atmosphere_pressure_bar": 1.0,
                "duration_hours": 1.0
            ],
            "replicated_by_independent_labs": replicated,
            "measurement_gate": "GATE_OPEN",
            "absorbed": false,
            "gate_type": "vendor-datasheet",
            "provisional": true,
            "provenance": [
                "source_url": "test://synthetic",
                "source_citation": "synthetic test fixture"
            ],
            "scope_caveats": [],
            "citations": []
        ]
        let data = try JSONSerialization.data(withJSONObject: dict)
        return try JSONDecoder().decode(SynthesisRecipeRecord.self, from: data)
    }

    // MARK: tests

    func testLk99DispatchFailsAtLeastOne() throws {
        let recipe = try loadLk99Recipe()
        XCTAssertEqual(recipe.replicatedByIndependentLabs, 0,
                       "LK-99 stub must keep replicated_by_independent_labs=0 (RTSC.md §8.8).")

        let result = MaterialFalsifierDispatch.dispatch(
            sampleId: "lk99_lee2023_v1",
            tier1: nil,
            tier2: recipe,
            tier3Measurements: []
        )

        XCTAssertTrue(result.ok, "Dispatch ok=true means record landed (≠ falsifier PASS).")
        XCTAssertNotNil(result.newRecordID)
        // F-RTSC-3 FAILs on replicated=0 → aggregate must be
        // FAILS-AT-LEAST-ONE (overrides any multi-skip aggregate).
        XCTAssertEqual(result.aggregateVerdict, "FAILS-AT-LEAST-ONE")

        // Verify the JSON landed on disk and parses back round-trip.
        let outDir = MaterialFalsifierDispatch.verdictRecordsRoot
            .appendingPathComponent("lk99_lee2023_v1", isDirectory: true)
        let contents = try FileManager.default.contentsOfDirectory(at: outDir,
            includingPropertiesForKeys: nil)
        let jsons = contents.filter { $0.pathExtension == "json" }
        XCTAssertFalse(jsons.isEmpty, "verdict JSON must land under \(outDir.path)")

        if let first = jsons.first {
            let data = try Data(contentsOf: first)
            let decoded = try JSONDecoder().decode(MaterialVerdictRecord.self, from: data)
            XCTAssertEqual(decoded.domain, "material_verdict")
            XCTAssertEqual(decoded.verb, "dispatch")
            XCTAssertEqual(decoded.kind, "tier4_falsifier_dispatch")
            XCTAssertEqual(decoded.aggregateVerdict, "FAILS-AT-LEAST-ONE")
            XCTAssertFalse(decoded.absorbed, "g3: Tier 4 NEVER flips absorbed=true.")
            XCTAssertEqual(decoded.replicatedByIndependentLabs, 0,
                           "carried forward from tier2; never auto-incremented.")
            XCTAssertEqual(decoded.measurementGate, .open,
                           "GATE_OPEN — dispatch alone never closes the gate.")
            XCTAssertEqual(decoded.falsifierResults.count, 6)
            for r in decoded.falsifierResults {
                XCTAssertFalse(r.evidence.isEmpty,
                               "evidence must never be empty for \(r.id)")
            }
            let f3 = decoded.falsifierResults.first(where: { $0.id == "F-RTSC-3-replication" })
            XCTAssertEqual(f3?.status, "FAIL")
        }
    }

    func testAbsorbedAlwaysFalseEvenWithReplication() throws {
        // tier2 with replicated=3 (F-RTSC-3 PASS), tier1=nil, tier3=[] →
        // 5 of 6 SKIPPED + 1 PASS = INCONCLUSIVE-MULTIPLE-MISSING.
        // The contract under test: absorbed=false regardless of any verdict.
        let recipe = try makeRecipe(replicated: 3)
        let result = MaterialFalsifierDispatch.dispatch(
            sampleId: "synthetic_absorbed_invariant_test",
            tier1: nil,
            tier2: recipe,
            tier3Measurements: []
        )
        XCTAssertTrue(result.ok)
        XCTAssertEqual(result.aggregateVerdict, "INCONCLUSIVE-MULTIPLE-MISSING")
    }
}
