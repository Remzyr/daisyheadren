---@class Pool
---@field _class table The class this pool manages.
---@field _available table List of inactive pooled objects.
---@field _active table List of active pooled objects.
local Pool = {}
Pool.__index = Pool

--- Creates a new object pool for a given class.
--- The class must have a `new` constructor and support `alive` and `exists` fields.
--- @param class table The class to pool.
--- @param prealloc number? Number of instances to preallocate (default 0).
--- @return Pool
function Pool.new(class, prealloc)
    local self = setmetatable({}, Pool)
    self._class = class
    self._available = {}
    self._active = {}

    for i = 1, prealloc or 0 do
        local obj = class.new()
        obj.exists = false
        obj.alive = false
        table.insert(self._available, obj)
    end

    return self
end

--- Gets an inactive object from the pool, or creates a new one if none are available.
--- @param ... any Arguments forwarded to the class constructor if a new instance is needed.
--- @return table
function Pool:get(...)
    local obj

    if #self._available > 0 then
        obj = table.remove(self._available)
        obj.exists = true
        obj.alive = true
    else
        obj = self._class.new(...)
    end

    table.insert(self._active, obj)
    return obj
end

--- Returns an object back to the pool and marks it inactive.
--- @param obj table
function Pool:release(obj)
    obj.exists = false
    obj.alive = false

    for i = #self._active, 1, -1 do
        if self._active[i] == obj then
            table.remove(self._active, i)
            break
        end
    end

    table.insert(self._available, obj)
end

--- Updates all active objects. Automatically releases any that are no longer alive.
--- @param dt number Delta time.
function Pool:update(dt)
    for i = #self._active, 1, -1 do
        local obj = self._active[i]
        if not obj.alive or not obj.exists then
            self:release(obj)
        elseif obj.update then
            obj:update(dt)
        end
    end
end

--- Draws all active and visible objects.
function Pool:draw()
    for i = 1, #self._active do
        local obj = self._active[i]
        if obj.visible and obj.draw then
            obj:draw()
        end
    end
end

--- Releases all active objects back into the pool.
function Pool:clear()
    for i = #self._active, 1, -1 do
        self:release(self._active[i])
    end
end

--- Returns the number of active objects.
--- @return number
function Pool:activeCount()
    return #self._active
end

--- Returns the number of available (inactive) objects.
--- @return number
function Pool:availableCount()
    return #self._available
end

return Pool
