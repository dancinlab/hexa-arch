// FalsifierEntry — typed-field schema for preregistered falsifiers
// (G5 from ARCH.md §11.4; hexa-ufo / hexa-aura / hexa-cern patterns).
//
// Preregistered falsifiers (F-WARP-1, F-AURA-2, …) live in sibling
// substrates (hexa-ufo, hexa-aura, …) as OPEN at v1.0.0 of each
// substrate. When a demiurge cell verifies that domain, the cell's
// `*VerifyRecord` carries this array typed instead of leaving the
// status hidden in a CSV.
//
// monotone — status is only allowed to flip OPEN → CONFIRMED OR
// OPEN → DEMOTED. silent retract is forbidden (hexa-ufo / hexa-aura
// invariants). G6 (cross-domain cascade) is enabled by `demotedIf`:
// if the named upstream falsifier flips to DEMOTED, this entry
// auto-cascades to DEMOTED.

import Foundation

public enum FalsifierStatus: String, Codable, Sendable {
    case open
    case confirmed
    case demoted
}

public struct FalsifierEntry: Codable, Sendable, Equatable, Identifiable {
    /// Stable id — "F-AURA-2", "F-WARP-1", "F-USE-3", …
    public let id: String
    /// Monotone status — OPEN → {CONFIRMED, DEMOTED} only.
    public let status: FalsifierStatus
    /// ISO 8601 opened-at timestamp.
    public let openedAt: String
    /// G6 — upstream falsifier id whose DEMOTED status auto-cascades
    /// this entry to DEMOTED (cross-domain dependency).
    public let demotedIf: String?
    /// Evidence ref (arxiv / DOI / commit) when status flips to
    /// CONFIRMED or DEMOTED. Required for non-OPEN status.
    public let evidenceRef: String?
    /// One-line description (e.g., "Alcubierre warp negative-energy
    /// requirement bound").
    public let summary: String?

    public init(id: String,
                status: FalsifierStatus = .open,
                openedAt: String,
                demotedIf: String? = nil,
                evidenceRef: String? = nil,
                summary: String? = nil) {
        self.id = id
        self.status = status
        self.openedAt = openedAt
        self.demotedIf = demotedIf
        self.evidenceRef = evidenceRef
        self.summary = summary
    }

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case openedAt = "opened_at"
        case demotedIf = "demoted_if"
        case evidenceRef = "evidence_ref"
        case summary
    }
}
