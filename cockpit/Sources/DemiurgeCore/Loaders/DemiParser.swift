// DemiParser — demiurge `.demi` file format parser (D83).
//
// `.demi` is a TOML-풍 section-oriented declarative format used as the
// machine-readable SSOT for the domain graph (`domains/INDEX.demi`).
// Cockpit + DemiurgeCLI both load via `DomainLoader.loadAll()` which
// dispatches through this parser.
//
// Syntax (D83):
//   - `[<id>]`                    — section header, starts a record
//   - `key = value`               — scalar (quoted-string or bare-word)
//   - `key = [a, b, c]`           — list (comma-separated)
//   - `key.subkey = value`        — dotted-key (nested)
//   - `#` ... \n                  — comment (line or trailing)
//   - blank lines OK
//
// Foundation-only — no external dependencies. Tolerant: silently
// skips malformed lines (logged via stderr if `verbose=true`).

import Foundation

/// One parsed value — string, list, or nested map (for dotted-keys).
public enum DemiValue: Sendable, Equatable {
    case string(String)
    case list([String])
    case map([String: DemiValue])
}

/// One section in a `.demi` file — `[<id>]` header + key/value table.
public struct DemiSection: Sendable, Equatable {
    public let id: String
    public let values: [String: DemiValue]

    public init(id: String, values: [String: DemiValue]) {
        self.id = id
        self.values = values
    }

    /// Convenience accessor — `.string` lookup or nil.
    public func string(_ key: String) -> String? {
        if case .string(let v) = values[key] { return v }
        return nil
    }
    /// Convenience accessor — `.list` lookup or empty array.
    public func list(_ key: String) -> [String] {
        if case .list(let v) = values[key] { return v }
        return []
    }
    /// Convenience accessor — `.map` lookup (for nested dotted-keys).
    public func map(_ key: String) -> [String: DemiValue] {
        if case .map(let v) = values[key] { return v }
        return [:]
    }
    /// Nested dotted-key string lookup (`facets.scale` → `device`).
    public func nestedString(_ outer: String, _ inner: String) -> String? {
        if case .string(let v) = map(outer)[inner] { return v }
        return nil
    }
    /// Nested dotted-key list lookup (`facets.cluster` → `[bio, chem]`).
    public func nestedList(_ outer: String, _ inner: String) -> [String] {
        if case .list(let v) = map(outer)[inner] { return v }
        return []
    }
}

public enum DemiParser {

    /// Parse `.demi` source string into ordered list of sections.
    /// Tolerant — malformed lines logged to stderr when `verbose`.
    public static func parse(_ source: String, verbose: Bool = false) -> [DemiSection] {
        var sections: [DemiSection] = []
        var currentID: String? = nil
        var currentValues: [String: DemiValue] = [:]

        func flush() {
            guard let id = currentID else { return }
            sections.append(DemiSection(id: id, values: currentValues))
            currentValues = [:]
        }

        for (lineNo, rawLine) in source.split(separator: "\n",
                                              omittingEmptySubsequences: false).enumerated() {
            // strip trailing comment, trim whitespace
            var line = String(rawLine)
            if let hash = line.firstIndex(of: "#") {
                line = String(line[..<hash])
            }
            line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }

            // section header
            if line.hasPrefix("[") && line.hasSuffix("]") {
                flush()
                currentID = String(line.dropFirst().dropLast())
                    .trimmingCharacters(in: .whitespaces)
                continue
            }

            // key = value
            guard let eqIdx = line.firstIndex(of: "=") else {
                if verbose {
                    FileHandle.standardError.write(
                        Data(("demi parse warn: line \(lineNo + 1) "
                              + "no '=' — \(line)\n").utf8))
                }
                continue
            }
            let keyPart = line[..<eqIdx].trimmingCharacters(in: .whitespaces)
            let valuePart = line[line.index(after: eqIdx)...]
                .trimmingCharacters(in: .whitespaces)

            let parsed = parseValue(valuePart)

            // dotted-key handling — accumulate into a nested .map
            if let dot = keyPart.firstIndex(of: ".") {
                let outer = String(keyPart[..<dot])
                let inner = String(keyPart[keyPart.index(after: dot)...])
                var existing: [String: DemiValue]
                if case .map(let m) = currentValues[outer] {
                    existing = m
                } else {
                    existing = [:]
                }
                existing[inner] = parsed
                currentValues[outer] = .map(existing)
            } else {
                currentValues[keyPart] = parsed
            }
        }
        flush()
        return sections
    }

    /// Parse a single RHS value — `"quoted"`, `bareword`, or `[a, b, c]`.
    private static func parseValue(_ raw: String) -> DemiValue {
        let s = raw.trimmingCharacters(in: .whitespaces)
        // list `[a, b, c]`
        if s.hasPrefix("[") && s.hasSuffix("]") {
            let inner = String(s.dropFirst().dropLast())
            let items = splitList(inner).map(unquote)
            return .list(items)
        }
        // string `"…"`
        return .string(unquote(s))
    }

    /// Strip surrounding double-quotes if present.
    private static func unquote(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces)
        if t.hasPrefix("\"") && t.hasSuffix("\"") && t.count >= 2 {
            return String(t.dropFirst().dropLast())
        }
        return t
    }

    /// Split a comma-separated list body, respecting quoted commas.
    private static func splitList(_ body: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        for ch in body {
            if ch == "\"" { inQuotes.toggle(); current.append(ch); continue }
            if ch == "," && !inQuotes {
                let trimmed = current.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { result.append(trimmed) }
                current = ""
                continue
            }
            current.append(ch)
        }
        let last = current.trimmingCharacters(in: .whitespaces)
        if !last.isEmpty { result.append(last) }
        return result
    }
}
