---@class Locale
---@field _strings table The loaded string table for the current locale.
---@field _fallback table The fallback string table used when a key is missing.
---@field _current string The active locale identifier.
local Locale = {}

Locale._strings = {}
Locale._fallback = {}
Locale._current = "en"

--- Loads a string table for a locale identifier.
--- The data should be a flat or nested table of string keys to translated strings.
--- @param id string Locale identifier, e.g. "en" or "ar".
--- @param data table String table.
function Locale.load(id, data)
    Locale._strings = data
    Locale._current = id
end

--- Sets a fallback string table used when a key is not found in the active locale.
--- @param data table Fallback string table.
function Locale.setFallback(data)
    Locale._fallback = data
end

--- Returns the translated string for a key.
--- Supports dot-separated nested keys like "menu.play".
--- Falls back to the fallback table, then returns the key itself if not found.
--- @param key string
--- @param ... any Optional values interpolated into the string via string.format.
--- @return string
function Locale.get(key, ...)
    local function resolve(tbl, k)
        local current = tbl
        for part in k:gmatch("[^%.]+") do
            if type(current) ~= "table" then return nil end
            current = current[part]
        end
        return type(current) == "string" and current or nil
    end

    local str = resolve(Locale._strings, key)
        or resolve(Locale._fallback, key)
        or key

    if select("#", ...) > 0 then
        return string.format(str, ...)
    end

    return str
end

--- Shortcut for Locale.get.
--- @param key string
--- @param ... any
--- @return string
function Locale.t(key, ...)
    return Locale.get(key, ...)
end

--- Returns the active locale identifier.
--- @return string
function Locale.current()
    return Locale._current
end

--- Returns true if the given key exists in the active locale or fallback.
--- @param key string
--- @return boolean
function Locale.has(key)
    return Locale.get(key) ~= key
end

return Locale
