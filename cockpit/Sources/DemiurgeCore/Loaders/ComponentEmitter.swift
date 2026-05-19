// ComponentEmitter — θ-2 engine tool for `component + synthesize`
// (κ-29 / rfc_011 §6.3 / D50 — CLI ↔ cockpit byte-identical engine).
//
// Wraps the bundled procedural BIPV geometry emission into one
// DemiurgeCore function so:
//   • cockpit's "▶ 실제로 돌리기" button (component·합성 stage)
//   • DemiurgeCLI's `emit-component` subcommand
//   • DemiurgeCLI's `action synthesize` (for a component project)
// all share the SAME writer — never byte-diverge.
//
// HONEST (g3 / @F f6): the emitted ComponentRecord is
// `producer = demiurge_procedural_placeholder · GATE_OPEN ·
// absorbed = false`. Geometry being well-formed is NOT the same gate
// as a thermal / structural / optical verdict being measured.

import Foundation

/// One run of the component emitter — kept as plain text + ID list so
/// the cockpit chat + CLI both pretty-print the same lines (D50).
public struct ComponentEmitResult: Sendable {
    /// Was every step (mkdir + .usda + record JSON) ok?
    public let ok: Bool
    /// Lines suitable for stdout / chat — newline-joined.
    public let lines: [String]
    /// The new record ID, if a record was successfully written.
    public let newRecordID: String?

    public init(ok: Bool, lines: [String], newRecordID: String?) {
        self.ok = ok
        self.lines = lines
        self.newRecordID = newRecordID
    }

    public var text: String { lines.joined(separator: "\n") }
}

public enum ComponentEmitter {
    /// Emit the bundled BIPV 5-layer procedural geometry as
    /// `exports/component/geometry/<id>.{usda,usdz,json}`. Same
    /// behavior as `DemiurgeCLI emit-component` (since CLI now calls
    /// us). Idempotent on disk — overwrites prior files.
    public static func emitBundled() -> ComponentEmitResult {
        let geometry = ComponentGeometry.bipv5Layer
        let dir = RecordLoader.exportsRoot
            .appendingPathComponent("component/geometry", isDirectory: true)
        var lines: [String] = []
        do {
            try FileManager.default.createDirectory(
                at: dir, withIntermediateDirectories: true)
        } catch {
            lines.append("emit-component: mkdir failed — \(error)")
            return ComponentEmitResult(ok: false, lines: lines, newRecordID: nil)
        }
        let usdaName = "\(geometry.id).usda"
        let usdzName = "\(geometry.id).usdz"
        let jsonName = "\(geometry.id).json"
        let usdaURL = dir.appendingPathComponent(usdaName)
        let usdzURL = dir.appendingPathComponent(usdzName)
        let jsonURL = dir.appendingPathComponent(jsonName)

        do {
            try USDExporter.usda(geometry).write(
                to: usdaURL, atomically: true, encoding: .utf8)
        } catch {
            lines.append("emit-component: write \(usdaName) failed — \(error)")
            return ComponentEmitResult(ok: false, lines: lines, newRecordID: nil)
        }
        lines.append("emit-component: wrote \(usdaName)")

        let usdzOK = USDExporter.packageUSDZ(from: usdaURL, to: usdzURL)
        lines.append(usdzOK
            ? "emit-component: wrote \(usdzName)"
            : "emit-component: usdz packaging unavailable — .usda only "
              + "(honest gap, g3)")

        let iso = ISO8601DateFormatter().string(from: Date())
        let record = ComponentRecord.procedural(
            for: geometry, producedAtUtc: iso,
            usdaFile: usdaName, usdzFile: usdzOK ? usdzName : nil)
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        do {
            try enc.encode(record).write(to: jsonURL)
        } catch {
            lines.append("emit-component: write \(jsonName) failed — \(error)")
            return ComponentEmitResult(ok: false, lines: lines, newRecordID: nil)
        }
        lines.append("emit-component: wrote \(jsonName)")
        lines.append("---")
        lines.append("📦 component artifact → exports/component/geometry/")
        lines.append("   GATE_OPEN · absorbed=false · procedural placeholder (g3)")
        return ComponentEmitResult(
            ok: true, lines: lines, newRecordID: geometry.id)
    }
}
