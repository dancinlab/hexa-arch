# hexa `exec` subprocess broken — empty stdout + "broken pipe" on all commands

**Date** : 2026-05-21
**Reporter** : SSA-fix session (rfc_006 §5 work)
**Severity** : blocks `stdlib/yosys/gate_record.hexa` end-to-end measurement
**Scope** : `self/runtime.c` (popen / pipe handling) — NOT a stdlib bug

## Reproduce

```hexa
// /tmp/probe.hexa
fn main() {
    let r1 = exec("echo hello")
    println("r1='" + to_string(r1).trim() + "'")
    let r2 = exec("command -v abc 2>/dev/null || true")
    println("r2='" + to_string(r2).trim() + "'")
    let r3 = exec("which abc 2>/dev/null || true")
    println("r3='" + to_string(r3).trim() + "'")
    let r4 = exec("echo $PATH")
    println("r4='" + to_string(r4).trim() + "'")
    let r5 = exec("ls /opt/homebrew/bin/abc 2>/dev/null || echo MISSING")
    println("r5='" + to_string(r5).trim() + "'")
}
```

```sh
$ hexa run /tmp/probe.hexa
sh: line 0: echo: write error: Broken pipe
r1=''
r2=''
r3=''
sh: line 0: echo: write error: Broken pipe
r4=''
sh: line 0: echo: write error: Broken pipe
r5=''
```

Every exec call returns empty + emits a `Broken pipe` warning on the
child side. Shell-side commands work fine:

```sh
$ command -v abc
/opt/homebrew/bin/abc
$ bash -c "command -v abc 2>/dev/null"
/opt/homebrew/bin/abc
$ /bin/sh -c "command -v abc 2>/dev/null"
/opt/homebrew/bin/abc
```

The child `sh` is being torn down before its stdout can be drained,
so `popen` returns "" and the child detects the closed pipe on its
next write attempt.

## Downstream blast radius

- `stdlib/kernels/logic_synth/abc_map.hexa::abc_binary_path()` —
  `exec("command -v abc …")` returns `""` → `[abc_map] exit=missing`
  → `[FAIL] d4:abc_map` → `[gate] verdict: PARTIAL — d4 frontend gap`.
- `stdlib/yosys/gate_record.hexa` end-to-end area measurement
  cannot complete; `router_d{4,6} area=0.0 µm²` cannot be tested
  for ±5 % oracle parity.
- Blocks `rfc_006 §5 measurement_gate` close even after PR #247
  (ABC comb-loop SSA fix) lands.

## Suspect

`self/runtime.c` was modified in the parent branch
`s1-step2-codegen-perf` (stashed at session start: "WIP s1-step2
sibling work (AGENTS.tape + self/runtime.c + untracked inbox
patch) 2026-05-21 before rfc006-yosys-comb-loop-ssa"). If the
current `self/native/hexa_v2` binary was rebuilt against that
modified runtime.c, popen plumbing might be in an inconsistent
state.

To test:
```sh
$ git -C ~/core/hexa-lang log -1 self/native/hexa_v2
$ git -C ~/core/hexa-lang log -1 self/runtime.c
```
If `hexa_v2` mtime > runtime.c HEAD mtime → binary built against
working tree, possibly a broken intermediate.

Also worth checking:
- `runtime.c:758` ("popen → sh -c → interp loses DYLD" comment)
- `runtime.c:7607` ("pipe/fork/execvp (not popen, which merges 2>&1
  when you redirect it)")
- `runtime.c:7735` `popen(cmd, "r")` — main exec entry
- `runtime.c:8281` `"POSIX fork buffer flush before popen (mirrors
  hexa_exec)"` comment

The broken-pipe-on-first-write pattern is classic
parent-closes-pipe-before-child-writes — likely a missing
`pclose`/`fclose` or a too-early `fflush` race.

## Tried + rolled back

In PR #247 dev cycle I tried an absolute-path fallback in
`abc_binary_path()`:

```hexa
let probe = exec("test -x /opt/homebrew/bin/abc && echo /opt/homebrew/bin/abc || true")
```

That ALSO returns "" (every exec call is broken, not just `command -v`).
Reverted. PR #247 ships pure `read_verilog.hexa` changes only.

## Next session

1. Reproduce the broken-pipe with the probe script above on a clean
   tree (no sibling stash applied) to confirm the bug isn't local to
   the working state.
2. If reproducible, instrument `self/runtime.c::hexa_exec` (or
   whichever wrapper hosts `popen("…", "r")`) with stderr trace —
   exact line where the pipe closes early.
3. After fix, re-run `hexa run stdlib/yosys/gate_record.hexa` and
   confirm `router_d4 area > 0` (the rfc_006 §5 measurement-gate
   signal).
