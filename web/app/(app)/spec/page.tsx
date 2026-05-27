// /spec — verb-only landing. Accepts ?d=<domain> (legacy query form from
// older menus) and redirects to the canonical /spec/<domain> path. Bare
// /spec (no query) lands on /dashboard.

import { redirect } from "next/navigation";

export default async function SpecVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/spec/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
