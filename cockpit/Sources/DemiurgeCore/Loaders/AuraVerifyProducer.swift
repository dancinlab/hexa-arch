// AuraVerifyProducer — fallback scanner for `aura + verify` when the
// sibling-repo dispatch (`~/core/hexa-aura/verify/run_all.hexa`) cannot
// run or fails. Mirrors the BrainVerifyProducer / *VerifyProducer
// pattern (D17 / g_stdlib_ownership), but the substrate here lives in
// anima-physics, NOT in cockpit — so this producer only WITNESSES the
// pre-emitted bridge records (e.g. `anima_aura_<UTC>.json`) under
// `exports/aura/verify/<UTC>Z/`.
//
// Architecture (g3 — silent success forbidden):
//   1. Sibling-repo dispatch is the PRIMARY path (preserved via
//      ProducerRegistry sibling variant); this producer runs ONLY as
//      a fallback when the sibling spawn returns exit != 0.
//   2. recursive scan of `exports/aura/verify/<stamp>/` for any
//      `anima_*.json` file (prefix filter — anima-physics bridge
//      records). The newest stamp wins (modeled on the per-stamp
//      subdir convention used by BrainAnalyzeProducer / D17 matter).
//   3. ALWAYS emits GATE_OPEN + absorbed=false in the surfaced text —
//      the cited record carries its own verdict but this fallback
//      does NOT elevate it (D80 — sibling-repo and bridge are both
//      transitional pointers; hexa-native ultimate-form port still
//      required for non-provisional absorbed).
//   4. If NO anima_* record exists, this producer surfaces the gap
//      honestly (engineToolSucceeded=false) — there is no record to
//      cite, so the only honest output is the gap text.
//
// This is intentionally lightweight (no Python spawn, no atlas
// re-derivation) — its single job is to make the demiurge dispatcher
// AWARE of the anima-physics bridge record that the sibling-repo
// dispatch alone ignores (the user-reported bypass: cycle-4 gap
// bridges agent landed the anima record but demiurge's auto-detect
// missed it because the sibling-repo path took over).
//
// D61 / g_demiurge_pointer_only: no compute lives here — only
// FileManager scans + record-ID extraction. The anima_aura_*.json
// file format is the SSOT for the cited values.

import Foundation

public enum AuraVerifyProducer {

    /// Default scan root — `exports/aura/verify/`. Sibling of
    /// `exports/aura/eeg/` (the analyze-verb produces eeg records;
    /// verify-verb produces verify records under this root).
    public static let scanRoot: URL =
        RecordLoader.exportsRoot
            .appendingPathComponent("aura/verify", isDirectory: true)

    /// Recursive scan of `scanRoot` for `anima_*.json` records, newest
    /// stamp first. Returns the first hit (single anima bridge record
    /// per run is the current convention; multi-record support is a
    /// TODO when a second producer joins).
    public static func locateNewestAnimaRecord() -> URL? {
        let fm = FileManager.default
        guard let stamps = try? fm.contentsOfDirectory(
            at: scanRoot, includingPropertiesForKeys: nil) else {
            return nil
        }
        // Stamps are ISO-8601 UTC dirnames — lexicographic sort matches
        // chronological order (newest last).
        let sortedStamps = stamps
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey])
                .isDirectory) == true }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        for stampDir in sortedStamps.reversed() {
            guard let entries = try? fm.contentsOfDirectory(
                at: stampDir, includingPropertiesForKeys: nil) else {
                continue
            }
            let animaRecords = entries
                .filter { $0.lastPathComponent.hasPrefix("anima_")
                       && $0.pathExtension == "json" }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
            if let hit = animaRecords.first {
                return hit
            }
        }
        return nil
    }

    /// Fallback entry — called by the ProducerRegistry sibling-variant
    /// override when the sibling-repo spawn returns exit != 0. Scans
    /// `exports/aura/verify/` for anima-physics bridge records and
    /// builds an `ActionResult` that cites the newest one without
    /// re-running compute.
    public static func verifyFromExports() -> ActionResult {
        var lines: [String] = []
        lines.append("[aura+verify · fallback] sibling-repo dispatch "
            + "failed or unavailable — scanning exports/aura/verify/ "
            + "for anima-physics bridge records (g3 — silent success "
            + "forbidden, anima record cited as fallback).")

        guard let recordURL = locateNewestAnimaRecord() else {
            lines.append("⏳ engine tool gap — no anima_*.json record "
                + "under \(scanRoot.path). aura + verify fallback "
                + "has nothing to cite; both substrates (sibling repo "
                + "AND anima-physics bridge) appear unavailable.")
            lines.append("GATE_OPEN / absorbed=false (g3).")
            return ActionResult(
                text: lines.joined(separator: "\n"),
                newRecordIDs: [],
                usedEngineTool: true,
                engineToolSucceeded: false)
        }

        // Extract the record_id from the JSON body when possible; fall
        // back to the filename stem otherwise. anima_aura_*.json carry
        // a top-level "record_id" string per the demiurge:aura:quality-
        // record interface.
        var recordID = recordURL.lastPathComponent
            .replacingOccurrences(of: ".json", with: "")
        if let data = try? Data(contentsOf: recordURL),
           let obj = try? JSONSerialization.jsonObject(with: data)
               as? [String: Any],
           let rid = obj["record_id"] as? String {
            recordID = rid
        }

        let stampDir = recordURL.deletingLastPathComponent()
            .lastPathComponent
        lines.append("anima record → exports/aura/verify/\(stampDir)/"
            + "\(recordURL.lastPathComponent)")
        lines.append("record_id = \(recordID)")
        lines.append("⏳ GATE_OPEN · absorbed=false — anima-physics "
            + "bridge record cited (sibling-repo dispatch failed); "
            + "this is a TRANSITIONAL pointer per D80 (hexa-native "
            + "ultimate-form port required for non-provisional "
            + "absorbed).")
        return ActionResult(
            text: lines.joined(separator: "\n"),
            newRecordIDs: [recordID],
            usedEngineTool: true,
            engineToolSucceeded: true)
    }
}
