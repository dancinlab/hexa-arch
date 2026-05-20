// FusionVerifyRecord — fusion + verify (OpenMC TBR neutronics, ROI 11).
// SSOT: ~/core/hexa-lang/stdlib/fusion/openmc_tbr.py. D72: kernels/
// mc_transport/ reuse (2nd consumer after antimatter+analyze). g3:
// GATE_OPEN / absorbed=false; install-gated AND data-gated skip.
//
// D80 (g_hexa_only): primary consumer cell for the mc_transport
// kernel pilot (`stdlib/kernels/mc_transport/mc_slab_demo.hexa`).
// The pilot proves the Monte-Carlo PATTERN (Beer-Lambert analytic
// oracle, bit-identical python companion at same LCG seed) — it
// does NOT replace OpenMC for full multi-region TBR. Per the
// connection-plan §2.2 the cell-level `hexaNativeParity` ref
// always carries `provisional = true` semantics (see scope_caveats)
// because mc_slab_demo is single-energy-group illustrative MC,
// not real Li-blanket cross sections.

import Foundation

public struct FusionVerifyRecord: Codable, Equatable, Sendable {
    public let domain: String
    public let verb: String
    public let kind: String
    public let stamp: String
    public let producer: String
    public let measurementGate: F1F2Record.MeasurementGate
    /// Cell-level absorbed flag (LEGACY / measured-oracle dimension —
    /// distinct from `isHexaNativeAbsorbed` below). Producer policy
    /// (D103): a substrate-parity PASS on the linked `hexaNativeParity`
    /// kernel MUST NOT auto-flip this to `true`. Doubly-true for fusion:
    /// the mc_transport pilot is illustrative-physics (RFC 013 §6.3),
    /// so even the substrate-parity dimension carries provisional
    /// semantics — see header. Cell-level absorbed requires a measured
    /// oracle for THIS cell's outputs.
    public let absorbed: Bool
    public let scopeCaveats: [String]
    public let citations: [String]
    public let skippedReason: String?
    public let kernelReuse: String?
    /// D80 — hexa-native parity port pointer for the mc_transport
    /// pattern-proof kernel. ALWAYS provisional (see header comment):
    /// the kernel is illustrative-physics, NOT a TBR replacement.
    public let hexaNativeParity: HexaNativeParityRef?

    enum CodingKeys: String, CodingKey {
        case domain, verb, kind, stamp, producer
        case measurementGate = "measurement_gate"
        case absorbed
        case scopeCaveats = "scope_caveats"
        case citations
        case skippedReason = "skipped_reason"
        case kernelReuse = "kernel_reuse"
        case hexaNativeParity = "hexa_native_parity"
    }

    /// D95 — derived absorbed flag (computed, NOT stored).
    /// Reflects `hexaNativeParity?.isHexaNativeAbsorbed`; SSOT is
    /// `domains/PILOTS.demi → parity_status` (D86 / D90).
    ///
    /// D103 dimension separation — see `HexaNativeParityRef` (Ufo
    /// VerifyRecord.swift) header for the two-axis policy. This is the
    /// substrate-parity dimension; `absorbed` above is the measured
    /// dimension. Producers set them independently.
    public var isHexaNativeAbsorbed: Bool {
        return hexaNativeParity?.isHexaNativeAbsorbed ?? false
    }
}
