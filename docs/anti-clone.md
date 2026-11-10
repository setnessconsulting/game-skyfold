# Anti-clone guardrails

Skyfold is inspired by the one-button flight genre. It is not a clone of
*Flappy Bird* or any other game. This document exists so that decision drift is
visible and reviewable.

## What we take

- The broad idea of a one-button flight challenge with gates.
- The quality dimensions of a great arcade game: instant restart, readable
  failure, expressive scoring, and a strong audiovisual identity.

Those dimensions are comparators, not assets.

## What we do differently

| Convention | Skyfold |
|---|---|
| A bird sprite | A procedural paper crane with fold lines, wing rig, flutter, and paper grain |
| Pipes | Living gate architecture: bell arches, windmill frames, aurora curtains, storm shutters |
| One tap only | Tap to flap; hold to glide. Two states, one button |
| Flat background | Layered paper diorama with parallax, torn edges, weather, and depth haze |
| Endless only | 24 authored passages, four gauntlets, Endless, and a daily seeded run |
| Score = gates passed | Distance, gate score, thread precision, graze sparks, embers, combo, medals |
| Ground strip | Open sky with depth layers; falling out is the fail state |
| Copied sound | Original synthesized adaptive score and sound effects |
| Portrait mobile-first | Landscape Windows-first, with a touch-ready layout for a later mobile release |

## Never ship

- The *Flappy Bird* name, logo, bird design, pipe design, ground strip, score
  font, color scheme, sound effects, music, or store copy.
- A public repository or release description that says "Flappy Bird clone."
- Copied screenshots, sprites, fonts, music, or sound effects.
- A public title or URL that uses the *Flappy Bird* mark.

## Public identity

- Game title: **Skyfold**.
- Repository: `setnessconsulting/game-skyfold`.
- The internal label `game-flappy-bird` is planning shorthand only.
- Before public release, run a trademark and search check for `Skyfold` and
  record the result. Fallback: `Featherline`.

## Review rule

Every art, audio, copy, and store-asset review asks: *Could this be mistaken for
a Flappy Bird asset or a clone screenshot?* If yes, it is rejected. The game
must be recognizable from a single screenshot as Skyfold.
