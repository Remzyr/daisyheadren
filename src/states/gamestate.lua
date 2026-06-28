local flare = require("flare.flare")
local Sprite = flare.sprite
local Text = flare.text
local Keyboard = flare.keyboard
local Sound = flare.sound
local GameState = {}

local daisyroute = false -- daisy route check, important switch, don't touch unless moving to a better place

function GameState:enter()
    
end

function GameState:update(dt)



    Keyboard.update()
end

function GameState:draw()

end

function GameState:keypressed(key)
    Keyboard.keypressed(key)
end

return GameState