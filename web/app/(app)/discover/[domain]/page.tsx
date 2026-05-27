// /discover/[domain] — 8-verb shell · discover slot = kick/gap tree.

import { VerbShell } from "@/components/VerbShell";

export const dynamic = "force-dynamic";

export default async function Page({
  params,
}: {
  params: Promise<{ domain: string }>;
}) {
  const { domain } = await params;
  return (
    <VerbShell
      verb="discover"
      domain={domain}
      statusByVerb={{}}
      record={<pre className="text-xs">{JSON.stringify({ verb: "discover", domain }, null, 2)}</pre>}
      slot={<div className="text-xs text-neutral-500">🌳 kick/gap tree · phanes bridge pending</div>}
      history={<div className="text-xs text-neutral-500">history · {domain}/discover</div>}
    />
  );
}
