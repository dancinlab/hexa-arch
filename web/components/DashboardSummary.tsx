// DashboardSummary — server component · pulls CATEGORIES + STDLIB_MATRIX
// straight from the tape parser to render the new GUI navigation panels
// (5 카테고리 trees · porting rollup · library shortcut).

import Link from "next/link";
import { loadTape } from "@/lib/tape";

export async function DashboardSummary() {
  let categories: Array<{ id: string; icon: string; alias: string; members: string[] }> = [];
  let rollup: Record<string, string | number | boolean | string[]> = {};
  try {
    const cats = await loadTape("domains/CATEGORIES.tape");
    categories = cats
      .filter((n) => n.type === "C")
      .map((n) => ({
        id: n.id,
        icon: String(n.fields.icon ?? "•"),
        alias: String(n.fields.alias ?? n.id),
        members: Array.isArray(n.fields.members) ? n.fields.members : [],
      }));
    const matrix = await loadTape("domains/STDLIB_MATRIX.tape");
    const summary = matrix.find((n) => n.id === "rollup_summary");
    if (summary) rollup = summary.fields;
  } catch {
    // file system unreachable -> empty panels
  }

  return (
    <section className="mt-8 space-y-6">
      <div className="flex items-baseline gap-4">
        <h2 className="text-lg font-bold">🗂 카테고리</h2>
        <span className="text-xs text-neutral-500">
          stdlib matrix · {String(rollup.porting_complete ?? "—")}
        </span>
        <Link href="/library" className="ml-auto text-xs hover:underline">
          📖 라이브러리 →
        </Link>
        <Link href="/matter" className="text-xs hover:underline">
          ⚖️ matter →
        </Link>
      </div>
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
        {categories.map((c) => (
          <article
            key={c.id}
            className="rounded border border-neutral-300 bg-white p-3 dark:border-neutral-700 dark:bg-neutral-900"
          >
            <header className="mb-2 flex items-center gap-2">
              <span className="text-lg">{c.icon}</span>
              <span className="font-bold">{c.alias}</span>
              <span className="ml-auto text-xs text-neutral-500">{c.members.length}</span>
            </header>
            <ul className="space-y-0.5 text-xs">
              {c.members.map((m) => (
                <li key={m}>
                  <Link className="hover:underline" href={`/spec/${m}`}>
                    {m}
                  </Link>
                </li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </section>
  );
}
