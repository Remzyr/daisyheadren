---@class SubState
---@field _stack table Stack of active substates.
local SubState = {}

SubState._stack = {}

local function call(fn, ...)
    if fn then return fn(...) end
end

--- Opens a substate on top of the current one.
--- The substate table can define open(), close(), update(dt), and draw().
--- @param state table The substate to open.
--- @param ... any Arguments forwarded to the substate's open callback.
function SubState.open(state, ...)
    local prev = SubState._stack[#SubState._stack]
    if prev and prev.pause then prev:pause() end
    table.insert(SubState._stack, state)
    call(state.open, state, ...)
end

--- Closes the topmost substate.
--- @param ... any Arguments forwarded to the substate's close callback.
function SubState.close(...)
    local state = table.remove(SubState._stack)
    if state then
        call(state.close, state, ...)
    end
    local prev = SubState._stack[#SubState._stack]
    if prev and prev.resume then prev:resume() end
end

--- Closes all substates.
function SubState.closeAll()
    while #SubState._stack > 0 do
        SubState.close()
    end
end

--- Updates the topmost substate. Call in love.update(dt).
--- @param dt number Delta time.
function SubState.update(dt)
    local state = SubState._stack[#SubState._stack]
    if state then call(state.update, state, dt) end
end

--- Draws all substates from bottom to top.
function SubState.draw()
    for i = 1, #SubState._stack do
        local state = SubState._stack[i]
        if state.draw then call(state.draw, state) end
    end
end

--- Returns the currently active substate, or nil if none are open.
--- @return table?
function SubState.current()
    return SubState._stack[#SubState._stack]
end

--- Returns true if any substate is currently open.
--- @return boolean
function SubState.isOpen()
    return #SubState._stack > 0
end

--- Returns the number of open substates.
--- @return number
function SubState.depth()
    return #SubState._stack
end

return SubState
