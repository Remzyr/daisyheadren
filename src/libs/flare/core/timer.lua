---@class Timer
local Timer = {}

Timer._timers = {}

--- Fires a callback once after a delay.
--- @param delay number Seconds to wait.
--- @param callback function Called when the timer fires.
--- @return table The timer handle.
function Timer.after(delay, callback)
    local t = {
        delay = delay,
        elapsed = 0,
        callback = callback,
        loop = false,
        active = true,
        paused = false,
    }
    table.insert(Timer._timers, t)
    return t
end

--- Fires a callback repeatedly at a given interval.
--- @param interval number Seconds between each call.
--- @param callback function Called on each interval.
--- @param times number? Max number of times to fire (nil means infinite).
--- @return table The timer handle.
function Timer.every(interval, callback, times)
    local t = {
        delay = interval,
        elapsed = 0,
        callback = callback,
        loop = true,
        times = times,
        fired = 0,
        active = true,
        paused = false,
    }
    table.insert(Timer._timers, t)
    return t
end

--- Updates all active timers. Call in love.update(dt).
--- @param dt number Delta time.
function Timer.update(dt)
    for i = #Timer._timers, 1, -1 do
        local t = Timer._timers[i]

        if t.active and not t.paused then
            t.elapsed = t.elapsed + dt

            while t.elapsed >= t.delay do
                t.elapsed = t.elapsed - t.delay
                t.callback()

                if t.loop then
                    if t.times then
                        t.fired = t.fired + 1
                        if t.fired >= t.times then
                            t.active = false
                            break
                        end
                    end
                else
                    t.active = false
                    break
                end
            end

            if not t.active then
                table.remove(Timer._timers, i)
            end
        end
    end
end

--- Cancels a timer so it never fires.
--- @param handle table The timer handle returned by after or every.
function Timer.cancel(handle)
    handle.active = false
    for i = #Timer._timers, 1, -1 do
        if Timer._timers[i] == handle then
            table.remove(Timer._timers, i)
            return
        end
    end
end

--- Pauses a timer.
--- @param handle table
function Timer.pause(handle)
    handle.paused = true
end

--- Resumes a paused timer.
--- @param handle table
function Timer.resume(handle)
    handle.paused = false
end

--- Resets a timer's elapsed time back to zero.
--- @param handle table
function Timer.reset(handle)
    handle.elapsed = 0
    if handle.fired then handle.fired = 0 end
end

--- Cancels all active timers.
function Timer.clear()
    Timer._timers = {}
end

return Timer
