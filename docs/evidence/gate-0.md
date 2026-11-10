# Gate 0 evidence — foundation and grey-box

**Recorded:** 2026-11-10 (America/Los_Angeles)
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf`
**Renderer:** GL Compatibility
**Repository:** `setnessconsulting/game-skyfold`
**Epic:** GAME-486

## What was verified

| Check | Command | Result |
|---|---|---|
| Import | `godot --headless --path . --import` | Pass |
| Full local verification | `.\tools\ci\verify.ps1` | Pass |
| GDScript parse check | `godot --headless --path . --check-only --script <each .gd>` | Pass |
| Headless core tests | `godot --headless --path . --script res://tests/run_tests.gd` | **34 tests, 90 checks, 0 failures** |
| Project verification | `godot --headless --path . --script res://tools/verify_project.gd` | **38 checks, 0 failures** |
| Runtime smoke | `godot --headless --path . --quit-after 300` | No runtime errors |
| Movie Maker render | `godot --path . --resolution 1280x720 --write-movie <png> --fixed-fps 60 --quit-after 90` | 90 frames rendered; frame reviewed |

The movie render used the RTX 4070 Laptop GPU. It is a presentation smoke test,
not a performance qualification.

## What this does not prove

- Human feel, fun, or readability. SF-05's five internal sessions are still
  pending.
- Final art or audio. The grey-box is intentionally placeholder.
- Campaign, Endless, Daily, saves, or accessibility.
- Windows export, clean-VM behavior, SmartScreen, or a release.
- Performance on Intel Iris Xe. The render used the discrete GPU.

## Next evidence

1. Five internal grey-box sessions and the SF-05 go/no-go memo.
2. The first `game-pr-fast` run on a PR head.
3. Export-template install and a Windows export smoke test.
4. The Paper Fields vertical slice and five external players.
