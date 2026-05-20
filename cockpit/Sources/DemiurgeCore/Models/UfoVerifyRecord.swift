// UfoVerifyRecord — typed Codable for `ufo + verify` cell.
//
// G5 (ARCH.md §11.4) — preregistered falsifiers are typed array, not
// loose CSV. hexa-ufo v1.0.0 ships 13 OPEN falsifiers (F-WARP-{1..3}
// + F-WORM-{1..3} + F-DIM-{1..3} + F-USE-{1..4}); a verify run reports
// each entry's monotone status (OPEN / CONFIRMED / DEMOTED).
//
// D80 honesty: ufo+verify cannot flip `absorbed=true` until every
// Stage-4-7 falsifier has CONFIRMED evidence (currently 0/13). The
// substrate emits this record as a state snapshot, not as a parity
// closure.

import Foundation

public struct UfoVerifyRecord: Codable, Sendable, Equatable {
    public let domain: String
    public let verb: String
    public let kind: String
    public let stamp: String
    public let producer: String
    public let measurementGate: F1F2Record.MeasurementGate
    public let absorbed: Bool
    public let scopeCaveats: [String]
    public let citations: [String]
    /// G5 — 13 preregistered falsifiers (F-WARP/WORM/DIM/USE).
    public let falsifiers: [FalsifierEntry]?
    /// D80 — link to the hexa-native parity port path, when one
    /// exists (nil otherwise, signaling provisional=true if
    /// absorbed is set).
    public let hexaNativeParity: HexaNativeParityRef?
    public let alienIndex: String?
    public let skippedReason: String?

    enum CodingKeys: String, CodingKey {
        case domain, verb, kind, stamp, producer
        case measurementGate = "measurement_gate"
        case absorbed
        case scopeCaveats = "scope_caveats"
        case citations
        case falsifiers
        case hexaNativeParity = "hexa_native_parity"
        case alienIndex = "alien_index"
        case skippedReason = "skipped_reason"
    }
}

/// D80 — pointer to the hexa-native kernel that proves parity for a
/// record. When emitted absorbed=true, this MUST be non-nil; otherwise
/// the record is `provisional` (D80 g_hexa_only).
public struct HexaNativeParityRef: Codable, Sendable, Equatable {
    /// Repo path of the hexa-native kernel (e.g. "hexa-lang/stdlib/
    /// cern/oracle_fodo_twiss.hexa").
    public let ref: String
    /// Observed relative error vs the transitional substrate.
    public let relErr: Double
    /// Tolerance for parity acceptance.
    public let tolerance: Double

    public init(ref: String, relErr: Double, tolerance: Double) {
        self.ref = ref
        self.relErr = relErr
        self.tolerance = tolerance
    }

    enum CodingKeys: String, CodingKey {
        case ref
        case relErr = "rel_err"
        case tolerance
    }
}
