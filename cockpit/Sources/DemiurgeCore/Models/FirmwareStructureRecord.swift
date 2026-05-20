// FirmwareStructureRecord — firmware + structure (D73, 16th domain).
// SSOT: ~/core/hexa-lang/stdlib/firmware/structure.py. D72: adapter-only.
// g3: GATE_OPEN / absorbed=false; west missing → honest install-gated skip.

import Foundation

public struct FirmwareStructureRecord: Codable, Equatable, Sendable {
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

    enum CodingKeys: String, CodingKey {
        case domain, verb, kind, stamp, producer
        case measurementGate = "measurement_gate"
        case absorbed
        case scopeCaveats = "scope_caveats"
        case citations
        case skippedReason = "skipped_reason"
    }
}
