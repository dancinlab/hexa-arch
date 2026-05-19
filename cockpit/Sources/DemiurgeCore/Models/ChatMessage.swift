// ChatMessage — the ③ "요리 선생님" chat turn (phase η-1).
//
// Lives in DemiurgeCore so cockpit (renders it) and ChatStore
// (persists it) share ONE type — @D g_ssot_single_source / D50.
// Pure Foundation (Package.swift contract); Codable for ChatStore.
//
// Honesty (g3, rfc_011 §4.2): `.rejected` is a render-only banner the
// cockpit's over-claim guard appends; it is NOT persisted (ChatStore
// drops it on save and the guard re-flags on load), so the honesty
// banner is always derived from the current guard, never a stale
// disk copy.

import Foundation

public struct ChatMessage: Identifiable, Codable, Equatable, Sendable {
    public enum Role: String, Codable, Sendable {
        case user, assistant, rejected
    }

    public let id: UUID
    public let role: Role
    public let text: String

    public init(id: UUID = UUID(), role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}
