local Assets = require("data.assets")

---@class Video
---@field currentVideo love.Video? The currently playing video.
---@field masterVolume number Global volume multiplier from 0 to 1.
---@field volume number Video volume multiplier from 0 to 1.
local Video = {}

Video.currentVideo = nil
Video.masterVolume = 1
Video.volume = 1

--- Loads and plays a video file.
--- @param path string Path to the video file.
--- @param volume number? Volume from 0 to 1 (default 1).
--- @return love.Video
function Video.play(path, volume)
    if Video.currentVideo then
        Video.currentVideo:pause()
    end
    local vid = Assets.video(path)
    vid:setVolume((volume or 1) * Video.volume * Video.masterVolume)
    vid:play()
    Video.currentVideo = vid
    return vid
end

--- Draws the current video on screen.
--- @param x number? X position (default 0).
--- @param y number? Y position (default 0).
--- @param angle number? Rotation in radians (default 0).
--- @param sx number? X scale (default 1).
--- @param sy number? Y scale (default 1).
function Video.draw(x, y, angle, sx, sy)
    if Video.currentVideo then
        love.graphics.draw(Video.currentVideo, x or 0, y or 0, angle or 0, sx or 1, sy or 1)
    end
end

--- Pauses the current video.
function Video.pause()
    if Video.currentVideo then
        Video.currentVideo:pause()
    end
end

--- Resumes a paused video.
function Video.resume()
    if Video.currentVideo then
        Video.currentVideo:play()
    end
end

--- Stops and clears the current video.
function Video.stop()
    if Video.currentVideo then
        Video.currentVideo:pause()
        Video.currentVideo = nil
    end
end

--- Returns true if a video is currently playing.
--- @return boolean
function Video.isPlaying()
    return Video.currentVideo ~= nil and Video.currentVideo:isPlaying()
end

--- Seeks the current video to a time in seconds.
--- @param time number Time in seconds.
function Video.seek(time)
    if Video.currentVideo then
        Video.currentVideo:seek(time)
    end
end

--- Returns the current playback position in seconds.
--- @return number?
function Video.tell()
    if Video.currentVideo then
        return Video.currentVideo:tell()
    end
end

--- Returns the width and height of the current video in pixels.
--- @return number?, number?
function Video.getDimensions()
    if Video.currentVideo then
        return Video.currentVideo:getDimensions()
    end
end

--- Sets the master volume and updates the current video accordingly.
--- @param value number Clamped to 0..1.
function Video.setMasterVolume(value)
    Video.masterVolume = math.max(0, math.min(value, 1))
    Video.updateVolume()
end

--- Sets the video volume and updates the current video accordingly.
--- @param value number Clamped to 0..1.
function Video.setVolume(value)
    Video.volume = math.max(0, math.min(value, 1))
    Video.updateVolume()
end

--- Recalculates and applies the volume to the current video.
function Video.updateVolume()
    if Video.currentVideo then
        Video.currentVideo:setVolume(Video.volume * Video.masterVolume)
    end
end

return Video
