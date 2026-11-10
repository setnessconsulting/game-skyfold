# Skyfold — technical plan

## 1. Toolchain

| Item | Decision |
|---|---|
| Engine | Godot **4.7.2.stable.official.ed1daf0bf** |
| Language | GDScript only |
| Renderer | `gl_compatibility` |
| Target | Windows 10/11 x86_64 at v1.0 |
| Base resolution | 1920×1080; 1280×720 window override |
| Stretch | `canvas_items`, aspect `expand` |
| Simulation | Fixed 120 Hz |
| Save path | `user://skyfold/` |
| Addons | None |
| Runtime dependencies | None |
| Network | None |

The engine version is pinned. An upgrade requires an ADR, a full re-run of the
verification suite, and a fresh export-template install.

## 2. Architecture

```text
Input / RunController
        |
        v
FlightSim (RefCounted, node-free, fixed 120 Hz)
        |
        +--> snapshot --> FlightView (interpolate, animate, draw)
        +--> RunState / Score / Medals / Unlocks --> SaveStore
        +--> events --> AudioDirector / HUD / Results

Data (JSON) --> validator --> Gate/Hazard spawner --> FlightSim
SceneRouter <--> Boot / Title / CampaignMap / Flight / Results / Settings
```

### Hard rules

- `scripts/sim/` is node-free. It must not use `Input`, `get_tree()`,
  `AudioServer`, scene loading, or global random functions.
- Views read snapshots; they never mutate the simulation.
- The simulation owns all gameplay rules, scoring, collision, and RNG.
- Fixed 120 Hz stepping. Rendering may interpolate but may not change the step.
- Replays are identified by seed plus an input tick sequence.
- A static check in `tools/verify_project.gd` rejects forbidden symbols in
  `scripts/sim/`.

### ADR-001 — Godot 4.7.2

Chosen because it is installed, stable, GDScript-first, and exports to Windows
and future mobile targets. The project uses the compatibility renderer so the
same content can run on integrated GPUs and mobile without a renderer rewrite.

### ADR-002 — Fixed 120 Hz simulation

A one-button game lives or dies on timing consistency. A 120 Hz fixed step gives
precise flap arcs, stable glide tuning, and replayable tests. Render interpolation
keeps motion smooth at 60, 120, or higher display refresh rates.

### ADR-003 — Node-free simulation

The simulation is a `RefCounted` object, not a scene tree. This makes headless
tests fast and deterministic, prevents presentation code from becoming gameplay
authority, and allows the same rules to be replayed or fuzzed without the engine.

### ADR-004 — Public repo, split license

The code is MIT so the repository is useful as a portfolio artifact. Original
art and audio are CC BY-NC-SA 4.0 so the game's identity is not repackaged
commercially. Third-party assets require recorded provenance.

## 3. Repository layout

```text
scenes/
  app/        boot, title, campaign_map, settings, credits, gallery
  game/       flight, results, pause, story_panel
  ui/         shared controls
scripts/
  sim/        flight_sim, rng, gate data helpers
  app/        game, scene_router, save_store, settings_store
  game/       flight, flight_view, crane_view, gate_view, camera_rig, hud
  audio/      audio_director, sfx_pool
  ui/         menus, focus, accessibility
data/
  biomes.json, gates.json, hazards.json, forms.json, medals.json
  passages/   one JSON file per passage
assets/
  art/svg/, art/textures/, fonts/, themes/
audio/
  generated/, default_bus_layout.tres
shaders/
  paper.gdshader, sky.gdshader, wind.gdshader, lightning.gdshader
localization/
  strings.csv
tests/
  run_tests.gd, sim/, data/, save/
tools/
  synth_audio.gd, validate_data.gd, verify_project.gd
  ci/verify.ps1, export_windows.ps1, package_release.ps1
docs/
  vision.md, anti-clone.md, technical-plan.md, epic-skyfold.md,
  playtest/, evidence/, release/
.github/workflows/
  game-pr-fast.yml, release-windows.yml
```

## 4. Data and save

- Gameplay data is versioned JSON with `schema_version: 1`.
- A validator checks unique IDs, gate-gap limits, reachability, medal
  attainability, and asset references. Invalid data fails CI.
- `save_v1.json` uses atomic temp→rename, a `.bak` backup, a checksum, schema
  migration, and corrupt-save recovery.
- Settings are stored separately from progress.
- Local top-10 tables are per mode and form. No names, no PII.
- No mid-run save; passages are short and auto-save after results.

## 5. Input

| Action | Default |
|---|---|
| `flap` | Space, left mouse, gamepad A |
| `pause` | Esc, P, gamepad Start |
| `restart` | R, gamepad Back |
| `confirm` | Enter, Space, gamepad A |
| `back` | Esc, gamepad B |
| `mute` | M |
| `fullscreen` | F11, Alt+Enter |

A 100 ms flap buffer lives in the controller. A double flap within 80 ms is
ignored. Hold-to-glide is the default; a toggle-glide option is an accessibility
setting.

## 6. Testing

| Layer | What | Where |
|---|---|---|
| Static | Parse every script; project settings; forbidden symbols in sim | CI |
| Unit | Flight, glide, gates, scoring, combo, medals, RNG, save | CI |
| Property/fuzz | 10k seeds; gate gaps; reachability; NaN guards | CI |
| Integration | Scene load, state transitions, input map, audio buses, localization keys | CI |
| Soak | 2-hour Endless; 100 restarts; save/load cycles | Local |
| Performance | Five runs on Iris Xe and RTX 4070; window modes; DPI | Local |
| Accessibility | Checklist plus external audit | Local |
| Human | Three playtest rounds; 8–12 external players | Local |

The headless runner is `tests/run_tests.gd` and follows the proven
`project-snake/godot` pattern: zero-dependency assertions and a non-zero exit on
failure.

## 7. CI/CD

- `game-pr-fast` runs on `windows-latest`.
- The workflow downloads the exact Godot 4.7.2 Windows zip, verifies its
  SHA-256, extracts it, and runs `tools/ci/verify.ps1`.
- The aggregate required check is named `game-pr-fast`.
- Draft PRs do not run the check.
- `release-windows.yml` is owner-dispatched. It exports and uploads an artifact;
  it never publishes a GitHub Release automatically.
- No secrets are available to PR code. No deployment happens from PRs.
- Jenkins is not a required check and is not dispatched for routine PRs.

## 8. Performance budgets

| Metric | Budget |
|---|---|
| Frame time | 60 fps p99 < 16.7 ms at 1080p on Iris Xe |
| High refresh | 120 fps option on RTX 4070 |
| Memory | < 300 MB |
| Cold start | < 3 s |
| Draw calls | < 250 |
| Simulation allocations | None per step |
| Soak | 2 hours without leak or drift |

The in-game F3 overlay logs frame time, draw calls, memory, and object counts to
CSV. PresentMon is optional. Performance evidence names the build SHA and the
exact hardware.

## 9. Export and release

- Windows Desktop preset, x86_64, separate `.pck`.
- Portable zip: `Skyfold.exe`, `Skyfold.pck`, `README.txt`, `LICENSE`,
  `ASSET-LICENSE.txt`, `THIRD_PARTY_NOTICES.txt`, `CHANGELOG.txt`.
- `SHA256SUMS.txt` and `release-manifest.json` record the source SHA, engine
  version, export preset, build time, files, and hashes.
- Clean-VM test on Windows 10 22H2 and Windows 11: no Godot installed, DPI
  100/125/150%, gamepad, audio, fullscreen, alt-tab, save path.
- The build is unsigned. SmartScreen may warn; that is documented rather than
  hidden. Code signing is a later decision.
- GitHub Releases are public; assets are immutable by version. Rollback points
  to the previous tag.

## 10. project-game-maker integration

The optional game profile and Godot toolchain declaration are **declared
metadata**:

- `GameProjectProfile` binds the repo, Jira epic, target platforms, quality
  budgets, and the optional `godot` tool profile.
- `GodotToolchainDeclaration` records the exact engine, renderer, main scene,
  and export platforms.
- The `godot-toolchain-v1` lane is `declared_only` / `not_executed`. It does not
  run Godot, import assets, export, or play the game.
- Live evidence comes from this repository's scripts, recorded with the exact
  engine version and source SHA.
- The profile is generated and validated at
  `docs/game-maker-profile.json`. The optional
  `GodotToolchainDeclaration` is **not** generated at this checkpoint: the
  current `godot-toolchain-v1` INI parser rejects Godot's multiline `[input]`
  action values. That is a recorded tool limitation, not a live-execution claim.
  A future parser version may unblock the declaration without changing the
  project's truth.
- The `godot-engineer` charter boundaries apply: only declared Godot files; no
  addons, engine-version changes, or main-scene changes without a profile
  update; record commands, exit state, output hash, and source SHA.

## 11. Risks

| Risk | Mitigation |
|---|---|
| Engine/template drift | Pin 4.7.2; install exact templates; re-verify after any upgrade |
| Determinism drift | Node-free sim; explicitly seeded RNG; fixed step; replay tests |
| Art volume | Vector/procedural kit; reusable gate families; four biomes only |
| Audio volume | One synth tool; four layered loops; reuse SFX palette |
| Scope creep | Gate reviews; locked 24+4 content; no new mechanics after Gate 2 |
| Difficulty | Playtest metrics; assist mode; medal thresholds; no passage > 10 median |
| SmartScreen | Document unsigned portable zip; revisit signing only if it blocks players |
| Name conflict | Clear `Skyfold` before public release; fallback `Featherline` |
| MCP/CI limits | MCP is a dev aid; CI is headless; visual/performance evidence is human |
