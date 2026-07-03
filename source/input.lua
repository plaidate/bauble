-- Crank aiming, d-pad fallback, fire button, and the smoke-test autopilot.

Input = {}

local auto = { t = 0, target = 0 }

-- returns: aimDelta (degrees), fire, start
function Input.gather()
    if AUTOPILOT then
        auto.t = auto.t - C.DT
        if auto.t <= 0 then
            auto.t = 0.4 + math.random() * 0.6
            auto.target = math.random(-C.AIM_MAX, C.AIM_MAX)
        end
        local delta = Util.clamp(auto.target - G.aim, -120 * C.DT, 120 * C.DT)
        local fire = (not G.flying) and math.random() < 0.3
        return delta, fire, true
    end

    -- the crank is the aimer: geared down for fine control
    local delta = playdate.getCrankChange() * C.CRANK_AIM_RATIO

    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        delta = delta - C.DPAD_AIM_SPEED * C.DT
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        delta = delta + C.DPAD_AIM_SPEED * C.DT
    end

    local fire = playdate.buttonJustPressed(playdate.kButtonA)
        or playdate.buttonJustPressed(playdate.kButtonB)
    return delta, fire, fire
end
