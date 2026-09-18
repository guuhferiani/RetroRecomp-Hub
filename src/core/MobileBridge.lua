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

    -- Virtual controls disabled by default in menu (direct touch navigation)
    MobileBridge.virtualControlsEnabled = false

    -- Safe area detection for notches and system navigation bars
    if MobileBridge.isMobileOS and love.window and love.window.getSafeArea then
        local sx, sy, sw, sh = love.window.getSafeArea()
        local winW, winH = love.graphics.getDimensions()
        MobileBridge.safeArea.left = sx
        MobileBridge.safeArea.top = sy
        MobileBridge.safeArea.right = math.max(0, winW - (sx + sw))
        MobileBridge.safeArea.bottom = math.max(0, winH - (sy + sh))
    end

    -- Prevent screen sleep while Hub is active on Android
    if MobileBridge.isMobileOS and love.window and love.window.setDisplaySleepEnabled then
        love.window.setDisplaySleepEnabled(false)
    end
end

function MobileBridge.hapticFeedback(duration)
    if MobileBridge.isMobileOS and love.system and love.system.vibrate then
        pcall(love.system.vibrate, duration or 0.018)
    end
end

function MobileBridge.isMobile()
    return MobileBridge.isMobileOS
end

function MobileBridge.toggleControls()
    MobileBridge.virtualControlsEnabled = not MobileBridge.virtualControlsEnabled
    MobileBridge.hapticFeedback(0.025)
    return MobileBridge.virtualControlsEnabled
end

function MobileBridge.pickRomFile(callback)
    if love.system and love.system.pickFile then
        -- Attempt to pick file with generic binary or all-files filter
        pcall(function()
            love.system.pickFile(function(fileOrPath)
                if callback and fileOrPath then
                    callback(fileOrPath)
                end
            end)
        end)
    elseif love.window and love.window.showMessageBox then
        print("[MOBILE] File picker not available directly, use standard file explorer.")
    end
end

function MobileBridge.launchRomMobile(game, romPath)
    print(string.format("[MOBILE] Launching %s on mobile: %s", game.title, tostring(romPath)))
    if not romPath or romPath == "" then return false end

    -- Try standard URI
    if love.system and love.system.openURL then
        local targetUrl = romPath:match("^%a+://") and romPath or ("file://" .. romPath)
        local ok, _ = pcall(function() return love.system.openURL(targetUrl) end)
        if ok then return true end
    end
    return false
end

return MobileBridge

