// /admin — provider toggle surface. Admin-only.
//
// Single-active switch (payment) · multi-enabled + priority (GPU/LLM).
// Writes via POST /api/v1/providers — server checks `users/{uid}.role === "admin"`.

import { redirect } from "next/navigation";
import { currentUser } from "@/lib/session";
import { getDoc } from "@/lib/firestore";
import { getRegistry } from "@/lib/providers";
import { AdminToggles } from "@/components/AdminToggles";

export const dynamic = "force-dynamic";

export default async function AdminPage() {
  const u = await currentUser();
  if (!u) redirect("/signin");

  let role = "user";
  try {
    const doc = await getDoc(`users/${u.localId}`);
    if (doc && (doc as Record<string, unknown>).role === "admin") role = "admin";
  } catch {
    // fall through with role="user"
  }
  if (role !== "admin") redirect("/dashboard");

  const registry = await getRegistry();

  return (
    <main className="mx-auto max-w-3xl px-6 py-12">
      <h1 className="text-2xl font-bold tracking-tight">⚙️ /admin</h1>
      <p className="mt-2 text-sm text-neutral-500">
        provider toggle · admin-only · user UI 불변 (라우터 자동 픽)
      </p>
      <AdminToggles initial={registry} />
    </main>
  );
}
