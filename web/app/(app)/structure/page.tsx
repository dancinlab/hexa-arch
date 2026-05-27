// /structure — verb-only landing. ?d=<domain> → canonical /structure/<domain>. bare → /dashboard.

import { redirect } from "next/navigation";

export default async function StructureVerbLanding({
  searchParams,
}: {
  searchParams: Promise<{ d?: string }>;
}) {
  const { d } = await searchParams;
  if (d) redirect(`/structure/${encodeURIComponent(d.toLowerCase())}`);
  redirect("/dashboard");
}
