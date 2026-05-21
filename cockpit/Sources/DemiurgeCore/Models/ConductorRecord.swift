// ConductorRecord — the material-side → device-side handoff schema
// (RTSC.md §8.5). One ConductorRecord describes a *characterized
// conductor* (Tc, Hc2, Jc, anisotropy γ, vendor, source) that a
// device-side producer like `stdlib/rtsc/getdp_hts.py` consumes to
// fill `nu[Coil]`, `Jc_limit`, `Hc2_limit` in the FEM stack.
//
// Position in the domain graph:
//
//   material-side (RTSC.md §8)             device-side (RTSC.md §1-§7)
//   ─────────────────────────              ───────────────────────────
//   synthesis · falsifier  ─── ingest ───►  rtsc · verify · analyze
//                          ConductorRecord
//
// The cockpit treats ConductorRecord as a *consumed* typed interface
// (g_cockpit_isolation a — read-only via `../exports/conductor/**`);
// the producer is hexa-rtsc or an external vendor datasheet ingest
// step, NOT the cockpit itself.
//
// g3 honest stance (RTSC.md §8.7) — non-negotiable:
//   • absorbed=false until vendor datasheet + INDEPENDENT lab
//     cross-validation. First-ingest records are absorbed=false.
//   • jc_data_table_ref_record_id MAY be null on first ingest; the
//     real Jc(B, T, θ) table lands as a separate Tier 3
//     MeasurementRecord PR (RTSC.md §8.7 4-tier expansion).
//   • citations + sourceProvenance are MANDATORY.
//   • For claimOnlyHypothetical or hexaRtscN6Candidate families,
//     absorbed=false FOREVER and gate_type MUST be
//     "empirically-unproven" — demiurge MUST NOT launder a claim into
//     an absorbed material spec.
//
// Schema mirror — RTSC.md §8.5 YAML stub:
//   domain: conductor / verb: ingest / kind: rebco_2g_hts_tape etc.

import Foundation

public struct ConductorRecord: Codable, Equatable, Sendable {
    public let domain: String
    public let verb: String
    public let kind: String
    public let stamp: String
    public let family: ConductorMaterial
    public let compound: String
    public let spec: Spec
    public let vendor: String?
    public let sourceProvenance: SourceProvenance
    public let measurementGate: F1F2Record.MeasurementGate
    public let absorbed: Bool
    public let gateType: String?
    public let provisional: Bool?
    public let scopeCaveats: [String]
    public let citations: [String]

    /// Characterized conductor spec — what the device-side FEM
    /// producer needs to fill `nu[Coil]` / `Jc_limit` / `Hc2_limit`.
    /// All Doubles SI: K, T, A/m^2. Optional fields are null when the
    /// vendor datasheet / measurement does not cover that operating
    /// point (e.g. REBCO Hc2 at 4 K is reported but the 77 K value
    /// may or may not be on the spec sheet).
    public struct Spec: Codable, Equatable, Sendable {
        public let tcK: Double
        public let hc2TAt4K: Double?
        public let hc2TAt77K: Double?
        public let peakJcAm2At4K: Double?
        public let peakJcAm2At77K: Double?
        public let anisotropyGamma: Double?
        /// Link to a MeasurementRecord of kind "jc_b_theta" — a Tier 3
        /// Jc(B, T, θ) typed table that lands as a separate PR. Null
        /// on first ingest per RTSC.md §8.7.
        public let jcDataTableRefRecordId: String?

        enum CodingKeys: String, CodingKey {
            case tcK = "tc_k"
            case hc2TAt4K = "hc2_t_at_4k"
            case hc2TAt77K = "hc2_t_at_77k"
            case peakJcAm2At4K = "peak_jc_a_per_m2_at_4k"
            case peakJcAm2At77K = "peak_jc_a_per_m2_at_77k"
            case anisotropyGamma = "anisotropy_gamma"
            case jcDataTableRefRecordId = "jc_data_table_ref_record_id"
        }
    }

    /// Source provenance (RTSC.md §8.5 provenance block). The
    /// `sourceSubstrate` enum is open-set string so a new ingest
    /// origin (e.g. "lab-measured") never breaks decode; downstream
    /// cockpit code maps unknown values to a REJECTED card.
    public struct SourceProvenance: Codable, Equatable, Sendable {
        /// One of: "hexa-rtsc" | "vendor-datasheet" | "external-paper"
        /// | "lab-measured".
        public let sourceSubstrate: String
        public let sourceRecordUrl: String?
        public let sourceCitation: String?

        enum CodingKeys: String, CodingKey {
            case sourceSubstrate = "source_substrate"
            case sourceRecordUrl = "source_record_url"
            case sourceCitation = "source_citation"
        }
    }

    enum CodingKeys: String, CodingKey {
        case domain, verb, kind, stamp, family, compound, spec, vendor
        case sourceProvenance = "source_provenance"
        case measurementGate = "measurement_gate"
        case absorbed
        case gateType = "gate_type"
        case provisional
        case scopeCaveats = "scope_caveats"
        case citations
    }
}
