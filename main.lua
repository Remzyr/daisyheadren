if arg[2] == "debug" then
    require("lldebugger").start()
end

table.insert(package.loaders, 1, function(modname)
    local path = modname:gsub("%.", "/") .. ".lua"
    local paths = {
        path,
        "src/libs/flare/" .. path,
        "src/libs/" .. path,
    }
    for _, p in ipairs(paths) do
        if love.filesystem.getInfo(p) then
            return function()
                return love.filesystem.load(p)(modname)
            end
        end
    end
end)
local flare = require("flare.flare")
local Sprite = flare.sprite

local logo

function love.load()
    logo = Sprite.new(0, 0, "daisy/img/Logo.png")
    logo:setScale(0.5)
end

function love.update(dt)
    logo:screenCenter(x)
    logo:update(dt)
end

function love.draw()
    logo:draw()
end