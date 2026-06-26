---@class InputAction
---@field _actions table Map of action names to their bindings and state.
local InputAction = {}

InputAction._actions = {}

--- Defines a new input action with a list of key bindings.
--- @param name string Action name.
--- @param keys table List of love key constants bound to this action.
function InputAction.define(name, keys)
    InputAction._actions[name] = {
        keys = keys,
        pressed = false,
        released = false,
        down = false,
    }
end

--- Returns true if the action was just pressed this frame.
--- @param name string
--- @return boolean
function InputAction.pressed(name)
    local action = InputAction._actions[name]
    return action and action.pressed or false
end

--- Returns true if the action was just released this frame.
--- @param name string
--- @return boolean
function InputAction.released(name)
    local action = InputAction._actions[name]
    return action and action.released or false
end

--- Returns true if any bound key is currently held down.
--- @param name string
--- @return boolean
function InputAction.down(name)
    local action = InputAction._actions[name]
    return action and action.down or false
end

--- Adds a key binding to an existing action.
--- @param name string
--- @param key string love key constant.
function InputAction.bind(name, key)
    local action = InputAction._actions[name]
    if action then
        table.insert(action.keys, key)
    end
end

--- Removes a key binding from an action.
--- @param name string
--- @param key string
function InputAction.unbind(name, key)
    local action = InputAction._actions[name]
    if not action then return end
    for i = #action.keys, 1, -1 do
        if action.keys[i] == key then
            table.remove(action.keys, i)
            return
        end
    end
end

--- Replaces all bindings for an action.
--- @param name string
--- @param keys table New list of key constants.
function InputAction.rebind(name, keys)
    local action = InputAction._actions[name]
    if action then
        action.keys = keys
    end
end

--- Call this in love.keypressed to update pressed state.
--- @param key string
function InputAction.keypressed(key)
    for _, action in pairs(InputAction._actions) do
        for _, k in ipairs(action.keys) do
            if k == key then
                action.pressed = true
                action.down = true
            end
        end
    end
end

--- Call this in love.keyreleased to update released state.
--- @param key string
function InputAction.keyreleased(key)
    for _, action in pairs(InputAction._actions) do
        for _, k in ipairs(action.keys) do
            if k == key then
                action.released = true
                action.down = false
            end
        end
    end
end

--- Clears pressed and released states. Call at the end of love.update.
function InputAction.flush()
    for _, action in pairs(InputAction._actions) do
        action.pressed = false
        action.released = false
    end
end

--- Removes a defined action entirely.
--- @param name string
function InputAction.remove(name)
    InputAction._actions[name] = nil
end

--- Returns a list of all defined action names.
--- @return table
function InputAction.list()
    local names = {}
    for name in pairs(InputAction._actions) do
        table.insert(names, name)
    end
    return names
end

return InputAction
