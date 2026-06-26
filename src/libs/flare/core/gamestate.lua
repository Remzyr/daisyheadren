local function __NULL__() end

local state_init = setmetatable({ leave = __NULL__ }, {
    __index = function()
        error("Gamestate not initialized. Use Gamestate.switch()")
    end
})

local stack = { state_init }
local initialized_states = setmetatable({}, { __mode = "k" })
local state_is_dirty = true
local named_states = {}

local transition = {
    active = false,
    mode = "none",
    alpha = 0,
    time = 0,
    duration = 0.25,
    action = nil
}

---@class GS
local GS = {}

--- Creates a new bare state table.
--- @param t table? Optional table to use as the state.
--- @return table
function GS.new(t)
    return t or {}
end

--- Registers a named state from a module path. Required before switching to it.
--- @param name string Identifier used to reference the state.
--- @param path string Require path to the state module.
--- @return table
function GS.register(name, path)
    assert(type(name) == "string", "State name must be a string")
    assert(type(path) == "string", "State path must be a string")

    local state = require(path)

    assert(type(state) == "table", "Required state must return a table")

    state.__name = name
    state.__path = path
    named_states[name] = state

    return state
end

--- Returns a registered state by name.
--- @param name string
--- @return table
function GS.get(name)
    assert(named_states[name], "No state registered with name: " .. tostring(name))
    return named_states[name]
end

local function call(fn, ...)
    return (fn or __NULL__)(...)
end

local function change_state(stack_offset, to, ...)
    if type(to) == "string" then
        to = GS.get(to)
    end

    local pre = stack[#stack]

    call(initialized_states[to] or to.init, to)
    initialized_states[to] = __NULL__

    stack[#stack + stack_offset] = to
    state_is_dirty = true

    return call(to.enter, to, pre, ...)
end

local function start_transition(action, duration)
    if transition.active then return false end

    transition.active = true
    transition.mode = "out"
    transition.alpha = 0
    transition.time = 0
    transition.duration = duration or transition.duration
    transition.action = action

    return true
end

--- Switches to a new state, replacing the current one.
--- @param to table|string State table or registered name.
--- @param ... any Arguments passed to the state's enter callback.
function GS.switch(to, ...)
    assert(to, "Missing argument: Gamestate to switch to")
    assert(to ~= GS, "Can't call switch with colon operator")

    if stack[#stack] == state_init then
        return change_state(0, to, ...)
    end

    local args = { ... }

    return start_transition(function()
        call(stack[#stack].leave, stack[#stack])
        return change_state(0, to, unpack(args))
    end)
end

--- Reloads the current state from disk and switches to the fresh version.
function GS.reloadCurrent()
    local current = GS.current()

    package.loaded[current.__path] = nil

    local newState = require(current.__path)
    newState.__path = current.__path

    for name, state in pairs(named_states) do
        if state == current then
            named_states[name] = newState
            break
        end
    end

    return GS.switch(newState)
end

--- Pushes a new state onto the stack without removing the current one.
--- @param to table|string State table or registered name.
--- @param ... any Arguments passed to the state's enter callback.
function GS.push(to, ...)
    assert(to, "Missing argument: Gamestate to switch to")
    assert(to ~= GS, "Can't call push with colon operator")

    local args = { ... }

    return start_transition(function()
        return change_state(1, to, unpack(args))
    end)
end

--- Pops the current state and resumes the one below it.
--- @param ... any Arguments passed to the resumed state's resume callback.
function GS.pop(...)
    assert(#stack > 1, "No more states to pop!")

    local args = { ... }

    return start_transition(function()
        local pre = stack[#stack]
        local to = stack[#stack - 1]

        stack[#stack] = nil

        call(pre.leave, pre)

        state_is_dirty = true

        return call(to.resume, to, pre, unpack(args))
    end)
end

--- Pops states until the target state is reached and resumes it.
--- @param target table|string State table or registered name.
--- @param ... any Arguments passed to the target state's resume callback.
function GS.popTo(target, ...)
    local args = { ... }

    return start_transition(function()
        if type(target) == "string" then
            target = GS.get(target)
        end

        while #stack > 1 and stack[#stack] ~= target do
            local pre = stack[#stack]
            stack[#stack] = nil
            call(pre.leave, pre)
        end

        assert(stack[#stack] == target, "Target state not found in stack")

        state_is_dirty = true

        return call(target.resume, target, unpack(args))
    end)
end

--- Returns the number of states currently on the stack.
--- @return number
function GS.stackSize()
    return #stack
end

--- Returns the currently active state.
--- @return table
function GS.current()
    return stack[#stack]
end

--- Returns true if the given state is currently active.
--- @param state table|string State table or registered name.
--- @return boolean
function GS.isActive(state)
    if type(state) == "string" then
        state = named_states[state]
    end
    return stack[#stack] == state
end

--- Clears the entire stack and optionally switches to a new state.
--- @param to table|string? State to switch to after clearing.
--- @param ... any Arguments passed to the new state's enter callback.
function GS.clearStack(to, ...)
    while #stack > 1 do
        local s = table.remove(stack)
        call(s.leave, s)
    end

    if to then
        return GS.switch(to, ...)
    end
end

--- Returns true if a transition is currently in progress.
--- @return boolean
function GS.isTransitioning()
    return transition.active
end

--- Sets the default fade transition duration.
--- @param duration number Duration in seconds.
function GS.setTransitionDuration(duration)
    transition.duration = duration or transition.duration
end

--- Updates the active state and any running transition. Call in love.update(dt).
--- @param dt number Delta time.
function GS.update(dt)
    if transition.active then
        transition.time = transition.time + dt

        local progress = math.min(transition.time / transition.duration, 1)

        if transition.mode == "out" then
            transition.alpha = progress

            if progress >= 1 then
                if transition.action then
                    transition.action()
                    transition.action = nil
                end

                transition.mode = "in"
                transition.time = 0
            end
        elseif transition.mode == "in" then
            transition.alpha = 1 - progress

            if progress >= 1 then
                transition.active = false
                transition.mode = "none"
                transition.alpha = 0
                transition.time = 0
            end
        end
    end

    if stack[#stack] ~= state_init then
        return call(stack[#stack].update, stack[#stack], dt)
    end
end

--- Draws the active state and any running fade transition overlay. Call in love.draw().
function GS.draw()
    if stack[#stack] ~= state_init then
        call(stack[#stack].draw, stack[#stack])
    end

    if transition.active then
        love.graphics.setColor(0, 0, 0, transition.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

--- Hooks GS callbacks into love's event handlers automatically.
--- @param callbacks table? List of callback names to register (default: all).
function GS.registerEvents(callbacks)
    local all_callbacks = { "draw", "update" }

    for k in pairs(love.handlers) do
        all_callbacks[#all_callbacks + 1] = k
    end

    local registry = {}

    callbacks = callbacks or all_callbacks

    for _, f in ipairs(callbacks) do
        registry[f] = love[f] or __NULL__

        love[f] = function(...)
            registry[f](...)
            return GS[f](...)
        end
    end
end

local function_cache = {}

setmetatable(GS, {
    __index = function(_, func)
        if not state_is_dirty or func == "update" then
            state_is_dirty = false

            function_cache[func] = function_cache[func] or function(...)
                return call(stack[#stack][func], stack[#stack], ...)
            end

            return function_cache[func]
        end

        return __NULL__
    end
})

return GS
