// /design — verb-only landing. ?d=<domain> → canonical /design/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function DesignVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/design/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
