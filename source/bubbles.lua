-- Bubble sprites: six types told apart by pattern, not color (1-bit screen).

local gfx <const> = playdate.graphics

Bubbles = {}

local PAT_50 <const> = { 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55 }
local PAT_25 <const> = { 0x88, 0x00, 0x22, 0x00, 0x88, 0x00, 0x22, 0x00 }

local function build(t)
    local d = C.DIAM
    local r = C.RADIUS
    local img = gfx.image.new(d, d)
    gfx.lockFocus(img)
    gfx.setColor(gfx.kColorBlack)
    local cx, cy = r, r

    if t == 1 then -- solid
        gfx.fillCircleAtPoint(cx, cy, r - 1)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(cx - 4, cy - 4, 2) -- shine
    elseif t == 2 then -- hollow
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(cx, cy, r - 2)
        gfx.setLineWidth(1)
    elseif t == 3 then -- dithered
        gfx.setPattern(PAT_50)
        gfx.fillCircleAtPoint(cx, cy, r - 1)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawCircleAtPoint(cx, cy, r - 1)
    elseif t == 4 then -- ring
        gfx.drawCircleAtPoint(cx, cy, r - 1)
        gfx.setLineWidth(3)
        gfx.drawCircleAtPoint(cx, cy, r - 6)
        gfx.setLineWidth(1)
    elseif t == 5 then -- cross
        gfx.drawCircleAtPoint(cx, cy, r - 1)
        gfx.setLineWidth(3)
        gfx.drawLine(cx - 5, cy, cx + 5, cy)
        gfx.drawLine(cx, cy - 5, cx, cy + 5)
        gfx.setLineWidth(1)
    else -- speckled
        gfx.setPattern(PAT_25)
        gfx.fillCircleAtPoint(cx, cy, r - 1)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawCircleAtPoint(cx, cy, r - 1)
        gfx.fillCircleAtPoint(cx, cy, 3)
    end

    gfx.unlockFocus()
    return img
end

function Bubbles.build()
    Bubbles.img = {}
    for t = 1, C.MAX_TYPES do
        Bubbles.img[t] = build(t)
    end

    local w, h = gfx.getTextSize("*BAUBLE*")
    local img = gfx.image.new(w, h)
    gfx.lockFocus(img)
    gfx.drawText("*BAUBLE*", 0, 0)
    gfx.unlockFocus()
    Bubbles.title = img
end

function Bubbles.draw(t, x, y)
    Bubbles.img[t]:draw(x - C.RADIUS, y - C.RADIUS)
end
