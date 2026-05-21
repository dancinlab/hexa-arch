// RTSC5GateEvaluation — constitution.md v1.4.0 R4 Stage 1 enforcement.
//
// SSOT: RTSC.md §8.9 ("진짜 RTSC absorbed=true 5-criteria gate") — the
// SOLE definition of *RTSC material* absorbed=true. Pattern 1 (namespace
// exploit — LTS Nb 가 `domain: "rtsc"` 박혀서 RTSC validation 으로 오독)
// 의 doctrinal lock: 5-gate field 가 attestation record 에 박혀야
// human-readable summary 가 "RTSC absorbed=true" 표현 가능.
//
// 5-criteria gate (RTSC.md §8.9):
//   (a) synthesis_replicated         — 합성 protocol 가 ≥ 3 lab 에서 재현
//   (b) tc_above_270K                — Tc ≥ 270 K (room-temperature 정의)
//   (c) ambient_pressure             — ≤ 1 atm (Hydride 의 GPa range 배제)
//   (d) independent_lab_replication  — ≥ 3 독립 lab 측정 재현
//   (e) measurement_oracle_parity    — Tier1 model vs Tier3 measured
//                                       rel_err < threshold (default 5%)
//
// Aggregate semantics:
//   - aggregate == .allPass  → rtsc_absorbed_eligible = true (5/5 PASS).
//   - aggregate == .anyFail  → any single gate FAIL → permanent FAIL.
//   - aggregate == .insufficient → mix of PASS + SKIPPED (or all SKIPPED);
//     NOT yet eligible for absorbed=true; remains gate-OPEN for future
//     evaluation rounds (R4 goal-preservation; matrix is append-only).
//
// 5-gate evidence references — per-gate citation string list. R4
// honesty floor: every gate state MUST have evidence — empty array is
// permitted only when ALL gates are .skipped (no claim made).
//
// D103 dimension separation reminder — RTSC5GateEvaluation lives on the
// *measured* dimension axis (RFC 013 §6.11 measured-oracle parity).
// Substrate-parity (HexaNativeParityRef) is independent and does NOT
// participate in the 5-gate evaluation.
//
// Cross-refs:
//   - constitution.md R4 (RTSC absorbed=true twin-error invariant)
//   - RTSC.md §8.9 (5-criteria gate) · §8.10 (Nb honest correction)
//   - MaterialAttestationRecord.swift (carrier record + decoder
//     invariant assertion)

import Foundation

public struct RTSC5GateEvaluation: Codable, Equatable, Sendable {

    /// Per-gate state. PASS = criterion met with cited evidence.
    /// FAIL = criterion explicitly violated (e.g. Tc = 9.25 K → (b)
    /// FAIL). SKIPPED = criterion not evaluated (insufficient data /
    /// out-of-scope for this attestation). Critical: SKIPPED is NOT
    /// PASS; it leaves the aggregate `.insufficient`, blocking the
    /// absorbed=true claim.
    public enum GateState: String, Codable, CaseIterable, Sendable {
        case pass = "PASS"
        case fail = "FAIL"
        case skipped = "SKIPPED"
    }

    /// Aggregate verdict across the 5 gates. Computed deterministically
    /// from the per-gate states by the producer (NOT auto-derived in
    /// the Codable layer — producers MUST set this explicitly so the
    /// decode can cross-check producer intent against the per-gate
    /// states; mismatch → decoding failure in the carrier record).
    public enum Aggregate: String, Codable, Sendable {
        case allPass = "ALL_PASS"
        case anyFail = "ANY_FAIL"
        case insufficient = "INSUFFICIENT"
    }

    /// §8.9 (a) — synthesis protocol replicated by independent labs.
    public let a_synthesis_replicated: GateState

    /// §8.9 (b) — measured Tc ≥ 270 K.
    public let b_tc_above_270K: GateState

    /// §8.9 (c) — measurement performed at ≤ 1 atm (ambient pressure).
    public let c_ambient_pressure: GateState

    /// §8.9 (d) — independent lab replication count ≥ 3.
    public let d_independent_lab_replication: GateState

    /// §8.9 (e) — measurement-oracle parity (Tier 1 model vs Tier 3
    /// measured) below threshold; default threshold 5% rel_err.
    public let e_measurement_oracle_parity: GateState

    /// Aggregate verdict. See `Aggregate` for semantics.
    public let aggregate: Aggregate

    /// Per-gate evidence references — one citation/record-id string
    /// per piece of evidence (free-form). May be empty only when all
    /// 5 gates are .skipped (no claim being made).
    public let evidence: [String]

    /// Eligibility predicate (stored — producer MUST set this true
    /// IFF `aggregate == .allPass`). MaterialAttestationRecord decoder
    /// cross-checks this field against the aggregate value.
    public let rtsc_absorbed_eligible: Bool

    public init(
        a_synthesis_replicated: GateState,
        b_tc_above_270K: GateState,
        c_ambient_pressure: GateState,
        d_independent_lab_replication: GateState,
        e_measurement_oracle_parity: GateState,
        aggregate: Aggregate,
        evidence: [String],
        rtsc_absorbed_eligible: Bool
    ) {
        self.a_synthesis_replicated = a_synthesis_replicated
        self.b_tc_above_270K = b_tc_above_270K
        self.c_ambient_pressure = c_ambient_pressure
        self.d_independent_lab_replication = d_independent_lab_replication
        self.e_measurement_oracle_parity = e_measurement_oracle_parity
        self.aggregate = aggregate
        self.evidence = evidence
        self.rtsc_absorbed_eligible = rtsc_absorbed_eligible
    }

    enum CodingKeys: String, CodingKey {
        case a_synthesis_replicated = "a_synthesis_replicated"
        case b_tc_above_270K = "b_tc_above_270k"
        case c_ambient_pressure = "c_ambient_pressure"
        case d_independent_lab_replication = "d_independent_lab_replication"
        case e_measurement_oracle_parity = "e_measurement_oracle_parity"
        case aggregate
        case evidence
        case rtsc_absorbed_eligible = "rtsc_absorbed_eligible"
    }

    /// Convenience — derive the aggregate from the per-gate states.
    /// Producers may use this to compute aggregate before constructing
    /// the struct; the Codable layer does NOT call it (the stored
    /// `aggregate` is the SSOT for cross-checking).
    public static func deriveAggregate(
        _ a: GateState,
        _ b: GateState,
        _ c: GateState,
        _ d: GateState,
        _ e: GateState
    ) -> Aggregate {
        let all = [a, b, c, d, e]
        if all.contains(.fail) { return .anyFail }
        if all.allSatisfy({ $0 == .pass }) { return .allPass }
        return .insufficient
    }
}
