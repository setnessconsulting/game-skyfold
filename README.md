# Skyfold

**A paper crane's flight.** Skyfold is an original one-button flight game for Windows, built with Godot 4.7.2. Tap to flap, hold to tuck into a glide, ride wind ribbons, thread living gates, and relight the lanterns before the storm folds the sky shut.

> **Status: Gate 0 foundation.** The deterministic flight core and grey-box prototype run; art, audio, campaign content, and the Windows release are not built yet. This README never claims more than the repository contains.

## What is here

- A deterministic, node-free flight simulation with fixed 120 Hz stepping.
- A playable grey-box: flap, glide, gates, thread/graze scoring, crash, instant restart, pause.
- A zero-dependency headless test runner and project verification.
- CI scaffolding for the portfolio `game-pr-fast` gate.
- Design, technical, and anti-clone documentation for the full release.

Not here yet: final art, audio, campaign passages, gauntlets, Endless, Daily, saves, accessibility pass, Windows export, or a public build.

## Run the grey-box

Requirements: Godot **4.7.2** standard build (not .NET). The local toolchain uses `godot` on `PATH`.

```powershell
godot --path . --editor
```

Press Play, or run without the editor:

```powershell
godot --path .
```

Controls: `Space` or left mouse to flap; hold after a flap to glide; release to fall. `R` restarts. `Esc` or `P` pauses. `M` mutes.

## Verify

```powershell
.\tools\ci\verify.ps1
```

The script imports the project, parse-checks every GDScript file, runs the headless test suite, and validates project settings. It exits non-zero on failure.

Individual commands:

```powershell
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tools/verify_project.gd
```

## Design and plan

- [Vision and pillars](docs/vision.md)
- [Anti-clone guardrails](docs/anti-clone.md)
- [Technical plan](docs/technical-plan.md)
- [Epic and release gates](docs/epic-skyfold.md)
- [Jira map](docs/jira-map.md)
- [Gate 0 evidence](docs/evidence/gate-0.md)

## Repository layout

```text
scenes/        boot, flight, and future app/game scenes
scripts/sim/   deterministic, node-free simulation
scripts/game/  input, presentation, HUD
tests/         zero-dependency headless GDScript tests
tools/         project verification and CI helpers
docs/          vision, technical plan, epic, evidence
```

## License

Code is MIT licensed. Original art and audio are licensed separately under CC BY-NC-SA 4.0; see [ASSET-LICENSE.md](ASSET-LICENSE.md). Third-party notices are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Skyfold is an original work. It is not affiliated with, endorsed by, or derived from *Flappy Bird* or any other game. See [docs/anti-clone.md](docs/anti-clone.md).
