// VerbShell — 8 verb 페이지 공통 셸 layout.
// Assembles TopBar + LeftRail (VerbTreeNav + CookChefRail) + MainSplitPane.
// Each verb page passes `verb`, `domain`, and Q12 slot ReactNode.

import type { ReactNode } from "react";
import { TopBar } from "./TopBar";
import { VerbTreeNav, type VerbId, type VerbStatus } from "./VerbTreeNav";
import { CookChefRail } from "./CookChefRail";
import { MainSplitPane } from "./MainSplitPane";

export async function VerbShell({
  verb,
  domain,
  statusByVerb,
  record,
  slot,
  history,
}: {
  verb: VerbId;
  domain: string;
  statusByVerb: Partial<Record<VerbId, VerbStatus>>;
  record: ReactNode;
  slot: ReactNode;
  history: ReactNode;
}) {
  return (
    <div className="flex h-screen flex-col">
      <TopBar projectId={domain} />
      <div className="flex flex-1 gap-3 p-3">
        <aside className="flex w-72 flex-col gap-3">
          <div className="rounded border border-neutral-300 bg-white p-2 dark:border-neutral-700 dark:bg-neutral-900">
            <div className="mb-2 px-2 text-xs uppercase text-neutral-500">
              {verb} · {domain}
            </div>
            <VerbTreeNav
              activeVerb={verb}
              statusByVerb={statusByVerb}
              domain={domain}
            />
          </div>
          <div className="min-h-0 flex-1">
            <CookChefRail domain={domain} />
          </div>
        </aside>
        <main className="flex-1">
          <MainSplitPane record={record} slot={slot} history={history} />
        </main>
      </div>
    </div>
  );
}
