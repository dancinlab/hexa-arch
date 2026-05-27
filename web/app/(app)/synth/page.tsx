// /synth — verb-only landing. ?d=<domain> → canonical /synth/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function SynthVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/synth/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
