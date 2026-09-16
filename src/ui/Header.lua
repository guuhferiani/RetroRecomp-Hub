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
    local mx, my = love.mouse.getPosition()

    -- Glass header background
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", 0, 0, w, headerH)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.line(0, headerH, w, headerH)

    -- Hub Brand Logo & Title
    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.header)
    local logoText = (w < 800) and "⚡ HUB" or "⚡ RETRORECOMP"
    love.graphics.print(logoText, 18 + safeLeft, 20)
    local logoW = Theme.fonts.header:getWidth(logoText)

    -- Right Action Buttons: Touch & Import
    local MobileBridge = require("src.core.MobileBridge")
    local rightX = w - safeRight - 16

    -- Status Pill
    local statusText = "● PRONTO"
    local statusW = Theme.fonts.small:getWidth(statusText) + 16
    local statusX = rightX - statusW
    Theme.drawBadge(statusText, statusX, 18, {0.06, 0.75, 0.45, 0.2}, Theme.colors.accentGbc)

    -- Touch Toggle Button
    local touchLabel = MobileBridge.virtualControlsEnabled and "📱 TOUCH: ON" or "📱 TOUCH: OFF"
    local touchBg = MobileBridge.virtualControlsEnabled and {0.06, 0.75, 0.45, 0.25} or {0.2, 0.25, 0.35, 0.4}
    local touchColor = MobileBridge.virtualControlsEnabled and Theme.colors.accentGbc or Theme.colors.textMuted
    local touchW = Theme.fonts.small:getWidth(touchLabel) + 18
    local touchBtnX = statusX - touchW - 10
    Theme.drawBadge(touchLabel, touchBtnX, 18, touchBg, touchColor)

    -- Import ROM Quick Button
    local importLabel = "📥 IMPORTAR"
    local isImportHover = (mx >= touchBtnX - 110 and mx <= touchBtnX - 10 and my >= 16 and my <= 48)
    local importBg = isImportHover and {0.15, 0.40, 0.60, 0.6} or {0.12, 0.25, 0.40, 0.4}
    local importW = Theme.fonts.small:getWidth(importLabel) + 18
    local importBtnX = touchBtnX - importW - 10
    Theme.drawBadge(importLabel, importBtnX, 18, importBg, Theme.colors.accentCyan or Theme.colors.accentGbc)

    -- Platform Tabs (Calculate responsive start and width)
    local availableTabSpace = importBtnX - (18 + safeLeft + logoW + 20)
    local tabCount = #Header.tabs
    local tabGap = 6
    local maxTabW = 96
    local tabW = math.max(68, math.min(maxTabW, math.floor((availableTabSpace - (tabCount - 1) * tabGap) / tabCount)))
    local tabStartX = 18 + safeLeft + logoW + 20

    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + tabGap)
        local ty = 14
        local tabH = 36
        local isSelected = (tab.id == activePlatform)
        local isHovered = (mx >= tx and mx <= tx + tabW and my >= ty and my <= ty + tabH)

        if isSelected then
            love.graphics.setColor(Theme.colors.panelCardHover)
            love.graphics.rectangle("fill", tx, ty, tabW, tabH, 8, 8)
            love.graphics.setColor(Theme.colors.accentGbc)
            love.graphics.rectangle("fill", tx + 8, ty + tabH - 3, tabW - 16, 3, 2, 2)
            love.graphics.setColor(Theme.colors.textPrimary)
        elseif isHovered then
            love.graphics.setColor(Theme.colors.panelCard)
            love.graphics.rectangle("fill", tx, ty, tabW, tabH, 8, 8)
            love.graphics.setColor(Theme.colors.textPrimary)
        else
            love.graphics.setColor(Theme.colors.textSecondary)
        end

        love.graphics.setFont((tabW < 80) and Theme.fonts.small or Theme.fonts.body)
        local tabLabel = (tabW < 80) and tab.id:upper() or tab.label
        love.graphics.printf(tabLabel, tx, ty + ((tabW < 80) and 10 or 9), tabW, "center")
    end

    return headerH
end

function Header.mousepressed(x, y, activePlatform, w, safeLeft, safeRight)
    safeLeft = safeLeft or 0
    safeRight = safeRight or 0
    local Theme = require("src.core.Theme")

    -- Right Action Buttons
    local rightX = w - safeRight - 16
    local statusText = "● PRONTO"
    local statusW = Theme.fonts.small:getWidth(statusText) + 16
    local statusX = rightX - statusW

    local MobileBridge = require("src.core.MobileBridge")
    local touchLabel = MobileBridge.virtualControlsEnabled and "📱 TOUCH: ON" or "📱 TOUCH: OFF"
    local touchW = Theme.fonts.small:getWidth(touchLabel) + 18
    local touchBtnX = statusX - touchW - 10

    local importLabel = "📥 IMPORTAR"
    local importW = Theme.fonts.small:getWidth(importLabel) + 18
    local importBtnX = touchBtnX - importW - 10

    -- Check Import Button
    if x >= importBtnX and x <= importBtnX + importW and y >= 14 and y <= 50 then
        return nil, false, true
    end

    -- Check Touch Toggle Button
    if x >= touchBtnX and x <= touchBtnX + touchW and y >= 14 and y <= 50 then
        MobileBridge.toggleControls()
        return nil, true, false
    end

    -- Check Platform Tabs
    local logoText = (w < 800) and "⚡ HUB" or "⚡ RETRORECOMP"
    local logoW = Theme.fonts.header:getWidth(logoText)
    local availableTabSpace = importBtnX - (18 + safeLeft + logoW + 20)
    local tabCount = #Header.tabs
    local tabGap = 6
    local maxTabW = 96
    local tabW = math.max(68, math.min(maxTabW, math.floor((availableTabSpace - (tabCount - 1) * tabGap) / tabCount)))
    local tabStartX = 18 + safeLeft + logoW + 20

    for i, tab in ipairs(Header.tabs) do
        local tx = tabStartX + (i - 1) * (tabW + tabGap)
        local ty = 14
        local tabH = 36
        if x >= tx and x <= tx + tabW and y >= ty and y <= ty + tabH then
            return tab.id, false, false
        end
    end

    return nil, false, false
end

return Header

