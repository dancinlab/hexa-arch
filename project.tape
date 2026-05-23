@V := "tape" :: spec [active]
  version = "1.5"

@I := "demiurge" :: identity [active]
  kind     = "Universal hexa-native technical-design architecture (7-verb pipeline · domain-plugin macOS cockpit)"
  brief    = "spec → structure → design → analyze ⟲ → synthesize → verify → handoff · materials → chip → component"
  parent   = "dancinlab"
  ssot     = "github.com/dancinlab/demiurge (`hx install demiurge`)"
  siblings = "hexa-lang"

@D d1 := "non-wet-lab verification → completed-form" :: governance [required active]
  do   = "drive every non-wet-lab step (sim · analysis · proof · synthesis · cockpit gate · handoff) to completed-form before the wet-lab boundary"
  dont = "leave non-wet-lab verification `partial` / `pending` when the path to completion is clear"

@D d2 := "wall encountered — surface breakthrough paths, never concede" :: governance [required active]
  do   = "on an empirically-demonstrated wall, propose 2-3 concrete breakthrough hypotheses — `/gap full` 40-lens sweep · `hexa kick`"
  dont = "concede `impossible with current methods` without naming concrete breakthrough paths to try"

@D d3 := "implementation code lives in one canonical home" :: governance [required active]
  do   = "algorithm / implementation code lives in the canonical stdlib home — topical folders hold docs / manifests / examples only"
  dont = "duplicate implementation across topical folders · treat per-domain repos as code homes"

@D d4 := "single generic dispatch — new instance = manifest only" :: governance [required active]
  do   = "dispatch all variants / domains / tenants through one generic path — new instance = drop a manifest"
  dont = "per-instance dispatcher / producer class · hard-coded instance branches in the router"

@D d5 := "universal generic path — no instance-name hardcoding" :: governance [required active]
  do   = "every instance / variant traverses the same generic path — add / rename / remove is manifest-only"
  dont = "branch on instance name in the generic layer · per-instance hardcoded checks"

@D d6 := "absorbed=true ⇔ measured-oracle PASS" :: governance [required active]
  do   = "flip `absorbed=true` only when an attached `MeasuredOracleRef` records `isMeasuredOraclePASS=true` · keep it orthogonal to substrate-parity"
  dont = "flip `absorbed` from a computed projection · attach a MeasuredOracleRef to illustrative-physics cells · branch the invariant on record type"

@D d7 := "first-principles physics breaks the ML training-distribution wall" :: governance [required active]
  do   = "when a wall is a model's training-distribution limit, the breakthrough path is first-principles physics, not more ML · report only grid-converged values"
  dont = "force a target number under goal pressure · present an under-converged value as the result · flip `absorbed` from a simulation-only prediction"

@D d8 := "compute sizing for DFT electron-phonon" :: governance [required active]
  do   = "small cells (4-7 atoms) → pool ubu-1/2 free baseline · batch / acceleration → Vast.ai CPU market · ≥20 atoms or dense k-grids → GPU pod"
  dont = "RunPod CPU pods (8-vCPU ceiling) · Vast.ai CPU-only rentals (no_such_ask — use GPU offers, run on host CPU) · pay for GPU on small cells"

@D d9 := "Vast.ai trouble → hexa-lang inbox" :: governance [required active]
  do   = "Vast finding → `hexa-lang/inbox/patches/<slug>.md` so `hexa cloud` absorbs upstream"
  dont = "paper-over a Vast-discovered `hexa cloud` gap inside the campaign"

@D d10 := "worktree concurrent agent index isolation" :: governance [required active]
  do   = "sequential commit on main · stage+commit one agent at a time · `git add <explicit-files>` only"
  dont = "parallel worktree agents staged at once → index leak · stage absorbed into another agent's commit"
