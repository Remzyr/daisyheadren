local Object = require("core.object")
local Assets = require("data.assets")

---@class Sprite : Object
---@field image love.Image? The loaded image.
---@field scale {x: number, y: number} Horizontal and vertical scale.
---@field origin {x: number, y: number} Draw origin offset in pixels.
---@field color number[] RGBA tint color.
---@field angle number Rotation in radians.
---@field visible boolean Whether the sprite is drawn.
---@field shader love.Shader? Optional shader applied during draw.
---@field antialiasing boolean Whether image smoothing is enabled.
local Sprite = setmetatable({}, { __index = Object })
Sprite.__index = Sprite

--- Creates a new Sprite.
--- @param x number? X position (default 0).
--- @param y number? Y position (default 0).
--- @param imagePath string|love.Image? Image path or image object.
--- @return Sprite
function Sprite.new(x, y, imagePath)
    local self = Object.new(x or 0, y or 0, 0, 0)
    setmetatable(self, Sprite)

    self.image = nil
    self.scale = { x = 1, y = 1 }
    self.origin = { x = 0, y = 0 }
    self.color = { 1, 1, 1, 1 }
    self.angle = 0
    self.visible = true
    self.shader = nil
    self.antialiasing = true

    if imagePath then
        self:loadGraphic(imagePath)
    end

    return self
end

--- Loads a graphic from a path or an existing image object.
--- @param path string|love.Image
--- @return Sprite
function Sprite:loadGraphic(path)
    if type(path) == "string" then
        self.image = Assets.image(path)
    else
        self.image = path
    end

    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self:updateFilter()

    return self
end

--- Updates the image filter based on antialiasing.
--- @return Sprite
function Sprite:updateFilter()
    if not self.image then return self end

    if self.antialiasing then
        self.image:setFilter("linear", "linear")
    else
        self.image:setFilter("nearest", "nearest")
    end

    return self
end

--- Enables or disables antialiasing.
--- @param enabled boolean
--- @return Sprite
function Sprite:setAntialiasing(enabled)
    self.antialiasing = enabled
    return self:updateFilter()
end

--- Sets scale uniformly or per axis.
--- @param x number Horizontal scale.
--- @param y number? Vertical scale (defaults to x).
--- @return Sprite
function Sprite:setScale(x, y)
    self.scale.x = x
    self.scale.y = y ~= nil and y or x
    return self
end

--- Sets the draw origin. Use "center" as a shortcut to center it on the image.
--- @param x number|string X origin in pixels, or "center".
--- @param y number? Y origin in pixels (ignored when x is "center").
--- @return Sprite
function Sprite:setOrigin(x, y)
    if x == "center" then
        self.origin.x = self.width / 2
        self.origin.y = self.height / 2
    else
        self.origin.x = x
        self.origin.y = y or 0
    end

    return self
end

--- Sets the RGBA tint color. Values are 0..1.
--- @param r number
--- @param g number
--- @param b number
--- @param a number? Alpha (default 1).
--- @return Sprite
function Sprite:setColor(r, g, b, a)
    self.color[1] = r
    self.color[2] = g
    self.color[3] = b
    self.color[4] = a or 1
    return self
end

--- Sets alpha without touching RGB.
--- @param a number 0..1
--- @return Sprite
function Sprite:setAlpha(a)
    self.color[4] = a
    return self
end

--- Centers the sprite on screen along the given axes.
--- @param axes string? "x", "y", or "xy" (default "xy").
--- @return Sprite
function Sprite:screenCenter(axes)
    local sw, sh = love.graphics.getDimensions()
    axes = axes or "xy"

    if axes:find("x") then
        self.x = (sw - self.width * self.scale.x) / 2
    end

    if axes:find("y") then
        self.y = (sh - self.height * self.scale.y) / 2
    end

    return self
end

--- Returns the center x of the sprite accounting for scale.
--- @return number
function Sprite:getCenterX()
    return self.x + (self.width * self.scale.x) / 2
end

--- Returns the center y of the sprite accounting for scale.
--- @return number
function Sprite:getCenterY()
    return self.y + (self.height * self.scale.y) / 2
end

--- Attaches a shader to be applied during draw.
--- @param shader love.Shader?
--- @return Sprite
function Sprite:setShader(shader)
    self.shader = shader
    return self
end

--- Draws the sprite.
function Sprite:draw()
    if not self.image or not self.visible then return end

    if self.shader then
        love.graphics.setShader(self.shader)
    end

    love.graphics.setColor(self.color)
    love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale.x, self.scale.y, self.origin.x, self.origin.y)
    love.graphics.setColor(1, 1, 1, 1)

    if self.shader then
        love.graphics.setShader()
    end
end

return Sprite