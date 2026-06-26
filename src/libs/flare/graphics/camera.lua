local cos, sin = math.cos, math.sin

---@class Camera
---@field x number World x position of the camera.
---@field y number World y position of the camera.
---@field scale number Zoom level.
---@field rot number Rotation in radians.
---@field smoother function Active smoothing function.
local camera = {}
camera.__index = camera

camera.smooth = {}

--- Returns a smoother that snaps instantly with no interpolation.
--- @return function
function camera.smooth.none()
    return function(dx, dy) return dx, dy end
end

--- Returns a smoother that moves toward the target at a fixed speed.
--- @param speed number Pixels per second.
--- @return function
function camera.smooth.linear(speed)
    assert(type(speed) == "number", "invalid parameter: speed = " .. tostring(speed))
    return function(dx, dy, s)
        local d   = math.sqrt(dx * dx + dy * dy)
        local dts = math.min((s or speed) * love.timer.getDelta(), d)
        if d > 0 then dx, dy = dx / d, dy / d end
        return dx * dts, dy * dts
    end
end

--- Returns a smoother that eases toward the target using damping.
--- @param stiffness number Higher values mean faster following.
--- @return function
function camera.smooth.damped(stiffness)
    assert(type(stiffness) == "number", "invalid parameter: stiffness = " .. tostring(stiffness))
    return function(dx, dy, s)
        local dts = love.timer.getDelta() * (s or stiffness)
        return dx * dts, dy * dts
    end
end

--- Creates a new camera.
--- @param x number? Initial world x (defaults to screen center).
--- @param y number? Initial world y (defaults to screen center).
--- @param zoom number? Initial zoom level (default 1).
--- @param rot number? Initial rotation in radians (default 0).
--- @param smoother function? Smoothing function (default smooth.none).
--- @return Camera
local function new(x, y, zoom, rot, smoother)
    x, y     = x or love.graphics.getWidth() / 2, y or love.graphics.getHeight() / 2
    zoom     = zoom or 1
    rot      = rot or 0
    smoother = smoother or camera.smooth.none()
    return setmetatable({
        x = x, y = y, scale = zoom, rot = rot, smoother = smoother,
        _shake_strength = 0,
        _shake_duration = 0,
        _shake_timer = 0,
        _shake_x = 0,
        _shake_y = 0,
        _target_zoom = nil,
        _zoom_speed = 0,
        _bounds = nil,
    }, camera)
end

--- Updates shake, zoom interpolation, and bounds clamping. Call in love.update(dt).
--- @param dt number Delta time.
function camera:update(dt)
    if self._shake_timer > 0 then
        self._shake_timer = self._shake_timer - dt
        local s = self._shake_strength * (self._shake_timer / self._shake_duration)
        self._shake_x = (math.random() * 2 - 1) * s
        self._shake_y = (math.random() * 2 - 1) * s
        if self._shake_timer <= 0 then
            self._shake_x, self._shake_y = 0, 0
        end
    end

    if self._target_zoom then
        local dz = self._target_zoom - self.scale
        if math.abs(dz) < 0.001 then
            self.scale       = self._target_zoom
            self._target_zoom = nil
        else
            self.scale = self.scale + dz * math.min(self._zoom_speed * dt, 1)
        end
    end

    if self._bounds then
        local b = self._bounds
        self.x  = math.max(b.x1, math.min(b.x2, self.x))
        self.y  = math.max(b.y1, math.min(b.y2, self.y))
    end
end

--- Starts a positional shake effect.
--- @param strength number Maximum shake offset in pixels.
--- @param duration number Duration of the shake in seconds.
function camera:shake(strength, duration)
    self._shake_strength = strength
    self._shake_duration = duration
    self._shake_timer    = duration
end

--- Restricts camera position to a rectangle. Pass nil to clear.
--- @param x1 number?
--- @param y1 number?
--- @param x2 number?
--- @param y2 number?
function camera:setBounds(x1, y1, x2, y2)
    if x1 == nil then
        self._bounds = nil
    else
        self._bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
    end
end

--- Smoothly interpolates zoom toward a target value.
--- @param target number Target zoom level.
--- @param speed number? Interpolation speed (default 5).
function camera:zoomSmooth(target, speed)
    self._target_zoom = target
    self._zoom_speed  = speed or 5
end

--- Moves the camera to look at a world position.
--- @param x number
--- @param y number
--- @return Camera
function camera:lookAt(x, y)
    self.x, self.y = x, y
    return self
end

--- Moves the camera by a delta.
--- @param dx number
--- @param dy number
--- @return Camera
function camera:move(dx, dy)
    self.x, self.y = self.x + dx, self.y + dy
    return self
end

--- Returns the current camera world position.
--- @return number, number
function camera:position()
    return self.x, self.y
end

--- Rotates the camera by an angle in radians.
--- @param phi number
--- @return Camera
function camera:rotate(phi)
    self.rot = self.rot + phi
    return self
end

--- Sets the camera rotation to an absolute angle in radians.
--- @param phi number
--- @return Camera
function camera:rotateTo(phi)
    self.rot = phi
    return self
end

--- Multiplies the current zoom by a factor.
--- @param mul number
--- @return Camera
function camera:zoom(mul)
    self.scale = self.scale * mul
    return self
end

--- Sets the zoom to an absolute value.
--- @param zoom number
--- @return Camera
function camera:zoomTo(zoom)
    self.scale = zoom
    return self
end

--- Pushes the camera transform. Call before drawing world objects.
--- @param x number? Viewport x (default 0).
--- @param y number? Viewport y (default 0).
--- @param w number? Viewport width (default screen width).
--- @param h number? Viewport height (default screen height).
--- @param noclip boolean? If true, disables scissor clipping.
function camera:attach(x, y, w, h, noclip)
    x, y = x or 0, y or 0
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    self._sx, self._sy, self._sw, self._sh = love.graphics.getScissor()
    if not noclip then love.graphics.setScissor(x, y, w, h) end
    local cx, cy = x + w / 2, y + h / 2
    love.graphics.push()
    love.graphics.translate(cx + self._shake_x, cy + self._shake_y)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rot)
    love.graphics.translate(-self.x, -self.y)
end

--- Pops the camera transform. Call after drawing world objects.
function camera:detach()
    love.graphics.pop()
    love.graphics.setScissor(self._sx, self._sy, self._sw, self._sh)
end

--- Attaches the camera, runs a drawing callback, then detaches.
--- @param ... any (x, y, w, h, noclip, func) or just (func).
function camera:draw(...)
    local x, y, w, h, noclip, func
    local nargs = select("#", ...)
    if nargs == 1 then func = ...
    elseif nargs == 5 then x, y, w, h, func = ...
    elseif nargs == 6 then x, y, w, h, noclip, func = ...
    else error("invalid arguments to camera:draw()") end
    self:attach(x, y, w, h, noclip)
    func()
    self:detach()
end

--- Converts world coordinates to camera/screen coordinates.
--- @param x number
--- @param y number
--- @param ox number? Viewport x offset.
--- @param oy number? Viewport y offset.
--- @param w number? Viewport width.
--- @param h number? Viewport height.
--- @return number, number
function camera:cameraCoords(x, y, ox, oy, w, h)
    ox, oy = ox or 0, oy or 0
    w, h   = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    local c, s = cos(self.rot), sin(self.rot)
    x, y = x - self.x, y - self.y
    x, y = c * x - s * y, s * x + c * y
    return x * self.scale + w / 2 + ox, y * self.scale + h / 2 + oy
end

--- Converts screen coordinates to world coordinates.
--- @param x number
--- @param y number
--- @param ox number? Viewport x offset.
--- @param oy number? Viewport y offset.
--- @param w number? Viewport width.
--- @param h number? Viewport height.
--- @return number, number
function camera:worldCoords(x, y, ox, oy, w, h)
    ox, oy = ox or 0, oy or 0
    w, h   = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    local c, s = cos(-self.rot), sin(-self.rot)
    x, y = (x - w / 2 - ox) / self.scale, (y - h / 2 - oy) / self.scale
    x, y = c * x - s * y, s * x + c * y
    return x + self.x, y + self.y
end

--- Returns the current mouse position in world coordinates.
--- @param ox number? Viewport x offset.
--- @param oy number? Viewport y offset.
--- @param w number? Viewport width.
--- @param h number? Viewport height.
--- @return number, number
function camera:mousePosition(ox, oy, w, h)
    local mx, my = love.mouse.getPosition()
    return self:worldCoords(mx, my, ox, oy, w, h)
end

--- Locks the camera x axis toward a world x position using a smoother.
--- @param x number Target world x.
--- @param smoother function? Overrides the camera's default smoother.
--- @return Camera
function camera:lockX(x, smoother, ...)
    local dx = (smoother or self.smoother)(x - self.x, self.y, ...)
    self.x = self.x + dx
    return self
end

--- Locks the camera y axis toward a world y position using a smoother.
--- @param y number Target world y.
--- @param smoother function? Overrides the camera's default smoother.
--- @return Camera
function camera:lockY(y, smoother, ...)
    local _, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
    self.y = self.y + dy
    return self
end

--- Moves the camera toward a world position using a smoother.
--- @param x number Target world x.
--- @param y number Target world y.
--- @param smoother function? Overrides the camera's default smoother.
--- @return Camera
function camera:lockPosition(x, y, smoother, ...)
    return self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

--- Keeps a world point within a screen-space window, scrolling the camera if needed.
--- @param x number World x of the point to keep visible.
--- @param y number World y of the point to keep visible.
--- @param x_min number Left screen boundary.
--- @param x_max number Right screen boundary.
--- @param y_min number Top screen boundary.
--- @param y_max number Bottom screen boundary.
--- @param smoother function? Overrides the camera's default smoother.
function camera:lockWindow(x, y, x_min, x_max, y_min, y_max, smoother, ...)
    x, y = self:cameraCoords(x, y)
    local dx, dy = 0, 0
    if x < x_min then dx = x - x_min
    elseif x > x_max then dx = x - x_max end
    if y < y_min then dy = y - y_min
    elseif y > y_max then dy = y - y_max end
    local c, s = cos(-self.rot), sin(-self.rot)
    dx, dy = (c * dx - s * dy) / self.scale, (s * dx + c * dy) / self.scale
    self:move((smoother or self.smoother)(dx, dy, ...))
end

return setmetatable({ new = new, smooth = camera.smooth }, { __call = function(_, ...) return new(...) end })
