// FirmwareVerifyRecord — firmware + verify (D73, 16th domain).
// SSOT: ~/core/hexa-lang/stdlib/firmware/verify.py. D72: adapter-only.
// g3: GATE_OPEN / absorbed=false; qemu-system-arm missing → skip.

import Foundation

public struct FirmwareVerifyRecord: Codable, Equatable, Sendable {
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
