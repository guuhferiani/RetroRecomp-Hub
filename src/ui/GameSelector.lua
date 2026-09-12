local GameSelector = {}

function GameSelector.draw(games, selectedGameId, x, y, w, h, Theme, ModManager)
    -- Sidebar Background Panel
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.line(x + w, y, x + w, y + h)

    -- Section Title
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("BIBLIOTECA (" .. #games .. " JOGOS)", x + 20, y + 20)

    -- Game Cards List
    local cardY = y + 45
    local cardW = w - 40
    local cardH = 80
    local mx, my = love.mouse.getPosition()

    for _, game in ipairs(games) do
        local cx = x + 20
        local cy = cardY
        local isSelected = (game.id == selectedGameId)
        local isHovered = (mx >= cx and mx <= cx + cardW and my >= cy and my <= cy + cardH)

        local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
        Theme.drawCard(cx, cy, cardW, cardH, 10, isHovered, isSelected, accent)

        -- Platform indicator mini bar on left
        love.graphics.setColor(accent)
        love.graphics.rectangle("fill", cx + 4, cy + 12, 4, cardH - 24, 2, 2)

        -- Game Title
        love.graphics.setColor(isSelected and Theme.colors.textPrimary or (isHovered and Theme.colors.textPrimary or Theme.colors.textSecondary))
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.print(game.title, cx + 18, cy + 14)

        -- Game Subtitle
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print(game.subtitle, cx + 18, cy + 34)

        -- Mods Count Badge
        local activeMods, totalMods = ModManager.getActiveCount(game.id)
        local modBadgeText = string.format("%d MODS", activeMods)
        local badgeColor = (game.platform == "gba") and {0.58, 0.38, 0.96, 0.25} or {0.06, 0.75, 0.50, 0.25}
        Theme.drawBadge(modBadgeText, cx + 18, cy + 52, badgeColor, accent)

        cardY = cardY + cardH + 12
    end
end

function GameSelector.mousepressed(games, x, y, startX, startY, w)
    local cardY = startY + 45
    local cardW = w - 40
    local cardH = 80

    for _, game in ipairs(games) do
        local cx = startX + 20
        local cy = cardY
        if x >= cx and x <= cx + cardW and y >= cy and y <= cy + cardH then
            return game.id
        end
        cardY = cardY + cardH + 12
    end
    return nil
end

return GameSelector
