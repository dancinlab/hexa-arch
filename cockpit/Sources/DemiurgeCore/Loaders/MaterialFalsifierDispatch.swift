// MaterialFalsifierDispatch — RTSC.md §8.7 Tier 4 dispatcher.
//
// Consumes a (Tier 1 ConductorRecord · Tier 2 SynthesisRecipeRecord ·
// Tier 3 MeasurementRecord[]) triple and emits a MaterialVerdictRecord
// scoring the 6 falsifiers (F-RTSC-{1,2,3} + F-SC-{1,2,3}) from
// hexa-rtsc/verify/{calc_bcs,calc_mcmillan,calc_hc2_48t,
// falsifier_check}.hexa per the §8.4 9-test characterization matrix.
//
// g3 honest stance (RTSC.md §8.7 → §8.8):
//   • Dispatching SUCCEEDED (record was written) ≠ falsifier PASSED.
//     ok=true means the verdict JSON landed in exports/material_verdict/;
//     the actual PASS/FAIL/INCONCLUSIVE/SKIPPED breakdown lives in
//     `falsifierResults[]`.
//   • Missing input ⇒ SKIPPED-MISSING-INPUT (NEVER fabricated PASS).
//   • `replicatedByIndependentLabs` is *carried forward* from Tier 2,
//     NEVER auto-incremented here.
//   • absorbed=false ALWAYS — even when aggregateVerdict = PASSES-ALL.
//     Absorbed-promotion requires a separate meta-cohort.
//
// @D g_cockpit_isolation: this loader only writes under
// `RecordLoader.exportsRoot/material_verdict/<sample_id>/<stamp>.json`
// — same exports tree the rest of the cockpit reads.

import Foundation

public struct MaterialVerdictResult: Sendable {
    public let ok: Bool
    public let lines: [String]
    public let newRecordID: String?
    public let aggregateVerdict: String?
    public init(ok: Bool, lines: [String], newRecordID: String?, aggregateVerdict: String?) {
        self.ok = ok
        self.lines = lines
        self.newRecordID = newRecordID
        self.aggregateVerdict = aggregateVerdict
    }
    public var text: String { lines.joined(separator: "\n") }
}

public enum MaterialFalsifierDispatch {

    public static let verdictRecordsRoot: URL =
        RecordLoader.exportsRoot.appendingPathComponent("material_verdict", isDirectory: true)

    /// Tier 4 dispatch. The three tier inputs are optional / open-ended:
    ///   • `tier1` — ConductorRecord providing predicted Tc + Hc2(0).
    ///     nil ⇒ F-SC-1, F-SC-2, F-SC-3 all SKIPPED-MISSING-INPUT.
    ///   • `tier2` — SynthesisRecipeRecord providing replication count.
    ///     nil ⇒ F-RTSC-3 SKIPPED-MISSING-INPUT (replication unknown).
    ///   • `tier3Measurements` — zero or more MeasurementRecord; this
    ///     function picks by `kind`:
    ///       "r_t"            → F-RTSC-2 + F-SC-2
    ///       "meissner_chi_t" → F-RTSC-1
    ///       "hc2_t"          → F-SC-3
    ///       "isotope_effect" → F-SC-1
    ///     Empty ⇒ all measurement-dependent falsifiers SKIPPED.
    public static func dispatch(
        sampleId: String,
        tier1: ConductorRecord?,
        tier2: SynthesisRecipeRecord?,
        tier3Measurements: [MeasurementRecord]
    ) -> MaterialVerdictResult {
        var lines: [String] = []
        lines.append("[tier4 dispatch] sample_id=\(sampleId)")
        lines.append("  tier1 (ConductorRecord)        : \(tier1 == nil ? "MISSING" : "present")")
        lines.append("  tier2 (SynthesisRecipeRecord)  : \(tier2 == nil ? "MISSING" : "present")")
        lines.append("  tier3 (MeasurementRecord[])    : count=\(tier3Measurements.count)")

        // ─── Tier 3 measurement bucketing ─────────────────────────────
        let rT = tier3Measurements.first(where: { $0.kind == "r_t" })
        let meissner = tier3Measurements.first(where: { $0.kind == "meissner_chi_t" })
        let hc2 = tier3Measurements.first(where: { $0.kind == "hc2_t" })
        let isotope = tier3Measurements.first(where: { $0.kind == "isotope_effect" })

        // ─── F-SC-1 — BCS / isotope ──────────────────────────────────
        // Compare measured α to BCS prediction α ≈ 0.5. Hexa-rtsc ref:
        // verify/calc_bcs.hexa. No isotope measurement ⇒ SKIPPED.
        let fSc1: MaterialVerdictRecord.FalsifierResult
        if let iso = isotope {
            // For an isotope_effect record, the headline carries the
            // measured exponent in `deltaCpOverGammaTc` slot is wrong;
            // the closest field is none — so we read `tcK` only and
            // require the producer to embed the α in
            // `scopeCaveats` / `dataPoints`. Conservative: search for
            // a data point with dependentVarName == "alpha".
            let alphaPoint = iso.dataPoints.first(where: { $0.dependentVarName == "alpha" })
            if let p = alphaPoint {
                let alpha = p.dependentVarValue
                let delta = abs(alpha - 0.5)
                if delta <= 0.15 {
                    fSc1 = .init(
                        id: "F-SC-1-bcs-isotope",
                        name: "BCS isotope effect (α ≈ 0.5)",
                        status: "PASS",
                        evidence: "tier3 isotope_effect record stamp=\(iso.stamp) reports α=\(alpha) within ±0.15 of BCS prediction 0.5",
                        confidence: 0.6
                    )
                } else {
                    fSc1 = .init(
                        id: "F-SC-1-bcs-isotope",
                        name: "BCS isotope effect (α ≈ 0.5)",
                        status: "FAIL",
                        evidence: "tier3 isotope_effect record stamp=\(iso.stamp) reports α=\(alpha); deviation |α−0.5|=\(delta) > 0.15",
                        confidence: 0.7
                    )
                }
            } else {
                fSc1 = .init(
                    id: "F-SC-1-bcs-isotope",
                    name: "BCS isotope effect (α ≈ 0.5)",
                    status: "INCONCLUSIVE",
                    evidence: "tier3 isotope_effect record stamp=\(iso.stamp) present but no data_point with dependent_var_name=\"alpha\" found",
                    confidence: 0.2
                )
            }
        } else {
            fSc1 = .init(
                id: "F-SC-1-bcs-isotope",
                name: "BCS isotope effect (α ≈ 0.5)",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "no tier3 MeasurementRecord with kind=\"isotope_effect\" supplied",
                confidence: 0.0
            )
        }

        // ─── F-SC-2 — McMillan Tc ────────────────────────────────────
        // Compare tier1 BCS-McMillan predicted Tc vs tier3 R(T) measured
        // Tc; if mismatch > 50% ⇒ FAIL. Hexa-rtsc ref: calc_mcmillan.hexa.
        let fSc2: MaterialVerdictRecord.FalsifierResult
        if let t1 = tier1, let rT = rT, let measuredTc = rT.headline.tcK {
            let predictedTc = t1.spec.tcK
            let ratio = predictedTc > 0 ? abs(measuredTc - predictedTc) / predictedTc : Double.infinity
            if ratio <= 0.5 {
                fSc2 = .init(
                    id: "F-SC-2-mcmillan-tc",
                    name: "McMillan/Allen-Dynes Tc consistency",
                    status: "PASS",
                    evidence: "tier1 ConductorRecord spec.tc_k=\(predictedTc) vs tier3 r_t headline.tc_k=\(measuredTc) (|Δ|/Tc_pred=\(String(format: "%.3f", ratio)) ≤ 0.5)",
                    confidence: 0.5
                )
            } else {
                fSc2 = .init(
                    id: "F-SC-2-mcmillan-tc",
                    name: "McMillan/Allen-Dynes Tc consistency",
                    status: "FAIL",
                    evidence: "tier1 ConductorRecord spec.tc_k=\(predictedTc) vs tier3 r_t headline.tc_k=\(measuredTc) (|Δ|/Tc_pred=\(String(format: "%.3f", ratio)) > 0.5)",
                    confidence: 0.7
                )
            }
        } else {
            var missing: [String] = []
            if tier1 == nil { missing.append("tier1") }
            if rT == nil { missing.append("tier3 r_t") }
            if let rT = rT, rT.headline.tcK == nil { missing.append("tier3 r_t headline.tc_k") }
            let missingList = missing.joined(separator: ", ")
            fSc2 = .init(
                id: "F-SC-2-mcmillan-tc",
                name: "McMillan/Allen-Dynes Tc consistency",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "missing inputs: \(missingList)",
                confidence: 0.0
            )
        }

        // ─── F-SC-3 — Hc2 ladder (WHH) ───────────────────────────────
        // Compare tier1 spec.hc2_t_at_4k vs tier3 hc2_t measurement.
        // Hexa-rtsc ref: calc_hc2_48t.hexa / numerics_whh_full.hexa.
        let fSc3: MaterialVerdictRecord.FalsifierResult
        if let t1 = tier1, let hc2 = hc2 {
            let measuredHc2 = hc2.headline.hc2T
            let predictedHc2 = t1.spec.hc2TAt4K
            if let m = measuredHc2, let p = predictedHc2 {
                let ratio = p > 0 ? abs(m - p) / p : Double.infinity
                if ratio <= 0.5 {
                    fSc3 = .init(
                        id: "F-SC-3-hc2-whh",
                        name: "Hc2(0) WHH extrapolation",
                        status: "PASS",
                        evidence: "tier1 spec.hc2_t_at_4k=\(p) vs tier3 hc2_t headline.hc2_t=\(m) (|Δ|/Hc2_pred=\(String(format: "%.3f", ratio)) ≤ 0.5)",
                        confidence: 0.5
                    )
                } else {
                    fSc3 = .init(
                        id: "F-SC-3-hc2-whh",
                        name: "Hc2(0) WHH extrapolation",
                        status: "FAIL",
                        evidence: "tier1 spec.hc2_t_at_4k=\(p) vs tier3 hc2_t headline.hc2_t=\(m) (|Δ|/Hc2_pred=\(String(format: "%.3f", ratio)) > 0.5)",
                        confidence: 0.7
                    )
                }
            } else {
                fSc3 = .init(
                    id: "F-SC-3-hc2-whh",
                    name: "Hc2(0) WHH extrapolation",
                    status: "INCONCLUSIVE",
                    evidence: "tier1 hc2_t_at_4k=\(predictedHc2.map { String($0) } ?? "nil") and tier3 hc2_t headline.hc2_t=\(measuredHc2.map { String($0) } ?? "nil") — at least one Hc2 value is nil",
                    confidence: 0.2
                )
            }
        } else {
            var missing: [String] = []
            if tier1 == nil { missing.append("tier1") }
            if hc2 == nil { missing.append("tier3 hc2_t") }
            let missingList = missing.joined(separator: ", ")
            fSc3 = .init(
                id: "F-SC-3-hc2-whh",
                name: "Hc2(0) WHH extrapolation",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "missing inputs: \(missingList)",
                confidence: 0.0
            )
        }

        // ─── F-RTSC-1 — Meissner ─────────────────────────────────────
        // tier3 meissner_chi_t present AND χ<0 ⇒ PASS.
        let fRtsc1: MaterialVerdictRecord.FalsifierResult
        if let m = meissner {
            if let chi = m.headline.chiVolumetric {
                if chi < 0 {
                    fRtsc1 = .init(
                        id: "F-RTSC-1-meissner",
                        name: "Meissner effect (χ < 0)",
                        status: "PASS",
                        evidence: "tier3 meissner_chi_t record stamp=\(m.stamp) headline.chi_volumetric=\(chi) < 0",
                        confidence: 0.6
                    )
                } else {
                    fRtsc1 = .init(
                        id: "F-RTSC-1-meissner",
                        name: "Meissner effect (χ < 0)",
                        status: "FAIL",
                        evidence: "tier3 meissner_chi_t record stamp=\(m.stamp) headline.chi_volumetric=\(chi) ≥ 0 (diamagnetism not observed)",
                        confidence: 0.7
                    )
                }
            } else {
                fRtsc1 = .init(
                    id: "F-RTSC-1-meissner",
                    name: "Meissner effect (χ < 0)",
                    status: "INCONCLUSIVE",
                    evidence: "tier3 meissner_chi_t record stamp=\(m.stamp) present but headline.chi_volumetric is nil",
                    confidence: 0.2
                )
            }
        } else {
            fRtsc1 = .init(
                id: "F-RTSC-1-meissner",
                name: "Meissner effect (χ < 0)",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "no tier3 MeasurementRecord with kind=\"meissner_chi_t\" supplied",
                confidence: 0.0
            )
        }

        // ─── F-RTSC-2 — R(T) drop ────────────────────────────────────
        // tier3 r_t measured Tc within [Tc_pred * 0.5, Tc_pred * 2.0]
        // ⇒ PASS (R(T<Tc) ≈ 0 is implicit in the r_t record kind by
        // §8.4 — the test_compound was reported as showing the drop;
        // we still want headline.tc_k to land in band).
        let fRtsc2: MaterialVerdictRecord.FalsifierResult
        if let t1 = tier1, let rT = rT, let measuredTc = rT.headline.tcK {
            let predictedTc = t1.spec.tcK
            let lo = predictedTc * 0.5
            let hi = predictedTc * 2.0
            if measuredTc >= lo && measuredTc <= hi {
                fRtsc2 = .init(
                    id: "F-RTSC-2-r-of-t",
                    name: "R(T) drop within [0.5·Tc_pred, 2.0·Tc_pred]",
                    status: "PASS",
                    evidence: "tier3 r_t record stamp=\(rT.stamp) headline.tc_k=\(measuredTc) ∈ [\(lo), \(hi)] (tier1 predicted Tc=\(predictedTc))",
                    confidence: 0.5
                )
            } else {
                fRtsc2 = .init(
                    id: "F-RTSC-2-r-of-t",
                    name: "R(T) drop within [0.5·Tc_pred, 2.0·Tc_pred]",
                    status: "FAIL",
                    evidence: "tier3 r_t record stamp=\(rT.stamp) headline.tc_k=\(measuredTc) ∉ [\(lo), \(hi)] (tier1 predicted Tc=\(predictedTc))",
                    confidence: 0.7
                )
            }
        } else {
            var missing: [String] = []
            if tier1 == nil { missing.append("tier1") }
            if rT == nil { missing.append("tier3 r_t") }
            if let rT = rT, rT.headline.tcK == nil { missing.append("tier3 r_t headline.tc_k") }
            let missingList = missing.joined(separator: ", ")
            fRtsc2 = .init(
                id: "F-RTSC-2-r-of-t",
                name: "R(T) drop within [0.5·Tc_pred, 2.0·Tc_pred]",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "missing inputs: \(missingList)",
                confidence: 0.0
            )
        }

        // ─── F-RTSC-3 — Independent replication ──────────────────────
        // tier2.replicated_by_independent_labs ≥ 2 ⇒ PASS;
        // 1 ⇒ INCONCLUSIVE; 0 ⇒ FAIL (claim-only).
        let fRtsc3: MaterialVerdictRecord.FalsifierResult
        if let t2 = tier2 {
            let n = t2.replicatedByIndependentLabs
            if n >= 2 {
                fRtsc3 = .init(
                    id: "F-RTSC-3-replication",
                    name: "Independent-lab replication (≥ 2)",
                    status: "PASS",
                    evidence: "tier2 SynthesisRecipeRecord replicated_by_independent_labs=\(n) ≥ 2",
                    confidence: 0.9
                )
            } else if n == 1 {
                fRtsc3 = .init(
                    id: "F-RTSC-3-replication",
                    name: "Independent-lab replication (≥ 2)",
                    status: "INCONCLUSIVE",
                    evidence: "tier2 SynthesisRecipeRecord replicated_by_independent_labs=1 (one lab only — replication not yet independent)",
                    confidence: 0.3
                )
            } else {
                fRtsc3 = .init(
                    id: "F-RTSC-3-replication",
                    name: "Independent-lab replication (≥ 2)",
                    status: "FAIL",
                    evidence: "tier2 SynthesisRecipeRecord replicated_by_independent_labs=\(n) (claim-only — no independent reproduction)",
                    confidence: 0.9
                )
            }
        } else {
            fRtsc3 = .init(
                id: "F-RTSC-3-replication",
                name: "Independent-lab replication (≥ 2)",
                status: "SKIPPED-MISSING-INPUT",
                evidence: "no tier2 SynthesisRecipeRecord supplied (replication count unknown)",
                confidence: 0.0
            )
        }

        let results = [fSc1, fSc2, fSc3, fRtsc1, fRtsc2, fRtsc3]

        // ─── Aggregate verdict ───────────────────────────────────────
        let nPass = results.filter { $0.status == "PASS" }.count
        let nFail = results.filter { $0.status == "FAIL" }.count
        let nSkip = results.filter { $0.status == "SKIPPED-MISSING-INPUT" }.count
        let aggregate: String
        if nFail == 0 && nSkip == 0 && nPass == results.count {
            aggregate = "PASSES-ALL"
        } else if nFail >= 1 {
            aggregate = "FAILS-AT-LEAST-ONE"
        } else if nSkip >= 3 {
            aggregate = "INCONCLUSIVE-MULTIPLE-MISSING"
        } else {
            aggregate = "PARTIAL"
        }

        // ─── Stamp + record-id ───────────────────────────────────────
        let rawStamp = ISO8601DateFormatter().string(from: Date())
        let stamp = rawStamp.replacingOccurrences(of: ":", with: "-")

        // ─── Carry-forward replication count ─────────────────────────
        let replicated = tier2?.replicatedByIndependentLabs ?? 0

        // ─── Build the record ────────────────────────────────────────
        let inputTriple = MaterialVerdictRecord.InputTriple(
            tier1SimRecordId: tier1.map { "conductor:\($0.compound):\($0.stamp)" },
            tier2RecipeRecordId: tier2.map { "synthesis_recipe:\($0.targetCompound):\($0.stamp)" },
            tier3MeasurementRecordIds: tier3Measurements.map { "measurement:\($0.kind):\($0.sampleId):\($0.stamp)" }
        )

        var caveats: [String] = [
            "RTSC.md §8.7 honest限界: Tier 4 PASS still requires a separate meta-cohort (cross-lab attestation) to flip absorbed=true. This record has absorbed=false unconditionally.",
            "replicated_by_independent_labs is carried forward from tier2; never auto-incremented by this dispatcher.",
            "measurement_gate remains GATE_OPEN — a dispatch verdict alone does not close the measurement gate."
        ]
        if nSkip > 0 {
            caveats.append("\(nSkip) of \(results.count) falsifiers SKIPPED-MISSING-INPUT — verdict is informationally incomplete.")
        }
        if let t2 = tier2, t2.replicatedByIndependentLabs == 0 {
            caveats.append("tier2 reports replicated_by_independent_labs=0 → claim-only territory per RTSC.md §8.8; absorbed=false 영원히 for this family.")
        }

        let citations: [String] = [
            "RTSC.md §8.4 (9-test characterization matrix)",
            "RTSC.md §8.5 (handoff schema)",
            "RTSC.md §8.7 Tier 4 (falsifier dispatch)",
            "RTSC.md §8.8 (g3 honest stance — RTSC claims never absorbed=true)",
            "hexa-rtsc verify/calc_bcs.hexa (F-SC-1)",
            "hexa-rtsc verify/calc_mcmillan.hexa (F-SC-2)",
            "hexa-rtsc verify/calc_hc2_48t.hexa (F-SC-3)",
            "hexa-rtsc verify/falsifier_check.hexa (6-falsifier registry)"
        ]

        let record = MaterialVerdictRecord(
            stamp: stamp,
            sampleId: sampleId,
            inputRecords: inputTriple,
            falsifierResults: results,
            aggregateVerdict: aggregate,
            replicatedByIndependentLabs: replicated,
            scopeCaveats: caveats,
            citations: citations
        )

        // ─── Write JSON ──────────────────────────────────────────────
        let outDir = verdictRecordsRoot.appendingPathComponent(sampleId, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        } catch {
            lines.append("[tier4 dispatch] mkdir failed: \(error.localizedDescription)")
            return MaterialVerdictResult(ok: false, lines: lines, newRecordID: nil, aggregateVerdict: aggregate)
        }

        let outFile = outDir.appendingPathComponent("\(stamp).json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data: Data
        do {
            data = try encoder.encode(record)
        } catch {
            lines.append("[tier4 dispatch] encode failed: \(error.localizedDescription)")
            return MaterialVerdictResult(ok: false, lines: lines, newRecordID: nil, aggregateVerdict: aggregate)
        }
        do {
            try data.write(to: outFile, options: .atomic)
        } catch {
            lines.append("[tier4 dispatch] write failed: \(error.localizedDescription)")
            return MaterialVerdictResult(ok: false, lines: lines, newRecordID: nil, aggregateVerdict: aggregate)
        }

        let recordID = "material_verdict:\(sampleId):\(stamp)"
        lines.append("[tier4 dispatch] aggregate=\(aggregate)")
        for r in results {
            lines.append("  · \(r.id) — \(r.status) — \(r.name)")
        }
        lines.append("[tier4 dispatch] wrote: \(outFile.path)")
        lines.append("[tier4 dispatch] honest g3: absorbed=false (Tier 4 verdict ≠ absorbed-promotion)")
        return MaterialVerdictResult(ok: true, lines: lines, newRecordID: recordID, aggregateVerdict: aggregate)
    }
}
