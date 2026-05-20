// CernAnalyzeXsuiteRecord — typed sidecar for the `cern + analyze`
// xsuite-tracking variant (D74 ProducerRegistry; ROI 14 substrate
// κ-49). Mirror of the JSON shape emitted by
// `~/core/hexa-lang/stdlib/cern/elegant_tracking.py`.
//
// D74 phased rollout: this lifts the xsuite-tracking record out of
// raw-json territory so cockpit's RecordView can render it with the
// same typed-display polish as the pylhe legacy CernAnalyzeRecord.
//
// HONEST (g3): the substrate carries the same scope caveats as the
// cern+synthesize sibling — toy FODO, optics only, NOT a sourced
// ring lattice. measurement_gate stays GATE_OPEN / absorbed=false
// until a sourced LHC / FCC-ee / SPS lattice + measured tune lands.

import Foundation

public struct CernAnalyzeXsuiteHeadline: Codable, Equatable, Sendable {
    public let numTurns: Int?
    public let particleSurvival: Int?

    enum CodingKeys: String, CodingKey {
        case numTurns = "num_turns"
        case particleSurvival = "particle_survival"
    }
}

public struct CernAnalyzeXsuiteRecord: Codable, Equatable, Sendable {
    public let domain: String
    public let verb: String
    public let kind: String
    public let stamp: String
    public let producer: String
    public let measurementGate: F1F2Record.MeasurementGate
    public let absorbed: Bool
    public let scopeCaveats: [String]
    public let citations: [String]
    public let skippedReason: String?
    public let headline: CernAnalyzeXsuiteHeadline?

    enum CodingKeys: String, CodingKey {
        case domain, verb, kind, stamp, producer
        case measurementGate = "measurement_gate"
        case absorbed
        case scopeCaveats = "scope_caveats"
        case citations
        case skippedReason = "skipped_reason"
        case headline
    }
}
