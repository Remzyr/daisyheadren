local Assets = require("data.assets")

---@class Shader
---@field path string Path to the shader source file
---@field shader love.Shader The compiled love shader object
---@field enabled boolean Whether the shader is applied on draw
local Shader = {}
Shader.__index = Shader

--- Creates a new shader from a file path.
--- @param path string Path to the GLSL shader file
--- @return Shader
function Shader.new(path)
    local self = setmetatable({}, Shader)
    self.path = path
    self.shader = Assets.shader(path)
    self.enabled = true
    return self
end

--- Sends a uniform value to the shader if it exists.
--- @param name string Uniform name
--- @param value any Uniform value
--- @param ... any Additional values for array uniforms
function Shader:send(name, value, ...)
    if self.shader:hasUniform(name) then
        self.shader:send(name, value, ...)
    end
end

--- Sets this shader as the active love graphics shader.
--- Does nothing if the shader is disabled.
function Shader:apply()
    if self.enabled then
        love.graphics.setShader(self.shader)
    end
end

--- Clears the active shader, restoring default rendering.
function Shader.clear()
    love.graphics.setShader()
end

--- Applies the shader, runs the callback, then clears the shader.
--- @param callback function? Drawing code to run while the shader is active
function Shader:draw(callback)
    self:apply()
    if callback then callback() end
    Shader.clear()
end

return Shader
