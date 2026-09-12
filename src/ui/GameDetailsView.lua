local GameDetailsView = {}

function GameDetailsView.draw(game, x, y, w, h, Theme, ModManager, SaveManager, CartridgeRenderer)
    local mx, my = love.mouse.getPosition()

    -- 1. Cartridge Display Area (Left half of details)
    local cartAreaW = math.min(360, math.max(260, math.floor(w * 0.38)))
    local cartCenterX = x + cartAreaW / 2
    local cartCenterY = y + math.min(200, math.floor(h * 0.33))

    -- Background glow behind cartridge
    local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    love.graphics.setColor(accent[1], accent[2], accent[3], 0.08)
    love.graphics.circle("fill", cartCenterX, cartCenterY, 150)

    CartridgeRenderer.update(love.timer.getDelta(), mx, my, cartCenterX, cartCenterY)
    CartridgeRenderer.draw(game, cartCenterX, cartCenterY, 1.0)

    -- Quick Slot selector below cartridge
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("SLOT DE SAVE ATIVO: SLOT " .. (game.currentSlot or 1), x + 10, cartCenterY + 130, cartAreaW - 20, "center")

    local slotBtnW, slotBtnH = 46, 26
    local slotStartX = cartCenterX - ((slotBtnW * 4 + 8 * 3) / 2)
    local slotY = cartCenterY + 152

    for s = 1, 4 do
        local sx = slotStartX + (s - 1) * (slotBtnW + 8)
        local isSlotActive = (s == (game.currentSlot or 1))
        local isSlotHover = (mx >= sx and mx <= sx + slotBtnW and my >= slotY and my <= slotY + slotBtnH)

        Theme.drawCard(sx, slotY, slotBtnW, slotBtnH, 6, isSlotHover, isSlotActive, accent)
        love.graphics.setColor(isSlotActive and Theme.colors.textPrimary or Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("S" .. s, sx, slotY + 6, slotBtnW, "center")
    end

    -- 2. Game Info & Action Controls (Right half of details)
    local infoX = x + cartAreaW + 20
    local infoW = w - cartAreaW - 40
    local infoY = y + 25

    -- Engine / Platform Tag
    local badgeColor = (game.platform == "gba") and {0.58, 0.38, 0.96, 0.25} or {0.06, 0.75, 0.50, 0.25}
    local bw, bh = Theme.drawBadge(game.badgeText or "NATIVO", infoX, infoY, badgeColor, accent)
    Theme.drawBadge(game.releaseYear or "2000", infoX + bw + 10, infoY, {0.2, 0.25, 0.35, 0.5}, Theme.colors.textSecondary)

    -- Big Game Title
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.title)
    love.graphics.print(game.title, infoX, infoY + 28)

    -- Subtitle
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print(game.subtitle, infoX, infoY + 58)

    -- Description Box
    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf(game.description or "", infoX, infoY + 95, infoW, "left")

    -- Feature Pills
    local featY = infoY + 160
    local featX = infoX
    for _, feat in ipairs(game.features or {}) do
        local fw = Theme.fonts.small:getWidth(feat) + 14
        Theme.drawBadge(feat, featX, featY, {0.15, 0.20, 0.28, 0.8}, Theme.colors.textSecondary)
        featX = featX + fw + 8
    end

    -- Action Buttons (Play, Mods, Saves, Shaders)
    local btnY = y + h - 68
    local playH = 46
    local gap = 10
    local minSingleRowW = 140 + 110 + 100 + 110 + (gap * 3)
    local actionBoxes = {}

    if infoW >= minSingleRowW then
        -- Single row layout
        local playW = math.max(140, math.min(180, math.floor(infoW * 0.28)))
        local remainW = infoW - playW - (gap * 3)
        local btnW = math.floor(remainW / 3)

        local isPlayHover = (mx >= infoX and mx <= infoX + playW and my >= btnY and my <= btnY + playH)
        local playColor = (game.platform == "gba") and (isPlayHover and Theme.colors.buttonPlayGbaHover or Theme.colors.buttonPlayGba)
                                                    or (isPlayHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
        love.graphics.setColor(playColor)
        love.graphics.rectangle("fill", infoX, btnY, playW, playH, 10, 10)
        love.graphics.setColor(1, 1, 1, 0.98)
        love.graphics.setFont(Theme.fonts.header)
        love.graphics.printf("▶  JOGAR", infoX, btnY + 13, playW, "center")

        local modsX = infoX + playW + gap
        local isModsHover = (mx >= modsX and mx <= modsX + btnW and my >= btnY and my <= btnY + playH)
        Theme.drawCard(modsX, btnY, btnW, playH, 10, isModsHover, false, accent)
        local activeCount = ModManager.getActiveCount(game.id)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf("🧩 MODS (" .. activeCount .. ")", modsX, btnY + 14, btnW, "center")

        local savesX = modsX + btnW + gap
        local isSavesHover = (mx >= savesX and mx <= savesX + btnW and my >= btnY and my <= btnY + playH)
        Theme.drawCard(savesX, btnY, btnW, playH, 10, isSavesHover, false, accent)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf("💾 SAVES", savesX, btnY + 14, btnW, "center")

        local shadersX = savesX + btnW + gap
        local isShadersHover = (mx >= shadersX and mx <= shadersX + btnW and my >= btnY and my <= btnY + playH)
        Theme.drawCard(shadersX, btnY, shadersW, playH, 10, isShadersHover, false, Theme.colors.accentGold)
        love.graphics.setColor(Theme.colors.accentGold)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf("⚡ SHADERS", shadersX, btnY + 14, btnW, "center")

        actionBoxes.play = { x = infoX, y = btnY, w = playW, h = playH }
        actionBoxes.mods = { x = modsX, y = btnY, w = btnW, h = playH }
        actionBoxes.saves = { x = savesX, y = btnY, w = btnW, h = playH }
        actionBoxes.shaders = { x = shadersX, y = btnY, w = btnW, h = playH }
    else
        -- 2-row layout: JOGAR full width on top, sub-buttons on bottom
        local row1Y = y + h - 105
        local row2Y = y + h - 55
        local playW = infoW
        local isPlayHover = (mx >= infoX and mx <= infoX + playW and my >= row1Y and my <= row1Y + 42)
        local playColor = (game.platform == "gba") and (isPlayHover and Theme.colors.buttonPlayGbaHover or Theme.colors.buttonPlayGba)
                                                    or (isPlayHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
        love.graphics.setColor(playColor)
        love.graphics.rectangle("fill", infoX, row1Y, playW, 42, 10, 10)
        love.graphics.setColor(1, 1, 1, 0.98)
        love.graphics.setFont(Theme.fonts.header)
        love.graphics.printf("▶  JOGAR", infoX, row1Y + 11, playW, "center")

        local subBtnW = math.floor((infoW - gap * 2) / 3)
        local modsX = infoX
        local isModsHover = (mx >= modsX and mx <= modsX + subBtnW and my >= row2Y and my <= row2Y + 40)
        Theme.drawCard(modsX, row2Y, subBtnW, 40, 8, isModsHover, false, accent)
        local activeCount = ModManager.getActiveCount(game.id)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("🧩 MODS (" .. activeCount .. ")", modsX, row2Y + 12, subBtnW, "center")

        local savesX = modsX + subBtnW + gap
        local isSavesHover = (mx >= savesX and mx <= savesX + subBtnW and my >= row2Y and my <= row2Y + 40)
        Theme.drawCard(savesX, row2Y, subBtnW, 40, 8, isSavesHover, false, accent)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("💾 SAVES", savesX, row2Y + 12, subBtnW, "center")

        local shadersX = savesX + subBtnW + gap
        local isShadersHover = (mx >= shadersX and mx <= shadersX + subBtnW and my >= row2Y and my <= row2Y + 40)
        Theme.drawCard(shadersX, row2Y, subBtnW, 40, 8, isShadersHover, false, Theme.colors.accentGold)
        love.graphics.setColor(Theme.colors.accentGold)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf("⚡ SHADERS", shadersX, row2Y + 12, subBtnW, "center")

        actionBoxes.play = { x = infoX, y = row1Y, w = playW, h = 42 }
        actionBoxes.mods = { x = modsX, y = row2Y, w = subBtnW, h = 40 }
        actionBoxes.saves = { x = savesX, y = row2Y, w = subBtnW, h = 40 }
        actionBoxes.shaders = { x = shadersX, y = row2Y, w = subBtnW, h = 40 }
    end

    actionBoxes.slotArea = { startX = slotStartX, y = slotY, w = slotBtnW, h = slotBtnH }
    return actionBoxes
end

return GameDetailsView
