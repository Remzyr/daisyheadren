local InputAction = require("input.inputaction")

---@class Keyboard
---@field binds table Map of action names to key bindings.
---@field gamepadBinds table Map of action names to gamepad button bindings.
---@field pressed table Keys pressed this frame.
---@field released table Keys released this frame.
---@field gamepadPressed table Gamepad buttons pressed this frame.
---@field gamepadReleased table Gamepad buttons released this frame.
---@field deadzone number Analog stick deadzone threshold (default 0.35).
local Keyboard = {}

Keyboard.binds = {
    up     = { "up", "w" },
    down   = { "down", "s" },
    left   = { "left", "a" },
    right  = { "right", "d" },
    accept = { "return", "space", "z" },
    back   = { "escape", "backspace", "x" },
    reload = { "f5" }
}

Keyboard.gamepadBinds = {
    up     = { "dpup" },
    down   = { "dpdown" },
    left   = { "dpleft" },
    right  = { "dpright" },
    accept = { "a", "start" },
    back   = { "b", "back" }
}

Keyboard.pressed = {}
Keyboard.released = {}
Keyboard.gamepadPressed = {}
Keyboard.gamepadReleased = {}
Keyboard.deadzone = 0.35

-- sync binds into InputAction on init
for action, keys in pairs(Keyboard.binds) do
    InputAction.define(action, keys)
end

--- Clears per-frame pressed and released state. Call at the end of love.update.
function Keyboard.update()
    Keyboard.pressed = {}
    Keyboard.released = {}
    Keyboard.gamepadPressed = {}
    Keyboard.gamepadReleased = {}
    InputAction.flush()
end

--- Call in love.keypressed.
--- @param key string
function Keyboard.keypressed(key)
    Keyboard.pressed[key] = true
    InputAction.keypressed(key)
end

--- Call in love.keyreleased.
--- @param key string
function Keyboard.keyreleased(key)
    Keyboard.released[key] = true
    InputAction.keyreleased(key)
end

--- Call in love.gamepadpressed.
--- @param joystick love.Joystick
--- @param button string
function Keyboard.gamepadpressed(joystick, button)
    Keyboard.gamepadPressed[button] = true
end

--- Call in love.gamepadreleased.
--- @param joystick love.Joystick
--- @param button string
function Keyboard.gamepadreleased(joystick, button)
    Keyboard.gamepadReleased[button] = true
end

--- Returns true if any key or gamepad button bound to the action is held.
--- @param action string
--- @return boolean
function Keyboard.down(action)
    for _, key in ipairs(Keyboard.binds[action] or {}) do
        if love.keyboard.isDown(key) then return true end
    end

    local joysticks = love.joystick.getJoysticks()

    for _, joystick in ipairs(joysticks) do
        for _, button in ipairs(Keyboard.gamepadBinds[action] or {}) do
            if joystick:isGamepadDown(button) then return true end
        end

        local lx = joystick:getGamepadAxis("leftx")
        local ly = joystick:getGamepadAxis("lefty")

        if action == "up"    and ly < -Keyboard.deadzone then return true end
        if action == "down"  and ly >  Keyboard.deadzone then return true end
        if action == "left"  and lx < -Keyboard.deadzone then return true end
        if action == "right" and lx >  Keyboard.deadzone then return true end
    end

    return false
end

--- Returns true if the action was just pressed this frame.
--- Also checks InputAction for any extra bindings added at runtime.
--- @param action string
--- @return boolean
function Keyboard.justPressed(action)
    for _, key in ipairs(Keyboard.binds[action] or {}) do
        if Keyboard.pressed[key] then return true end
    end

    for _, button in ipairs(Keyboard.gamepadBinds[action] or {}) do
        if Keyboard.gamepadPressed[button] then return true end
    end

    return InputAction.pressed(action)
end

--- Returns true if the action was just released this frame.
--- Also checks InputAction for any extra bindings added at runtime.
--- @param action string
--- @return boolean
function Keyboard.justReleased(action)
    for _, key in ipairs(Keyboard.binds[action] or {}) do
        if Keyboard.released[key] then return true end
    end

    for _, button in ipairs(Keyboard.gamepadBinds[action] or {}) do
        if Keyboard.gamepadReleased[button] then return true end
    end

    return InputAction.released(action)
end

--- Replaces the key bindings for an action and syncs with InputAction.
--- @param action string
--- @param keys table List of love key constants.
function Keyboard.bind(action, keys)
    Keyboard.binds[action] = keys
    InputAction.rebind(action, keys)
end

--- Replaces the gamepad button bindings for an action.
--- @param action string
--- @param buttons table List of gamepad button constants.
function Keyboard.bindGamepad(action, buttons)
    Keyboard.gamepadBinds[action] = buttons
end

return Keyboard
