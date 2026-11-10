# Repository status — Skyfold

**Last updated:** 2026-11-10 (Gate 0 foundation)
**Jira epic:** [GAME-486](https://setnessconsulting.atlassian.net/browse/GAME-486)
**Child map:** [docs/jira-map.md](docs/jira-map.md)

## State

**Lifecycle:** foundation / grey-box prototype. There is no public build.

| Capability | State | Evidence |
|---|---|---|
| Public repo and Godot 4.7.2 project | Implemented | `project.godot`; clean-clone import |
| Deterministic flight simulation | Implemented and verified | `scripts/sim/flight_sim.gd`; 34 tests / 90 checks |
| Tap flap + hold glide | Implemented and verified | Grey-box; headless tests |
| Gates, thread/graze scoring, combo | Implemented and verified | Headless tests |
| Instant restart and pause | Implemented | Grey-box scene |
| Headless verification | Implemented and verified | `tools/ci/verify.ps1`; 38 project checks |
| CI `game-pr-fast` | Verified on PR #1 | Workflow run 42904695940; required check |
| Export templates | Installed and verified | `4.7.2.stable` Windows templates |
| Windows export smoke | Implemented; not clean-VM qualified | `build/windows/Skyfold.exe` + `.pck`; exported runtime 300-frame smoke |
| Final art and audio | Not started | — |
| Campaign, Endless, Daily | Not started | — |
| Saves and accessibility | Not started | — |
| Windows export and release | Not started | — |

## Verification

Canonical command:

```powershell
.\tools\ci\verify.ps1
```

Current evidence is repository-only. It does not qualify feel, visual quality,
audio, accessibility, performance on a clean Windows VM, or a release. See
[docs/evidence/gate-0.md](docs/evidence/gate-0.md).

## Jira state

The epic and 34 children exist. All children are in Backlog. Gate 0 work is
being implemented in the repository; statuses will move only as evidence is
recorded. SF-05's human five-session feel gate is pending, so Gate 0 is not
complete.

## Merge gate

The intended required check is `game-pr-fast` from GitHub Actions on the exact
PR head. Jenkins is not a required check. Branch protection is configured after
the first workflow run.

## Open work

1. Five internal grey-box sessions and the SF-05 go/no-go memo.
2. First `game-pr-fast` PR run and branch protection.
3. Export-template install and a Windows export smoke test.
4. Vertical slice (Paper Fields) and five external players.

Then systems, art, audio, content, verification, and the Windows release follow
in [docs/epic-skyfold.md](docs/epic-skyfold.md).
