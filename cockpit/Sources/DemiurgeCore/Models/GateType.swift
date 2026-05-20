// GateType — G7 taxonomy (ARCH.md §11.4) for *why* a cell's
// MeasurementGate is OPEN.
//
// `MeasurementGate` says *whether* a cell is open / closed-measured /
// failed; `GateType` says *why* it's open. The aura/ufo simulations
// (§11.1, §11.2) revealed that "install-gated" and "proprietary-
// mandatory" mix together in the current scope_caveats free-text,
// hiding the honest distinction between a substrate that can be
// installed locally vs one that requires a regulator-approved tool.
//
// Each Producer-side substrate emits this field alongside the
// MeasurementGate; the cockpit project-wide dashboard (G2) groups
// records by GateType so users see the real shape of the gap.
//
// D80 g_hexa_only — `hexaNativeAbsent` is a distinct GateType
// because even an `installGated` substrate that passes its own
// parity check is *still* hexa-native-absent until the kernel
// lands.

import Foundation

public enum GateType: String, Codable, Sendable, CaseIterable {

    /// Substrate (Python / C++ tool) not installed locally — user
    /// can `brew install` or `pip install` to unblock.
    case installGated = "install-gated"

    /// Platform mismatch — substrate is Windows-only (FEMM via Wine),
    /// Linux-only (CARLA / Unreal), or otherwise platform-bound. User
    /// would need to switch hosts or use the wilson-pool.
    case platformGated = "platform-gated"

    /// Reference data missing — substrate is installed but a required
    /// dataset (ENDF/B-VIII.0 ~3GB, WebbPSF reference, …) is not
    /// downloaded. User can fetch the dataset to unblock.
    case dataGated = "data-gated"

    /// Regulatory-bound — verify path requires a regulator-approved
    /// tool (FDA Class III PMA, Sim4Life MDDT for MRI safety, …) and
    /// open replacement does not exist in the public surface (D1
    /// clean-room). User needs a regulated lab, not a software fix.
    case regulatoryGated = "regulatory-gated"

    /// Proprietary-only with no open equivalent — Cadence Virtuoso /
    /// Synopsys Sentaurus / Schrödinger LiveDesign / ANSYS Maxwell.
    /// Distinct from `regulatoryGated` (regulator forces specific
    /// proprietary tool) and `installGated` (open tool exists, just
    /// not installed).
    case proprietaryOnly = "proprietary-only"

    /// D80 — substrate measured + passed but no hexa-native parity
    /// port exists yet. `absorbed=true` is cap'd at *provisional* per
    /// `@D g_hexa_only`; flips to non-provisional only when the
    /// hexa-native kernel lands.
    case hexaNativeAbsent = "hexa-native-absent"

    /// Substrate spec exists but no producer has been wired yet
    /// (cell is "honest-gap LLM fallback path"). Counts under "still
    /// to build" rather than "still to install".
    case producerAbsent = "producer-absent"

    /// Catch-all for cells that don't yet declare a GateType. Should
    /// be rare; G2 dashboard flags these for review.
    case unspecified = "unspecified"
}

/// Convenience grouping for the G2 dashboard.
public extension GateType {
    /// True when the gate could be resolved by the *user* doing an
    /// install or download (no demiurge-side code change needed).
    var userResolvable: Bool {
        switch self {
        case .installGated, .platformGated, .dataGated: return true
        case .regulatoryGated, .proprietaryOnly,
             .hexaNativeAbsent, .producerAbsent,
             .unspecified: return false
        }
    }

    /// True when the gate requires a demiurge-side hexa-native port
    /// to flip from provisional → non-provisional absorbed=true.
    var hexaNativeBlocked: Bool { self == .hexaNativeAbsent }

    /// Korean label for the cockpit ProvenanceBanner and G2 dashboard.
    var label: String {
        switch self {
        case .installGated:      return "설치 필요"
        case .platformGated:     return "플랫폼 제한"
        case .dataGated:         return "데이터 누락"
        case .regulatoryGated:   return "규제 인증 필요"
        case .proprietaryOnly:   return "상용 전용 (오픈 부재)"
        case .hexaNativeAbsent:  return "hexa-native 포트 부재"
        case .producerAbsent:    return "producer 미작성"
        case .unspecified:       return "분류 안 됨"
        }
    }
}
