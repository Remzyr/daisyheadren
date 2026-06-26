local Sprite = require("flare.graphics.sprite")
local Assets = require("flare.data.assets")

---@class AnimatedSprite : Sprite
---@field quads table Map of animation name to list of love.Quad frames.
---@field _animData table Map of animation name to fps/loop/frameTime data.
---@field _rawFrames table Raw frame data from the loaded atlas.
---@field _offsets table Map of animation name to per-frame offset tables.
---@field currentAnim string? The name of the currently playing animation.
---@field frame number Current frame index (1-based).
---@field elapsed number Time elapsed on the current frame.
---@field playing boolean Whether the animation is currently advancing.
---@field finished boolean Whether a non-looping animation has completed.
---@field onComplete function? Called when a non-looping animation finishes.
local AnimatedSprite = setmetatable({}, { __index = Sprite })
AnimatedSprite.__index = AnimatedSprite

local function parseXML(src)
    local frames = {}
    for attrs in src:gmatch('<SubTexture([^/]*)/>') do
        local name = attrs:match('name="([^"]+)"')
        local x = tonumber(attrs:match('x="([^"]+)"'))
        local y = tonumber(attrs:match('y="([^"]+)"'))
        local w = tonumber(attrs:match('width="([^"]+)"'))
        local h = tonumber(attrs:match('height="([^"]+)"'))
        local fx = tonumber(attrs:match('frameX="([^"]+)"')) or 0
        local fy = tonumber(attrs:match('frameY="([^"]+)"')) or 0
        local fw = tonumber(attrs:match('frameWidth="([^"]+)"')) or w
        local fh = tonumber(attrs:match('frameHeight="([^"]+)"')) or h
        if name and x and y and w and h then
            table.insert(frames, {
                name = name,
                x = x, y = y, w = w, h = h,
                fx = fx, fy = fy, fw = fw, fh = fh
            })
        end
    end
    return frames
end

local function groupFrames(rawFrames)
    local groups = {}
    local order = {}
    for _, f in ipairs(rawFrames) do
        local anim = f.name:match("^(.-)%d+$") or f.name
        if not groups[anim] then
            groups[anim] = {}
            table.insert(order, anim)
        end
        table.insert(groups[anim], f)
    end
    return groups, order
end

--- Creates a new AnimatedSprite.
--- @param path string|love.Image Path to the spritesheet or an already-loaded image.
--- @param frameWidth number? Frame width. Required only when not using an atlas.
--- @param frameHeight number? Frame height. Required only when not using an atlas.
--- @return AnimatedSprite
function AnimatedSprite.new(path, frameWidth, frameHeight)
    local self = Sprite.new(0, 0, path)
    setmetatable(self, AnimatedSprite)

    self.width  = frameWidth or self.width
    self.height = frameHeight or self.height

    self.quads = {}
    self._animData = {}
    self._rawFrames = {}
    self._offsets = {}

    self.currentAnim = nil
    self.frame = 1
    self.elapsed = 0
    self.playing = false
    self.finished = false
    self.onComplete = nil

    return self
end

--- Loads animations from a Sparrow/Starling XML texture atlas.
--- @param xmlPath string Path to the .xml atlas file.
--- @param fps number? Default fps for all animations (default 24).
--- @param loop boolean? Whether animations loop by default (default true).
function AnimatedSprite:loadXML(xmlPath, fps, loop)
    local src = love.filesystem.read(xmlPath)
    assert(src, "XML atlas not found: " .. xmlPath)

    local rawFrames = parseXML(src)
    self._rawFrames = rawFrames
    local groups = groupFrames(rawFrames)
    local iw, ih = self.image:getDimensions()

    for anim, frames in pairs(groups) do
        local quads = {}
        local offsets = {}
        for _, f in ipairs(frames) do
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.w, f.h, iw, ih))
            table.insert(offsets, { x = -f.fx, y = -f.fy })
            self.width  = self.width  == 0 and f.fw or self.width
            self.height = self.height == 0 and f.fh or self.height
        end
        self.quads[anim] = quads
        self._offsets[anim] = offsets
        self._animData[anim] = {
            fps = fps or 24,
            loop = loop ~= false,
            frameTime = 1 / (fps or 24)
        }
    end
end

--- Loads animations from an Adobe Animate / TexturePacker JSON atlas.
--- @param jsonPath string Path to the .json atlas file.
--- @param fps number? Default fps for all animations (default 24).
--- @param loop boolean? Whether animations loop by default (default true).
function AnimatedSprite:loadJSON(jsonPath, fps, loop)
    local Json = require("flare.data.json")
    local data = Json.decode(love.filesystem.read(jsonPath))
    assert(data and data.frames, "Invalid JSON atlas: " .. jsonPath)

    local rawFrames = {}
    local iw, ih = self.image:getDimensions()

    if data.frames[1] then
        for _, entry in ipairs(data.frames) do
            local f = entry.frame
            table.insert(rawFrames, { name = entry.filename, x = f.x, y = f.y, w = f.w, h = f.h, fx = 0, fy = 0, fw = f.w, fh = f.h })
        end
    else
        for name, entry in pairs(data.frames) do
            local f = entry.frame
            table.insert(rawFrames, { name = name, x = f.x, y = f.y, w = f.w, h = f.h, fx = 0, fy = 0, fw = f.w, fh = f.h })
        end
    end

    self._rawFrames = rawFrames
    local groups = groupFrames(rawFrames)

    for anim, frames in pairs(groups) do
        local quads = {}
        local offsets = {}
        for _, f in ipairs(frames) do
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.w, f.h, iw, ih))
            table.insert(offsets, { x = -f.fx, y = -f.fy })
            self.width  = self.width  == 0 and f.fw or self.width
            self.height = self.height == 0 and f.fh or self.height
        end
        self.quads[anim] = quads
        self._offsets[anim] = offsets
        self._animData[anim] = {
            fps = fps or 24,
            loop = loop ~= false,
            frameTime = 1 / (fps or 24)
        }
    end
end

--- Adds an animation manually by specifying frame indices (1-based) from the spritesheet.
--- @param name string Animation name.
--- @param frames table List of frame indices.
--- @param fps number Frames per second.
--- @param loop boolean? Whether to loop (default true).
function AnimatedSprite:addAnimation(name, frames, fps, loop)
    local iw = self.image:getWidth()
    local cols = math.floor(iw / self.width)
    local quads = {}
    local offsets = {}

    for _, idx in ipairs(frames) do
        local col = (idx - 1) % cols
        local row = math.floor((idx - 1) / cols)
        table.insert(quads, love.graphics.newQuad(
            col * self.width, row * self.height,
            self.width, self.height,
            self.image:getDimensions()
        ))
        table.insert(offsets, { x = 0, y = 0 })
    end

    self.quads[name] = quads
    self._offsets[name] = offsets
    self._animData[name] = {
        fps = fps or 12,
        loop = loop ~= false,
        frameTime = 1 / (fps or 12)
    }
end

--- Adds an animation by collecting all frames whose name starts with a given prefix.
--- @param name string Animation name.
--- @param prefix string Frame name prefix to match.
--- @param fps number? Frames per second (default 24).
--- @param loop boolean? Whether to loop (default true).
function AnimatedSprite:addAnimationByPrefix(name, prefix, fps, loop)
    local iw, ih = self.image:getDimensions()
    local quads = {}
    local offsets = {}

    for _, f in ipairs(self._rawFrames) do
        if f.name:sub(1, #prefix) == prefix then
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.w, f.h, iw, ih))
            table.insert(offsets, { x = -f.fx, y = -f.fy })
            self.width  = self.width  == 0 and f.fw or self.width
            self.height = self.height == 0 and f.fh or self.height
        end
    end

    assert(#quads > 0, "No frames found with prefix: " .. prefix)

    self.quads[name] = quads
    self._offsets[name] = offsets
    self._animData[name] = {
        fps = fps or 24,
        loop = loop ~= false,
        frameTime = 1 / (fps or 24)
    }
end

--- Adds an animation by picking specific frame indices from an atlas prefix.
--- @param name string Animation name.
--- @param prefix string Frame name prefix to match.
--- @param indices table List of 1-based indices into the matched frames.
--- @param fps number? Frames per second (default 24).
--- @param loop boolean? Whether to loop (default true).
function AnimatedSprite:addAnimationByIndices(name, prefix, indices, fps, loop)
    local iw, ih = self.image:getDimensions()
    local matched = {}

    for _, f in ipairs(self._rawFrames) do
        if f.name:sub(1, #prefix) == prefix then
            table.insert(matched, f)
        end
    end

    assert(#matched > 0, "No frames found with prefix: " .. prefix)

    local quads = {}
    local offsets = {}

    for _, idx in ipairs(indices) do
        local f = matched[idx]
        assert(f, "Index out of range for prefix " .. prefix .. ": " .. idx)
        table.insert(quads, love.graphics.newQuad(f.x, f.y, f.w, f.h, iw, ih))
        table.insert(offsets, { x = -f.fx, y = -f.fy })
        self.width  = self.width  == 0 and f.fw or self.width
        self.height = self.height == 0 and f.fh or self.height
    end

    self.quads[name] = quads
    self._offsets[name] = offsets
    self._animData[name] = {
        fps = fps or 24,
        loop = loop ~= false,
        frameTime = 1 / (fps or 24)
    }
end

--- Sets the fps for an existing animation.
--- @param name string
--- @param fps number
function AnimatedSprite:setFPS(name, fps)
    local data = self._animData[name]
    assert(data, "Animation not found: " .. tostring(name))
    data.fps = fps
    data.frameTime = 1 / fps
end

--- Plays an animation by name. Does nothing if already playing unless forced.
--- @param name string Animation name.
--- @param force boolean? If true, restarts even if already playing.
function AnimatedSprite:play(name, force)
    if self.currentAnim == name and self.playing and not force then return end
    assert(self.quads[name], "Animation not found: " .. tostring(name))
    self.currentAnim = name
    self.frame = 1
    self.elapsed = 0
    self.playing = true
    self.finished = false
end

--- Stops the current animation on the current frame.
function AnimatedSprite:stop()
    self.playing = false
end

--- Resumes a stopped animation.
function AnimatedSprite:resume()
    self.playing = true
end

--- Updates the animation frame. Call in love.update(dt).
--- @param dt number Delta time.
function AnimatedSprite:update(dt)
    if not self.playing or not self.currentAnim then return end

    local data = self._animData[self.currentAnim]
    local frames = self.quads[self.currentAnim]

    self.elapsed = self.elapsed + dt

    while self.elapsed >= data.frameTime do
        self.elapsed = self.elapsed - data.frameTime
        self.frame = self.frame + 1

        if self.frame > #frames then
            if data.loop then
                self.frame = 1
            else
                self.frame = #frames
                self.playing = false
                self.finished = true
                if self.onComplete then self.onComplete() end
                break
            end
        end
    end
end

--- Draws the current animation frame.
function AnimatedSprite:draw()
    if not self.currentAnim or not self.visible then return end

    local frames = self.quads[self.currentAnim]
    local offsets = self._offsets[self.currentAnim]
    local quad = frames[self.frame]
    local off = offsets and offsets[self.frame] or { x = 0, y = 0 }
    if not quad then return end

    local s = type(self.scale) == "table" and self.scale or { x = self.scale, y = self.scale }
    local sx = s.x * (self.flipX and -1 or 1)
    local sy = s.y * (self.flipY and -1 or 1)
    local ox = self.flipX and self.width or 0
    local oy = self.flipY and self.height or 0

    if self.shader then love.graphics.setShader(self.shader) end
    love.graphics.setColor(self.color)
    love.graphics.draw(
        self.image, quad,
        self.x + off.x * s.x + ox,
        self.y + off.y * s.y + oy,
        self.angle or 0, sx, sy
    )
    love.graphics.setColor(1, 1, 1, 1)
    if self.shader then love.graphics.setShader() end
end

--- Returns true if the given animation is currently playing.
--- @param name string
--- @return boolean
function AnimatedSprite:isPlaying(name)
    return self.currentAnim == name and self.playing
end

--- Returns a list of all loaded animation names.
--- @return table
function AnimatedSprite:getAnimations()
    local list = {}
    for name in pairs(self.quads) do
        table.insert(list, name)
    end
    return list
end

return AnimatedSprite