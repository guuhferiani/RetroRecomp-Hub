local Header = {
    tabs = {
        { id = "all", label = "★ TODOS" },
        { id = "gbc", label = "🎮 GB/GBC" },
        { id = "gba", label = "⚡ GBA" },
        { id = "snes", label = "🕹️ SNES" },
        { id = "ps1", label = "💿 PS1" }
    }
}

function Header.draw(w, activePlatform, Theme, safeLeft, safeRight)
    local headerH = 64
    safeLeft = safeLeft or 0
    safeRight = safeRight or 0

    -- Glass header background
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", 0, 0, w, headerH)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.line(0, headerH, w, headerH)

    -- Hub Brand Logo & Title
    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("⚡ RETRORECOMP", 20 + safeLeft, 20)

    -- Platform Tabs (5 consoles)
    local tabStartX = 20 + safeLeft + 200
    local tabW, tabH = 96, 36
    local mx, my = love.mouse.getPosition()

    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + 6)
        local ty = 14
        local isSelected = (tab.id == activePlatform)
        local isHovered = (mx >= tx and mx <= tx + tabW and my >= ty and my <= ty + tabH)

        if isSelected then
            love.graphics.setColor(Theme.colors.panelCardHover)
            love.graphics.rectangle("fill", tx, ty, tabW, tabH, 8, 8)
            love.graphics.setColor(Theme.colors.accentGbc)
            love.graphics.rectangle("fill", tx + 12, ty + tabH - 3, tabW - 24, 3, 2, 2)
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

    -- Touch toggle button on top right
    local MobileBridge = require("src.core.MobileBridge")
    local touchLabel = MobileBridge.virtualControlsEnabled and "📱 TOUCH: ON" or "📱 TOUCH: OFF"
    local touchBg = MobileBridge.virtualControlsEnabled and {0.06, 0.75, 0.45, 0.25} or {0.2, 0.25, 0.35, 0.4}
    local touchColor = MobileBridge.virtualControlsEnabled and Theme.colors.accentGbc or Theme.colors.textMuted
    local touchBtnX = w - safeRight - 260
    Theme.drawBadge(touchLabel, touchBtnX, 18, touchBg, touchColor)

    -- Status pill on top right
    local statusText = "● PRONTO"
    love.graphics.setFont(Theme.fonts.small)
    Theme.drawBadge(statusText, w - safeRight - 120, 18, {0.06, 0.75, 0.45, 0.2}, Theme.colors.accentGbc)

    return headerH
end

function Header.mousepressed(x, y, activePlatform, w, safeLeft, safeRight)
    safeLeft = safeLeft or 0
    safeRight = safeRight or 0

    -- Check Touch Toggle Button
    local touchBtnX = w - safeRight - 260
    if w and x >= touchBtnX - 10 and x <= touchBtnX + 130 and y >= 14 and y <= 50 then
        local MobileBridge = require("src.core.MobileBridge")
        MobileBridge.toggleControls()
        return nil, true
    end

    local tabStartX = 20 + safeLeft + 200
    local tabW, tabH = 96, 36

    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + 6)
        local ty = 14
        if x >= tx and x <= tx + tabW and y >= ty and y <= ty + tabH then
            return tab.id, false
        end
    end

    return nil, false
end

return Header
