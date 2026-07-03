-- The launcher: aiming, firing, flight, landing, and what follows.

Shooter = {}

local clamp = Util.clamp

local function randomFieldType()
    local types = Grid.typesInField()
    if #types == 0 then return math.random(1, Levels.numTypes(G.level)) end
    return types[math.random(#types)]
end

function Shooter.loadNext()
    G.curType = G.nextType
    G.nextType = randomFieldType()
end

function Shooter.reload()
    G.curType = randomFieldType()
    G.nextType = randomFieldType()
end

function Shooter.aimVector()
    local rad = math.rad(G.aim)
    return math.sin(rad), -math.cos(rad)
end

function Shooter.fire()
    if G.flying then return end
    local dx, dy = Shooter.aimVector()
    G.flying = {
        x = C.LAUNCH_X, y = C.LAUNCH_Y,
        vx = dx * C.SHOT_SPEED, vy = dy * C.SHOT_SPEED,
        type = G.curType,
    }
    G.idleT = 0
    Sfx.fire()
end

-- Main.levelClear / Main.loseLife are wired up in main.lua
local function land(x, y, t)
    local cell = Grid.snapCell(x, y)
    if not cell then
        -- the field is jammed solid: that's a loss
        Main.loseLife()
        return
    end
    local r, c = cell[1], cell[2]
    Grid.set(r, c, t)
    Sfx.stick()

    local popped, dropped = Grid.resolve(r, c)
    if popped > 0 then
        local px, py = Grid.cellPos(r, c)
        G.addScore(popped * 10)
        Sfx.pop(popped)
        if dropped > 0 then
            -- dropped bubbles are the jackpot: 2^n * 10, capped
            local bonus = math.min(2 ^ dropped, 256) * 10
            G.addScore(bonus)
            G.addPopup(px, py, "*" .. bonus .. "*")
            Sfx.drop(dropped)
        else
            G.addPopup(px, py, tostring(popped * 10))
        end
    end

    if Grid.isEmpty() then
        Main.levelClear()
        return
    end

    -- the compressor inches closer with every shot
    G.shotsLeft = G.shotsLeft - 1
    if G.shotsLeft <= 0 then
        Grid.compress()
        G.shotsLeft = Levels.shotsPerCompress(G.level)
    elseif G.shotsLeft <= 2 then
        Sfx.warn()
    end

    if Grid.checkLose() then
        Main.loseLife()
        return
    end

    Shooter.loadNext()
end

function Shooter.update()
    local b = G.flying
    if not b then return end

    b.x = b.x + b.vx * C.DT
    b.y = b.y + b.vy * C.DT

    -- wall bounces
    if b.x < C.FIELD_LEFT + C.RADIUS then
        b.x = C.FIELD_LEFT + C.RADIUS
        b.vx = -b.vx
        Sfx.bounce()
    elseif b.x > C.FIELD_RIGHT - C.RADIUS then
        b.x = C.FIELD_RIGHT - C.RADIUS
        b.vx = -b.vx
        Sfx.bounce()
    end

    -- the ceiling
    if b.y <= G.ceilingY + C.RADIUS then
        b.y = G.ceilingY + C.RADIUS
        G.flying = nil
        land(b.x, b.y, b.type)
        return
    end

    -- other bubbles
    local hit = false
    Grid.forEach(function(r, c)
        if hit then return end
        local cx, cy = Grid.cellPos(r, c)
        local dx, dy = b.x - cx, b.y - cy
        if dx * dx + dy * dy < (C.DIAM * 0.85) ^ 2 then
            hit = true
        end
    end)
    if hit then
        G.flying = nil
        land(b.x, b.y, b.type)
    end
end
