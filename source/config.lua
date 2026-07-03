-- Tunables and harness flags.

C = {
    SCREEN_W = 400,
    SCREEN_H = 240,
    DT = 1 / 30,

    -- the field: 8 columns of 24px bubbles, hex-packed, centered on screen
    FIELD_LEFT = 104,
    FIELD_RIGHT = 296,
    DIAM = 24,
    RADIUS = 12,
    ROW_PITCH = 21,    -- DIAM * 0.866, rounded
    DEADLINE = 192,    -- bubbles past this line lose the round
    MAX_ROWS = 12,

    LAUNCH_X = 200,
    LAUNCH_Y = 214,
    AIM_MAX = 78,          -- degrees off vertical, either way
    CRANK_AIM_RATIO = 0.5, -- aim degrees per crank degree (fine control)
    DPAD_AIM_SPEED = 60,   -- degrees per second
    SHOT_SPEED = 460,
    IDLE_FIRE = 7,         -- seconds of idling before the launcher fires itself

    START_LIVES = 3,
    LEVEL_CLEAR_BONUS = 1000,

    MAX_TYPES = 6,
}

AUTOPILOT = false  -- smoke-test mode: aims randomly and keeps firing
SMOKE_EASY = false -- smoke-test mode: tiny sparse layouts so rounds clear fast
