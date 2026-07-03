-- Helpers: clamp and a one-shot delayed-call scheduler.

Util = {}

function Util.clamp(v, lo, hi)
    if v < lo then return lo elseif v > hi then return hi else return v end
end

local pending = {}

function Util.after(delay, fn)
    pending[#pending + 1] = { t = delay, fn = fn }
end

function Util.runPending()
    for i = #pending, 1, -1 do
        local p = pending[i]
        p.t = p.t - C.DT
        if p.t <= 0 then
            table.remove(pending, i)
            p.fn()
        end
    end
end
