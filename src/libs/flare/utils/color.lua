---@class Color
local Color = {}

--- Creates a color table from RGBA values in the 0..1 range.
--- @param r number
--- @param g number
--- @param b number
--- @param a number? Alpha (default 1).
--- @return table
function Color.new(r, g, b, a)
    return { r = r, g = g, b = b, a = a or 1 }
end

--- Creates a color from 0..255 RGBA values.
--- @param r number
--- @param g number
--- @param b number
--- @param a number? Alpha 0..255 (default 255).
--- @return table
function Color.fromBytes(r, g, b, a)
    return Color.new(r / 255, g / 255, b / 255, (a or 255) / 255)
end

--- Creates a color from a hex string like "#ff8800" or "ff8800".
--- @param hex string
--- @return table
function Color.fromHex(hex)
    hex = hex:gsub("^#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    local a = #hex == 8 and tonumber(hex:sub(7, 8), 16) / 255 or 1
    return Color.new(r, g, b, a)
end

--- Converts a color to a hex string like "ff8800".
--- @param color table
--- @param includeAlpha boolean? If true, appends the alpha channel (default false).
--- @return string
function Color.toHex(color, includeAlpha)
    local r = math.floor(color.r * 255 + 0.5)
    local g = math.floor(color.g * 255 + 0.5)
    local b = math.floor(color.b * 255 + 0.5)
    if includeAlpha then
        local a = math.floor((color.a or 1) * 255 + 0.5)
        return string.format("%02x%02x%02x%02x", r, g, b, a)
    end
    return string.format("%02x%02x%02x", r, g, b)
end

--- Creates a color from HSL values. H is 0..360, S and L are 0..1.
--- @param h number Hue 0..360.
--- @param s number Saturation 0..1.
--- @param l number Lightness 0..1.
--- @param a number? Alpha (default 1).
--- @return table
function Color.fromHSL(h, s, l, a)
    h = h / 360
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue(p, q, h + 1/3)
        g = hue(p, q, h)
        b = hue(p, q, h - 1/3)
    end

    return Color.new(r, g, b, a or 1)
end

--- Converts a color to HSL. Returns h (0..360), s (0..1), l (0..1).
--- @param color table
--- @return number, number, number
function Color.toHSL(color)
    local r, g, b = color.r, color.g, color.b
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local l = (max + min) / 2
    local h, s = 0, 0

    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)

        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end

        h = h / 6
    end

    return h * 360, s, l
end

--- Linearly interpolates between two colors.
--- @param a table
--- @param b table
--- @param t number 0..1
--- @return table
function Color.lerp(a, b, t)
    return Color.new(
        a.r + (b.r - a.r) * t,
        a.g + (b.g - a.g) * t,
        a.b + (b.b - a.b) * t,
        (a.a or 1) + ((b.a or 1) - (a.a or 1)) * t
    )
end

--- Returns a copy of the color with a different alpha.
--- @param color table
--- @param a number Alpha 0..1.
--- @return table
function Color.withAlpha(color, a)
    return Color.new(color.r, color.g, color.b, a)
end

--- Sets the current love graphics color from a color table.
--- @param color table
function Color.set(color)
    love.graphics.setColor(color.r, color.g, color.b, color.a or 1)
end

--- Resets the love graphics color to opaque white.
function Color.reset()
    love.graphics.setColor(1, 1, 1, 1)
end

-- common presets
Color.WHITE = Color.new(1, 1, 1)
Color.BLACK = Color.new(0, 0, 0)
Color.RED = Color.new(1, 0, 0)
Color.GREEN = Color.new(0, 1, 0)
Color.BLUE = Color.new(0, 0, 1)
Color.YELLOW = Color.new(1, 1, 0)
Color.CYAN = Color.new(0, 1, 1)
Color.MAGENTA = Color.new(1, 0, 1)
Color.TRANSPARENT = Color.new(0, 0, 0, 0)

return Color
