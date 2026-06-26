local flare = require("flare.flare")
local Sprite = flare.sprite
local Text = flare.text
local Keyboard = flare.keyboard

local MainMenu = {}
local logo
local title

function MainMenu:enter()
    logo = Sprite.new(0, 0, "daisy/menu/Logo.png")
    logo:setScale(0.5)
    logo:screenCenter("xy")

    local font = love.graphics.newFont("daisy/fonts/daisy.ttf", 32)
    title = Text.new(0, 0, "Press Start", font)
end

function MainMenu:update(dt)
    local t = love.timer.getTime()
    local sw, sh = love.graphics.getDimensions()

    logo:screenCenter("x")
    logo.y = sh * 0.3
    logo:update(dt)

    title:wobble(t, 0.2, 5)
    title:shakeWave(t, 3, 7)

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
    love.graphics.clear(0.05, 0.05, 0.1, 1)
    logo:draw()
    title:draw()
end

function MainMenu:keypressed(key)
    Keyboard.keypressed(key)
end

return MainMenu