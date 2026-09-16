local RomManager = require("src.core.RomManager")

local GameDetailsView = {}

function GameDetailsView.draw(game, x, y, w, h, Theme, ModManager, SaveManager, CartridgeRenderer)
    local mx, my = love.mouse.getPosition()
    local hasRom, romPath, romSize = RomManager.getRomStatus(game)

    -- 1. Cartridge Display Area (Left half of details)
    local cartAreaW = math.min(360, math.max(220, math.floor(w * 0.36)))
    local cartCenterX = x + cartAreaW / 2
    local cartCenterY = y + math.min(190, math.floor(h * 0.31))
    local cartScale = (cartAreaW < 260) and 0.82 or 1.0

    -- Background glow behind cartridge
    local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    love.graphics.setColor(accent[1], accent[2], accent[3], 0.08)
    love.graphics.circle("fill", cartCenterX, cartCenterY, 140 * cartScale)

    CartridgeRenderer.update(love.timer.getDelta(), mx, my, cartCenterX, cartCenterY)
    CartridgeRenderer.draw(game, cartCenterX, cartCenterY, cartScale)

    -- Quick Slot selector below cartridge
    local slotOffsetY = (cartScale < 1.0) and 105 or 125
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("SLOT ATIVO: " .. (game.currentSlot or 1), x + 10, cartCenterY + slotOffsetY, cartAreaW - 20, "center")

    local slotBtnW, slotBtnH = (cartScale < 1.0) and 38 or 44, 26
    local slotStartX = cartCenterX - ((slotBtnW * 4 + 6 * 3) / 2)
    local slotY = cartCenterY + slotOffsetY + 20

    for s = 1, 4 do
        local sx = slotStartX + (s - 1) * (slotBtnW + 6)
        local isSlotActive = (s == (game.currentSlot or 1))
        local isSlotHover = (mx >= sx and mx <= sx + slotBtnW and my >= slotY and my <= slotY + slotBtnH)

        Theme.drawCard(sx, slotY, slotBtnW, slotBtnH, 6, isSlotHover, isSlotActive, accent)
        love.graphics.setColor(isSlotActive and Theme.colors.textPrimary or Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("S" .. s, sx, slotY + 6, slotBtnW, "center")
    end

    -- 2. Game Info & Action Controls (Right half of details)
    local infoX = x + cartAreaW + 16
    local infoW = w - cartAreaW - 32
    local infoY = y + 20

    -- Engine / Platform Tag + ROM Status Badge
    local badgeColor = (game.platform == "gba") and {0.58, 0.38, 0.96, 0.25} or {0.06, 0.75, 0.50, 0.25}
    local bw, bh = Theme.drawBadge(game.badgeText or "NATIVO", infoX, infoY, badgeColor, accent)
    local yw, yh = Theme.drawBadge(game.releaseYear or "2000", infoX + bw + 8, infoY, {0.2, 0.25, 0.35, 0.5}, Theme.colors.textSecondary)

    -- ROM Status Badge
    local romBadgeText = hasRom and ("✓ ROM (" .. romSize .. ")") or "⚠️ ROM AUSENTE"
    local romBadgeBg = hasRom and {0.06, 0.75, 0.50, 0.25} or {0.95, 0.65, 0.15, 0.30}
    local romBadgeColor = hasRom and Theme.colors.accentGbc or {1.0, 0.75, 0.25, 1.0}
    Theme.drawBadge(romBadgeText, infoX + bw + yw + 16, infoY, romBadgeBg, romBadgeColor)

    -- Big Game Title
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont((infoW < 400) and Theme.fonts.header or Theme.fonts.title)
    love.graphics.print(game.title, infoX, infoY + 26)

    -- Subtitle
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.print(game.subtitle, infoX, infoY + 54)

    -- Description Box
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf(game.description or "", infoX, infoY + 86, infoW, "left")

    -- Feature Pills
    local featY = infoY + 155
    local featX = infoX
    for _, feat in ipairs(game.features or {}) do
        local fw = Theme.fonts.small:getWidth(feat) + 14
        if featX + fw <= infoX + infoW then
            Theme.drawBadge(feat, featX, featY, {0.15, 0.20, 0.28, 0.8}, Theme.colors.textSecondary)
            featX = featX + fw + 8
        end
    end

    -- Action Buttons (Play, Import, Mods, Saves, Shaders)
    local gap = 8
    local actionBoxes = {}

    -- 2-row adaptive button grid: Row 1 = [▶ JOGAR] & [📥 IMPORTAR], Row 2 = [MODS], [SAVES], [SHADERS]
    local row1Y = y + h - 100
    local row2Y = y + h - 50
    local playH = 42
    local subH = 38

    -- Row 1: Play (60%) and Import (40%)
    local playW = math.floor((infoW - gap) * 0.58)
    local importBtnW = infoW - playW - gap

    local isPlayHover = (mx >= infoX and mx <= infoX + playW and my >= row1Y and my <= row1Y + playH)
    local playColor = (game.platform == "gba") and (isPlayHover and Theme.colors.buttonPlayGbaHover or Theme.colors.buttonPlayGba)
                                                or (isPlayHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
    love.graphics.setColor(playColor)
    love.graphics.rectangle("fill", infoX, row1Y, playW, playH, 8, 8)
    love.graphics.setColor(1, 1, 1, 0.98)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.printf("▶  JOGAR", infoX, row1Y + 11, playW, "center")

    local importBtnX = infoX + playW + gap
    local isImportHover = (mx >= importBtnX and mx <= importBtnX + importBtnW and my >= row1Y and my <= row1Y + playH)
    Theme.drawCard(importBtnX, row1Y, importBtnW, playH, 8, isImportHover, false, Theme.colors.accentCyan or Theme.colors.accentGbc)
    love.graphics.setColor(Theme.colors.accentCyan or Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("📥 IMPORTAR", importBtnX, row1Y + 12, importBtnW, "center")

    -- Row 2: Mods (33%), Saves (33%), Shaders (33%)
    local subBtnW = math.floor((infoW - gap * 2) / 3)

    local modsX = infoX
    local isModsHover = (mx >= modsX and mx <= modsX + subBtnW and my >= row2Y and my <= row2Y + subH)
    Theme.drawCard(modsX, row2Y, subBtnW, subH, 8, isModsHover, false, accent)
    local activeCount = ModManager.getActiveCount(game.id)
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("🧩 MODS (" .. activeCount .. ")", modsX, row2Y + 11, subBtnW, "center")

    local savesX = modsX + subBtnW + gap
    local isSavesHover = (mx >= savesX and mx <= savesX + subBtnW and my >= row2Y and my <= row2Y + subH)
    Theme.drawCard(savesX, row2Y, subBtnW, subH, 8, isSavesHover, false, accent)
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("💾 SAVES", savesX, row2Y + 11, subBtnW, "center")

    local shadersX = savesX + subBtnW + gap
    local isShadersHover = (mx >= shadersX and mx <= shadersX + subBtnW and my >= row2Y and my <= row2Y + subH)
    Theme.drawCard(shadersX, row2Y, subBtnW, subH, 8, isShadersHover, false, Theme.colors.accentGold)
    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("⚡ SHADERS", shadersX, row2Y + 11, subBtnW, "center")

    actionBoxes.play = { x = infoX, y = row1Y, w = playW, h = playH }
    actionBoxes.import = { x = importBtnX, y = row1Y, w = importBtnW, h = playH }
    actionBoxes.mods = { x = modsX, y = row2Y, w = subBtnW, h = subH }
    actionBoxes.saves = { x = savesX, y = row2Y, w = subBtnW, h = subH }
    actionBoxes.shaders = { x = shadersX, y = row2Y, w = subBtnW, h = subH }
    actionBoxes.slotArea = { startX = slotStartX, y = slotY, w = slotBtnW, h = slotBtnH }

    return actionBoxes
end

return GameDetailsView

