local Assets = require("data.assets")

---@class Sound
---@field masterVolume number Global volume multiplier from 0 to 1.
---@field musicVolume number Music volume multiplier from 0 to 1.
---@field sfxVolume number SFX volume multiplier from 0 to 1.
---@field currentMusic love.Source? The currently playing music source.
local Sound = {}

Sound.masterVolume = 1
Sound.musicVolume = 1
Sound.sfxVolume = 1
Sound.currentMusic = nil

--- Plays a one-shot sound effect.
--- @param path string Path to the sound file.
--- @param volume number? Volume from 0 to 1 (default 1).
--- @param pitch number? Pitch multiplier (default 1).
--- @return love.Source
function Sound.play(path, volume, pitch)
    local source = Paths.sound(path, "static"):clone()
    source:setVolume((volume or 1) * Sound.sfxVolume * Sound.masterVolume)
    source:setPitch(pitch or 1)
    source:play()
    return source
end

--- Stops any current music and plays a new streamed music track.
--- @param path string Path to the music file.
--- @param volume number? Volume from 0 to 1 (default 1).
--- @param loop boolean? Whether to loop the track (default true).
--- @return love.Source
function Sound.music(path, volume, loop)
    if Sound.currentMusic then
        Sound.currentMusic:stop()
    end
    local source = Paths.music(path, "stream")
    source:setLooping(loop ~= false)
    source:setVolume((volume or 1) * Sound.musicVolume * Sound.masterVolume)
    source:play()
    Sound.currentMusic = source
    return source
end

--- Stops and clears the current music track.
function Sound.stopMusic()
    if Sound.currentMusic then
        Sound.currentMusic:stop()
        Sound.currentMusic = nil
    end
end

--- Pauses the current music track.
function Sound.pauseMusic()
    if Sound.currentMusic then
        Sound.currentMusic:pause()
    end
end

--- Resumes a paused music track.
function Sound.resumeMusic()
    if Sound.currentMusic then
        Sound.currentMusic:play()
    end
end

--- Sets the master volume and updates the current music accordingly.
--- @param value number Clamped to 0..1.
function Sound.setMasterVolume(value)
    Sound.masterVolume = math.max(0, math.min(value, 1))
    Sound.updateMusicVolume()
end

--- Sets the music volume and updates the current music accordingly.
--- @param value number Clamped to 0..1.
function Sound.setMusicVolume(value)
    Sound.musicVolume = math.max(0, math.min(value, 1))
    Sound.updateMusicVolume()
end

--- Sets the SFX volume. Applies to future sound plays only.
--- @param value number Clamped to 0..1.
function Sound.setSFXVolume(value)
    Sound.sfxVolume = math.max(0, math.min(value, 1))
end

--- Recalculates and applies the volume to the current music source.
function Sound.updateMusicVolume()
    if Sound.currentMusic then
        Sound.currentMusic:setVolume(Sound.musicVolume * Sound.masterVolume)
    end
end

return Sound
