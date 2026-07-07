-- Synth one-shot sound effects.

local snd <const> = playdate.sound

Sfx = {}

local sq = snd.synth.new(snd.kWaveSquare)
local tri = snd.synth.new(snd.kWaveTriangle)
local saw = snd.synth.new(snd.kWaveSawtooth)
local noise = snd.synth.new(snd.kWaveNoise)

function Sfx.fire()
    tri:playNote(700, 0.25, 0.05)
end

function Sfx.bounce()
    sq:playNote(1100, 0.2, 0.03)
end

function Sfx.stick()
    sq:playNote(220, 0.25, 0.05)
end

function Sfx.pop(n)
    for i = 0, math.min(n, 6) - 1 do
        Util.after(i * 0.05, function() tri:playNote(523 + i * 90, 0.3, 0.06) end)
    end
end

function Sfx.drop(n)
    for i = 0, math.min(n, 5) - 1 do
        Util.after(i * 0.06, function() saw:playNote(400 - i * 55, 0.25, 0.07) end)
    end
end

function Sfx.compress()
    noise:playNote(90, 0.4, 0.25)
    sq:playNote(70, 0.3, 0.2)
end

function Sfx.warn()
    sq:playNote(880, 0.25, 0.06)
end

function Sfx.clear()
    local notes = { 523, 659, 784, 1047, 1319 }
    for i, n in ipairs(notes) do
        Util.after((i - 1) * 0.11, function() tri:playNote(n, 0.3, 0.1) end)
    end
end

function Sfx.die()
    saw:playNote(400, 0.4, 0.12)
    Util.after(0.13, function() saw:playNote(280, 0.4, 0.12) end)
    Util.after(0.26, function() saw:playNote(160, 0.4, 0.25) end)
end
