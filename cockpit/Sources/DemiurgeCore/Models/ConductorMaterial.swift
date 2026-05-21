// ConductorMaterial — the material-side family taxonomy that flanks
// the device-side rtsc producers (RTSC.md §5 Axis B · §8.2 8-family
// matrix). One value of this enum identifies "what conductor is wound
// into the coil" — i.e. the input ConductorRecord.spec.family that a
// device producer like `getdp_hts.py` consumes to fill `nu[Coil]`,
// `Jc_limit`, `Hc2_limit`.
//
// RTSC.md §8.2 matrix authority — labels are deliberately HONEST:
//   • hts_rebco / lts_nbti / lts_nb3sn / mgb2 / fesc_iron_based —
//     industry-replicated, Tier 3 vendor datasheets exist.
//   • hts_bi2212 — replicated 1986~ cuprate, round-wire.
//   • heavy_hydride — replicated above ~150 GPa only; device-impossible
//     at ambient pressure (RTSC.md §8.2 "GPa 압력 풀면 unstable").
//   • twisted_bilayer_graphene — replicated 2018~ but ~1.7 K device
//     niche, not a power conductor.
//   • lk99_hypothetical — NOT replicated; claim-only.
//   • hexa_rtsc_n6_candidate — closed-form-only; empirical sandbox absent.
//   • cu_normal — non-SC baseline (resistive Cu, the device-side null
//     hypothesis comparator).
//
// g3 honest stance (RTSC.md §8.7): lk99Hypothetical and
// hexaRtscN6Candidate ingest records MUST stay `absorbed=false` and
// gate_type="empirically-unproven" forever — demiurge MUST NOT promote
// a hypothetical material to absorbed=true.
//
// SSOT pairing: §5 Axis B's ConductorMaterial ledger and §8.2's family
// matrix are 1:1 — every row in §8.2 maps to exactly one case here,
// plus cu_normal as the non-SC baseline.

import Foundation

public enum ConductorMaterial: String, Codable, CaseIterable, Sendable {
    case cuNormal = "cu_normal"
    case ltsNbTi = "lts_nbti"
    case ltsNb3Sn = "lts_nb3sn"
    case mgB2 = "mgb2"
    case fescIronBased = "fesc_iron_based"
    case htsRebco = "hts_rebco"          // YBCO / GdBCO 2G tape
    case htsBi2212 = "hts_bi2212"
    case heavyHydride = "heavy_hydride"
    case twistedBilayerGraphene = "twisted_bilayer_graphene"
    case lk99Hypothetical = "lk99_hypothetical"
    case hexaRtscN6Candidate = "hexa_rtsc_n6_candidate"
}

extension ConductorMaterial {
    /// Human-readable label per RTSC.md §8.2 honest-naming policy.
    /// Hypothetical / not-replicated families carry the caveat in the
    /// label itself so any cockpit row using `displayName` cannot
    /// silently launder a claim.
    public var displayName: String {
        switch self {
        case .cuNormal:
            return "Copper (normal conductor, non-SC baseline)"
        case .ltsNbTi:
            return "NbTi LTS (industry-mature, ~9 K, MRI/LHC standard)"
        case .ltsNb3Sn:
            return "Nb3Sn LTS (industry-mature, ~18 K, high-field PIT wire)"
        case .mgB2:
            return "MgB2 (replicated 2001~, ~39 K, PIT wire)"
        case .fescIronBased:
            return "Iron-based SC (FeSC, replicated 2008~, 25-55 K)"
        case .htsRebco:
            return "REBCO HTS (YBCO/GdBCO 2G tape, ~93 K)"
        case .htsBi2212:
            return "BSCCO HTS (Bi-2212/Bi-2223 round wire, ~95-110 K)"
        case .heavyHydride:
            return "Heavy hydride (H3S/LaH10/CaH6, 200-260 K at >150 GPa — device-impossible at ambient)"
        case .twistedBilayerGraphene:
            return "Twisted bilayer graphene (TBG @ 1.1 deg magic angle, ~1.7 K, lab-only)"
        case .lk99Hypothetical:
            return "LK-99 (hypothetical, NOT replicated)"
        case .hexaRtscN6Candidate:
            return "hexa-rtsc n=6 candidate (closed-form only, empirically unproven)"
        }
    }
}
