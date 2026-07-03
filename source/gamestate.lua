-- Shared game state and the helpers that mutate it.

G = {
    state = "title", -- "title" | "play" | "levelclear" | "retry" | "gameover"
    frame = 0,
    score = 0,
    lives = C.START_LIVES,
    level = 1,
    grid = {},         -- [r][c] = bubble type
    ceilingY = 2,      -- pixel y of the compressor's underside
    shotsLeft = 8,     -- shots until the ceiling drops
    aim = 0,           -- degrees off vertical; positive leans right
    curType = 1,
    nextType = 1,
    flying = nil,      -- { x, y, vx, vy, type }
    falling = {},      -- dropped bubbles tumbling off-screen
    particles = {},
    popups = {},
    idleT = 0,
    stateT = 0,        -- timer for overlay states
}

local saved = playdate.datastore.read()
G.highScore = (saved and saved.highScore) or 0

function G.saveHigh()
    if G.score > G.highScore then
        G.highScore = G.score
        playdate.datastore.write({ highScore = G.highScore })
    end
end

function G.addScore(n)
    G.score = G.score + n
end

function G.addPopup(x, y, text)
    G.popups[#G.popups + 1] = { x = x, y = y, text = text, life = 1.1 }
end

function G.burst(x, y, n)
    for _ = 1, n do
        local a = math.random() * math.pi * 2
        local s = 30 + math.random(70)
        G.particles[#G.particles + 1] = {
            x = x, y = y,
            vx = math.cos(a) * s, vy = math.sin(a) * s,
            life = 0.3 + math.random() * 0.3,
        }
    end
end

function G.updateFx()
    for i = #G.particles, 1, -1 do
        local p = G.particles[i]
        p.life = p.life - C.DT
        if p.life <= 0 then
            table.remove(G.particles, i)
        else
            p.x = p.x + p.vx * C.DT
            p.y = p.y + p.vy * C.DT
        end
    end
    for i = #G.popups, 1, -1 do
        local p = G.popups[i]
        p.life = p.life - C.DT
        p.y = p.y - 16 * C.DT
        if p.life <= 0 then table.remove(G.popups, i) end
    end
    for i = #G.falling, 1, -1 do
        local f = G.falling[i]
        f.vy = f.vy + 600 * C.DT
        f.x = f.x + f.vx * C.DT
        f.y = f.y + f.vy * C.DT
        if f.y > C.SCREEN_H + 20 then table.remove(G.falling, i) end
    end
end
