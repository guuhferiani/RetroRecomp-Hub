function love.conf(t)
    t.identity = "RetroRecompHub"
    t.version = "11.5"
    t.console = false

    t.window.title = "RetroRecomp Hub"
    t.window.width = 1120
    t.window.height = 700
    t.window.minwidth = 320
    t.window.minheight = 240
    t.window.fullscreen = false
    t.window.resizable = true
    t.window.vsync = 1
    t.window.msaa = 4
    t.window.highdpi = true
    t.window.usedpiscale = true

    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.window = true
end
