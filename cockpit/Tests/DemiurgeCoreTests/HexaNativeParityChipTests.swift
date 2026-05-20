// HexaNativeParityChipTests — D99 chip render-model 3-case branch test.
//
// The SwiftUI `HexaNativeParityChip` view lives in CockpitApp; the
// branch decision (label / tone / tooltip / accessibilityID) lives in
// `HexaNativeParityChipModel` (DemiurgeCore) so it can be branch-tested
// without pulling SwiftUI into this test target.
//
// Covers exactly the 3 acceptance cases (D99):
//   1. ref == nil                 → tone=.absent       "no hexa-native"
//   2. ref present + absorbed     → tone=.absorbed     "hexa-native \u{2713} <SHA>"
//   3. ref present + not absorbed → tone=.provisional  "hexa-native (provisional)"
//
// SSOT-only — no new stored data, no fixture file under exports/.

import XCTest
@testable import DemiurgeCore

final class HexaNativeParityChipTests: XCTestCase {

    // MARK: — fixtures (no exports/ write — Swift literal only)

    /// PASS-status ref → `isHexaNativeAbsorbed == true`.
    private func passRef() -> HexaNativeParityRef {
        HexaNativeParityRef(
            kernelPath: "stdlib/kernels/solar/solar_kernel.hexa",
            parityTest: "stdlib/kernels/solar/solar_kernel_test.hexa",
            parityMethod: .substrateToSubstrate,
            parityTolerance: 1e-13,
            parityToleranceNote: nil,
            parityStatus: "21/21 PASS at rel_err <=1e-13",
            hexaLangSHA: "122620deabcdef",
            scopeNotes: "fixture",
            relErr: nil)
    }

    /// Non-PASS ref → `isHexaNativeAbsorbed == false`. Ref attached
    /// (D80: planned/in-progress kernel), but parity has not run green.
    private func provisionalRef() -> HexaNativeParityRef {
        HexaNativeParityRef(
            kernelPath: "stdlib/kernels/foo/bar.hexa",
            parityTest: "stdlib/kernels/foo/bar_test.hexa",
            parityMethod: .other,
            parityTolerance: nil,
            parityToleranceNote: nil,
            parityStatus: "3/5 PASS, 2/5 FAIL",
            hexaLangSHA: "deadbeef00",
            scopeNotes: "fixture",
            relErr: nil)
    }

    // MARK: — 3 acceptance branches

    /// Case 1 — `ref == nil` ⇒ gray "no hexa-native".
    func testChipModelAbsentCase() {
        let m = HexaNativeParityChipModel.from(nil)
        XCTAssertEqual(m.tone, .absent)
        XCTAssertEqual(m.label, "no hexa-native")
        XCTAssertEqual(m.accessibilityID,
                       "hexa-native-parity-chip.absent")
        XCTAssertFalse(m.tooltip.isEmpty,
                       "absent chip must still carry a tooltip rationale")
    }

    /// Case 2 — `ref present + isHexaNativeAbsorbed` ⇒ green
    /// "hexa-native \u{2713} <SHA>", tooltip carries kernelPath +
    /// parityStatus + full hexa-lang SHA.
    func testChipModelAbsorbedCase() {
        let ref = passRef()
        let m = HexaNativeParityChipModel.from(ref)
        XCTAssertEqual(m.tone, .absorbed)
        // Label must include the absorbed checkmark and a short SHA
        // (8-char prefix), and MUST NOT collapse to the absent / pro-
        // visional phrasing.
        XCTAssertTrue(m.label.hasPrefix("hexa-native \u{2713} "),
                      "absorbed label must start with 'hexa-native \u{2713} ', got \(m.label)")
        XCTAssertTrue(m.label.contains("122620de"),
                      "absorbed label must carry the short SHA prefix")
        XCTAssertFalse(m.label.contains("provisional"))
        XCTAssertFalse(m.label.contains("no hexa-native"))
        XCTAssertEqual(m.accessibilityID,
                       "hexa-native-parity-chip.absorbed")
        // Tooltip pulls the full SHA + the kernel path + the parity
        // status (D80 honesty — analyst can audit on hover).
        XCTAssertTrue(m.tooltip.contains(ref.kernelPath))
        XCTAssertTrue(m.tooltip.contains(ref.parityStatus))
        XCTAssertTrue(m.tooltip.contains(ref.hexaLangSHA))
    }

    /// Case 3 — `ref present + NOT absorbed` ⇒ yellow "hexa-native
    /// (provisional)". D80 honesty floor — must NOT paint green.
    func testChipModelProvisionalCase() {
        let ref = provisionalRef()
        let m = HexaNativeParityChipModel.from(ref)
        XCTAssertEqual(m.tone, .provisional)
        XCTAssertEqual(m.label, "hexa-native (provisional)")
        XCTAssertEqual(m.accessibilityID,
                       "hexa-native-parity-chip.provisional")
        // D80 honesty — must not look like the absorbed branch.
        XCTAssertNotEqual(m.tone, .absorbed)
        XCTAssertFalse(m.label.contains("\u{2713}"),
                       "provisional must not carry the absorbed checkmark")
        // Tooltip surfaces kernelPath + parityStatus + honesty note.
        XCTAssertTrue(m.tooltip.contains(ref.kernelPath))
        XCTAssertTrue(m.tooltip.contains(ref.parityStatus))
        XCTAssertTrue(m.tooltip.contains("D80"),
                      "provisional tooltip must cite the D80 honesty rationale")
    }

    // MARK: — branch coverage cross-check

    /// All three accessibility IDs MUST be distinct — the test layer
    /// uses them as a stable case key, and a downstream UI test would
    /// query them to assert which branch rendered.
    func testChipModelAccessibilityIDsAreDistinct() {
        let ids: Set<String> = [
            HexaNativeParityChipModel.from(nil).accessibilityID,
            HexaNativeParityChipModel.from(passRef()).accessibilityID,
            HexaNativeParityChipModel.from(provisionalRef()).accessibilityID,
        ]
        XCTAssertEqual(ids.count, 3,
                       "3 chip branches must produce 3 distinct accessibility IDs")
    }
}
