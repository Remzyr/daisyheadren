---@class Basic
---@field active boolean Whether the object receives updates.
---@field visible boolean Whether the object is drawn.
---@field exists boolean Whether the object is active in the world.
---@field alive boolean Whether the object is considered alive.
local Basic = {}
Basic.__index = Basic

--- Creates a new Basic instance.
--- @return Basic
function Basic.new()
    local self = setmetatable({}, Basic)

    self.active = true
    self.visible = true
    self.exists = true
    self.alive = true

    return self
end

--- Called every frame. Override to add update logic.
--- @param dt number Delta time.
function Basic:update(dt)
end

--- Called every frame. Override to add draw logic.
function Basic:draw()
end

--- Sets alive and exists to false.
function Basic:kill()
    self.alive = false
    self.exists = false
end

--- Sets alive and exists back to true.
function Basic:revive()
    self.alive = true
    self.exists = true
end

--- Removes the object from the world without marking it as dead.
function Basic:destroy()
    self.exists = false
end

return Basic
