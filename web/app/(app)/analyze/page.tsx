// /analyze — verb-only landing. ?d=<domain> → canonical /analyze/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function AnalyzeVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/analyze/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
