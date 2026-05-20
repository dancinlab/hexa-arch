// PilotLoader — load `demiurge/domains/PILOTS.demi` (D87 + D90 + D91)
// into typed `PilotEntry` rows.
//
// SSOT: `demiurge/domains/PILOTS.demi` — declarative parity SSOT for
// `stdlib/kernels/<X>/*.hexa` pilots on hexa-lang origin/main. Each
// row mirrors the (planned) `HexaNativeParityRef` Swift struct 1:1
// (D90); a Producer at T7 will look up its kernel via `find(kernelPath:)`
// and inject the row's 8 fields into the cell-record without copying
// the table into Swift code (D86 g_no_hardcoded_data).
//
// Companion SSOT (D93): `hexa-lang:inbox/notes/hexa-native-port-
// pattern-pilot.md` — same kernels, prose dimension. Cross-link in
// both directions; this file is the field-level authority, the .md
// is the rationale + gotchas authority.
//
// HONESTY (D80, same contract as DependenciesLoader / ProducerLoader):
// when the file is absent the loader emits a stderr warning and
// returns an empty array. It does NOT crash and does NOT silently
// substitute a Swift-hardcoded mirror. Producers downstream then
// leave `HexaNativeParityRef` nil on the record, which keeps the
// cell at its current GateType.
//
// SCHEMA (D90): see the head-of-file comment in `domains/PILOTS.demi`.
// Eight fields per section, each mapped to one `PilotEntry` property.

import Foundation

/// One row from `domains/PILOTS.demi` — a hexa-native parity pilot
/// for a single `stdlib/kernels/<X>/*.hexa` kernel file (D91 — kernel
/// granularity, NOT assertion granularity).
public struct PilotEntry: Sendable, Equatable {

    /// Row id — `[pilot-<id>]` in the .demi file (e.g. `pilot-solar`).
    /// D91 convention: lowercase, dash-separated, `pilot-` prefix.
    public let id: String

    /// `kernel_path` — repo-relative path to the .hexa kernel on
    /// hexa-lang (e.g. `"stdlib/kernels/solar/solar_kernel.hexa"`).
    /// This is the `find(kernelPath:)` lookup key (T7 phase).
    public let kernelPath: String

    /// `parity_test` — repo-relative path to the parity test on
    /// hexa-lang (e.g. `"stdlib/kernels/solar/solar_kernel_test.hexa"`).
    public let parityTest: String

    /// `parity_method` — one-line method description (what was
    /// compared against what; sample set; oracle source).
    public let parityMethod: String

    /// `parity_tolerance` — tolerance string (D80 ceiling or actual
    /// observed gap).
    public let parityTolerance: String

    /// `parity_status` — `"NN/NN PASS at rel_err=…"` summary string.
    /// D91 — when sub-test counts grow this string is updated; new
    /// row is NOT added.
    public let parityStatus: String

    /// `hexa_lang_sha` — short commit SHA on hexa-lang origin/main
    /// where the kernel + parity-test landed.
    public let hexaLangSha: String

    /// `algorithm_ref` — textbook / paper reference (e.g.
    /// `"NRL Plasma Formulary p.34"`).
    public let algorithmRef: String

    /// `scope_notes` — one-line caveat (what this does NOT prove —
    /// the g3 honesty field).
    public let scopeNotes: String

    public init(id: String,
                kernelPath: String,
                parityTest: String,
                parityMethod: String,
                parityTolerance: String,
                parityStatus: String,
                hexaLangSha: String,
                algorithmRef: String,
                scopeNotes: String) {
        self.id              = id
        self.kernelPath      = kernelPath
        self.parityTest      = parityTest
        self.parityMethod    = parityMethod
        self.parityTolerance = parityTolerance
        self.parityStatus    = parityStatus
        self.hexaLangSha     = hexaLangSha
        self.algorithmRef    = algorithmRef
        self.scopeNotes      = scopeNotes
    }
}

public enum PilotLoader {

    /// Resolve the canonical path for `demiurge/domains/PILOTS.demi`
    /// (D87 — `.demi` lives in demiurge, NOT hexa-lang). Priority:
    /// 1. `$DEMIURGE_REPO/domains/PILOTS.demi`
    /// 2. `$PWD/domains/PILOTS.demi`
    /// 3. `~/core/demiurge/domains/PILOTS.demi` (last resort)
    public static func pilotsPath() -> String? {
        let env = ProcessInfo.processInfo.environment
        if let repo = env["DEMIURGE_REPO"] {
            let p = "\(repo)/domains/PILOTS.demi"
            if FileManager.default.fileExists(atPath: p) { return p }
        }
        let cwd = FileManager.default.currentDirectoryPath
        let pwdPath = "\(cwd)/domains/PILOTS.demi"
        if FileManager.default.fileExists(atPath: pwdPath) { return pwdPath }
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let homePath = "\(home)/core/demiurge/domains/PILOTS.demi"
        if FileManager.default.fileExists(atPath: homePath) { return homePath }
        return nil
    }

    /// Load + parse + project. Returns empty array + stderr warning
    /// when the file is missing (D80 honesty: no silent hardcoded
    /// fallback — `HexaNativeParityRef` stays nil on the cell-record
    /// and the G2 dashboard surfaces the gap).
    public static func loadAll() -> [PilotEntry] {
        guard let path = pilotsPath() else {
            FileHandle.standardError.write(
                Data(("PilotLoader: PILOTS.demi not found (tried "
                      + "$DEMIURGE_REPO/domains, $PWD/domains, "
                      + "~/core/demiurge/domains) — returning [] "
                      + "(D80)\n").utf8))
            return []
        }
        guard let src = try? String(contentsOfFile: path, encoding: .utf8)
            else {
            FileHandle.standardError.write(
                Data(("PilotLoader: cannot read \(path) "
                      + "— returning [] (D80)\n").utf8))
            return []
        }
        let sections = DemiParser.parse(src)
        return sections.compactMap { project($0) }
    }

    /// Project one `DemiSection` into a `PilotEntry`. Tolerant —
    /// returns nil on missing required fields (logged to stderr).
    public static func project(_ s: DemiSection) -> PilotEntry? {
        guard let kernelPath = s.string("kernel_path"),
              let parityTest = s.string("parity_test"),
              let parityMethod = s.string("parity_method"),
              let parityTolerance = s.string("parity_tolerance"),
              let parityStatus = s.string("parity_status"),
              let hexaLangSha = s.string("hexa_lang_sha"),
              let algorithmRef = s.string("algorithm_ref")
        else {
            FileHandle.standardError.write(
                Data(("PilotLoader: section '\(s.id)' missing or "
                      + "invalid required field (kernel_path / "
                      + "parity_test / parity_method / "
                      + "parity_tolerance / parity_status / "
                      + "hexa_lang_sha / algorithm_ref) — skipped\n"
                ).utf8))
            return nil
        }
        let scopeNotes = s.string("scope_notes") ?? ""
        return PilotEntry(
            id: s.id,
            kernelPath: kernelPath,
            parityTest: parityTest,
            parityMethod: parityMethod,
            parityTolerance: parityTolerance,
            parityStatus: parityStatus,
            hexaLangSha: hexaLangSha,
            algorithmRef: algorithmRef,
            scopeNotes: scopeNotes)
    }

    /// Lookup by `kernel_path` — the primary key for Producer / cell-
    /// emit dispatch (D94, T7 phase). Returns nil if no row matches.
    public static func find(kernelPath: String,
                            in entries: [PilotEntry]? = nil) -> PilotEntry?
    {
        let rows = entries ?? loadAll()
        return rows.first(where: { $0.kernelPath == kernelPath })
    }

    /// Lookup by row `id` — for cross-link tooling that already knows
    /// the `pilot-<X>` id (e.g. pattern-pilot.md → PILOTS.demi
    /// reverse cross-link verification).
    public static func find(id: String,
                            in entries: [PilotEntry]? = nil) -> PilotEntry?
    {
        let rows = entries ?? loadAll()
        return rows.first(where: { $0.id == id })
    }

    /// D94 / T7 — convenience: lookup a `PilotEntry` by id and project
    /// it to a `HexaNativeParityRef` ready for injection into a cell
    /// record. Returns nil if the id is absent OR if the .demi file
    /// is missing (D80 honesty: no silent fallback).
    ///
    /// This is the canonical Producer-side wire — every cell-record
    /// `+verify` / `+analyze` producer that has a primary pilot in
    /// `domains/PILOTS.demi` calls `PilotLoader.parityRef(forId:)`
    /// right before emitting its record, then assigns the result to
    /// the record's `hexaNativeParity` field. No producer hardcodes
    /// the parity-status / hexa-lang SHA / algorithm-ref strings.
    public static func parityRef(forId id: String,
                                 in entries: [PilotEntry]? = nil)
        -> HexaNativeParityRef?
    {
        guard let entry = find(id: id, in: entries) else { return nil }
        return entry.toParityRef()
    }

    /// D94 / T7 — same as `parityRef(forId:)` but keyed by the kernel
    /// file path (the `kernel_path` column in PILOTS.demi). Use this
    /// when the Producer already speaks in `stdlib/kernels/<X>/…`
    /// paths; use `parityRef(forId:)` when the Producer knows the
    /// short pilot id (`pilot-solar` …).
    public static func parityRef(forKernelPath kernelPath: String,
                                 in entries: [PilotEntry]? = nil)
        -> HexaNativeParityRef?
    {
        guard let entry = find(kernelPath: kernelPath, in: entries)
            else { return nil }
        return entry.toParityRef()
    }
}

// MARK: - PilotEntry → HexaNativeParityRef projection (D94 / T7)

extension PilotEntry {

    /// Project a `PilotEntry` (8 free-text fields, 1:1 with PILOTS.demi)
    /// into a `HexaNativeParityRef` (9 fields, typed enum for method +
    /// `Double?` for numeric tolerance) — the wire that lets every
    /// `+verify` / `+analyze` Producer emit a fully-typed cell-record
    /// `hexa_native_parity` block without hardcoding any of the parity
    /// strings in Swift (D86 g_no_hardcoded_data).
    ///
    /// Heuristics (D94 honesty floor — when a heuristic is ambiguous
    /// we prefer `.other` + a `scopeNotes` carry-over over a wrong-
    /// looking enum value):
    ///   * `parityMethod` enum derived first by id-prefix lookup
    ///     (the 10 kernel pilots have stable ids), then by free-text
    ///     keyword in the method string.
    ///   * `parityTolerance` (Double) extracted from the leading
    ///     `<=Xe-Y` / `~Xe-Y` / `rel_err = 0.0` patterns; the raw
    ///     string survives in `parityToleranceNote` for non-numeric
    ///     cases (exact discrete, event-for-event match).
    ///   * `relErr` left nil — pilots report `parityStatus` summary,
    ///     not a single rel-err number; downstream producers can
    ///     override per-call when they know the exact observed gap.
    public func toParityRef() -> HexaNativeParityRef {
        let method = Self.deriveParityMethod(id: id, freeText: parityMethod)
        let (numeric, note) = Self.deriveTolerance(parityTolerance)
        return HexaNativeParityRef(
            kernelPath: kernelPath,
            parityTest: parityTest,
            parityMethod: method,
            parityTolerance: numeric,
            parityToleranceNote: note,
            parityStatus: parityStatus,
            hexaLangSHA: hexaLangSha,
            scopeNotes: scopeNotes.isEmpty
                ? "see \(parityTest) for parity gate scope"
                : scopeNotes,
            relErr: nil)
    }

    /// id-first, free-text-second derivation of the `ParityMethod`
    /// enum. The 10 landed pilots map deterministically by id; new
    /// pilots fall through to a keyword scan; final fallback is
    /// `.other` (caller's `scopeNotes` carries the rationale).
    static func deriveParityMethod(id: String,
                                   freeText: String)
        -> HexaNativeParityRef.ParityMethod
    {
        // Stable id-based mapping (D91 — id convention is the contract).
        switch id {
        case "pilot-solar":                return .substrateToSubstrate
        case "pilot-mc_transport":         return .pythonCompanionSeedMatch
        case "pilot-neural_lif":           return .substrateToSubstrate
        case "pilot-graph_bfs":            return .substrateToSubstrate
        case "pilot-urdf_fk_2link":        return .substrateToSubstrate
        case "pilot-plasma_metrics":       return .handMirroredPython
        case "pilot-orbital_kepler":       return .handMirroredPython
        case "pilot-dft_naive":            return .roundtripIdentity
        case "pilot-event_queue":          return .heapqOracleExact
        case "pilot-transport_kinematics": return .handMirroredPython
        default: break
        }
        // Free-text keyword scan for new pilots.
        let t = freeText.lowercased()
        if t.contains("heapq")                 { return .heapqOracleExact }
        if t.contains("round-trip")
            || t.contains("roundtrip")         { return .roundtripIdentity }
        if t.contains("same lcg seed")
            || t.contains("same-rng-seed")
            || t.contains("python-companion") {
            return .pythonCompanionSeedMatch
        }
        if t.contains("analytic oracle")
            || t.contains("beer-lambert")
            || t.contains("analytic spectra") {
            return .analyticOracle
        }
        if t.contains("hand-mirrored")
            || t.contains("libm closed-form") {
            return .handMirroredPython
        }
        if t.contains("substrate parity")
            || t.contains("companion parity")
            || t.contains("numpy")
            || t.contains("networkx") {
            return .substrateToSubstrate
        }
        return .other
    }

    /// Extract a numeric tolerance from a free-text string. Returns
    /// `(numeric, note)`:
    ///   * If a leading `<=Xe-Y` / `~Xe-Y` / `rel_err = N` is found,
    ///     `numeric` is set and `note` is the full original string
    ///     (so the caveat survives — D80 honesty over numeric reduction).
    ///   * If no numeric pattern is recognisable (e.g. "exact (discrete
    ///     algorithm — node-order match)"), `numeric` is nil and the
    ///     whole string lands in `note`.
    static func deriveTolerance(_ raw: String) -> (Double?, String?) {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return (nil, nil) }

        // "rel_err = 0.0 ..." special-case (bit-exact pilots).
        let lower = trimmed.lowercased()
        if lower.contains("rel_err = 0") || lower.contains("rel_err=0") {
            return (0.0, trimmed)
        }

        // Scan for the first scientific-notation token like 1e-13,
        // 2e-15, 1e-3 — accept optional leading <=, <, ~.
        let scalars = Array(trimmed)
        var i = 0
        while i < scalars.count {
            let c = scalars[i]
            // Look for a digit (start of a number).
            if c.isNumber {
                var j = i
                // Walk digits and decimals.
                while j < scalars.count, (scalars[j].isNumber
                                           || scalars[j] == ".") {
                    j += 1
                }
                // Optional 'e' / 'E' + optional sign + digits.
                if j < scalars.count,
                   scalars[j] == "e" || scalars[j] == "E" {
                    var k = j + 1
                    if k < scalars.count,
                       scalars[k] == "+" || scalars[k] == "-" {
                        k += 1
                    }
                    var sawDigit = false
                    while k < scalars.count, scalars[k].isNumber {
                        sawDigit = true
                        k += 1
                    }
                    if sawDigit {
                        let token = String(scalars[i..<k])
                        if let d = Double(token) {
                            return (d, trimmed)
                        }
                    }
                }
                // Bare decimal (e.g. "0.0").
                let token = String(scalars[i..<j])
                if let d = Double(token), token.contains(".") {
                    return (d, trimmed)
                }
                i = max(j, i + 1)
                continue
            }
            i += 1
        }
        // No numeric tolerance — return the raw string as a note.
        return (nil, trimmed)
    }
}
