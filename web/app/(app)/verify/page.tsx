// /verify — verb-only landing. ?d=<domain> → canonical /verify/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function VerifyVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/verify/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
