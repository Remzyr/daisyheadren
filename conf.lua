function love.conf(t)
    t.identity = "daisyheadren" -- save folder name

    t.version = "11.5" -- your LÖVE version

    t.console = false

    t.window.title = "DAISY HEAD REN"

    t.window.resizable = true
    t.window.vsync = 1

    t.window.msaa = 0
    t.window.depth = nil
    t.window.stencil = true

    t.window.fullscreen = false
    t.window.borderless = false

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end