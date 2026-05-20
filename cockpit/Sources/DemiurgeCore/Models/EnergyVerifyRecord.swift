// EnergyVerifyRecord — energy + verify (OpenMC k-eff, ROI 12).
// SSOT: ~/core/hexa-lang/stdlib/energy/openmc_keff.py. D72: kernels/
// mc_transport/ reuse (3rd consumer — N+M payoff visible). g3:
// GATE_OPEN / absorbed=false; install-gated AND data-gated skip.
//
// D80 (g_hexa_only): also the consumer cell for the solar pilot
// (`stdlib/kernels/solar/solar_kernel.hexa`, 21/21 PASS rel_err<=1e-13
// vs pvlib 0.13.0 — landed on hexa-lang origin/main 2026-05-20). The
// `hexaNativeParity` field below carries that ref when a record is
// emitted from the solar-clearsky path. The k-eff Monte-Carlo path
// continues to leave the ref nil (the substrate kernel is `mc_slab_
// demo.hexa` but the cell's primary path is OpenMC k-eff, not the
// pattern-proof MC kernel).

import Foundation

public struct EnergyVerifyRecord: Codable, Equatable, Sendable {
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
    public let kernelReuse: String?
    /// D80 — hexa-native parity port pointer (nil = provisional /
    /// no port yet). Populated for the solar-clearsky path; nil for
    /// the OpenMC k-eff path (heavy-port — see
    /// `~/core/hexa-lang/domains/DEPENDENCIES.demi`
    /// `[domain-energy_openmc_keff]` portable_status = "heavy-port").
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
    public var isHexaNativeAbsorbed: Bool {
        return hexaNativeParity?.isHexaNativeAbsorbed ?? false
    }
}
