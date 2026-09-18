local Router = {
    isLaunching = false,
    launchMessage = nil,
    launchTimer = 0,
    isTestMode = false
}

local function fileExists(path)
    if not path or path == "" then return false end
    local f = io.open(path, "rb")
    if f then
        f:close()
        return true
    end
    return false
end

local function normalizePath(p)
    if not p then return "" end
    if love.system and love.system.getOS() == "Windows" then
        return p:gsub("/", "\\")
    else
        return p:gsub("\\", "/")
    end
end

function Router.findEmulator(game)
    local src = love.filesystem and love.filesystem.getSource() or "."
    local platform = game and game.platform or "gba"

    local candidates = {}

    if platform == "snes" then
        table.insert(candidates, src .. "/emulator/snes9x.exe")
        table.insert(candidates, src .. "/emulator/snes9x-x64.exe")
        table.insert(candidates, "emulator/snes9x.exe")
        table.insert(candidates, "emulator/snes9x-x64.exe")
    elseif platform == "ps1" then
        table.insert(candidates, src .. "/emulator/duckstation.exe")
        table.insert(candidates, src .. "/emulator/duckstation-qt-x64-ReleaseLTCG.exe")
        table.insert(candidates, "emulator/duckstation.exe")
    else
        table.insert(candidates, src .. "/emulator/mGBA.exe")
        table.insert(candidates, "emulator/mGBA.exe")
        table.insert(candidates, "../Pokemon-GBA/emulator/mGBA.exe")
        table.insert(candidates, "../Proj-Local Pokemon/gba/emulator/mGBA.exe")
    end

    for _, c in ipairs(candidates) do
        local norm = normalizePath(c)
        if fileExists(norm) then
            return norm
        end
    end
    return nil
end

function Router.findRom(game)
    if not game then return nil end
    local Config = require("src.core.Config")
    local custom = Config.customRomPaths and Config.customRomPaths[game.id]
    if custom and custom ~= "" then
        if fileExists(custom) then
            return custom
        end
        local normCustom = normalizePath(custom)
        if fileExists(normCustom) then
            return normCustom
        end
        if love.filesystem and love.filesystem.getInfo(custom) then
            return love.filesystem.getSaveDirectory() .. "/" .. custom
        end
    end

    local src = love.filesystem and love.filesystem.getSource() or "."
    local saveDir = love.filesystem and love.filesystem.getSaveDirectory() or "."
    local candidates = {
        saveDir .. "/roms/" .. (game.platform or "") .. "/" .. (game.romFile or ""),
        saveDir .. "/" .. (game.romFile or ""),
        src .. "/" .. (game.romFile or ""),
        game.romFile or "",
        src .. "/" .. (game.romFallback or ""),
        game.romFallback or "",
        src .. "/roms/" .. (game.platform or "") .. "/" .. (game.romFile or ""),
        "roms/" .. (game.platform or "") .. "/" .. (game.romFile or "")
    }

    for _, c in ipairs(candidates) do
        local norm = normalizePath(c)
        if fileExists(norm) then
            return norm
        end
    end
    return nil
end

function Router.launchGame(game, slotId)
    Router.isLaunching = true
    Router.launchTimer = 1.8
    Router.launchMessage = string.format("Iniciando %s via [%s]...", game.title, game.badgeText)

    print(string.format("[ROUTER] Launching game: %s (engine: %s, slot: %d)", game.id, game.engine, slotId or 1))

    if Router.isTestMode then
        print("[ROUTER] Test mode active: skipping process execution.")
        return true
    end

    local romPath = Router.findRom(game)
    local emuPath = Router.findEmulator(game)

    print(string.format("[ROUTER] Found ROM: %s", tostring(romPath)))
    print(string.format("[ROUTER] Found Emulator: %s", tostring(emuPath)))

    local MobileBridge = require("src.core.MobileBridge")
    if MobileBridge.isMobile() then
        if romPath then
            local ok = MobileBridge.launchRomMobile(game, romPath)
            Router.launchMessage = ok and string.format("Abrindo %s no Android...", game.title) or "Iniciando no ambiente móvel..."
            return true
        else
            Router.launchMessage = string.format("Importe a ROM de %s no celular!", game.title)
            return false
        end
    end

    if emuPath and romPath then
        local emuDir = emuPath:match("^(.*)\\[^\\]+$") or emuPath:match("^(.*)/[^/]+$") or "."
        local cmd = string.format('start "" /d "%s" "%s" "%s"', emuDir, emuPath, romPath)
        print(string.format("[ROUTER] Executing: %s", cmd))
        os.execute(cmd)
        Router.launchMessage = string.format("Jogo %s aberto com sucesso!", game.title)
        return true
    elseif romPath then
        local cmd = string.format('start "" "%s"', romPath)
        print(string.format("[ROUTER] Executing via Windows file association: %s", cmd))
        os.execute(cmd)
        Router.launchMessage = string.format("Abrindo %s via reprodutor padrão...", game.title)
        return true
    else
        Router.launchMessage = string.format("Erro: ROM de %s não encontrada!", game.title)
        print(string.format("[ROUTER] ERROR: ROM not found for %s", game.id))
        return false
    end
end

function Router.update(dt)
    if Router.isLaunching then
        Router.launchTimer = Router.launchTimer - dt
        if Router.launchTimer <= 0 then
            Router.isLaunching = false
            Router.launchMessage = nil
        end
    end
end

function Router.drawOverlay(w, h, Theme)
    if Router.isLaunching then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 0, 0, w, h)

        local boxW, boxH = 480, 160
        local bx, by = (w - boxW) / 2, (h - boxH) / 2

        Theme.drawCard(bx, by, boxW, boxH, 16, true, true, Theme.colors.accentGold)

        love.graphics.setColor(Theme.colors.accentGold)
        love.graphics.setFont(Theme.fonts.header)
        love.graphics.printf("CARREGANDO MOTOR RETRORECOMP", bx, by + 24, boxW, "center")

        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf(Router.launchMessage or "Iniciando aplicação...", bx + 20, by + 65, boxW - 40, "center")

        -- Animated loading bar
        local barW = boxW - 60
        local progress = 1.0 - (Router.launchTimer / 1.8)
        love.graphics.setColor(0.2, 0.25, 0.35, 0.8)
        love.graphics.rectangle("fill", bx + 30, by + 110, barW, 10, 5, 5)

        love.graphics.setColor(Theme.colors.accentGbc)
        love.graphics.rectangle("fill", bx + 30, by + 110, barW * math.min(1.0, math.max(0.05, progress)), 10, 5, 5)
    end
end

return Router
