// TopBar — Q3 상단 · 프로젝트 selector · 사용자 · /admin (role=admin 만).
// PR#35: client component → layout 이 더 이상 async server fetch 안 함 →
// SPA navigation 시 layout 전체 re-render 없음 (children 만 swap).
// /api/v1/me 한 번 fetch 후 로컬 캐시.

"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

type Me = { authenticated: boolean; email?: string; role?: string };

export function TopBar() {
  const [me, setMe] = useState<Me | null>(null);
  useEffect(() => {
    let live = true;
    fetch("/api/v1/me")
      .then((r) => (r.ok ? r.json() : { authenticated: false }))
      .then((d: Me) => { if (live) setMe(d); })
      .catch(() => { if (live) setMe({ authenticated: false }); });
    return () => { live = false; };
  }, []);

  return (
    <header className="flex items-center gap-3 border-b border-neutral-300 bg-white px-4 py-2 text-sm dark:border-neutral-700 dark:bg-neutral-950">
      <Link href="/dashboard" className="font-bold">📐 demiurge</Link>
      <span className="flex-1" />
      <Link href="/library" className="text-xs hover:underline">📖 library</Link>
      <Link href="/matter" className="text-xs hover:underline">⚖️ matter</Link>
      {me?.role === "admin" && (
        <Link href="/admin" className="rounded border border-red-400 px-2 py-0.5 text-xs text-red-500">
          ⚙️ /admin
        </Link>
      )}
      {me?.authenticated ? (
        <Link href="/account" className="text-xs">{me.email}</Link>
      ) : (
        <Link href="/signin" className="text-xs hover:underline">sign in</Link>
      )}
    </header>
  );
}
