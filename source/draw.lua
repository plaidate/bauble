-- Rendering: the field, launcher, HUD margins, and menu screens.
-- Black art on a white background.

local gfx <const> = playdate.graphics

Draw = {}

local PAT_HATCH <const> = { 0x88, 0x44, 0x22, 0x11, 0x88, 0x44, 0x22, 0x11 }

function Draw.field()
    gfx.setColor(gfx.kColorBlack)
    -- side walls
    gfx.setLineWidth(2)
    gfx.drawLine(C.FIELD_LEFT, 0, C.FIELD_LEFT, C.SCREEN_H)
    gfx.drawLine(C.FIELD_RIGHT, 0, C.FIELD_RIGHT, C.SCREEN_H)
    gfx.setLineWidth(1)

    -- the compressor: a hatched slab from the top down to the ceiling
    gfx.setPattern(PAT_HATCH)
    gfx.fillRect(C.FIELD_LEFT + 1, 0, C.FIELD_RIGHT - C.FIELD_LEFT - 2, G.ceilingY)
    gfx.setColor(gfx.kColorBlack)
    local warn = G.shotsLeft <= 2 and G.state == "play"
    if not warn or G.frame % 10 < 6 then
        gfx.setLineWidth(warn and 3 or 2)
        gfx.drawLine(C.FIELD_LEFT, G.ceilingY, C.FIELD_RIGHT, G.ceilingY)
        gfx.setLineWidth(1)
    end

    -- the deadline
    for x = C.FIELD_LEFT + 4, C.FIELD_RIGHT - 8, 12 do
        gfx.drawLine(x, C.DEADLINE, x + 6, C.DEADLINE)
    end
end

function Draw.bubblesInField()
    Grid.forEach(function(r, c, t)
        local x, y = Grid.cellPos(r, c)
        Bubbles.draw(t, x, y)
    end)
    for _, f in ipairs(G.falling) do
        Bubbles.draw(f.type, f.x, f.y)
    end
    if G.flying then
        Bubbles.draw(G.flying.type, G.flying.x, G.flying.y)
    end
end

function Draw.launcher()
    local dx, dy = Shooter.aimVector()
    gfx.setColor(gfx.kColorBlack)

    -- aim guide: dotted sight line
    for i = 1, 4 do
        local d = 26 + i * 15
        local gx, gy = C.LAUNCH_X + dx * d, C.LAUNCH_Y + dy * d
        if gx > C.FIELD_LEFT + 4 and gx < C.FIELD_RIGHT - 4 and gy > G.ceilingY then
            gfx.fillCircleAtPoint(gx, gy, 1.5)
        end
    end

    -- the arrow
    gfx.setLineWidth(3)
    gfx.drawLine(C.LAUNCH_X, C.LAUNCH_Y, C.LAUNCH_X + dx * 24, C.LAUNCH_Y + dy * 24)
    gfx.setLineWidth(1)
    local px, py = -dy, dx -- perpendicular
    gfx.fillTriangle(
        C.LAUNCH_X + dx * 30, C.LAUNCH_Y + dy * 30,
        C.LAUNCH_X + dx * 20 + px * 5, C.LAUNCH_Y + dy * 20 + py * 5,
        C.LAUNCH_X + dx * 20 - px * 5, C.LAUNCH_Y + dy * 20 - py * 5)

    -- the loaded bubble rides the base
    gfx.drawCircleAtPoint(C.LAUNCH_X, C.LAUNCH_Y, C.RADIUS + 3)
    if not G.flying then
        Bubbles.draw(G.curType, C.LAUNCH_X, C.LAUNCH_Y)
    end
end

function Draw.hud()
    gfx.setColor(gfx.kColorBlack)
    -- left margin: score
    gfx.drawText("*SCORE*", 8, 8)
    gfx.drawText(tostring(G.score), 8, 26)
    gfx.drawText("HIGH", 8, 56)
    gfx.drawText(tostring(G.highScore), 8, 74)
    -- lives as little launcher dots
    for i = 1, G.lives do
        gfx.fillCircleAtPoint(14 + (i - 1) * 14, 110, 5)
    end

    -- right margin: level, next bubble, compressor countdown
    gfx.drawText("*LEVEL " .. G.level .. "*", 306, 8)
    gfx.drawText("NEXT", 306, 40)
    Bubbles.draw(G.nextType, 352, 48)
    gfx.drawText("DROP IN", 306, 76)
    for i = 1, G.shotsLeft do
        gfx.fillRect(306 + (i - 1) * 10, 96, 7, 7)
    end
end

local function centerText(s, y)
    gfx.drawTextAligned(s, C.SCREEN_W / 2, y, kTextAlignment.center)
end

function Draw.play()
    gfx.clear(gfx.kColorWhite)
    Draw.field()
    Draw.bubblesInField()
    Draw.launcher()
    Draw.hud()

    gfx.setColor(gfx.kColorBlack)
    for _, p in ipairs(G.particles) do
        gfx.fillRect(p.x - 1, p.y - 1, 2, 2)
    end
    for _, p in ipairs(G.popups) do
        gfx.drawTextAligned(p.text, p.x, p.y - 28, kTextAlignment.center)
    end

    if G.state == "levelclear" then
        centerText("*LEVEL CLEAR!*", 110)
    elseif G.state == "retry" then
        centerText("*BUBBLES OVER THE LINE!*", 100)
        centerText(G.lives .. (G.lives == 1 and " LIFE LEFT" or " LIVES LEFT"), 122)
    end
end

function Draw.title()
    gfx.clear(gfx.kColorWhite)
    gfx.setColor(gfx.kColorBlack)
    local tw = Bubbles.title:getSize()
    Bubbles.title:drawScaled(C.SCREEN_W / 2 - tw * 1.4, 26, 2.8)

    for t = 1, C.MAX_TYPES do
        Bubbles.draw(t, 110 + (t - 1) * 36, 96)
    end

    centerText("crank: aim    A or B: fire", 130)
    centerText("pop threes - drop the rest - beat the ceiling", 148)
    if G.frame % 30 < 20 then
        centerText("*PRESS A TO START*", 176)
    end
    centerText("HIGH SCORE " .. G.highScore, 204)
end

function Draw.gameover()
    gfx.clear(gfx.kColorWhite)
    gfx.setColor(gfx.kColorBlack)
    centerText("*GAME OVER*", 64)
    centerText("SCORE " .. G.score, 94)
    centerText("LEVEL " .. G.level, 112)
    if G.score >= G.highScore and G.score > 0 then
        centerText("*NEW HIGH SCORE!*", 132)
    else
        centerText("HIGH SCORE " .. G.highScore, 132)
    end
    if G.frame % 30 < 20 then
        centerText("PRESS A TO PLAY AGAIN", 162)
    end
end
