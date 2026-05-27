// Provider registry — single Firestore doc `providers/registry`.
// Payment is single-active switch · GPU/LLM are multi-enabled + priority.
// Read = public · write = admin only (enforced in /api/v1/providers POST).

import { getDoc, setDoc } from "./firestore";

export type ProviderRegistry = {
  payment: {
    active: "stripe" | "lemonsqueezy";
    available: string[];
  };
  gpu: Record<string, { enabled: boolean; priority: number }>;
  llm: Record<string, { enabled: boolean; priority: number }>;
};

export const DEFAULT_REGISTRY: ProviderRegistry = {
  payment: {
    active: "stripe",
    available: ["stripe", "lemonsqueezy"],
  },
  gpu: {
    vast: { enabled: true, priority: 1 },
    runpod: { enabled: true, priority: 2 },
    vertex: { enabled: true, priority: 3 },
  },
  llm: {
    vertex_gemini: { enabled: true, priority: 1 },
    openai: { enabled: false, priority: 99 },
    anthropic: { enabled: false, priority: 99 },
  },
};

const DOC_PATH = "providers/registry";

export async function getRegistry(): Promise<ProviderRegistry> {
  try {
    const doc = await getDoc(DOC_PATH);
    if (doc && typeof doc === "object") {
      return { ...DEFAULT_REGISTRY, ...(doc as Partial<ProviderRegistry>) };
    }
  } catch {
    // Firestore unreachable -> hand back DEFAULT_REGISTRY (XPRIZE-safe).
  }
  return DEFAULT_REGISTRY;
}

export async function writeRegistry(next: ProviderRegistry): Promise<void> {
  await setDoc(DOC_PATH, next as unknown as Record<string, unknown>);
}

/** Pick active payment provider (single-active switch). */
export function activePayment(r: ProviderRegistry): string {
  return r.payment.active;
}

/** Pick highest-priority enabled provider for GPU/LLM (returns null if none). */
export function pickProvider(
  r: ProviderRegistry,
  kind: "gpu" | "llm",
): string | null {
  const entries = Object.entries(r[kind])
    .filter(([, v]) => v.enabled)
    .sort((a, b) => a[1].priority - b[1].priority);
  return entries[0]?.[0] ?? null;
}
