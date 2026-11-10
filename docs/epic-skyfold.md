# Epic — Skyfold: a paper crane's flight (Windows v1.0)

**Status:** Gate 0 is in progress. Jira epic **GAME-486** owns scope and
acceptance; the child keys are mapped in [jira-map.md](jira-map.md).

## Outcome

A complete, original one-button flight game for Windows, free and publicly
downloadable from GitHub Releases, with a four-biome 24-passage campaign, four
hazard gauntlets, Endless, a daily seeded run, unlockable origami forms, medals,
local scores, final vector art, original synthesized audio, and verified
accessibility and performance.

Skyfold is not a Flappy Bird clone. It uses tap/hold flap–glide, wind fields,
thread scoring, living gate architecture, and a wordless paper-diorama story.
See [anti-clone.md](anti-clone.md).

## End-state checklist

- All 28 campaign nodes, Endless, and Daily are playable start to finish.
- Four forms are unlocked and viable; medals, local scores, and saves work.
- Four biomes are visually distinct with final art and audio; no placeholders.
- 60 fps p99 at 1080p on Intel Iris Xe; 2-hour soak; 10k-seed soak.
- Accessibility checklist and external audit complete.
- 8–12 external playtesters; no P0/P1; completion and fun targets met.
- Public Windows zip built from a clean tag, tested on a clean VM, with
  checksums and a release manifest.
- README, screenshots, release notes, known issues, privacy, licenses, and
  rollback documented.
- Jira children done; retrospective and maintenance notes written.

## In scope

One-button flight, glide, wind, gates, hazards, 24 passages, four gauntlets,
Endless, Daily, four forms, medals, saves, accessibility, original art/audio,
Windows packaging, public GitHub release.

## Out of scope

Mobile/iOS/Android at v1.0, multiplayer, accounts, cloud saves, online
leaderboards, ads, IAP, telemetry, Steam/itch/Microsoft Store, level editor,
localization beyond English (strings still externalized), 3D, C#, addons, boss
combat, and Flappy Bird IP.

## Version map

| Version | Gate | Meaning |
|---|---|---|
| `v0.1 First Flight` | Gate 0 | Deterministic core, grey-box, CI, docs |
| `v0.2 Paper Fields` | Gate 1 | Vertical slice and external go/no-go |
| `v0.3 Systems Complete` | Gate 2 | Flight v2, data, flow, saves, Endless, forms |
| `v0.4 Content Complete` | Gates 3–5 | Final art/audio and all 28 campaign nodes |
| `v0.5 Release Candidate` | Gate 6 | Performance, accessibility, playtests, review |
| `v1.0 Ship` | Gate 7 | Public Windows zip and GitHub Release |
| `v1.1 Mobile` | Gate 8 | Deferred mobile readiness |

## Definition of Done

Every child is Done or explicitly dispositioned; the exact v1.0 artifact is
publicly downloadable and verified; no open P0/P1; docs and evidence complete.

---

## Gate 0 — Lock and foundation

| ID | Work package | Done when |
|---|---|---|
| SF-01 | Vision, pillars, anti-clone, name/license lock | `docs/vision.md`, `docs/anti-clone.md`, license split, name-search memo, fallback title recorded |
| SF-02 | Public repo and Godot foundation | `game-skyfold` public; 4.7.2 project with GL Compatibility, 1920×1080/1280×720, 120 Hz, input map, boot scene; docs/AGENTS/LICENSE; clean-clone import passes; export templates verified |
| SF-03 | CI and verification rails | `game-pr-fast` on Windows runner; pinned Godot with SHA-256; import, check-only, tests, project validation; branch protection; local verify script |
| SF-04 | Deterministic flight core | Node-free `FlightSim`; tap/hold, gravity, terminal velocity, gates, collision, snapshot; seeded RNG; input buffer; 25+ tests; replay; static guard |
| SF-05 | Grey-box feel prototype | 60-second loop with three gate patterns; score/restart/pause; five internal sessions; tuning table; < 50 ms input response; go/no-go memo |

**Hard gate:** do not start the vertical slice until SF-05 passes.

## Gate 1 — Vertical slice

| ID | Work package | Done when |
|---|---|---|
| SF-06 | Paper Fields vertical slice | One biome at final-quality art/audio sample; three passages; title/HUD/pause/settings/results; save basics; gauntlet stub; 10–15 minutes; 60 fps; no placeholder |
| SF-07 | External slice playtest and go/no-go | Five external players; scripted session; metrics; findings; go/no-go against pillars; re-tune before content if it fails |

**Hard gate:** if the slice does not prove the feel and the paper identity, stop
and re-scope before producing 24 passages.

## Gate 2 — Systems

| ID | Work package | Done when |
|---|---|---|
| SF-08 | Flight model v2 | Wind ribbons (steady/gust/updraft/downdraft), glide tuning, thread/graze/combo, difficulty curves, assist modifiers; deterministic tests; tuning doc |
| SF-09 | Data-driven campaign schema | Versioned JSON for passages/biomes/gates/hazards/forms/medals; validator; three sample passages; invalid data fails CI; preview tool |
| SF-10 | Game flow and state machine | Boot→title→map→passage→results→next; Endless/Daily/Settings/Credits/Gallery; pause/focus loss; retry < 1 s; no dead ends; integration tests |
| SF-11 | Save, progress, settings | Atomic save, backup, checksum, migration, corruption recovery, medals/unlocks, per-mode/form bests, settings; tests |
| SF-12 | Endless and daily | Seeded generator, escalation, weather modifiers, UTC daily seed, local top 10; 10k-seed soak; reproducible; no impossible gates |
| SF-13 | Origami forms and unlocks | Four forms with distinct handling; unlock conditions; selection UI; each viable; balance tests; no pay-to-win |

## Gate 3 — Art and UX

| ID | Work package | Done when |
|---|---|---|
| SF-14 | Art bible and UI kit | Palette, typography, shapes, VFX language, gate families, UI kit; four style frames; contrast; provenance; OFL fonts |
| SF-15 | Crane hero | Procedural paper crane with flap/glide/tilt/hit/celebrate; fold/paper shader; trail; readable at 720p and 4K; 60 fps; no aliasing |
| SF-16 | Biome art | Four biome sets, 3–4 parallax layers each, weather, transitions, lanterns; no placeholders; draw-call budget; distinct silhouettes |
| SF-17 | Gates and hazards | 12+ gate archetypes, six hazards, telegraphs, fair hitboxes; readability audit at 1280×720; no off-screen kills; hitbox debug view |
| SF-18 | HUD, menus, settings | Title, map, pause, results, medals, settings, accessibility, credits, diagnostics; keyboard/gamepad/mouse; 44 px targets; text scaling; all strings via `tr()` |
| SF-19 | Accessibility | Remap, hold/toggle glide, reduced motion, shake/flash toggles, high contrast, colorblind cues, text scale, captions, pause; assist; external audit; no audio-only cues |
| SF-20 | Wordless story panels | Ten panels: intro, four biome intros, four outros, ending; skip/replay/gallery; coherent; no lore contradictions |

## Gate 4 — Audio

| ID | Work package | Done when |
|---|---|---|
| SF-21 | Audio synthesis pipeline | GDScript synth tool; deterministic recipes; 32 kHz mono music stems, 48 kHz SFX; `--check` hashes; no external samples; source and generated assets; license-clean; repo size budget |
| SF-22 | Adaptive music, SFX, mix | Four biome beds with layers; transitions; ambience; 20+ SFX; bus layout and limiter; volumes/mute; no clipping; loudness measured; 30-minute fatigue test; audio starts after gesture |

## Gate 5 — Content

| ID | Work package | Done when |
|---|---|---|
| SF-23 | 24 campaign passages | Six per biome; one idea each; difficulty curve; medal targets; data/art/audio; all completable; median ≤ 5 attempts; no passage > 10; no soft locks |
| SF-24 | Four hazard gauntlets | One per biome; combines mechanics; unique layout; medal thresholds; skilled completion; distinct from normal passages; no unfair RNG |
| SF-25 | Endless and daily content | Four weather sets, 12 modifiers, escalation; 100 manual runs plus 10k seeds; no impossible patterns; daily variety; local tables |
| SF-26 | Unlocks, meta, gallery | Forms, medals, stamps, gallery, credits; all unlocks reachable; clear UI; save-safe; no grind |

## Gate 6 — Verification

| ID | Work package | Done when |
|---|---|---|
| SF-27 | Automated suite | Unit/property/integration/soak; 10k seeds; save migration; scene smoke; input map; export preset; static guards; CI green; no flaky tests |
| SF-28 | Performance, soak, compatibility | 60 fps p99 at 1080p on Iris Xe; 120 fps option; < 300 MB; < 3 s load; 2-hour soak; window modes/aspects/DPI; clean logs |
| SF-29 | Human playtest program | 8–12 players; three rounds; metrics; no P0/P1; completion/fun targets; accessibility feedback; fix list |
| SF-30 | Independent review | Different model/human reviews exact build, code, UX, accessibility, legal/provenance; findings dispositioned; no blockers |

## Gate 7 — Release

| ID | Work package | Done when |
|---|---|---|
| SF-31 | Windows export and package | Export preset; portable zip; exe/pck/README/licenses; icon/version; SHA-256; release manifest; clean Win10/11 VM; no missing DLLs; size budget; SmartScreen note |
| SF-32 | Release presentation | README, screenshots/GIFs, optional 60-second trailer, changelog, known issues, controls, accessibility statement, privacy, credits/licenses; a new player understands it |
| SF-33 | GitHub Release v1.0 and closeout | Tag `v1.0.0`; release notes; assets/checksums; public download from a clean machine; exact SHA; rollback documented; Jira done; retrospective; maintenance notes; mobile roadmap |

## Gate 8 — Mobile readiness (deferred)

| ID | Work package | Done when |
|---|---|---|
| SF-34 | Mobile readiness audit | Touch mapping, safe areas, aspect ratios, performance/battery budget, Android export prerequisites, iOS decision; no v1.0 code; documented plan |

---

## Dependency rule

The gate order is the default blocker chain: **0 → 1 → 2 → 3/4 → 5 → 6 → 7 → 8**.
Within Gates 3 and 4, parallelize where files do not overlap.

Hard blockers:

`SF-01 → SF-02 → SF-03 → SF-04 → SF-05 → SF-06 → SF-07 → SF-08/SF-09/SF-10/SF-11 → SF-12/SF-13 → SF-23 → SF-24/SF-25/SF-26 → SF-27/SF-28 → SF-29/SF-30 → SF-31/SF-32 → SF-33`.

Jira blocker links are execution authority. Create them through Jira Admin and
read back direction; do not add a reverse link.

## Quality gates

| Gate | Evidence required |
|---|---|
| Feel | Input log, replay tests, five playtesters |
| Readability | Hitbox debug captures, readability audit |
| Performance | F3 CSV, five-run protocol, named hardware |
| Content | Playtest metrics, completion audit |
| Reliability | CI logs, 2-hour soak, 10k seeds |
| Accessibility | Checklist plus external audit |
| Human | 8–12 external playtesters; no P0/P1 |
| Release | Clean-VM readback, checksums, release manifest, rollback |
