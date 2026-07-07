# Bauble — Player's Manual

*Crank to aim, pop threes, and beat the ceiling before it crushes you.*

## The Premise

The bubbles are piling up and the ceiling is coming down. Bauble is a 1-bit
color-matching bubble shooter: you crank a launcher at the bottom of the screen,
fire bubbles up into a hex-packed field, and pop clusters of three or more that
match. Every shot you take, an ugly hatched compressor inches closer — clear the
board before it presses your bubbles past the deadline. There is no color here:
the six bubble types are told apart entirely by their **pattern**, so read the
art, not the palette.

## Controls

| Playdate | Action |
| --- | --- |
| **crank** | aim the launcher (geared down for fine control) |
| **d-pad left / right** | aim the launcher (slower fallback) |
| **A** or **B** | fire the loaded bubble |
| **System menu → restart** | drop back to the title screen |

Dawdle too long and the launcher fires itself — you get about **7 seconds** to
line up a shot before it goes off on its own.

## How to Play

### The core loop

1. A bubble sits loaded on the launcher at the bottom center of the screen.
2. Aim with the crank (up to 78° either side of straight up) and fire.
3. The bubble flies up, **bouncing off the two side walls** but sticking the
   moment it touches the ceiling or another bubble.
4. It snaps into the nearest open cell of the hex grid.
5. If that makes a cluster of **three or more** of the same pattern, the whole
   cluster pops.
6. Any bubbles that were only hanging on through the popped cluster — no longer
   connected to the ceiling — **fall away** for bonus points.
7. Empty the entire field to clear the level.

### The field

Bubbles pack in a honeycomb: even rows hold **8** bubbles, odd rows hold **7**
(shifted half a bubble across), up to 12 rows deep. Boards are **mirror-symmetric**
left-to-right and **deterministic** — the same level always deals the same board,
and a retry replays it exactly.

### The compressor (the ceiling)

The hatched slab at the top is the compressor. A counter on the right — the
**DROP IN** boxes — shows how many shots remain before it drops one full row
closer. When only two boxes are left the ceiling line thickens and blinks and a
warning tone sounds. If any bubble is pushed past the dashed **deadline** near
the bottom, you lose a life. The field jamming completely solid also costs a life.

### The launcher

You only ever load bubble types that are **still present on the board**, so you
never waste a shot on a pattern you can't use. The **NEXT** bubble is previewed
in the right margin. A dotted sight line shows the straight-ahead path (it does
**not** predict wall bounces — that part is on you).

## Scoring

| Event | Points |
| --- | --- |
| Popping a cluster | 10 × bubbles popped |
| Dropping hangers | 2^(dropped) × 10, capped at **2560** |
| Clearing a level | **1000** bonus |

Big drops are the jackpot: knock out the bubble propping up a large hanging
cluster and the exponential drop bonus dwarfs the pop score. Your best run is
saved as the **HIGH SCORE** between sessions.

## Lives & Progression

- You start with **3 lives** (shown as launcher dots in the left margin).
- Lose a life and the whole board lets go and tumbles away; you **retry the same
  board** with one fewer life.
- Run out of lives and it's **GAME OVER** — your high score is saved.
- Clear the board and you advance to the next level. Each level:
  - adds bubble **types** — starts at 4 patterns, works up to all 6 by level 5;
  - deals **more rows** (4 up to 6);
  - gives you **fewer shots between compressions** — 9 at level 1, down to a
    minimum of 4 — so the ceiling closes in faster.

## The Six Bubbles

All six are drawn in black on white and distinguished by pattern only:

| # | Pattern | Look |
| --- | --- | --- |
| 1 | **solid** | filled disc with a white shine dot |
| 2 | **hollow** | a thin empty outline ring |
| 3 | **dithered** | 50% checkerboard fill with an outline |
| 4 | **ring** | outline plus a thick concentric inner ring |
| 5 | **cross** | outline with a bold plus sign |
| 6 | **speckled** | sparse dither fill with a solid center dot |

## Hazards

- **The compressor** — drops a full row closer every few shots; pushes bubbles
  toward the deadline.
- **The deadline** — the dashed line near the bottom. A bubble crossing it costs
  a life.
- **A jammed field** — if a fired bubble can find no open cell, that's a lost
  life too.
- **The idle timer** — 7 seconds of inaction and the launcher fires whatever is
  loaded, wherever you're aimed.

## Tips

1. **Bank off the walls.** The side walls bounce; the ceiling sticks. Angle shots
   off a wall to reach bubbles tucked into the far corners.
2. **Aim past the sight line.** The dotted guide only shows the straight path —
   for a bank shot you have to picture the bounce yourself.
3. **Hunt for chain drops.** Popping the bubble that anchors a big hanging cluster
   drops everything below it for a 2^n bonus worth up to 2560 points — far more
   than the pop itself.
4. **Respect the blink.** When the ceiling line starts flashing you have two shots
   before it drops. Clear your lowest bubbles first.
5. **Commit to a pattern.** Because you only load types still on the board, fully
   clearing one pattern is always productive — no shot is ever wasted.
6. **Don't stall.** Seven idle seconds and the launcher fires on its own. Settle
   your aim before the timer runs down.
7. **Learn the board.** Retries deal the identical layout, so a failed run is a
   free look at the puzzle — plan a cleaner opening next time.
