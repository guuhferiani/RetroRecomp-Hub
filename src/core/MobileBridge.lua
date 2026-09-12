local MobileBridge = {
    isMobileOS = false,
    hasTouchScreen = false,
    virtualControlsEnabled = false,
    safeArea = { top = 0, bottom = 0, left = 0, right = 0 }
}

function MobileBridge.init()
    local osName = love.system and love.system.getOS() or "Unknown"
    MobileBridge.isMobileOS = (osName == "Android" or osName == "iOS")

    -- Detect if device has touch capability
    MobileBridge.hasTouchScreen = MobileBridge.isMobileOS or (love.touch and #love.touch.getTouches() > 0)

    -- Auto-enable virtual controls on mobile devices
    MobileBridge.virtualControlsEnabled = MobileBridge.isMobileOS

    -- Safe area detection for notches and system navigation bars
    if MobileBridge.isMobileOS and love.window and love.window.getSafeArea then
        local sx, sy, sw, sh = love.window.getSafeArea()
        local winW, winH = love.graphics.getDimensions()
        MobileBridge.safeArea.left = sx
        MobileBridge.safeArea.top = sy
        MobileBridge.safeArea.right = math.max(0, winW - (sx + sw))
        MobileBridge.safeArea.bottom = math.max(0, winH - (sy + sh))
    end
end

function MobileBridge.isMobile()
    return MobileBridge.isMobileOS
end

function MobileBridge.toggleControls()
    MobileBridge.virtualControlsEnabled = not MobileBridge.virtualControlsEnabled
    return MobileBridge.virtualControlsEnabled
end

function MobileBridge.pickRomFile(callback)
    if love.system and love.system.pickFile then
        -- Storage Access Framework on Android / iOS
        love.system.pickFile("application/octet-stream", function(filePath)
            if callback then callback(filePath) end
        end)
    else
        print("[MOBILE] File picker not available on this platform.")
    end
end

function MobileBridge.launchRomMobile(game, romPath)
    print(string.format("[MOBILE] Launching %s on mobile: %s", game.title, tostring(romPath)))
    if love.system and love.system.openURL and romPath then
        -- Triggers Android Intent file association (RetroArch, PizzaBoy, mGBA, etc.)
        love.system.openURL("file://" .. romPath)
        return true
    end
    return false
end

return MobileBridge
