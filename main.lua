local Theme = require("src.core.Theme")
local Config = require("src.core.Config")
local PlatformManager = require("src.core.PlatformManager")
local ModManager = require("src.core.ModManager")
local SaveManager = require("src.core.SaveManager")
local Router = require("src.core.Router")
local MobileBridge = require("src.core.MobileBridge")
local ShaderManager = require("src.core.ShaderManager")

local Header = require("src.ui.Header")
local GameSelector = require("src.ui.GameSelector")
local GameDetailsView = require("src.ui.GameDetailsView")
local CartridgeRenderer = require("src.ui.CartridgeRenderer")
local TouchOverlay = require("src.ui.TouchOverlay")
local ModsModal = require("src.ui.ModsModal")
local SavesModal = require("src.ui.SavesModal")
local ShaderModal = require("src.ui.ShaderModal")

local currentModal = nil -- nil, "mods", "saves", "shaders"
local actionHitboxes = {}
local modalHitboxes = {}

function love.load(args)
    Theme.init()
    Config.load()
    MobileBridge.init()
    TouchOverlay.init()
    ShaderManager.init(Config.activeShader)

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
end

function love.draw()
    local w, h = love.graphics.getDimensions()

    -- 1. Background Fill & Subtle Pattern
    love.graphics.setColor(Theme.colors.bg)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Subtle grid lines
    love.graphics.setColor(1, 1, 1, 0.02)
    for x = 0, w, 40 do love.graphics.line(x, 0, x, h) end
    for y = 0, h, 40 do love.graphics.line(0, y, w, y) end

    -- 2. Header Bar
    local headerH = Header.draw(w, Config.selectedPlatform, Theme)

    -- 3. Filtered Games & Active Game
    local availableGames = PlatformManager.getGamesByPlatform(Config.selectedPlatform)
    local selectedGame = PlatformManager.getGameById(Config.selectedGameId)

    -- If current game is not in filtered platform, default to first available
    local gameFound = false
    for _, g in ipairs(availableGames) do
        if g.id == selectedGame.id then gameFound = true break end
    end
    if not gameFound and #availableGames > 0 then
        selectedGame = availableGames[1]
        Config.selectedGameId = selectedGame.id
    end

    -- 4. Left Sidebar: Game List
    local sidebarW = 320
    GameSelector.draw(availableGames, selectedGame.id, 0, headerH, sidebarW, h - headerH, Theme, ModManager)

    -- 5. Main Area: Game Details & 3D/Interactive Cartridge
    local detailsX = sidebarW
    local detailsW = w - sidebarW
    actionHitboxes = GameDetailsView.draw(selectedGame, detailsX, headerH, detailsW, h - headerH, Theme, ModManager, SaveManager, CartridgeRenderer)

    -- 6. Modals (Mods / Saves / Shaders)
    if currentModal == "mods" then
        modalHitboxes = ModsModal.draw(selectedGame, w, h, Theme, ModManager)
    elseif currentModal == "saves" then
        modalHitboxes = SavesModal.draw(selectedGame, w, h, Theme, SaveManager)
    elseif currentModal == "shaders" then
        modalHitboxes = ShaderModal.draw(selectedGame, w, h, Theme, ShaderManager)
    end

    -- 7. Router Launch Overlay
    Router.drawOverlay(w, h, Theme)

    -- 8. Mobile Virtual Touch Controls Overlay
    if MobileBridge.virtualControlsEnabled then
        local isGba = (selectedGame and selectedGame.platform == "gba")
        TouchOverlay.draw(w, h, Theme, isGba)
    end
end

function love.mousepressed(x, y, button)
    local w = love.graphics.getWidth()
    if button ~= 1 then return end

    -- A. If modal is open, handle modal events
    if currentModal == "mods" and modalHitboxes then
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
        -- Click outside modal to close
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

    -- B. Header Platform Tabs & Touch Toggle
    local clickedPlatform, toggledTouch = Header.mousepressed(x, y, Config.selectedPlatform, w)
    if toggledTouch then return end
    if clickedPlatform then
        Config.selectedPlatform = clickedPlatform
        Config.save()
        return
    end

    -- C. Sidebar Game Selection
    local availableGames = PlatformManager.getGamesByPlatform(Config.selectedPlatform)
    local clickedGameId = GameSelector.mousepressed(availableGames, x, y, 0, 64, 320)
    if clickedGameId then
        Config.selectedGameId = clickedGameId
        Config.save()
        return
    end

    -- D. Action Buttons
    if actionHitboxes then
        -- Play
        if actionHitboxes.play then
            local p = actionHitboxes.play
            if x >= p.x and x <= p.x + p.w and y >= p.y and y <= p.y + p.h then
                local g = PlatformManager.getGameById(Config.selectedGameId)
                Router.launchGame(g, g.currentSlot or 1)
                return
            end
        end
        -- Mods Button
        if actionHitboxes.mods then
            local m = actionHitboxes.mods
            if x >= m.x and x <= m.x + m.w and y >= m.y and y <= m.y + m.h then
                currentModal = "mods"
                return
            end
        end
        -- Saves Button
        if actionHitboxes.saves then
            local s = actionHitboxes.saves
            if x >= s.x and x <= s.x + s.w and y >= s.y and y <= s.y + s.h then
                currentModal = "saves"
                return
            end
        end
        -- Shaders Button
        if actionHitboxes.shaders then
            local sh = actionHitboxes.shaders
            if x >= sh.x and x <= sh.x + sh.w and y >= sh.y and y <= sh.y + sh.h then
                currentModal = "shaders"
                return
            end
        end
        -- Quick Slot Buttons
        if actionHitboxes.slotArea then
            local sa = actionHitboxes.slotArea
            for slot = 1, 4 do
                local sx = sa.startX + (slot - 1) * (sa.w + 10)
                if x >= sx and x <= sx + sa.w and y >= sa.y and y <= sa.y + sa.h then
                    local g = PlatformManager.getGameById(Config.selectedGameId)
                    g.currentSlot = slot
                    SaveManager.selectSlot(Config.selectedGameId, slot)
                    return
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if currentModal then
            currentModal = nil
        else
            love.event.quit()
        end
    elseif key == "tab" then
        -- Cycle platforms (All -> GBC -> GBA -> SNES -> PS1 -> All)
        if Config.selectedPlatform == "all" then Config.selectedPlatform = "gbc"
        elseif Config.selectedPlatform == "gbc" then Config.selectedPlatform = "gba"
        elseif Config.selectedPlatform == "gba" then Config.selectedPlatform = "snes"
        elseif Config.selectedPlatform == "snes" then Config.selectedPlatform = "ps1"
        else Config.selectedPlatform = "all" end
        Config.save()
    elseif key == "return" or key == "space" then
        if not currentModal then
            local g = PlatformManager.getGameById(Config.selectedGameId)
            Router.launchGame(g, g.currentSlot or 1)
        end
    elseif key == "m" then
        currentModal = (currentModal == "mods") and nil or "mods"
    elseif key == "s" then
        currentModal = (currentModal == "saves") and nil or "saves"
    elseif key == "f" then
        currentModal = (currentModal == "shaders") and nil or "shaders"
    elseif key == "1" or key == "2" or key == "3" or key == "4" then
        local slotNum = tonumber(key)
        local g = PlatformManager.getGameById(Config.selectedGameId)
        g.currentSlot = slotNum
        SaveManager.selectSlot(Config.selectedGameId, slotNum)
    elseif key == "t" then
        MobileBridge.toggleControls()
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if MobileBridge.virtualControlsEnabled then
        local btn = TouchOverlay.touchpressed(id, x, y, dx, dy, pressure)
        if btn then return end
    end
    -- Fallback to standard mouse press for UI interaction
    love.mousepressed(x, y, 1)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if MobileBridge.virtualControlsEnabled then
        TouchOverlay.touchmoved(id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if MobileBridge.virtualControlsEnabled then
        TouchOverlay.touchreleased(id, x, y, dx, dy, pressure)
    end
end

