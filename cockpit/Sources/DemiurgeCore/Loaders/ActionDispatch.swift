// ActionDispatch — the shared θ-2 / chat backend (rfc_011 §6, D49).
//
// cockpit's chat + "▶ 실제로 돌리기" action AND DemiurgeCLI's action
// subcommand both go through the same three functions here, so the
// action prompt, the record-ID parser, and the claude-CLI invocation
// are byte-identical across both surfaces (@D g_ssot_single_source /
// D50 — CLI ↔ cockpit 멱등성).
//
// Honesty (g3, @F f6): the action prompt instructs the agent to
// report "no engine tool" plainly when none is available, and never
// to claim a measurement without a backing exports/ record. The
// cockpit's REJECTED guard (rfc_011 §4.2 — overclaims/) is an
// independent second line of defense.

import Foundation

public enum ActionDispatch {

    /// rfc_011 §6.3 action prompt for a verb — instructs the agent to
    /// check for a real engine tool / existing measured record and
    /// report honestly (g3 / @F f6). Identical across cockpit + CLI.
    public static func actionPrompt(verb: Verb) -> String {
        return "The user clicked '실제로 돌리기' (run for real) on the "
            + "\(verb.canonical) stage of a demiurge project. Check "
            + "whether demiurge has a real engine tool for this stage "
            + "and whether any measured record exists under exports/**. "
            + "If a tool is available, describe how it would run. If "
            + "NOT, state plainly in Korean that there is no engine "
            + "tool yet — do NOT claim anything was measured or "
            + "verified (g3 — no over-claim). Never assert ✅ / 측정완료 "
            + "without a backing exports/ record ID."
    }

    /// Best-effort extraction of F1F2 record IDs from agent output —
    /// rfc_011 §6.3 "output piped + parsed for new record IDs".
    public static func parseRecordIDs(_ text: String) -> [String] {
        let pattern = "F1F2[-_][A-Za-z0-9._-]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        let ids = regex.matches(in: text, range: range).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
        return Array(Set(ids)).sorted()
    }

    /// Invoke `claude -p <guarded>` as a SYNCHRONOUS subprocess and
    /// return the captured stdout. Read-only — `claude -p` (print
    /// mode) without inherited tool permissions cannot modify files
    /// or run builds (g3 / @F f6). The cockpit wraps this in a
    /// Task.detached so the UI thread does not block; the CLI calls
    /// it directly (its main is already off the UI thread).
    public static func askClaude(prompt: String, context: String) -> String {
        let guarded = "[demiurge — answer concisely in Korean, plain "
            + "language; do NOT modify files, run builds, or invoke "
            + "tools. Project context: \(context)] \(prompt)"
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        proc.arguments = ["claude", "-p", guarded]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        do {
            try proc.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            proc.waitUntilExit()
            let out = (String(data: data, encoding: .utf8) ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if out.isEmpty {
                return "(claude returned no output; exit \(proc.terminationStatus))"
            }
            return out
        } catch {
            return "claude invocation failed: \(error.localizedDescription)\n"
                + "(`claude` must be on PATH)"
        }
    }
}
