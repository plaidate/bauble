# Bauble

**Crank to aim, pop threes, and beat the ceiling — a 1-bit bubble shooter.**

Bauble is an original take on the aim-and-pop bubble-puzzle genre, built from the
ground up for the Panic Playdate. Crank a launcher at the bottom of the screen to
aim, fire bubbles up into a hex-packed field, and pop clusters of three or more
matching bubbles. The twist: there is no color. Six bubble types are told apart
entirely by their **pattern** — solid, hollow, dithered, ring, cross, and speckled
— all rendered in crisp procedural 1-bit art with no external assets.

Every shot you take, a hatched compressor grinds one step closer to the deadline.
Empty the board before it presses your bubbles over the line. Chase the jackpot by
knocking out the bubble that holds up a hanging cluster and dropping everything
below it for an exponential bonus. Boards are deterministic and mirror-symmetric,
so a failed run is a free look at the puzzle — every retry replays the exact same
layout. How many levels can you clear before the ceiling wins?

## Features

- **Crank-aimed launcher** — the crank is geared down for fine, precise aiming,
  with a d-pad fallback.
- **Pattern-not-color matching** — six bubble types distinguished by texture, made
  for the 1-bit screen.
- **The compressor** — a ceiling that drops closer every few shots and squeezes the
  field toward a deadline.
- **Chain-drop jackpots** — sever a cluster's anchor and cascade bubbles off-screen
  for a 2^n bonus up to 2560 points.
- **Deterministic, mirrored boards** — learn a level and plan a better opening; a
  retry deals the identical puzzle.
- **Escalating levels** — more patterns, more rows, and fewer shots between
  compressions the deeper you go.
- **Fully procedural art & synth audio** — no external assets, saved high score.

## Controls

- **Crank** (or d-pad left/right) — aim the launcher
- **A / B** — fire
- Idle too long and the launcher fires itself.

## Install (no dev tools needed)

1. Download **Bauble.pdx.zip** from the Releases page (or from the `dist/` folder).
2. Sideload it to your Playdate at <https://play.date/account/sideload/>, **or**
   unzip it into the Playdate Simulator that ships with the SDK.

## License

MIT.
