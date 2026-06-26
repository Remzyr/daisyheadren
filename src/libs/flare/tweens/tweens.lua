---@class Tweens
local Tweens = {}

Tweens.list = {}

local function lerp(a, b, t)
    return a + (b - a) * t
end

local eases = {
    linear = function(t)
        return t
    end,

    outQuad = function(t)
        return 1 - (1 - t) * (1 - t)
    end,

    inQuad = function(t)
        return t * t
    end,

    inOutQuad = function(t)
        if t < 0.5 then return 2 * t * t end
        return 1 - math.pow(-2 * t + 2, 2) / 2
    end,

    expoIn = function(t)
        return t == 0 and 0 or math.pow(2, 10 * t - 10)
    end,

    expoOut = function(t)
        return t == 1 and 1 or 1 - math.pow(2, -10 * t)
    end,

    quartIn = function(t)
        return t * t * t * t
    end,

    quartOut = function(t)
        return 1 - math.pow(1 - t, 4)
    end,

    sineIn = function(t)
        return 1 - math.cos((t * math.pi) / 2)
    end,

    sineOut = function(t)
        return math.sin((t * math.pi) / 2)
    end,

    bounceOut = function(t)
        local n1, d1 = 7.5625, 2.75
        if t < 1 / d1 then
            return n1 * t * t
        elseif t < 2 / d1 then
            t = t - 1.5 / d1
            return n1 * t * t + 0.75
        elseif t < 2.5 / d1 then
            t = t - 2.25 / d1
            return n1 * t * t + 0.9375
        else
            t = t - 2.625 / d1
            return n1 * t * t + 0.984375
        end
    end,

    bounceIn = function(t)
        local n1, d1 = 7.5625, 2.75
        t = 1 - t
        if t < 1 / d1 then
            return 1 - n1 * t * t
        elseif t < 2 / d1 then
            t = t - 1.5 / d1
            return 1 - (n1 * t * t + 0.75)
        elseif t < 2.5 / d1 then
            t = t - 2.25 / d1
            return 1 - (n1 * t * t + 0.9375)
        else
            t = t - 2.625 / d1
            return 1 - (n1 * t * t + 0.984375)
        end
    end,

    elasticOut = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * (2 * math.pi) / 3) + 1
    end,

    elasticIn = function(t)
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * (2 * math.pi) / 3)
    end,

    backIn = function(t)
        local c1, c3 = 1.70158, 1.70158 + 1
        return c3 * t * t * t - c1 * t * t
    end,

    backOut = function(t)
        local c1, c3 = 1.70158, 1.70158 + 1
        return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
    end,
}

--- Starts a tween on a target table.
--- @param target table The object whose fields will be tweened
--- @param duration number Duration in seconds
--- @param values table Key/value pairs of fields to tween to
--- @param ease string? Name of the easing function (default "linear")
--- @param onComplete function? Callback fired when the tween finishes
--- @return table the Tween handle
function Tweens.to(target, duration, values, ease, onComplete)
    local tween = {
        target     = target,
        duration   = duration or 1,
        time       = 0,
        values     = values,
        start      = {},
        ease       = eases[ease or "linear"] or eases.linear,
        onComplete = onComplete,
        finished   = false,
        paused     = false,
    }

    for key in pairs(values) do
        tween.start[key] = target[key]
    end

    table.insert(Tweens.list, tween)
    return tween
end

--- Updates all active tweens. call this in love.update(dt).
--- @param dt number delta time
function Tweens.update(dt)
    for i = #Tweens.list, 1, -1 do
        local tween = Tweens.list[i]

        if not tween.paused then
            tween.time = tween.time + dt

            local t      = math.min(tween.time / tween.duration, 1)
            local eased  = tween.ease(t)

            for key, value in pairs(tween.values) do
                local start = tween.start[key]

                if type(value) == "table" then
                    tween.target[key] = tween.target[key] or {}
                    for j = 1, #value do
                        tween.target[key][j] = lerp(start[j], value[j], eased)
                    end
                else
                    tween.target[key] = lerp(start, value, eased)
                end
            end

            if t >= 1 then
                tween.finished = true
                if tween.onComplete then tween.onComplete() end
                table.remove(Tweens.list, i)
            end
        end
    end
end

--- Cancels a specific tween.
--- @param tween table The tween handle returned by Tweens.to
--- @return boolean true IF found and removed
function Tweens.cancel(tween)
    for i = #Tweens.list, 1, -1 do
        if Tweens.list[i] == tween then
            table.remove(Tweens.list, i)
            return true
        end
    end
    return false
end

--- Pauses a tween so it stops updating until resumed.
--- @param tween table
function Tweens.pause(tween)
    tween.paused = true
end

--- Resumes a paused tween.
--- @param tween table
function Tweens.resume(tween)
    tween.paused = false
end

--- Cancels all tweens on a specific target.
--- @param target table
function Tweens.cancelTarget(target)
    for i = #Tweens.list, 1, -1 do
        if Tweens.list[i].target == target then
            table.remove(Tweens.list, i)
        end
    end
end

--- Returns true if a tween is still active.
--- @param tween table
--- @return boolean
function Tweens.isActive(tween)
    for i = 1, #Tweens.list do
        if Tweens.list[i] == tween then return true end
    end
    return false
end

--- Removes all active tweens.
function Tweens.clear()
    Tweens.list = {}
end

return Tweens
