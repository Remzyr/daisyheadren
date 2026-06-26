--- @class Math
local Math = {}

---Used to account for floating-point inaccuracies.
Math.EPLISON = 0.0000001
Math.AVOGADROS_NUMBER = 6.022*10^23

--- Wraps a value within a [min, max] range (inclusive).
--- @param val number
--- @param min number
--- @param max number
--- @return number
function Math.wrap(val, min, max)
    local range = max - min + 1
    if val < min then
        val = val + range * (min - val) / range + 1
    end
    return min + (val - min) % range
end

--- Clamps a value between min and max.
--- @param val number
--- @param min number
--- @param max number
--- @return number
function Math.clamp(val, min, max)
    return val < min and min or (val > max and max or val)
end

--- Linearly interpolates between a and b by t.
--- @param a number
--- @param b number
--- @param t number between 0 and 1
--- @return number
function Math.lerp(a, b, t)
    return a + (b - a) * t
end

--- Returns the linear interpolation factor t given a value between a and b.
--- @param a number
--- @param b number
--- @param val number
--- @return number
function Math.inverseLerp(a, b, val)
    if a == b then return 0 end
    return (val - a) / (b - a)
end

--- Remaps a value from one range to another.
--- @param val number
--- @param inMin number
--- @param inMax number
--- @param outMin number
--- @param outMax number
--- @return number
function Math.remap(val, inMin, inMax, outMin, outMax)
    return outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin)
end

--- returns the sign of a number: 1, -1, or 0.
--- @param val number
--- @return number
function Math.sign(val)
    if val > 0 then return 1
    elseif val < 0 then return -1
    else return 0 end
end

--- rounds a number to the nearest integer, or to a given decimal place.
--- @param val number
--- @param decimals number? defaults to 0
--- @return number
function Math.round(val, decimals)
    local m = 10 ^ (decimals or 0)
    return math.floor(val * m + 0.5) / m
end

--- Returns true if val is within tolerance of target.
--- @param val number
--- @param target number
--- @param tolerance number
--- @return boolean
function Math.approx(val, target, tolerance)
    return math.abs(val - target) <= tolerance
end

--- Approaches target from current by step, without overshooting.
--- @param current number
--- @param target number
--- @param step number
--- @return number
function Math.approach(current, target, step)
    if current < target then
        return math.min(current + step, target)
    else
        return math.max(current - step, target)
    end
end

--- Returns the distance between two points.
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Math.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

--- Returns the squared distance between two points (cheaper than distance).
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Math.distanceSq(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

--- Returns the angle in radians from point 1 to point 2.
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function Math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

--- Checks if two axis-aligned rectangles overlap.
--- @param x1 number
--- @param y1 number
--- @param w1 number
--- @param h1 number
--- @param x2 number
--- @param y2 number
--- @param w2 number
--- @param h2 number
--- @return boolean
function Math.rectOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x1 + w1 > x2
       and y1 < y2 + h2 and y1 + h1 > y2
end

--- Returns true if a point is inside an axis-aligned rectangle.
--- @param px number
--- @param py number
--- @param rx number
--- @param ry number
--- @param rw number
--- @param rh number
--- @return boolean
function Math.pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw
       and py >= ry and py <= ry + rh
end

--- Returns true if a point is inside a circle.
--- @param px number
--- @param py number
--- @param cx number
--- @param cy number
--- @param radius number
--- @return boolean
function Math.pointInCircle(px, py, cx, cy, radius)
    return Math.distanceSq(px, py, cx, cy) <= radius * radius
end

--- Returns a Random number between `min` and `max` number.
---@param min number
---@param max number
function Math.rand(min, max)
    return min + love.math.random() * (max - min)
end

return Math
