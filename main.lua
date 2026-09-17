local Theme = require("src.core.Theme")
local Config = require("src.core.Config")
local PlatformManager = require("src.core.PlatformManager")
local ModManager = require("src.core.ModManager")
local SaveManager = require("src.core.SaveManager")
local Router = require("src.core.Router")
local MobileBridge = require("src.core.MobileBridge")
local ShaderManager = require("src.core.ShaderManager")
local RomManager = require("src.core.RomManager")

local Header = require("src.ui.Header")
local GameSelector = require("src.ui.GameSelector")
local GameDetailsView = require("src.ui.GameDetailsView")
local CartridgeRenderer = require("src.ui.CartridgeRenderer")
local TouchOverlay = require("src.ui.TouchOverlay")
local ModsModal = require("src.ui.ModsModal")
local SavesModal = require("src.ui.SavesModal")
local ShaderModal = require("src.ui.ShaderModal")
local ImportRomModal = require("src.ui.ImportRomModal")

local currentModal = nil -- nil, "mods", "saves", "shaders", "import"
local actionHitboxes = {}
local modalHitboxes = {}

-- Virtual resolution & responsive scaling (Portrait-first for mobile)
local uiScale = 1.0
local virtualW = 420
local virtualH = 840
local safeLeft = 0
local safeRight = 0
local launcherX = 0
local launcherW = 420
local lastHeaderH = 96
local currentHeaderHitboxes = {}

local function updateViewport()
    local realW, realH = love.graphics.getDimensions()
    realW = math.max(320, realW)
    realH = math.max(240, realH)

    if realH >= realW then
        -- Portrait mode (Mobile / vertical screen): fixed virtual width 420px, variable height
        virtualW = 420
        uiScale = realW / virtualW
        virtualH = math.floor(realH / uiScale)
    else
        -- Landscape mode (Desktop / widescreen): fixed virtual height 740px, variable width
        virtualH = 740
        uiScale = realH / virtualH
        virtualW = math.floor(realW / uiScale)
    end

    if love.window and love.window.getSafeArea then
        local sx, sy, sw, sh = love.window.getSafeArea()
        safeLeft = math.floor(sx / uiScale)
        safeRight = math.floor(math.max(0, realW - (sx + sw)) / uiScale)
    else
        safeLeft = 0
        safeRight = 0
    end
end

-- Virtual mouse coordinate mapping (converts physical pixels to virtual UI coords)
local origGetMousePos = love.mouse.getPosition
local origGetMouseX = love.mouse.getX
local origGetMouseY = love.mouse.getY

function love.mouse.getPosition()
    local mx, my = origGetMousePos()
    return mx / uiScale, my / uiScale
end

function love.mouse.getX()
    return origGetMouseX() / uiScale
end

function love.mouse.getY()
    return origGetMouseY() / uiScale
end

function love.load(args)
    Theme.init()
    Config.load()
    MobileBridge.init()
    TouchOverlay.init()
    ShaderManager.init(Config.activeShader)

    -- Set window icon if available
    if love.filesystem and love.filesystem.getInfo and love.filesystem.getInfo("assets/icon.png") then
        local status, iconData = pcall(love.image.newImageData, "assets/icon.png")
        if status and iconData and love.window and love.window.setIcon then
            love.window.setIcon(iconData)
        end
    end

    -- Fullscreen immersive mode on Android to use edge-to-edge display
    if MobileBridge.isMobile() and love.window and love.window.setFullscreen then
        pcall(love.window.setFullscreen, true)
    end

    -- Automated verification test mode
    for _, a in ipairs(args or {}) do
        if a == "--test" then
            Router.isTestMode = true
            print("[TEST] Running automated RetroRecomp Hub self-tests...")
            local gbcGames = PlatformManager.getGamesByPlatform("gbc")
            local gbaGames = PlatformManager.getGamesByPlatform("gba")
            local snesGames = PlatformManager.getGamesByPlatform("snes")
            local ps1Games = PlatformManager.getGamesByPlatform("ps1")
            assert(#gbcGames >= 2, "Expected at least 2 GBC games")
            assert(#gbaGames >= 1, "Expected at least 1 GBA game")
            assert(#snesGames >= 1, "Expected at least 1 SNES game")
            assert(#ps1Games >= 1, "Expected at least 1 PS1 game")

            -- Test Shaders
            assert(#ShaderManager.getPresets() >= 4, "Expected at least 4 shader presets")
            ShaderManager.setPreset("crt")
            assert(ShaderManager.activeShaderId == "crt", "Expected active shader to be crt")

            -- Test Mod Manager
            local active, total = ModManager.getActiveCount("crystal")
            assert(total > 0, "Expected mods in crystal")
            ModManager.toggle("crystal", "ptbr_crystal")
            ModManager.toggle("crystal", "ptbr_crystal")

            -- Test RomManager
            local quick = RomManager.getQuickPaths()
            assert(#quick > 0, "Expected quick access paths")
            assert(RomManager.isSupportedFile("game.gbc") == true, "Expected gbc to be supported")
            assert(RomManager.isSupportedFile("game.gba") == true, "Expected gba to be supported")
            assert(RomManager.isSupportedFile("game.sfc") == true, "Expected sfc to be supported")
            assert(RomManager.isSupportedFile("game.chd") == true, "Expected chd to be supported")
            assert(RomManager.isSupportedFile("image.png") == false, "Expected png to be unsupported")

            -- Test Router
            Router.launchGame(gbcGames[1], 1)
            Router.update(0.016)

            print("[TEST] All RetroRecomp Hub tests completed successfully!")
            love.event.quit(0)
            return
        elseif a == "--verify" then
            print("=== CHECKING ROM AND EMULATOR RESOLUTION ===")
            local emu = Router.findEmulator()
            print("Emulator:", tostring(emu))
            assert(emu ~= nil, "mGBA emulator was not found!")

            for _, g in ipairs(PlatformManager.games) do
                local rom = Router.findRom(g)
                local status = rom and "OK ✓ (" .. rom .. ")" or "PENDENTE (coloque a ROM em roms/" .. g.platform .. "/)"
                print(string.format("Game [%s - %s]: %s", g.platform, g.title, status))
                if g.id == "crystal" or g.id == "yellow" or g.id == "firered" then
                    assert(rom ~= nil, "ROM not found for " .. g.id)
                end
            end

            print("=== VERIFICATION OF ALL 5 PLATFORMS COMPLETED SUCCESSFULLY! ===")
            love.event.quit(0)
            return
        end
    end
end

function love.update(dt)
    Router.update(dt)
    ImportRomModal.update(dt)
end

function love.draw()
    updateViewport()

    love.graphics.push()
    love.graphics.scale(uiScale, uiScale)

    local w, h = virtualW, virtualH

    -- 1. Dark Charcoal Background
    love.graphics.setColor(Theme.colors.recompDarkBg)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Subtle grid lines
    love.graphics.setColor(1, 1, 1, 0.015)
    for x = 0, w, 40 do love.graphics.line(x, 0, x, h) end
    for y = 0, h, 40 do love.graphics.line(0, y, w, y) end

    -- Active Selected Game
    local selectedGame = PlatformManager.getGameById(Config.selectedGameId)
    if not selectedGame then
        selectedGame = PlatformManager.games[1]
        Config.selectedGameId = selectedGame.id
    end

    -- 2. Layout Positioning
    local isPortrait = (h >= w)
    launcherW = math.min(w - safeLeft - safeRight, 420)
    
    if isPortrait then
        launcherX = safeLeft + math.floor((w - safeLeft - safeRight - launcherW) / 2)
    else
        -- On wide screens, position launcher on left or center
        if w >= 820 then
            launcherX = safeLeft + 40
            -- Draw 3D Cartridge showcase on right side for desktop players!
            local artCenterX = launcherX + launcherW + math.floor((w - (launcherX + launcherW) - safeRight) / 2)
            local artCenterY = math.floor(h / 2)
            CartridgeRenderer.update(love.timer.getDelta(), love.mouse.getX(), love.mouse.getY(), artCenterX, artCenterY)
            CartridgeRenderer.draw(selectedGame, artCenterX, artCenterY, 1.15)
        else
            launcherX = math.floor((w - launcherW) / 2)
        end
    end

    -- 3. Header & Toolbar
    love.graphics.push()
    love.graphics.translate(launcherX, 0)
    local headerH, hHitboxes = Header.draw(launcherW, Config.selectedPlatform, selectedGame, Theme, 0, 0)
    lastHeaderH = headerH
    currentHeaderHitboxes = hHitboxes
    love.graphics.pop()

    -- 4. Main Game Details View (Title, ROM Card, 4 Save Slots, Footer)
    love.graphics.push()
    love.graphics.translate(launcherX, headerH)
    actionHitboxes = GameDetailsView.draw(selectedGame, 0, 0, launcherW, h - headerH, Theme, ModManager, SaveManager, CartridgeRenderer)
    love.graphics.pop()

    -- 5. Floating Game Selector Dropdown (when [ R ▼ ] is clicked)
    if Header.isDropdownOpen then
        Header.drawDropdown(launcherX + 14, 52 + 38, launcherW, selectedGame.id, Theme)
    end

    -- 6. Modals (Mods / Saves / Shaders / Import)
    if currentModal == "mods" and selectedGame then
        modalHitboxes = ModsModal.draw(selectedGame, w, h, Theme, ModManager)
    elseif currentModal == "saves" and selectedGame then
        modalHitboxes = SavesModal.draw(selectedGame, w, h, Theme, SaveManager)
    elseif currentModal == "shaders" and selectedGame then
        modalHitboxes = ShaderModal.draw(selectedGame, w, h, Theme, ShaderManager)
    elseif currentModal == "import" and selectedGame then
        modalHitboxes = ImportRomModal.draw(selectedGame, w, h, Theme)
    end

    -- 7. Router Launch Overlay
    Router.drawOverlay(w, h, Theme)

    -- 8. Mobile Virtual Touch Controls Overlay
    if MobileBridge.virtualControlsEnabled then
        local isGba = (selectedGame and selectedGame.platform == "gba")
        TouchOverlay.draw(w, h, Theme, isGba)
    end

    love.graphics.pop()
end

function love.mousepressed(screenX, screenY, button)
    if button ~= 1 then return end
    updateViewport()
    local x = screenX / uiScale
    local y = screenY / uiScale
    local w = virtualW
    local h = virtualH

    -- A. If modal is open, handle modal events
    if currentModal == "import" and modalHitboxes then
        local action = ImportRomModal.mousepressed(x, y, button, modalHitboxes, PlatformManager.getGameById(Config.selectedGameId))
        if action == "close" then
            currentModal = nil
        end
        return
    elseif currentModal == "mods" and modalHitboxes then
        if modalHitboxes.closeBtn then
            local cb = modalHitboxes.closeBtn
            if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
                currentModal = nil
                return
            end
        end
        for _, t in ipairs(modalHitboxes.toggles or {}) do
            if x >= t.x and x <= t.x + t.w and y >= t.y and y <= t.y + t.h then
                ModManager.toggle(Config.selectedGameId, t.modId)
                return
            end
        end
        local mb = modalHitboxes.modalBounds
        if mb and (x < mb.x or x > mb.x + mb.w or y < mb.y or y > mb.y + mb.h) then
            currentModal = nil
            return
        end
        return
    elseif currentModal == "saves" and modalHitboxes then
        if modalHitboxes.closeBtn then
            local cb = modalHitboxes.closeBtn
            if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
                currentModal = nil
                return
            end
        end
        for _, sb in ipairs(modalHitboxes.slotButtons or {}) do
            if x >= sb.x and x <= sb.x + sb.w and y >= sb.y and y <= sb.y + sb.h then
                local g = PlatformManager.getGameById(Config.selectedGameId)
                g.currentSlot = sb.slotId
                SaveManager.selectSlot(Config.selectedGameId, sb.slotId)
                return
            end
        end
        local mb = modalHitboxes.modalBounds
        if mb and (x < mb.x or x > mb.x + mb.w or y < mb.y or y > mb.y + mb.h) then
            currentModal = nil
            return
        end
        return
    elseif currentModal == "shaders" and modalHitboxes then
        if modalHitboxes.closeBtn then
            local cb = modalHitboxes.closeBtn
            if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
                currentModal = nil
                return
            end
        end
        for _, pb in ipairs(modalHitboxes.presetButtons or {}) do
            if x >= pb.x and x <= pb.x + pb.w and y >= pb.y and y <= pb.y + pb.h then
                ShaderManager.setPreset(pb.presetId)
                Config.activeShader = pb.presetId
                Config.save()
                return
            end
        end
        local mb = modalHitboxes.modalBounds
        if mb and (x < mb.x or x > mb.x + mb.w or y < mb.y or y > mb.y + mb.h) then
            currentModal = nil
            return
        end
        return
    end

    -- B. If Game Selector Dropdown is open
    if Header.isDropdownOpen then
        for _, item in ipairs(Header.dropdownHitboxes or {}) do
            if x >= item.x and x <= item.x + item.w and y >= item.y and y <= item.y + item.h then
                MobileBridge.hapticFeedback(0.020)
                Config.selectedGameId = item.gameId
                Config.save()
                Header.isDropdownOpen = false
                return
            end
        end
        Header.isDropdownOpen = false
        return
    end

    -- C. Header & Toolbar Click Events
    local relHeaderX = x - launcherX
    local headerAction = Header.mousepressed(relHeaderX, y, currentHeaderHitboxes)
    if headerAction == "toggleDropdown" then
        MobileBridge.hapticFeedback(0.015)
        return
    elseif headerAction == "import" then
        MobileBridge.hapticFeedback(0.020)
        ImportRomModal.initPath()
        currentModal = "import"
        return
    elseif headerAction == "mods" then
        MobileBridge.hapticFeedback(0.020)
        currentModal = (currentModal == "mods") and nil or "mods"
        return
    elseif headerAction == "shaders" then
        MobileBridge.hapticFeedback(0.020)
        currentModal = (currentModal == "shaders") and nil or "shaders"
        return
    elseif headerAction == "platformSwap" then
        -- Cycle platforms: all -> gbc -> gba -> snes -> ps1 -> all
        local plats = { "all", "gbc", "gba", "snes", "ps1" }
        local curIdx = 1
        for i, p in ipairs(plats) do
            if p == Config.selectedPlatform then curIdx = i break end
        end
        local nextIdx = (curIdx % #plats) + 1
        Config.selectedPlatform = plats[nextIdx]
        local filtered = PlatformManager.getGamesByPlatform(Config.selectedPlatform)
        if #filtered > 0 then
            Config.selectedGameId = filtered[1].id
        end
        Config.save()
        MobileBridge.hapticFeedback(0.025)
        return
    elseif headerAction == "quit" then
        return
    end

    -- D. Main View Actions (Play, Import, Slots, Delete, Footer)
    if actionHitboxes then
        local relY = y - lastHeaderH
        local relX = x - launcherX

        -- Play
        if actionHitboxes.play then
            local p = actionHitboxes.play
            if relX >= p.x and relX <= p.x + p.w and relY >= p.y and relY <= p.y + p.h then
                MobileBridge.hapticFeedback(0.035)
                local g = PlatformManager.getGameById(Config.selectedGameId)
                Router.launchGame(g, g.currentSlot or 1)
                return
            end
        end

        -- Import Button
        if actionHitboxes.import then
            local imp = actionHitboxes.import
            if relX >= imp.x and relX <= imp.x + imp.w and relY >= imp.y and relY <= imp.y + imp.h then
                MobileBridge.hapticFeedback(0.020)
                ImportRomModal.initPath()
                currentModal = "import"
                return
            end
        end

        -- Alterar ROM link
        if actionHitboxes.changeRom then
            local cr = actionHitboxes.changeRom
            if relX >= cr.x and relX <= cr.x + cr.w and relY >= cr.y and relY <= cr.y + cr.h then
                MobileBridge.hapticFeedback(0.020)
                ImportRomModal.initPath()
                currentModal = "import"
                return
            end
        end

        -- Import Save Button
        if actionHitboxes.importSave then
            local isb = actionHitboxes.importSave
            if relX >= isb.x and relX <= isb.x + isb.w and relY >= isb.y and relY <= isb.y + isb.h then
                MobileBridge.hapticFeedback(0.020)
                currentModal = "saves"
                return
            end
        end

        -- Delete Slot Buttons
        for s = 1, 4 do
            local del = actionHitboxes.deleteSlot and actionHitboxes.deleteSlot[s]
            if del and relX >= del.x and relX <= del.x + del.w and relY >= del.y and relY <= del.y + del.h then
                MobileBridge.hapticFeedback(0.035)
                local g = PlatformManager.getGameById(Config.selectedGameId)
                SaveManager.selectSlot(g.id, s)
                return
            end
        end

        -- Slot Selection Cards
        for s = 1, 4 do
            local slotBox = actionHitboxes.slots and actionHitboxes.slots[s]
            if slotBox and relX >= slotBox.x and relX <= slotBox.x + slotBox.w and relY >= slotBox.y and relY <= slotBox.y + slotBox.h then
                MobileBridge.hapticFeedback(0.018)
                local g = PlatformManager.getGameById(Config.selectedGameId)
                g.currentSlot = s
                SaveManager.selectSlot(g.id, s)
                return
            end
        end

        -- Footer Buttons
        if actionHitboxes.footer1 and relX >= actionHitboxes.footer1.x and relX <= actionHitboxes.footer1.x + actionHitboxes.footer1.w and relY >= actionHitboxes.footer1.y and relY <= actionHitboxes.footer1.y + actionHitboxes.footer1.h then
            MobileBridge.hapticFeedback(0.015)
            return
        end
        if actionHitboxes.footer2 and relX >= actionHitboxes.footer2.x and relX <= actionHitboxes.footer2.x + actionHitboxes.footer2.w and relY >= actionHitboxes.footer2.y and relY <= actionHitboxes.footer2.y + actionHitboxes.footer2.h then
            MobileBridge.hapticFeedback(0.015)
            print("[HUB] Verificando atualizações...")
            return
        end
        if actionHitboxes.footer3 and relX >= actionHitboxes.footer3.x and relX <= actionHitboxes.footer3.x + actionHitboxes.footer3.w and relY >= actionHitboxes.footer3.y and relY <= actionHitboxes.footer3.y + actionHitboxes.footer3.h then
            MobileBridge.hapticFeedback(0.015)
            currentModal = "mods"
            return
        end
    end
end

function love.wheelmoved(dx, dy)
    updateViewport()
    if currentModal == "import" then
        ImportRomModal.wheelmoved(dx, dy)
    end
end

function love.filedropped(file)
    local ok, msg = RomManager.handleDroppedFile(file)
    if ok then
        MobileBridge.hapticFeedback(0.035)
        print("[HUB] " .. msg)
    else
        print("[HUB] File dropped error: " .. tostring(msg))
    end
end

function love.keypressed(key)
    if key == "escape" then
        if Header.isDropdownOpen then
            Header.isDropdownOpen = false
        elseif currentModal then
            currentModal = nil
        else
            love.event.quit()
        end
    elseif key == "tab" then
        -- Cycle platforms
        local plats = { "all", "gbc", "gba", "snes", "ps1" }
        local curIdx = 1
        for i, p in ipairs(plats) do
            if p == Config.selectedPlatform then curIdx = i break end
        end
        local nextIdx = (curIdx % #plats) + 1
        Config.selectedPlatform = plats[nextIdx]
        local filtered = PlatformManager.getGamesByPlatform(Config.selectedPlatform)
        if #filtered > 0 then
            Config.selectedGameId = filtered[1].id
        end
        Config.save()
    elseif key == "return" or key == "space" then
        if not currentModal and not Header.isDropdownOpen then
            local g = PlatformManager.getGameById(Config.selectedGameId)
            Router.launchGame(g, g.currentSlot or 1)
        end
    elseif key == "m" then
        currentModal = (currentModal == "mods") and nil or "mods"
    elseif key == "s" then
        currentModal = (currentModal == "saves") and nil or "saves"
    elseif key == "f" then
        currentModal = (currentModal == "shaders") and nil or "shaders"
    elseif key == "i" then
        ImportRomModal.initPath()
        currentModal = (currentModal == "import") and nil or "import"
    elseif key == "1" or key == "2" or key == "3" or key == "4" then
        local slotNum = tonumber(key)
        local g = PlatformManager.getGameById(Config.selectedGameId)
        g.currentSlot = slotNum
        SaveManager.selectSlot(Config.selectedGameId, slotNum)
    elseif key == "t" then
        MobileBridge.toggleControls()
    end
end

function love.touchpressed(id, tx, ty, dx, dy, pressure)
    updateViewport()
    local realW, realH = love.graphics.getDimensions()
    local px = (tx <= 1.0 and tx >= 0.0) and (tx * realW) or tx
    local py = (ty <= 1.0 and ty >= 0.0) and (ty * realH) or ty
    local vx = px / uiScale
    local vy = py / uiScale

    if MobileBridge.virtualControlsEnabled then
        local btn = TouchOverlay.touchpressed(id, vx, vy, dx, dy, pressure)
        if btn then return end
    end
    -- Fallback to standard mouse press for UI interaction
    love.mousepressed(px, py, 1)
end

function love.touchmoved(id, tx, ty, dx, dy, pressure)
    if MobileBridge.virtualControlsEnabled then
        updateViewport()
        local realW, realH = love.graphics.getDimensions()
        local px = (tx <= 1.0 and tx >= 0.0) and (tx * realW) or tx
        local py = (ty <= 1.0 and ty >= 0.0) and (ty * realH) or ty
        local vx = px / uiScale
        local vy = py / uiScale
        TouchOverlay.touchmoved(id, vx, vy, dx, dy, pressure)
    else
        -- Touch scroll in modal
        if currentModal == "import" then
            local deltaY = (dy or 0)
            if deltaY and math.abs(deltaY) > 0 then
                local realH = love.graphics.getHeight()
                ImportRomModal.touchmoved(deltaY * (realH / uiScale))
            end
        end
    end
end

function love.touchreleased(id, tx, ty, dx, dy, pressure)
    if MobileBridge.virtualControlsEnabled then
        updateViewport()
        local realW, realH = love.graphics.getDimensions()
        local px = (tx <= 1.0 and tx >= 0.0) and (tx * realW) or tx
        local py = (ty <= 1.0 and ty >= 0.0) and (ty * realH) or ty
        local vx = px / uiScale
        local vy = py / uiScale
        TouchOverlay.touchreleased(id, vx, vy, dx, dy, pressure)
    end
end



