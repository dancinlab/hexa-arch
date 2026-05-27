// HandoffDossier — client-side dossier preview + download.
// Pulls /api/v1/handoff/[domain], renders manifest summary, offers download.

"use client";

import { useEffect, useState } from "react";

type Dossier = {
  domain: string;
  generated_at: string;
  records: Array<Record<string, unknown>>;
  manifest: {
    verb_count: number;
    complete_count: number;
    in_progress_count: number;
    todo_count: number;
  };
};

export function HandoffDossier({ domain }: { domain: string }) {
  const [dossier, setDossier] = useState<Dossier | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch(`/api/v1/handoff/${domain}`)
      .then(async (r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then((d) => setDossier(d as Dossier))
      .catch((e: unknown) =>
        setError(e instanceof Error ? e.message : String(e)),
      );
  }, [domain]);

  if (error) return <div className="text-xs text-danger">{error}</div>;
  if (!dossier) return <div className="text-xs text-muted">로딩…</div>;

  const m = dossier.manifest;
  const pct = m.verb_count
    ? Math.round((m.complete_count / m.verb_count) * 100)
    : 0;

  return (
    <div className="space-y-3 text-sm">
      <div className="flex items-center gap-3">
        <span className="text-2xl">📦</span>
        <div className="flex-1">
          <div className="font-bold text-ink">{dossier.domain} dossier</div>
          <div className="text-xs text-muted">
            {dossier.generated_at.slice(0, 19).replace("T", " ")} ·{" "}
            {m.complete_count}/{m.verb_count} 완료 ({pct}%)
          </div>
        </div>
        <a
          className="rounded-control border border-hairline-strong px-3 py-1 text-xs text-ink hover:bg-surface-strong"
          href={`/api/v1/handoff/${domain}?download=1`}
        >
          ⬇ 다운로드 (.json)
        </a>
      </div>
      <div className="grid grid-cols-3 gap-2 text-xs">
        <div className="rounded-chip border border-hairline bg-surface px-2 py-1 text-success">
          🟢 complete {m.complete_count}
        </div>
        <div className="rounded-chip border border-hairline bg-surface px-2 py-1 text-muted">
          🟡 in_progress {m.in_progress_count}
        </div>
        <div className="rounded-chip border border-hairline bg-surface px-2 py-1 text-muted-soft">
          ⚪ todo {m.todo_count}
        </div>
      </div>
      <details className="text-xs">
        <summary className="cursor-pointer text-body">
          📜 records ({dossier.records.length})
        </summary>
        <ul className="mt-1 space-y-1">
          {dossier.records.map((r, i) => (
            <li
              key={String(r.verb ?? r.id ?? i)}
              className="flex items-center gap-2 rounded-chip border border-hairline bg-surface px-2 py-1"
            >
              <span className="font-mono text-body-strong">
                {String(r.verb ?? r.id ?? `record ${i + 1}`)}
              </span>
              {typeof r.summary === "string" && r.summary && (
                <span className="flex-1 truncate text-muted">{r.summary}</span>
              )}
              <RecordStatus status={r.status} />
            </li>
          ))}
        </ul>
      </details>
    </div>
  );
}

function RecordStatus({ status }: { status: unknown }) {
  const s = typeof status === "string" ? status : "";
  const tone =
    s === "complete"
      ? "text-success"
      : s === "in_progress"
        ? "text-muted"
        : s === "todo"
          ? "text-muted-soft"
          : "text-danger";
  return <span className={`ml-auto shrink-0 ${tone}`}>{s || "—"}</span>;
}
