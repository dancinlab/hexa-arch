// F1F2Record — Codable mirror of rfc_002 v1.0 schema (the chip:noc:F1F2 typed
// record produced by demiurge[chip] for downstream consumers).
//
// rfc_002 §3 (schema) + §4 (provenance / no-over-claim required fields).
// Forward-compat per rfc_002 §6 unknown-key idiom: this struct decodes only
// the fields the UI renders; Swift Codable already ignores extra keys, so
// producer schema growth never breaks the cockpit (D27 monorepo schema-drift
// is still caught by review since model + records live in one repo).
//
// @D g_cockpit_isolation (a): this file decodes records read from
// ../exports/** only; it neither imports nor writes any producer-side state.

import Foundation

struct F1F2Record: Codable, Identifiable {
    let interface: String
    let schemaVersion: String
    let recordId: String
    let producedAtUtc: String
    let topology: Topology
    let traffic: String
    let verdict: Verdict
    let provenance: Provenance

    var id: String { recordId }

    struct Topology: Codable {
        let kind: String
        let degree: Int
        let nodeCount: Int
        let routing: String
    }

    struct Verdict: Codable {
        let f1: String
        let f2: String
        let rationale: String
    }

    /// rfc_002 §4 — the honesty-as-feature payload.
    /// The cockpit MUST render every field VERBATIM (rfc_009 §4); it never
    /// upgrades a claim. Missing -> the consumer renders a REJECTED card.
    struct Provenance: Codable {
        let absorbed: Bool
        let measurementGate: MeasurementGate
        let simEngine: String
        let simCommitHash: String
        let gateFailures: [String]
        let consumerTarget: String
        let atlasCiteBlock: String
        let scopeCaveats: [String]
    }

    /// rfc_002 §4 measurement_gate enum.
    enum MeasurementGate: String, Codable {
        case open               = "GATE_OPEN"
        case bPinnedMet         = "GATE_B_PINNED_MET"
        case closedMeasured     = "GATE_CLOSED_MEASURED"
        case failed             = "GATE_FAILED"

        var displayLabel: String { rawValue }
    }
}
