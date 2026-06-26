---@class Assets
local Assets = {}

Assets.images = {}
Assets.sounds = {}
Assets.fonts = {}
Assets.shaders = {}
Assets.data = {}
Assets.json = {}
Assets.videos = {}

Assets.imageFilter = {
    min = "nearest",
    mag = "nearest"
}

---Sets default image filter for loaded images.
---@param min string
---@param mag string
function Assets.setImageFilter(min, mag)
    Assets.imageFilter.min = min or "nearest"
    Assets.imageFilter.mag = mag or min or "nearest"
end

---Checks if a file exists.
---@param path string
---@return boolean
function Assets.exists(path)
    return love.filesystem.getInfo(path) ~= nil
end

---Loads and caches an image.
---@param path string
---@return love.Image
function Assets.image(path)
    if not Assets.images[path] then
        assert(Assets.exists(path), "Image not found: " .. path)

        local img = love.graphics.newImage(path)
        img:setFilter(Assets.imageFilter.min, Assets.imageFilter.mag)

        Assets.images[path] = img
    end

    return Assets.images[path]
end

---Loads and caches a sound source.
---@param path string
---@param sourceType? "static"|"stream"|"queue"
---@return love.Source
function Assets.sound(path, sourceType)
    sourceType = sourceType or "static"

    local key = path .. ":" .. sourceType

    if not Assets.sounds[key] then
        assert(Assets.exists(path), "Sound not found: " .. path)
        Assets.sounds[key] = love.audio.newSource(path, sourceType)
    end

    return Assets.sounds[key]
end

---Loads and caches a font.
---@param path string
---@param size? number
---@return love.Font
function Assets.font(path, size)
    size = size or 16
    local key = path .. ":" .. tostring(size)

    if not Assets.fonts[key] then
        assert(Assets.exists(path), "Font not found: " .. path)
        Assets.fonts[key] = love.graphics.newFont(path, size)
    end

    return Assets.fonts[key]
end

---Loads and caches the default LÖVE font.
---@param size? number
---@return love.Font
function Assets.defaultFont(size)
    size = size or 16
    local key = "default:" .. tostring(size)

    if not Assets.fonts[key] then
        Assets.fonts[key] = love.graphics.newFont(size)
    end

    return Assets.fonts[key]
end

---Loads and caches a shader.
---@param path string
---@return love.Shader
function Assets.shader(path)
    if not Assets.shaders[path] then
        assert(Assets.exists(path), "Shader not found: " .. path)
        Assets.shaders[path] = love.graphics.newShader(path)
    end

    return Assets.shaders[path]
end

---Reads and caches a text file.
---@param path string
---@return string
function Assets.text(path)
    if not Assets.data[path] then
        assert(Assets.exists(path), "Text file not found: " .. path)
        Assets.data[path] = love.filesystem.read(path)
    end

    return Assets.data[path]
end

---Loads and caches Lua data files.
---The file must return a table.
---@param path string
---@return table
function Assets.lua(path)
    if not Assets.data[path] then
        assert(Assets.exists(path), "Lua data file not found: " .. path)

        local chunk, err = love.filesystem.load(path)
        assert(chunk, err)

        Assets.data[path] = chunk()
    end

    return Assets.data[path]
end

---Loads and caches a video.
---@param path string
---@return love.Video
function Assets.video(path)
    if not Assets.videos[path] then
        assert(Assets.exists(path), "Video not found: " .. path)
        Assets.videos[path] = love.graphics.newVideo(path)
    end

    return Assets.videos[path]
end

---Loads and caches JSON data.
---Requires your fl.json module.
---@param path string
---@return table
function Assets.jsonData(path)
    if not Assets.json[path] then
        local Json = require("flare.data.json")
        Assets.json[path] = Json.decode(Assets.text(path))
    end

    return Assets.json[path]
end

---Returns raw file data.
---@param path string
---@return love.FileData
function Assets.fileData(path)
    assert(Assets.exists(path), "File not found: " .. path)
    return love.filesystem.newFileData(path)
end

---Creates a full asset path.
---@param folder string
---@param name string
---@param ext? string
---@return string
function Assets.path(folder, name, ext)
    if ext and not name:match("%." .. ext .. "$") then
        name = name .. "." .. ext
    end

    return folder .. "/" .. name
end

---Shortcut for assets/images.
---@param name string
---@return string
function Assets.imagePath(name)
    return Assets.path("assets/images", name, "png")
end

---Shortcut for assets/sounds.
---@param name string
---@return string
function Assets.soundPath(name)
    return Assets.path("assets/sounds", name, "ogg")
end

---Shortcut for assets/video.
---@param name string
---@return string
function Assets.videoPath(name)
    return Assets.path("assets/video", name, "ogv")
end

---Shortcut for assets/fonts.
---@param name string
---@return string
function Assets.fontPath(name)
    return Assets.path("assets/fonts", name, "ttf")
end

---Shortcut for assets/shaders.
---@param name string
---@return string
function Assets.shaderPath(name)
    return Assets.path("assets/shaders", name, "glsl")
end

---Safely loads an asset without crashing.
---@param loader fun(path:string):any
---@param path string
---@return boolean success
---@return any result
function Assets.try(loader, path)
    local ok, result = pcall(loader, path)
    return ok, result
end

---Unloads one cached asset.
---@param category "images"|"sounds"|"fonts"|"shaders"|"data"|"json"|"video"
---@param key string
function Assets.unload(category, key)
    if Assets[category] then
        Assets[category][key] = nil
    end
end

---Reloads a cached asset.
---@param category "images"|"sounds"|"fonts"|"shaders"|"data"|"json"|"video"
---@param key string
function Assets.reload(category, key)
    Assets.unload(category, key)
end

---Returns cache counts.
---@return table
function Assets.stats()
    local function count(tbl)
        local c = 0
        for _ in pairs(tbl) do
            c = c + 1
        end
        return c
    end

    return {
        images = count(Assets.images),
        sounds = count(Assets.sounds),
        fonts = count(Assets.fonts),
        shaders = count(Assets.shaders),
        data = count(Assets.data),
        json = count(Assets.json),
        video = count(Assets.videos)
    }
end

---Clears all cached assets.
function Assets.clear()
    Assets.images = {}
    Assets.sounds = {}
    Assets.fonts = {}
    Assets.shaders = {}
    Assets.data = {}
    Assets.json = {}
    Assets.videos = {}  -- was Assets.video
end

return Assets
