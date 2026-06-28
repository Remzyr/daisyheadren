local flare = require("flare.flare")
local Sprite = flare.sprite
local Text = flare.text
local Keyboard = flare.keyboard
local Trippy = flare.Shader
local MainMenu = {}
local logo
local logo
local title
local theme
local bg = flare.sprite
local daisyroute = false -- daisy route check, this is an important switch to the game, please don't touch it unless moving to a better place

function MainMenu:enter()
    theme = love.audio.newSource("src/daisy/audio/mainmenu.mp3", "stream")
    local font = love.graphics.newFont("src/daisy/fonts/daisy.ttf", 32)
    Trippy = Shader.new("src/daisy/shaders/trippy.glsl")
   -- Trippy:send("color_freq", 0.05)
--     Trippy:send("color_speed", -0.1)
   -- Trippy:send("color_speed", -0.1)
    if(daisyroute==true) then
        theme:setPitch(0.2)
        logo = Sprite.new(0, 0, "src/daisy/menu/_/daisyroute.png")
        logo:setScale(0.5)
      logo:screenCenter("xy")
        love.graphics.clear(0.05, 0.05, 0.1, 1)
        theme:setVolume(0.8)
        title = Text.new(0, 0, "PLAY GAME", font)
    else
   
    logo = Sprite.new(0, 0, "src/daisy/menu/Logo.png")
    logo:setScale(0.7)
    logo:screenCenter("xy")
    theme:setVolume(0.5)
    title = Text.new(0, 0, "PLAY GAME", font)

    end
end

function MainMenu:update(dt)
    local t = love.timer.getTime()
    local sw, sh = love.graphics.getDimensions()

    logo:screenCenter("x")
    logo.y = sh * 0.3
    logo:update(dt)

    --if (daisyroute==true) then 
    --title:shakeWave(t, 5, 0.2)
   -- else 
   title:shakeWave(t, 1.5, 5)
   -- end

    local textW = title.font:getWidth(title.text)
    title.x = (sw - textW) / 2
    title.y = sh * 0.7

    if Keyboard.justPressed("accept") then
        print("Switching to game...")
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