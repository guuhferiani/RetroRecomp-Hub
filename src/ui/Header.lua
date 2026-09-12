local Header = {
    tabs = {
        { id = "all", label = "★ TODOS" },
        { id = "gbc", label = "🎮 GB / GBC" },
        { id = "gba", label = "⚡ GBA" }
    }
}

function Header.draw(w, activePlatform, Theme)
    local headerH = 64

    -- Glass header background
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", 0, 0, w, headerH)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.line(0, headerH, w, headerH)

    -- Hub Brand Logo & Title
    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("⚡ RETRORECOMP HUB", 24, 20)

    -- Platform Tabs
    local tabStartX = 320
    local tabW, tabH = 120, 36
    local mx, my = love.mouse.getPosition()

    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + 10)
        local ty = 14
        local isSelected = (tab.id == activePlatform)
        local isHovered = (mx >= tx and mx <= tx + tabW and my >= ty and my <= ty + tabH)

        if isSelected then
            love.graphics.setColor(Theme.colors.panelCardHover)
            love.graphics.rectangle("fill", tx, ty, tabW, tabH, 8, 8)
            love.graphics.setColor(Theme.colors.accentGbc)
            love.graphics.rectangle("fill", tx + 15, ty + tabH - 3, tabW - 30, 3, 2, 2)
            love.graphics.setColor(Theme.colors.textPrimary)
        elseif isHovered then
            love.graphics.setColor(Theme.colors.panelCard)
            love.graphics.rectangle("fill", tx, ty, tabW, tabH, 8, 8)
            love.graphics.setColor(Theme.colors.textPrimary)
        else
            love.graphics.setColor(Theme.colors.textSecondary)
        end

        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf(tab.label, tx, ty + 9, tabW, "center")
    end

    -- Status pill on top right
    local statusText = "● PRONTO"
    love.graphics.setFont(Theme.fonts.small)
    Theme.drawBadge(statusText, w - 130, 18, {0.06, 0.75, 0.45, 0.2}, Theme.colors.accentGbc)

    return headerH
end

function Header.mousepressed(x, y, activePlatform)
    local tabStartX = 320
    local tabW, tabH = 120, 36
    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + 10)
        local ty = 14
        if x >= tx and x <= tx + tabW and y >= ty and y <= ty + tabH then
            return tab.id
        end
    end
    return nil
end

return Header
