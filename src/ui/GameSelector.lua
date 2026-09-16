local RomManager = require("src.core.RomManager")

local GameSelector = {
    scrollOffset = 0,
    maxScroll = 0
}

function GameSelector.draw(games, selectedGameId, x, y, w, h, Theme, ModManager)
    -- Sidebar Background Panel
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.line(x + w, y, x + w, y + h)

    -- Section Title
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("BIBLIOTECA (" .. #games .. " JOGOS)", x + 20, y + 16)

    -- Clip game list
    local listY = y + 42
    local listH = h - 48
    love.graphics.setScissor(x, listY, w, listH)

    -- Game Cards List
    local cardW = w - 40
    local cardH = 82
    local totalHeight = #games * (cardH + 10)
    GameSelector.maxScroll = math.max(0, totalHeight - listH)
    GameSelector.scrollOffset = math.max(0, math.min(GameSelector.scrollOffset, GameSelector.maxScroll))

    local cardY = listY + 4 - GameSelector.scrollOffset
    local mx, my = love.mouse.getPosition()

    for _, game in ipairs(games) do
        local cx = x + 20
        local cy = cardY
        local isSelected = (game.id == selectedGameId)
        local isHovered = (mx >= cx and mx <= cx + cardW and my >= cy and my <= cy + cardH and my >= listY and my <= listY + listH)

        local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
        Theme.drawCard(cx, cy, cardW, cardH, 10, isHovered, isSelected, accent)

        -- Platform indicator mini bar on left
        love.graphics.setColor(accent)
        love.graphics.rectangle("fill", cx + 4, cy + 12, 4, cardH - 24, 2, 2)

        -- Game Title
        love.graphics.setColor(isSelected and Theme.colors.textPrimary or (isHovered and Theme.colors.textPrimary or Theme.colors.textSecondary))
        love.graphics.setFont(Theme.fonts.body)
        local titleText = game.title
        if Theme.fonts.body:getWidth(titleText) > cardW - 60 then
            titleText = titleText:sub(1, 20) .. "..."
        end
        love.graphics.print(titleText, cx + 16, cy + 12)

        -- Game Subtitle
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        local subText = game.subtitle or ""
        if Theme.fonts.small:getWidth(subText) > cardW - 35 then
            subText = subText:sub(1, 25) .. "..."
        end
        love.graphics.print(subText, cx + 16, cy + 33)

        -- ROM Status Indicator
        local hasRom = RomManager.getRomStatus(game)
        local romStatusText = hasRom and "✓ ROM" or "⚠️ IMPORTAR"
        local romStatusBg = hasRom and {0.06, 0.75, 0.50, 0.20} or {0.95, 0.65, 0.15, 0.25}
        local romStatusColor = hasRom and Theme.colors.accentGbc or {1.0, 0.75, 0.25, 1.0}
        local rw, rh = Theme.drawBadge(romStatusText, cx + 16, cy + 54, romStatusBg, romStatusColor)

        -- Mods Count Badge
        local activeMods, totalMods = ModManager.getActiveCount(game.id)
        if totalMods > 0 then
            local modBadgeText = string.format("%d MODS", activeMods)
            local badgeColor = (game.platform == "gba") and {0.58, 0.38, 0.96, 0.25} or {0.20, 0.25, 0.35, 0.5}
            Theme.drawBadge(modBadgeText, cx + 16 + rw + 6, cy + 54, badgeColor, Theme.colors.textSecondary)
        end

        cardY = cardY + cardH + 10
    end

    love.graphics.setScissor()
end

function GameSelector.mousepressed(games, x, y, startX, startY, w, h)
    local listY = startY + 42
    local listH = (h or 656) - 48
    local cardW = w - 40
    local cardH = 82
    local cardY = listY + 4 - GameSelector.scrollOffset

    for _, game in ipairs(games) do
        local cx = startX + 20
        local cy = cardY
        if x >= cx and x <= cx + cardW and y >= cy and y <= cy + cardH and y >= listY and y <= listY + listH then
            return game.id
        end
        cardY = cardY + cardH + 10
    end
    return nil
end

function GameSelector.wheelmoved(dx, dy)
    GameSelector.scrollOffset = math.max(0, math.min(GameSelector.scrollOffset - dy * 35, GameSelector.maxScroll))
end

function GameSelector.touchmoved(dy)
    GameSelector.scrollOffset = math.max(0, math.min(GameSelector.scrollOffset - dy, GameSelector.maxScroll))
end

return GameSelector

