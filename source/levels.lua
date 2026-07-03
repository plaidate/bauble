-- Level layouts: deterministic per level (retries replay the same board),
-- mirrored left-right like the arcade puzzles.

Levels = {}

-- small deterministic PRNG so a level always deals the same board
local function lcg(seed)
    local s = seed
    return function()
        s = (s * 1103515245 + 12345) % 2147483648
        return s / 2147483648
    end
end

function Levels.numTypes(level)
    if SMOKE_EASY then return 2 end
    return math.min(3 + (level + 1) // 2, C.MAX_TYPES)
end

function Levels.shotsPerCompress(level)
    return math.max(4, 9 - (level - 1) // 2)
end

function Levels.generate(level)
    local rnd = lcg(level * 7919 + 13)
    local rows = SMOKE_EASY and 2 or math.min(4 + level // 3, 6)
    local fillP = SMOKE_EASY and 0.5 or 0.82
    local ntypes = Levels.numTypes(level)

    G.grid = {}
    for r = 0, rows - 1 do
        local cols = Grid.cols(r)
        for c = 0, math.ceil(cols / 2) - 1 do
            local mirror = cols - 1 - c
            if rnd() < fillP then
                local t = math.floor(rnd() * ntypes) + 1
                Grid.set(r, c, t)
                Grid.set(r, mirror, t)
            end
        end
    end

    -- never deal an empty board
    if Grid.isEmpty() then
        Grid.set(0, 3, 1)
        Grid.set(0, 4, 1)
    end
end
