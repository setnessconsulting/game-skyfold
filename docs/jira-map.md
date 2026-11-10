# Skyfold Jira map

**Epic:** [GAME-486](https://setnessconsulting.atlassian.net/browse/GAME-486) — Skyfold - a paper crane's flight (Windows v1.0)

The epic owns scope, status, and acceptance. This repository owns implementation
truth. The children form a blocker chain in gate order; the chain is a
conservative execution order, not a claim that every step is complete.

| Story | Jira | Gate | State at Gate 0 checkpoint |
|---|---|---|---|
| SF-01 Vision, pillars, anti-clone, name/license | GAME-487 | 0 | Docs committed; name search pending |
| SF-02 Public repo and Godot foundation | GAME-488 | 0 | Repo and project committed; export templates pending |
| SF-03 CI and verification rails | GAME-489 | 0 | Workflow committed; first PR run pending |
| SF-04 Deterministic flight core | GAME-490 | 0 | Implemented and verified |
| SF-05 Grey-box feel prototype | GAME-491 | 0 | Playable prototype built; human five-session gate pending |
| SF-06 Paper Fields vertical slice | GAME-492 | 1 | Not started |
| SF-07 External slice playtest and go/no-go | GAME-493 | 1 | Not started |
| SF-08 Flight model v2 | GAME-494 | 2 | Not started |
| SF-09 Data-driven campaign schema | GAME-495 | 2 | Not started |
| SF-10 Game flow and state machine | GAME-496 | 2 | Not started |
| SF-11 Save, progress, settings | GAME-497 | 2 | Not started |
| SF-12 Endless and daily | GAME-498 | 2 | Not started |
| SF-13 Origami forms and unlocks | GAME-499 | 2 | Not started |
| SF-14 Art bible and UI kit | GAME-500 | 3 | Not started |
| SF-15 Crane hero rig | GAME-501 | 3 | Not started |
| SF-16 Biome art sets | GAME-502 | 3 | Not started |
| SF-17 Gates and hazards | GAME-503 | 3 | Not started |
| SF-18 HUD, menus, settings | GAME-504 | 3 | Not started |
| SF-19 Accessibility | GAME-505 | 3 | Not started |
| SF-20 Story panels and gallery | GAME-506 | 3 | Not started |
| SF-21 Audio synthesis pipeline | GAME-507 | 4 | Not started |
| SF-22 Adaptive music, SFX, mix | GAME-508 | 4 | Not started |
| SF-23 Twenty-four campaign passages | GAME-509 | 5 | Not started |
| SF-24 Four hazard gauntlets | GAME-510 | 5 | Not started |
| SF-25 Endless and daily content | GAME-511 | 5 | Not started |
| SF-26 Unlocks, medals, gallery | GAME-512 | 5 | Not started |
| SF-27 Automated suite and fuzz | GAME-513 | 6 | Not started |
| SF-28 Performance and compatibility | GAME-514 | 6 | Not started |
| SF-29 Human playtest program | GAME-515 | 6 | Not started |
| SF-30 Independent review | GAME-516 | 6 | Not started |
| SF-31 Windows export and package | GAME-517 | 7 | Not started |
| SF-32 Release presentation and privacy | GAME-518 | 7 | Not started |
| SF-33 Public GitHub Release v1.0 | GAME-519 | 7 | Not started |
| SF-34 Mobile readiness audit | GAME-520 | 8 | Deferred |

## Link direction

Jira Admin's `Blocks` capability uses the native direction: the inward issue is
blocked by the outward issue. The chain is `GAME-487` blocks `GAME-488` blocks
`GAME-489` ... through `GAME-520`. A spot read of `GAME-487` confirms the
outward `Blocks` link to `GAME-488`.

## Status rule

Jira status describes tracker state and never substitutes for evidence. A child
moves to Done only when its acceptance evidence is recorded in the repository or
linked from the issue. Repository-only checks do not qualify feel, art, audio,
accessibility, Windows VM behavior, or a release.
