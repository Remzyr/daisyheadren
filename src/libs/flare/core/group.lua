local Basic = require("core.basic")

---@class Group : Basic
---@field members table List of objects in the group.
---@field maxSize number? Maximum number of members (nil means unlimited).
local Group = setmetatable({}, { __index = Basic })
Group.__index = Group

--- Creates a new Group.
--- @param maxSize number? Optional maximum member count.
--- @return Group
function Group.new(maxSize)
    local self = Basic.new()
    setmetatable(self, Group)
    self.members = {}
    self.maxSize = maxSize
    return self
end

--- Adds an object to the group.
--- @param obj table
--- @return table The added object.
function Group:add(obj)
    if self.maxSize and #self.members >= self.maxSize then
        return obj
    end
    table.insert(self.members, obj)
    return obj
end

--- Removes an object from the group.
--- @param obj table
--- @return table? The removed object, or nil if not found.
function Group:remove(obj)
    for i = #self.members, 1, -1 do
        if self.members[i] == obj then
            table.remove(self.members, i)
            return obj
        end
    end
    return nil
end

--- Updates all active members.
--- @param dt number Delta time.
function Group:update(dt)
    if not self.active then return end
    for i = 1, #self.members do
        local obj = self.members[i]
        if obj.exists and obj.active and obj.update then
            obj:update(dt)
        end
    end
end

--- Draws all visible members.
function Group:draw()
    if not self.visible then return end
    for i = 1, #self.members do
        local obj = self.members[i]
        if obj.exists and obj.visible and obj.draw then
            obj:draw()
        end
    end
end

--- Returns the first inactive member, or nil if none exist.
--- @return table?
function Group:getFirstDead()
    for i = 1, #self.members do
        if not self.members[i].alive then
            return self.members[i]
        end
    end
    return nil
end

--- Returns the first active member, or nil if none exist.
--- @return table?
function Group:getFirstAlive()
    for i = 1, #self.members do
        if self.members[i].alive then
            return self.members[i]
        end
    end
    return nil
end

--- Returns the number of alive members.
--- @return number
function Group:countAlive()
    local count = 0
    for i = 1, #self.members do
        if self.members[i].alive then count = count + 1 end
    end
    return count
end

--- Returns the number of dead members.
--- @return number
function Group:countDead()
    local count = 0
    for i = 1, #self.members do
        if not self.members[i].alive then count = count + 1 end
    end
    return count
end

--- Calls a function on every member.
--- @param fn function Called with the member as the first argument.
function Group:forEach(fn)
    for i = 1, #self.members do
        fn(self.members[i])
    end
end

--- Kills all members.
function Group:killAll()
    for i = 1, #self.members do
        if self.members[i].kill then
            self.members[i]:kill()
        end
    end
end

--- Removes all members from the group.
function Group:clear()
    self.members = {}
end

--- Returns the number of members in the group.
--- @return number
function Group:count()
    return #self.members
end

return Group
