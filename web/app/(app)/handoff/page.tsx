// /handoff — verb-only landing. ?d=<domain> → canonical /handoff/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function HandoffVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/handoff/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
