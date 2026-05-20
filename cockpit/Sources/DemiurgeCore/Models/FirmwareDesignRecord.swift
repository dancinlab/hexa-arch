// FirmwareDesignRecord — firmware + design (D73, 16th domain).
// SSOT: ~/core/hexa-lang/stdlib/firmware/design.py. D72: adapter-only.
// g3: GATE_OPEN / absorbed=false; arm-none-eabi-gcc missing → skip.

import Foundation

public struct FirmwareDesignRecord: Codable, Equatable, Sendable {
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
