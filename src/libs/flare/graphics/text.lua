local Object = require("core.object")

---@class Letter
---@field canvas love.Canvas
---@field x number
---@field y number
---@field ox number base x (before offsets)
---@field oy number base y
---@field offsetX number tween/effect offset
---@field offsetY number
---@field angle number
---@field scaleX number
---@field scaleY number
---@field alpha number
---@field char string

---@class Text: Object
---@field letters Letter[]
---@field text string
---@field font love.Font
---@field r number
---@field g number
---@field b number
---@field a number
local Text = setmetatable({}, { __index = Object })
Text.__index = Text

---@param x number
---@param y number
---@param str string
---@param font love.Font
function Text.new(x, y, str, font)
    local self = setmetatable(Object.new(x, y), Text)
    self.font = font or love.graphics.getFont()
    self.r, self.g, self.b, self.a = 1, 1, 1, 1
    self.letters = {}
    self.text = ""
    self:setText(str or "")
    return self
end

function Text:setText(str)
    self.text = str
    self.letters = {}

    local cx = 0
    for i = 1, #str do
        local ch = str:sub(i, i)
        local w = self.font:getWidth(ch)
        local h = self.font:getHeight()

        local canvas = love.graphics.newCanvas(math.max(w, 1), h)
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)
        love.graphics.setFont(self.font)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(ch, 0, 0)
        love.graphics.setCanvas()

        self.letters[i] = {
            canvas = canvas,
            char = ch,
            x = cx,
            y = 0,
            ox = cx,
            oy = 0,
            offsetX = 0,
            offsetY = 0,
            angle = 0,
            scaleX = 1,
            scaleY = 1,
            alpha = 1,
        }

        cx = cx + w
    end
end

-- returns a letter by index, for external tween access
---@param i integer
---@return Letter
function Text:getLetter(i)
    return self.letters[i]
end

function Text:setColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b or 1, a or 1
end

function Text:draw()
    for _, l in ipairs(self.letters) do
        local dx = self.x + l.ox + l.offsetX
        local dy = self.y + l.oy + l.offsetY
        local w = l.canvas:getWidth()
        local h = l.canvas:getHeight()
        love.graphics.setColor(self.r, self.g, self.b, self.a * l.alpha)
        love.graphics.draw(
            l.canvas,
            dx, dy,
            l.angle,
            l.scaleX, l.scaleY,
            w * 0.5, h * 0.5  -- pivot at center of each letter
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- convenience: shake all letters with a simple sin wave
-- call this in update, t = love.timer.getTime()
---@param t number
---@param amp number
---@param speed number
function Text:shakeWave(t, amp, speed)
    amp = amp or 4
    speed = speed or 8
    for i, l in ipairs(self.letters) do
        l.offsetY = math.sin(t * speed + i * 0.8) * amp
    end
end

-- wobble angle per letter
---@param t number
---@param amp number
---@param speed number
function Text:wobble(t, amp, speed)
    amp = amp or 0.15
    speed = speed or 5
    for i, l in ipairs(self.letters) do
        l.angle = math.sin(t * speed + i * 1.2) * amp
    end
end

-- fade each letter in with a stagger
---@param t number elapsed time since fade started
---@param stagger number seconds between each letter
---@param fadeDur number seconds each letter takes to fade in
function Text:fadeIn(t, stagger, fadeDur)
    stagger = stagger or 0.05
    fadeDur = fadeDur or 0.1
    for i, l in ipairs(self.letters) do
        local start = (i - 1) * stagger
        l.alpha = math.min(1, math.max(0, (t - start) / fadeDur))
    end
end

return Text
