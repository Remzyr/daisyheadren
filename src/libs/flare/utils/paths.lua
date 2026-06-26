local Assets = require("data.assets")

local Paths = {}

Paths.root = "assets"

Paths.currentLibrary = nil

Paths.extensions = {
    image = ".png",
    sound = ".ogg",
    voice = ".wav",
    music = ".ogg",
    data = ".json",
    shader = ".glsl",
    video = ".ogv"
}

---Cleans the Path.
---@param path string
---@return string
local function cleanPath(path)
    path = path:gsub("\\", "/")
    path = path:gsub("^/", "")
    return path
end

local function withExtension(path, ext)
    if path:sub(-#ext) ~= ext then
        return path .. ext
    end

    return path
end
---Gets path of a certain file in the assets
---@param folder string
---@param key string
---@param ext string
---@return string
local function getPath(folder, key, ext)
    key = cleanPath(key)

    if ext then
        key = withExtension(key, ext)
    end

    local path

    if Paths.currentLibrary then
        path = Paths.root .. "/" .. Paths.currentLibrary .. "/" .. folder .. "/" .. key

        if Assets.exists(path) then
            return path
        end
    end

    path = Paths.root .. "/" .. folder .. "/" .. key

    return path
end

function Paths.setLibrary(library)
    Paths.currentLibrary = library
end

function Paths.clearLibrary()
    Paths.currentLibrary = nil
end

function Paths.image(key)
    return Assets.image(getPath("images", key, Paths.extensions.image))
end

function Paths.sound(key)
    return Assets.sound(getPath("sounds", key, Paths.extensions.sound))
end

function Paths.voice(key)
    return Assets.sound(getPath("sounds/characters", key, Paths.extensions.voice))
end

function Paths.music(key)
    return Assets.sound(getPath("music", key, Paths.extensions.music), "stream")
end

function Paths.video(key)
    return Assets.video(getPath("video", key, Paths.extensions.video))
end

local _fontDebugDone = false

function Paths.font(key, size)
    if not key or key == nil then
        return Assets.defaultFont(size)
    end

    local ttfPath = getPath("fonts", key, ".ttf")
    if Assets.exists(ttfPath) then
        return Assets.font(ttfPath, size)
    end

    return Assets.font(getPath("fonts", key, ".otf"), size)
end

function Paths.shader(key)
    return Assets.shader(getPath("shaders", key, Paths.extensions.shader))
end

function Paths.data(key)
    return getPath("data", key, Paths.extensions.data)
end

function Paths.text(key)
    return Assets.text(getPath("data", key, ".txt"))
end

function Paths.read(path)
    return love.filesystem.read(path)
end

return Paths
