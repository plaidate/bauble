-- Bauble — a 1-bit color-matching bubble shooter for Playdate
-- An original take on the aim-and-pop bubble puzzle genre.
-- The crank aims the launcher; A or B fires. Idle too long and it fires itself.
--
-- Module layout (globals shared across imports):
--   config.lua    C: tunables and flags
--   util.lua      Util: clamp + delayed-call scheduler
--   sfx.lua       Sfx: synth sound effects
--   bubbles.lua   Bubbles: the six bubble sprites (patterns, not colors)
--   gamestate.lua G: all mutable game state + helpers
--   grid.lua      Grid: hex cell math, matching, dropping, the compressor
--   levels.lua    Levels: deterministic mirrored layouts per level
--   shooter.lua   Shooter: aiming, flight, landing resolution
--   input.lua     Input: crank/d-pad controls and the smoke-test autopilot
--   draw.lua      Draw: rendering and menu screens

import "CoreLibs/graphics"

import "config"
import "util"
import "sfx"
import "bubbles"
import "gamestate"
import "grid"
import "levels"
import "shooter"
import "input"
import "draw"

Main = {}

local function setupLevel(level)
    G.level = level
    G.ceilingY = 2
    G.shotsLeft = Levels.shotsPerCompress(level)
    G.flying = nil
    G.falling = {}
    G.aim = 0
    G.idleT = 0
    Levels.generate(level)
    Shooter.reload()
end

local function startGame()
    G.score = 0
    G.lives = C.START_LIVES
    G.particles, G.popups = {}, {}
    setupLevel(1)
    G.state = "play"
end

function Main.levelClear()
    G.addScore(C.LEVEL_CLEAR_BONUS)
    G.state = "levelclear"
    G.stateT = 2
    Sfx.clear()
end

function Main.loseLife()
    G.lives = G.lives - 1
    Sfx.die()
    -- the whole board lets go
    Grid.forEach(function(r, c, t)
        local x, y = Grid.cellPos(r, c)
        G.falling[#G.falling + 1] = {
            x = x, y = y, type = t,
            vx = math.random(-40, 40), vy = -30,
        }
    end)
    G.grid = {}
    G.flying = nil
    if G.lives <= 0 then
        G.state = "gameover"
        G.stateT = 0
        G.saveHigh()
    else
        G.state = "retry"
        G.stateT = 2
    end
end

local function updatePlay()
    local aimDelta, fire = Input.gather()

    if aimDelta ~= 0 then G.idleT = 0 end
    G.aim = Util.clamp(G.aim + aimDelta, -C.AIM_MAX, C.AIM_MAX)

    -- dawdling is not allowed: the launcher fires itself
    G.idleT = G.idleT + C.DT
    if G.idleT > C.IDLE_FIRE and not G.flying then
        fire = true
    end

    if fire then Shooter.fire() end
    Shooter.update()
    G.updateFx()
end

function playdate.update()
    G.frame = G.frame + 1
    Util.runPending()

    -- smoke builds (AUTOPILOT) periodically dump a frame for headless checks
    if AUTOPILOT and playdate.simulator and (G.frame == 30 or G.frame % 300 == 0) then
        playdate.simulator.writeToFile(playdate.graphics.getDisplayImage(), "build/bauble-shot.png")
    end

    if G.state == "title" then
        Draw.title()
        local _, _, start = Input.gather()
        if start then startGame() end
    elseif G.state == "play" then
        updatePlay()
        if G.state ~= "gameover" then
            Draw.play()
        end
    elseif G.state == "levelclear" then
        G.stateT = G.stateT - C.DT
        G.updateFx()
        Draw.play()
        if G.stateT <= 0 then
            setupLevel(G.level + 1)
            G.state = "play"
        end
    elseif G.state == "retry" then
        G.stateT = G.stateT - C.DT
        G.updateFx()
        Draw.play()
        if G.stateT <= 0 then
            setupLevel(G.level) -- the same board, dealt again
            G.state = "play"
        end
    elseif G.state == "gameover" then
        G.stateT = G.stateT + C.DT
        Draw.gameover()
        local _, _, start = Input.gather()
        if start and G.stateT > 1 then startGame() end
    end
end

playdate.getSystemMenu():addMenuItem("restart", function()
    G.state = "title"
end)

-- startup
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.display.setRefreshRate(30)
Bubbles.build()
