
--- @class Save
--- @field file string The filename used for the save file (default: "save.dat")
--- @field data table The current in-memory save data
local Save = {}
Save.file = "save.dat"
Save.data = {}

local secret = nil

local function serialize(v)
    local t = type(v)
    if t == "number" or t == "boolean" then return tostring(v) end
    if t == "string" then return string.format("%q", v) end
    if t == "table" then
        local out = "{"
        for k, val in pairs(v) do
            local key = type(k) == "string"
                and "[" .. string.format("%q", k) .. "]"
                or  "[" .. tostring(k) .. "]"
            out = out .. key .. "=" .. serialize(val) .. ","
        end
        return out .. "}"
    end
    return "nil"
end

local function sign(raw)
    assert(secret, "save: call Save.init(key) before using save/load")
    return love.data.encode("string", "hex", love.data.hash("sha256", raw .. secret))
end

local function wipe()
    Save.data = {}
    Save.save()
end

--- Initializes the save system with a secret key and optional filename.
--- Must be called before Save.save() or Save.load().
--- @param key string Secret key used to sign save data
--- @param filename string? Optional save file name (default: "save.dat")
function Save.init(key, filename)
    assert(type(key) == "string" and #key > 0, "save: key must be a non-empty string")
    secret = key
    if filename then Save.file = filename end
end

--- serializes and writes Save.data to disk, signed with the secret key.
function Save.save()
    local raw    = serialize(Save.data)
    local packed = love.data.encode("string", "base64", raw .. "\n" .. sign(raw))
    love.filesystem.write(Save.file, packed)
end

--- Loads and verifies save data from disk into Save.data.
--- Wipes and resets to an empty table if the file is missing, corrupted, or tampered with.
function Save.load()
    if not love.filesystem.getInfo(Save.file) then
        wipe(); return
    end

    local packed = love.filesystem.read(Save.file)

    local ok, decoded = pcall(love.data.decode, "string", "base64", packed)
    if not ok or not decoded then wipe(); return end

    local raw, sig = decoded:match("^(.-)\n([a-fA-F0-9]+)$")
    if not raw or sig ~= sign(raw) then wipe(); return end

    local chunk = load("return " .. raw)
    if not chunk then wipe(); return end

    local success, loaded = pcall(chunk)
    if not success or type(loaded) ~= "table" then wipe(); return end

    Save.data = loaded
end

--- Sets a key in Save.data and immediately persists to disk.
--- @param k string key to set
--- @param v any value to store
function Save.set(k, v)
    Save.data[k] = v
    Save.save()
end

--- Gets a value from Save.data by key.
--- @param k string Key to retrieve
--- @return any
function Save.get(k)
    return Save.data[k]
end

--- Wipes all save data and writes an empty table to disk.
function Save.reset()
    wipe()
end

return Save
