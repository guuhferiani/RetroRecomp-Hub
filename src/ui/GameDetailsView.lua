local GameDetailsView = {}

function GameDetailsView.draw(game, x, y, w, h, Theme, ModManager, SaveManager, CartridgeRenderer)
    local mx, my = love.mouse.getPosition()

    -- 1. Cartridge Display Area (Left half of details)
    local cartAreaW = math.floor(w * 0.45)
    local cartCenterX = x + cartAreaW / 2
    local cartCenterY = y + 175

    -- Background glow behind cartridge
    local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    love.graphics.setColor(accent[1], accent[2], accent[3], 0.08)
    love.graphics.circle("fill", cartCenterX, cartCenterY, 150)

    CartridgeRenderer.update(love.timer.getDelta(), mx, my, cartCenterX, cartCenterY)
    CartridgeRenderer.draw(game, cartCenterX, cartCenterY, 1.0)

    -- Quick Slot selector below cartridge
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("SLOT DE SAVE ATIVO: SLOT " .. (game.currentSlot or 1), x + 20, cartCenterY + 140, cartAreaW - 40, "center")

    local slotBtnW, slotBtnH = 50, 28
    local slotStartX = cartCenterX - ((slotBtnW * 4 + 10 * 3) / 2)
    local slotY = cartCenterY + 160

    for s = 1, 4 do
        local sx = slotStartX + (s - 1) * (slotBtnW + 10)
        local isSlotActive = (s == (game.currentSlot or 1))
        local isSlotHover = (mx >= sx and mx <= sx + slotBtnW and my >= slotY and my <= slotY + slotBtnH)

        Theme.drawCard(sx, slotY, slotBtnW, slotBtnH, 6, isSlotHover, isSlotActive, accent)
        love.graphics.setColor(isSlotActive and Theme.colors.textPrimary or Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("S" .. s, sx, slotY + 7, slotBtnW, "center")
    end

    -- 2. Game Info & Action Controls (Right half of details)
    local infoX = x + cartAreaW + 20
    local infoW = w - cartAreaW - 60
    local infoY = y + 40

    -- Engine / Platform Tag
    local badgeColor = (game.platform == "gba") and {0.58, 0.38, 0.96, 0.25} or {0.06, 0.75, 0.50, 0.25}
    local bw, bh = Theme.drawBadge(game.badgeText or "NATIVO", infoX, infoY, badgeColor, accent)
    Theme.drawBadge(game.releaseYear or "2000", infoX + bw + 10, infoY, {0.2, 0.25, 0.35, 0.5}, Theme.colors.textSecondary)

    -- Big Game Title
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.title)
    love.graphics.print(game.title, infoX, infoY + 32)

    -- Subtitle
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print(game.subtitle, infoX, infoY + 65)

    -- Description Box
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf(game.description or "", infoX, infoY + 105, infoW, "left")

    -- Feature Pills
    local featY = infoY + 175
    local featX = infoX
    for _, feat in ipairs(game.features or {}) do
        local fw = Theme.fonts.small:getWidth(feat) + 16
        Theme.drawBadge(feat, featX, featY, {0.15, 0.20, 0.28, 0.8}, Theme.colors.textSecondary)
        featX = featX + fw + 8
    end

    -- Action Buttons (Play, Mods, Saves, Shaders)
    local btnY = h - 75
    local playW = 160
    local playH = 50
    local isPlayHover = (mx >= infoX and mx <= infoX + playW and my >= btnY and my <= btnY + playH)

    local playColor = (game.platform == "gba") and (isPlayHover and Theme.colors.buttonPlayGbaHover or Theme.colors.buttonPlayGba)
                                                or (isPlayHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
    love.graphics.setColor(playColor)
    love.graphics.rectangle("fill", infoX, btnY, playW, playH, 12, 12)

    love.graphics.setColor(1, 1, 1, 0.98)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.printf("▶  JOGAR", infoX, btnY + 15, playW, "center")

    -- Mods Button
    local modsX = infoX + playW + 12
    local modsW = 135
    local isModsHover = (mx >= modsX and mx <= modsX + modsW and my >= btnY and my <= btnY + playH)
    Theme.drawCard(modsX, btnY, modsW, playH, 12, isModsHover, false, accent)

    local activeCount, totalCount = ModManager.getActiveCount(game.id)
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("🧩 MODS (" .. activeCount .. ")", modsX, btnY + 16, modsW, "center")

    -- Saves Button
    local savesX = modsX + modsW + 12
    local savesW = 120
    local isSavesHover = (mx >= savesX and mx <= savesX + savesW and my >= btnY and my <= btnY + playH)
    Theme.drawCard(savesX, btnY, savesW, playH, 12, isSavesHover, false, accent)

    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("💾 SAVES", savesX, btnY + 16, savesW, "center")

    -- Shaders Button
    local shadersX = savesX + savesW + 12
    local shadersW = 130
    local isShadersHover = (mx >= shadersX and mx <= shadersX + shadersW and my >= btnY and my <= btnY + playH)
    Theme.drawCard(shadersX, btnY, shadersW, playH, 12, isShadersHover, false, Theme.colors.accentGold)

    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("⚡ SHADERS", shadersX, btnY + 16, shadersW, "center")

    -- Return click bounding boxes
    return {
        play = { x = infoX, y = btnY, w = playW, h = playH },
        mods = { x = modsX, y = btnY, w = modsW, h = playH },
        saves = { x = savesX, y = btnY, w = savesW, h = playH },
        shaders = { x = shadersX, y = btnY, w = shadersW, h = playH },
        slotArea = { startX = slotStartX, y = slotY, w = slotBtnW, h = slotBtnH }
    }
end

return GameDetailsView
