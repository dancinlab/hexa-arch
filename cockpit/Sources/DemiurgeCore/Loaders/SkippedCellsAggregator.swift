// SkippedCellsAggregator — G2 (ARCH.md §11.4) — scan exports/ for
// records that emitted with `skipped_reason` set, then group them by
// domain + verb + gate_type so the cockpit dashboard can show the
// honest project-wide gap.
//
// Pure DemiurgeCore; reads JSON via Foundation only. Decoding is
// tolerant — any record that lacks the optional `skipped_reason` /
// `gate_type` fields just doesn't contribute to the aggregate (no
// crash on legacy records emitted before D80 / G7).

import Foundation

/// One row in the dashboard: a single skipped cell record.
public struct SkippedCellEntry: Sendable, Equatable {
    public let domain: String
    public let verb: String
    public let stamp: String
    public let producer: String
    public let gateType: GateType
    public let skippedReason: String
    public let recordPath: String

    public init(domain: String, verb: String, stamp: String,
                producer: String, gateType: GateType,
                skippedReason: String, recordPath: String) {
        self.domain = domain
        self.verb = verb
        self.stamp = stamp
        self.producer = producer
        self.gateType = gateType
        self.skippedReason = skippedReason
        self.recordPath = recordPath
    }
}

/// Minimal Codable view over the common skipped-cell record shape;
/// every typed Record (SSCBSynthRecord, EnergyVerifyRecord, …) is a
/// superset of these fields, so we decode laxly via this stub.
private struct SkippedCellStub: Decodable {
    let domain: String?
    let verb: String?
    let stamp: String?
    let producer: String?
    let skipped_reason: String?
    let gate_type: String?
    let measurement_gate: String?
}

public enum SkippedCellsAggregator {

    /// Scan `<exportsRoot>/<domain>/<verb>/.../*.json` for records.
    /// Returns rows in scan order (callers can sort/filter as needed).
    public static func scan(under exportsRoot: URL) -> [SkippedCellEntry] {
        let fm = FileManager.default
        guard let walker = fm.enumerator(at: exportsRoot,
                                         includingPropertiesForKeys: nil) else {
            return []
        }
        var result: [SkippedCellEntry] = []
        let decoder = JSONDecoder()
        for case let url as URL in walker
            where url.pathExtension == "json" && !url.lastPathComponent.hasSuffix(".meta.json") {
            guard let data = try? Data(contentsOf: url),
                  let stub = try? decoder.decode(SkippedCellStub.self, from: data)
                  else { continue }
            // Only count rows that explicitly emitted a skipped reason.
            guard let reason = stub.skipped_reason, !reason.isEmpty else {
                continue
            }
            let gate: GateType = {
                if let s = stub.gate_type,
                   let g = GateType(rawValue: s) { return g }
                // Heuristic fallback when substrate has not yet adopted G7:
                let r = reason.lowercased()
                if r.contains("missing") || r.contains("not found")
                    || r.contains("import") { return .installGated }
                if r.contains("macos") || r.contains("wine")
                    || r.contains("linux") { return .platformGated }
                if r.contains("data") || r.contains("dataset")
                    || r.contains("endf") { return .dataGated }
                if r.contains("regulator") || r.contains("fda")
                    || r.contains("mddt") || r.contains("class") {
                        return .regulatoryGated
                }
                if r.contains("proprietary") || r.contains("commercial") {
                    return .proprietaryOnly
                }
                return .unspecified
            }()
            result.append(SkippedCellEntry(
                domain: stub.domain ?? "?",
                verb: stub.verb ?? "?",
                stamp: stub.stamp ?? "",
                producer: stub.producer ?? "",
                gateType: gate,
                skippedReason: reason,
                recordPath: url.path))
        }
        return result
    }

    /// Group by GateType — used by the dashboard for the donut/bar.
    public static func byGateType(_ entries: [SkippedCellEntry])
        -> [(GateType, [SkippedCellEntry])] {
        var buckets: [GateType: [SkippedCellEntry]] = [:]
        for e in entries { buckets[e.gateType, default: []].append(e) }
        return GateType.allCases
            .compactMap { gt in buckets[gt].map { (gt, $0) } }
    }

    /// Group by domain — used by the dashboard's domain-by-domain
    /// "what's blocking us" table.
    public static func byDomain(_ entries: [SkippedCellEntry])
        -> [(String, [SkippedCellEntry])] {
        var buckets: [String: [SkippedCellEntry]] = [:]
        for e in entries { buckets[e.domain, default: []].append(e) }
        return buckets.keys.sorted()
            .map { ($0, buckets[$0] ?? []) }
    }
}
