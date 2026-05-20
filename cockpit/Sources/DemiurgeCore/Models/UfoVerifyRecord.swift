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
///
/// Schema follows the connection-plan §4.1 shape
/// (`inbox/notes/hexa-native-connection-plan-2026-05-20.md`). The
/// fields below preserve the original `(ref / relErr / tolerance)`
/// trio under new names (kernelPath / relErr / parityTolerance) and
/// add the parity-method / status / hexa-lang SHA / scope-notes
/// envelope so a downstream loader can recover the full audit trail
/// without scraping the cell's free-text caveats.
///
/// Honesty (D80 g_hexa_only): emitting this struct does NOT flip
/// `absorbed` by itself — the cell-side absorbed gate stays capped
/// at provisional until the kernel's parity test runs green AND
/// the demiurge cell consumes the kernel (not just points at it).
public struct HexaNativeParityRef: Codable, Sendable, Equatable {

    /// How the parity claim was established.
    ///
    /// - `.substrateToSubstrate` — both `.hexa` and `.py` implement
    ///   the same closed-form algebra; parity = "did the port
    ///   re-implement the same arithmetic correctly?" (e.g. solar
    ///   Hughes 1985 + Haurwitz 1945).
    /// - `.analyticOracle` — closed-form analytic oracle
    ///   (Beer-Lambert, analytic spectra) compared against the hexa
    ///   kernel.
    /// - `.pythonCompanionSeedMatch` — stochastic kernel parity via
    ///   same-RNG-seed bit-identical companion (mc_slab_demo).
    /// - `.roundtripIdentity` — `idft∘dft == I` style identity test.
    /// - `.heapqOracleExact` — python `heapq` event-for-event for
    ///   event schedulers (event_queue).
    /// - `.handMirroredPython` — hand-mirrored arithmetic; not
    ///   closed-form, but every line matches the python by
    ///   inspection.
    /// - `.other` — escape hatch; caller uses `scopeNotes` to
    ///   describe.
    public enum ParityMethod: String, Codable, Sendable, Equatable {
        case substrateToSubstrate     = "substrate_to_substrate"
        case analyticOracle           = "analytic_oracle"
        case pythonCompanionSeedMatch = "python_companion_seed_match"
        case roundtripIdentity        = "roundtrip_identity"
        case heapqOracleExact         = "heapq_oracle_exact"
        case handMirroredPython       = "hand_mirrored_python"
        case other                    = "other"
    }

    /// Repo path (hexa-lang-relative) of the hexa-native kernel,
    /// e.g. `"stdlib/kernels/solar/solar_kernel.hexa"`.
    public let kernelPath: String
    /// Repo path of the parity test, e.g.
    /// `"stdlib/kernels/solar/solar_kernel_test.hexa"`.
    public let parityTest: String
    /// Which kind of parity claim this ref is asserting.
    public let parityMethod: ParityMethod
    /// Numeric tolerance for parity acceptance (relative error).
    /// `nil` when the oracle is event-exact / integer-exact and the
    /// caller sets `parityToleranceNote` instead.
    public let parityTolerance: Double?
    /// Free-text caveat for non-numeric tolerances ("exact (integer
    /// outputs)", "event-for-event match"). `nil` when
    /// `parityTolerance` is numeric.
    public let parityToleranceNote: String?
    /// Pass status snapshot, e.g. `"21/21 PASS rel_err<=1e-13"`.
    public let parityStatus: String
    /// hexa-lang `origin/main` SHA at the time this ref was emitted
    /// (full 40-char or short — caller pins).
    public let hexaLangSHA: String
    /// One-line scope caveat — what the kernel does and does NOT
    /// cover. Required (D80 honesty floor).
    public let scopeNotes: String
    /// Observed relative error vs the transitional substrate, when
    /// the parity claim has a numeric error to report. `nil` when
    /// `parityMethod` is non-numeric (e.g. `.heapqOracleExact`).
    public let relErr: Double?

    public init(kernelPath: String,
                parityTest: String,
                parityMethod: ParityMethod,
                parityTolerance: Double?,
                parityToleranceNote: String?,
                parityStatus: String,
                hexaLangSHA: String,
                scopeNotes: String,
                relErr: Double?) {
        self.kernelPath          = kernelPath
        self.parityTest          = parityTest
        self.parityMethod        = parityMethod
        self.parityTolerance     = parityTolerance
        self.parityToleranceNote = parityToleranceNote
        self.parityStatus        = parityStatus
        self.hexaLangSHA         = hexaLangSHA
        self.scopeNotes          = scopeNotes
        self.relErr              = relErr
    }

    enum CodingKeys: String, CodingKey {
        case kernelPath          = "kernel_path"
        case parityTest          = "parity_test"
        case parityMethod        = "parity_method"
        case parityTolerance     = "parity_tolerance"
        case parityToleranceNote = "parity_tolerance_note"
        case parityStatus        = "parity_status"
        case hexaLangSHA         = "hexa_lang_sha"
        case scopeNotes          = "scope_notes"
        case relErr              = "rel_err"
    }
}
