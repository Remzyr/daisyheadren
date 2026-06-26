local Assets = require("data.assets")

---@class Trail
---@field target table The object being trailed (needs x, y, width, height).
---@field length number Max number of ghost snapshots.
---@field delay number Seconds between each snapshot.
---@field alpha number Starting alpha of the oldest ghost (default 0.6).
---@field color number[] RGBA tint applied to all ghosts.
---@field _snapshots table List of recorded position snapshots.
---@field _elapsed number Time since last snapshot.
local Trail = {}
Trail.__index = Trail

--- Creates a new Trail that follows a target object.
--- @param target table Object with x, y, width, height, image, angle, scale.
--- @param length number? Max ghost count (default 8).
--- @param delay number? Seconds between snapshots (default 0.05).
--- @return Trail
function Trail.new(target, length, delay)
    local self = setmetatable({}, Trail)
    self.target = target
    self.length = length or 8
    self.delay = delay or 0.05
    self.alpha = 0.6
    self.color = { 1, 1, 1 }
    self._snapshots = {}
    self._elapsed = 0
    return self
end

--- Updates the trail, recording new snapshots from the target.
--- @param dt number Delta time.
function Trail:update(dt)
    self._elapsed = self._elapsed + dt

    if self._elapsed >= self.delay then
        self._elapsed = 0

        table.insert(self._snapshots, 1, {
            x = self.target.x,
            y = self.target.y,
            angle = self.target.angle or 0,
            scaleX = self.target.scale and self.target.scale.x or 1,
            scaleY = self.target.scale and self.target.scale.y or 1,
            originX = self.target.origin and self.target.origin.x or 0,
            originY = self.target.origin and self.target.origin.y or 0,
        })

        if #self._snapshots > self.length then
            table.remove(self._snapshots)
        end
    end
end

--- Draws all ghost snapshots behind the target.
--- Oldest snapshots are more transparent.
function Trail:draw()
    local image = self.target.image
    if not image then return end

    local r, g, b = self.color[1], self.color[2], self.color[3]

    for i, snap in ipairs(self._snapshots) do
        local a = self.alpha * (1 - (i - 1) / self.length)
        love.graphics.setColor(r, g, b, a)
        love.graphics.draw(
            image,
            snap.x, snap.y,
            snap.angle,
            snap.scaleX, snap.scaleY,
            snap.originX, snap.originY
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
end

--- Clears all recorded snapshots.
function Trail:clear()
    self._snapshots = {}
end

return Trail
