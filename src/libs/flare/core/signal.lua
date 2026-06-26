---@class Signal
---@field _listeners table List of registered listener functions.
local Signal = {}
Signal.__index = Signal

--- Creates a new Signal instance.
--- @return Signal
function Signal.new()
    local self = setmetatable({}, Signal)
    self._listeners = {}
    return self
end

--- Registers a listener function to this signal.
--- @param fn function Called when the signal is emitted.
--- @return function The listener, for use with off().
function Signal:on(fn)
    table.insert(self._listeners, fn)
    return fn
end

--- Registers a listener that fires only once then removes itself.
--- @param fn function
function Signal:once(fn)
    local wrapper
    wrapper = function(...)
        fn(...)
        self:off(wrapper)
    end
    self:on(wrapper)
end

--- Removes a registered listener.
--- @param fn function The listener to remove.
function Signal:off(fn)
    for i = #self._listeners, 1, -1 do
        if self._listeners[i] == fn then
            table.remove(self._listeners, i)
            return
        end
    end
end

--- Emits the signal, calling all registered listeners with the given arguments.
--- @param ... any Arguments forwarded to each listener.
function Signal:emit(...)
    for i = 1, #self._listeners do
        self._listeners[i](...)
    end
end

--- Removes all listeners from this signal.
function Signal:clear()
    self._listeners = {}
end

--- Returns the number of registered listeners.
--- @return number
function Signal:count()
    return #self._listeners
end

return Signal