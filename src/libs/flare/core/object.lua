local Basic = require("core.basic")

---@class Object : Basic
---@field x number World x position.
---@field y number World y position.
---@field width number Width in pixels.
---@field height number Height in pixels.
---@field velocity {x: number, y: number} Current velocity.
---@field acceleration {x: number, y: number} Acceleration applied each frame.
---@field drag {x: number, y: number} Drag applied when no acceleration is active.
---@field maxVelocity {x: number, y: number} Maximum velocity on each axis.
---@field angle number Rotation in degrees.
---@field alpha number Opacity from 0 to 1.
local Object = setmetatable({}, { __index = Basic })
Object.__index = Object

--- Creates a new Object.
--- @param x number? World x position (default 0).
--- @param y number? World y position (default 0).
--- @param width number? Width in pixels (default 0).
--- @param height number? Height in pixels (default 0).
--- @return Object
function Object.new(x, y, width, height)
    local self = Basic.new()
    setmetatable(self, Object)

    self.x = x or 0
    self.y = y or 0
    self.width = width or 0
    self.height = height or 0

    self.velocity = { x = 0, y = 0 }
    self.acceleration = { x = 0, y = 0 }
    self.drag = { x = 0, y = 0 }
    self.maxVelocity = { x = math.huge, y = math.huge }

    self.angle = 0
    self.alpha = 1

    return self
end

local function approach(value, target, amount)
    if value < target then
        return math.min(value + amount, target)
    elseif value > target then
        return math.max(value - amount, target)
    end
    return target
end

--- Applies acceleration, drag, velocity clamping, and position integration.
--- @param dt number Delta time.
function Object:updateMotion(dt)
    self.velocity.x = self.velocity.x + self.acceleration.x * dt
    self.velocity.y = self.velocity.y + self.acceleration.y * dt

    if self.acceleration.x == 0 then
        self.velocity.x = approach(self.velocity.x, 0, self.drag.x * dt)
    end

    if self.acceleration.y == 0 then
        self.velocity.y = approach(self.velocity.y, 0, self.drag.y * dt)
    end

    self.velocity.x = math.max(-self.maxVelocity.x, math.min(self.velocity.x, self.maxVelocity.x))
    self.velocity.y = math.max(-self.maxVelocity.y, math.min(self.velocity.y, self.maxVelocity.y))

    self.x = self.x + self.velocity.x * dt
    self.y = self.y + self.velocity.y * dt
end

--- Updates motion each frame. Override to add custom behavior.
--- @param dt number Delta time.
function Object:update(dt)
    self:updateMotion(dt)
end

--- Returns true if this object's bounding box overlaps another object's.
--- @param other Object
--- @return boolean
function Object:overlaps(other)
    return self.x < other.x + other.width
        and self.x + self.width > other.x
        and self.y < other.y + other.height
        and self.y + self.height > other.y
end

--- Returns the center x of the object.
--- @return number
function Object:centerX()
    return self.x + self.width / 2
end

--- Returns the center y of the object.
--- @return number
function Object:centerY()
    return self.y + self.height / 2
end

--- Sets the position of the object.
--- @param x number
--- @param y number
function Object:setPosition(x, y)
    self.x = x
    self.y = y
end

--- Sets the velocity of the object.
--- @param x number
--- @param y number
function Object:setVelocity(x, y)
    self.velocity.x = x
    self.velocity.y = y
end

--- Stops all movement by zeroing velocity and acceleration.
function Object:stop()
    self.velocity.x = 0
    self.velocity.y = 0
    self.acceleration.x = 0
    self.acceleration.y = 0
end

return Object
