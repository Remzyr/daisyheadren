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
Sprite = flare.sprite
---@type GS
Gamestate = flare.gamestate
---@type Save
Save = flare.save
---@type Keyboard
Keyboard = flare.keyboard
---@type Paths
Paths = flare.paths
local function registerStates(dir, prefix)
    prefix = prefix or ""
    local items = love.filesystem.getDirectoryItems(dir)
    for _, item in ipairs(items) do
        local path = dir .. "/" .. item
        local info = love.filesystem.getInfo(path)
        if info.type == "directory" then
            registerStates(path, prefix)
        elseif item:match("%.lua$") then
            local name = prefix .. item:gsub("%.lua$", "")
            local modpath = path:gsub("^states/", "states."):gsub("/", "."):gsub("%.lua$", "")
            Gamestate.register(name, modpath)
        end
    end
end

function love.load() 
    Save.init("daisyheadren")
    Save.load()
    -- u do whatever u want
    Save.data.settings = Save.data.settings or {
        fullscreen = false,
        volume = 100,
    }
    Save.data.checks = Save.data.checks or {
        daisyroute = false,
    }

    --[[
    if Save.get(checks).daisyroute == false then 
       print("tee ess")
    end
    ]]--

    registerStates("src/states")
    Gamestate.switch("mainmenu")

end

function love.update(dt)
    Gamestate.update(dt)
    Keyboard.update()

    if Keyboard.justPressed("reload") then
        Gamestate.reloadCurrent()
    end
end

function love.draw()
    Gamestate.draw()
end

function love.keypressed(key, scancode, isrepeat)
    Keyboard.keypressed(key)
end

function love.keyreleased(key)
    Keyboard.keyreleased(key)
end

function love.gamepadpressed(joystick, button)
    Keyboard.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    Keyboard.gamepadreleased(joystick, button)
end