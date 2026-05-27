// /synth/[domain] — 8-verb shell · slot placeholder until PR#5+ wires real viewers.

import { VerbShell } from "@/components/VerbShell";
import type { VerbId } from "@/components/VerbTreeNav";

export const dynamic = "force-dynamic";

export default async function Page({
  params,
}: {
  params: Promise<{ domain: string }>;
}) {
  const { domain } = await params;
  const verb: VerbId = "synth";
  return (
    <VerbShell
      verb={verb}
      domain={domain}
      statusByVerb={{}}
      record={<pre className="text-xs">{JSON.stringify({ verb, domain }, null, 2)}</pre>}
      slot={<div className="text-xs text-neutral-500">slot · {verb} (real viewer = PR#5+)</div>}
      history={<div className="text-xs text-neutral-500">history · {domain}/{verb} (Firestore stream pending)</div>}
    />
  );
}
