// trajectory — 도메인 .log.md 의 step 로그를 ara "AUTO-CAPTURED TRAJECTORY"
// 4-label 타임라인으로 변환 (decision · dead_end · heuristic · experiment).
// 키워드 휴리스틱 분류 — LLM 없이 결정적.

export type TrajLabel = "decision" | "dead_end" | "heuristic" | "experiment";
export type TrajEntry = { label: TrajLabel; text: string };

export function classifyLogLine(line: string): TrajLabel {
  const l = line.toLowerCase();
  // dead_end — 벽 · 실패 · 발산 · falsified
  if (/🔴|falsif|diverg|\bwall\b|\bfail|막힘|벽|불가|abandon|revert/.test(l)) {
    return "dead_end";
  }
  // experiment — 측정 · 통과 · 수렴 · 게이트
  if (/🟢|✅|\bpass\b|absorb|converg|gate|measured|verdict|run|loss|결과|측정/.test(l)) {
    return "experiment";
  }
  // decision — 선택 · 채택 · 전략 · 접근
  if (/decision|chose|choose|택|결정|strateg|approach|채택|pivot|adopt|선택/.test(l)) {
    return "decision";
  }
  // 나머지 — heuristic (fix · use · apply · tweak)
  return "heuristic";
}

// 로그 본문 → 최근 N개 trajectory entry (앞부분이 최신 — log 는 prepend 가정).
export function logToTrajectory(logText: string, max = 8): TrajEntry[] {
  return logText
    .split("\n")
    .map((l) => l.replace(/^[-*#>\s]+/, "").trim())
    .filter((l) => l.length > 8 && !/^={3,}|^-{3,}/.test(l))
    .slice(0, max)
    .map((text) => ({
      label: classifyLogLine(text),
      text: text.length > 140 ? text.slice(0, 137) + "…" : text,
    }));
}
