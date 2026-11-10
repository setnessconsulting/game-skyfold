# Agent guidance — game-skyfold

## Purpose

Skyfold is an original one-button flight game for Windows, built with Godot 4.7.2. This repository owns the game source, tests, assets, build identity, and release evidence. It is not a Game Maker orchestration repository and does not own the games-site catalog.

## Source-of-truth hierarchy

1. Jira `GAME` epic and children for scope, status, and acceptance.
2. This repository for implementation truth.
3. `docs/vision.md`, `docs/technical-plan.md`, and `docs/epic-skyfold.md` for governing design and delivery intent.
4. `STATUS.md` for the truthful capability ledger.
5. Plans, prompts, and screenshots are not proof of completed functionality.

## Canonical toolchain

- Godot **4.7.2.stable** standard build, GDScript only, GL Compatibility renderer.
- Do not upgrade the engine, renderer, or main scene without an ADR and a profile/toolchain update.
- Do not add editor plugins, addons, packages, or C#.
- The local editor binary is `C:\ProgramData\Setness\Tools\Godot\4.7.2\Godot_v4.7.2-stable_win64.exe`; the console wrapper is `C:\ProgramData\Setness\CI\bin\godot.cmd`.

## Canonical verification

```powershell
.\tools\ci\verify.ps1
```

That script runs:

```powershell
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --script res://tools/verify_project.gd
```

plus a parse check of every `*.gd` file. It must pass from a clean checkout before a PR is ready.

## Gameplay boundary

- `scripts/sim/` is deterministic and node-free. It must not use `Input`, `get_tree()`, `AudioServer`, scene loading, or global random functions.
- Views read simulation snapshots; they never mutate the simulation.
- Fixed 120 Hz simulation step; render interpolation is presentation-only.
- Seeded RNG only. Replays are identified by seed and input tick sequence.
- A static check in `tools/verify_project.gd` enforces the forbidden-symbol rule.

## Pull requests

- Changes to `main` land through a non-draft pull request.
- The required check is `game-pr-fast` from GitHub Actions. It must pass on the exact PR head.
- The author self-reviews the exact diff and may merge after required checks pass; no separate approving review is required.
- Jenkins is not a required PR check and must not be dispatched for routine work.
- Do not force-push. Do not weaken branch protection or tests to make a check pass.

## Asset and legal rules

- Do not use the *Flappy Bird* name, bird design, pipes, ground strip, score font, sounds, or store copy in any public artifact.
- Do not commit copied sprites, music, fonts, or sound effects. Every asset must be original or licensed with provenance recorded in `THIRD_PARTY_NOTICES.md`.
- No secrets, tokens, `.env` files, credential values, personal data, or financial data in the repository, build, logs, or Jira.
- The game makes no network calls and collects no telemetry.

## Evidence lanes

A green `game-pr-fast` result is repository verification, not a playable-build qualification. Human feel, visual, audio, accessibility, performance, Windows VM, and release gates require separate recorded evidence. Do not claim a release, export, or feel result from a headless test alone.

## project-game-maker integration

The optional `GameProjectProfile` and `GodotToolchainDeclaration` are declared metadata. The `godot-toolchain-v1` lane is `declared_only` / `not_executed`: it does not run Godot, import assets, export, or play the game. Live evidence comes from this repository's scripts, recorded with the exact engine version and source SHA.
