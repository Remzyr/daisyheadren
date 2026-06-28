local flare = require("flare.flare")
local Sprite = flare.sprite
local Text = flare.text
local Keyboard = flare.keyboard
local Sound = flare.sound
local Trippy
local canvas
local MainMenu = {}
local logo
local title
local theme
local daisyroute = false -- daisy route check, important switch, don't touch unless moving to a better place

function MainMenu:enter()
    theme = Sound.music("mainmenu")
    local font = Paths.font("daisy", 32)
    canvas = love.graphics.newCanvas()
    Trippy = love.graphics.newShader(Paths.shader("trippy"))
    Trippy:send("color_freq", 0.05)
    Trippy:send("color_speed", -0.1)
    Trippy:send("color_amp", 0.05)
    if daisyroute then
        theme:setPitch(0.2)
        theme:setVolume(0.8)
        logo = Sprite.new(0, 0, "assets/menu/_/daisyroute.png")
        logo:setScale(0.5)
        logo:screenCenter("xy")
    else
        theme:setVolume(0.5)
        logo = Sprite.new(0, 0, "assets/menu/Logo.png")
        logo:setScale(0.7)
        logo:screenCenter("xy")
    end

    title = Text.new(0, 0, "PLAY GAME", font)
end

function MainMenu:update(dt)
    local t = love.timer.getTime()
    local sw, sh = love.graphics.getDimensions()

    Trippy:send("iTime", t)
    Trippy:send("iResolution", {sw, sh})

    logo:screenCenter("x")
    logo.y = sh * 0.3
    logo:update(dt)

    title:shakeWave(t, 1.5, 5)

    local textW = title.font:getWidth(title.text)
    title.x = (sw - textW) / 2
    title.y = sh * 0.7

    if Keyboard.justPressed("accept") then
        print("Switching to game...")
    end

    Keyboard.update()
end

function MainMenu:draw()
    theme:play()

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.05, 0.05, 0.1, 1)
    logo:draw()
    title:draw()
    love.graphics.setCanvas()

    love.graphics.setShader(Trippy)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function MainMenu:keypressed(key)
    Keyboard.keypressed(key)
end

return MainMenu