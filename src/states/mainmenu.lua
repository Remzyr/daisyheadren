local flare = require("flare.flare")
local Sprite = flare.sprite
local Text = flare.text
local Keyboard = flare.keyboard
local Trippy
local MainMenu = {}
local logo
local title
local theme

function MainMenu:enter()
    Trippy = Shader.new("daisy/shaders/trippy.frag")
    Trippy:send("color_freq", 0.05)
    Trippy:send("color_speed", -0.1)
    Trippy:send("color_speed", -0.1)

    logo = Sprite.new(0, 0, "daisy/menu/Logo.png")
    logo:setScale(0.5)
    logo:screenCenter("xy")
    theme = love.audio.newSource("daisy/audio/mainmenu.mp3", "stream")
    theme:setVolume(0.5)
    local font = love.graphics.newFont("daisy/fonts/daisy.ttf", 32)
    title = Text.new(0, 0, "PLAY GAME", font)
end

function MainMenu:update(dt)
    local t = love.timer.getTime()
    local sw, sh = love.graphics.getDimensions()

    logo:screenCenter("x")
    logo.y = sh * 0.3
    logo:update(dt)

    
    title:shakeWave(t, 1.5, 5)

    local textW = title.font:getWidth(title.text)
    title.x = (sw - textW) / 2
    title.y = sh * 0.7

    if Keyboard.justPressed("accept") then
        print("yknow.")
        -- GS.switch("game")
    end

    Keyboard.update()
end

function MainMenu:draw()
    Trippy:apply()
    theme:play()
    love.graphics.clear(0.05, 0.05, 0.1, 1)
    logo:draw()
    title:draw()
end

function MainMenu:keypressed(key)
    Keyboard.keypressed(key)
end

return MainMenu