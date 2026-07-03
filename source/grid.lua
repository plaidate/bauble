-- The hex-packed bubble field: cell math, matching, dropping, compressing.
-- Even rows hold 8 bubbles, odd rows 7 (shifted half a bubble right).

Grid = {}

function Grid.cols(r)
    return (r % 2 == 0) and 8 or 7
end

function Grid.cellPos(r, c)
    local x = C.FIELD_LEFT + C.RADIUS + (r % 2) * C.RADIUS + c * C.DIAM
    local y = G.ceilingY + C.RADIUS + r * C.ROW_PITCH
    return x, y
end

function Grid.get(r, c)
    return G.grid[r] and G.grid[r][c]
end

function Grid.set(r, c, v)
    G.grid[r] = G.grid[r] or {}
    G.grid[r][c] = v
end

function Grid.neighbors(r, c)
    local o = r % 2
    local cand = {
        { r, c - 1 }, { r, c + 1 },
        { r - 1, c - 1 + o }, { r - 1, c + o },
        { r + 1, c - 1 + o }, { r + 1, c + o },
    }
    local out = {}
    for _, rc in ipairs(cand) do
        local rr, cc = rc[1], rc[2]
        if rr >= 0 and rr <= C.MAX_ROWS and cc >= 0 and cc < Grid.cols(rr) then
            out[#out + 1] = rc
        end
    end
    return out
end

function Grid.forEach(fn)
    for r = 0, C.MAX_ROWS do
        if G.grid[r] then
            for c = 0, Grid.cols(r) - 1 do
                if G.grid[r][c] then fn(r, c, G.grid[r][c]) end
            end
        end
    end
end

function Grid.isEmpty()
    local found = false
    Grid.forEach(function() found = true end)
    return not found
end

function Grid.typesInField()
    local set, list = {}, {}
    Grid.forEach(function(_, _, t)
        if not set[t] then
            set[t] = true
            list[#list + 1] = t
        end
    end)
    return list
end

-- nearest empty cell to (x, y) that touches the ceiling or an occupied cell
function Grid.snapCell(x, y)
    local best, bestD
    for r = 0, C.MAX_ROWS do
        for c = 0, Grid.cols(r) - 1 do
            if not Grid.get(r, c) then
                local ok = (r == 0)
                if not ok then
                    for _, n in ipairs(Grid.neighbors(r, c)) do
                        if Grid.get(n[1], n[2]) then
                            ok = true
                            break
                        end
                    end
                end
                if ok then
                    local cx, cy = Grid.cellPos(r, c)
                    local d = (cx - x) ^ 2 + (cy - y) ^ 2
                    if not bestD or d < bestD then
                        bestD = d
                        best = { r, c }
                    end
                end
            end
        end
    end
    return best
end

local function flood(r, c, sameType, visited)
    local t = Grid.get(r, c)
    local stack = { { r, c } }
    local out = {}
    while #stack > 0 do
        local rc = table.remove(stack)
        local rr, cc = rc[1], rc[2]
        local key = rr * 16 + cc
        local v = Grid.get(rr, cc)
        if not visited[key] and v and (not sameType or v == t) then
            visited[key] = true
            out[#out + 1] = rc
            for _, n in ipairs(Grid.neighbors(rr, cc)) do
                stack[#stack + 1] = n
            end
        end
    end
    return out
end

-- after placing at (r, c): pop a 3+ match, then drop anything left hanging.
-- returns popped count, dropped count
function Grid.resolve(r, c)
    local popped, dropped = 0, 0

    local match = flood(r, c, true, {})
    if #match >= 3 then
        popped = #match
        for _, rc in ipairs(match) do
            local x, y = Grid.cellPos(rc[1], rc[2])
            G.burst(x, y, 4)
            Grid.set(rc[1], rc[2], nil)
        end
    end

    if popped > 0 then
        -- anything not anchored to the ceiling falls
        local anchored = {}
        for c0 = 0, Grid.cols(0) - 1 do
            if Grid.get(0, c0) then
                flood(0, c0, false, anchored)
            end
        end
        Grid.forEach(function(rr, cc, t)
            if not anchored[rr * 16 + cc] then
                local x, y = Grid.cellPos(rr, cc)
                G.falling[#G.falling + 1] = {
                    x = x, y = y, type = t,
                    vx = math.random(-30, 30), vy = -40,
                }
                Grid.set(rr, cc, nil)
                dropped = dropped + 1
            end
        end)
    end

    return popped, dropped
end

function Grid.compress()
    G.ceilingY = G.ceilingY + C.ROW_PITCH
    Sfx.compress()
end

function Grid.checkLose()
    local lost = false
    Grid.forEach(function(r, c)
        local _, y = Grid.cellPos(r, c)
        if y + C.RADIUS > C.DEADLINE then lost = true end
    end)
    return lost
end
