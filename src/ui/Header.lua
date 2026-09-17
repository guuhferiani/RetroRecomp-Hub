local PlatformManager = require("src.core.PlatformManager")

local Header = {
    isDropdownOpen = false,
    dropdownHitboxes = {}
}

function Header.draw(w, activePlatform, selectedGame, Theme, safeLeft, safeRight)
    safeLeft = safeLeft or 0
    safeRight = safeRight or 0
    local mx, my = love.mouse.getPosition()
    local hitboxes = {}

    local startX = 14 + safeLeft
    local contentW = w - safeLeft - safeRight

    -- Row 1: Logo & Utility Buttons (Y: 10 to 44)
    local logoW, logoH = Theme.drawLogo(startX, 12)

    -- Top Right Utility Buttons: [ ⚙ ] and [ ✕ ]
    local btnSize = 32
    local closeX = w - safeRight - btnSize - 14
    local gearX = closeX - btnSize - 8
    local row1Y = 12

    -- Gear / Settings Button
    local isGearHover = (mx >= gearX and mx <= gearX + btnSize and my >= row1Y and my <= row1Y + btnSize)
    love.graphics.setColor(isGearHover and Theme.colors.panelCardHover or Theme.colors.recompToolBg)
    love.graphics.rectangle("fill", gearX, row1Y, btnSize, btnSize, 6, 6)
    love.graphics.setColor(Theme.colors.recompToolBorder)
    love.graphics.rectangle("line", gearX, row1Y, btnSize, btnSize, 6, 6)
    love.graphics.setColor(isGearHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
    Theme.drawGearIcon(gearX + btnSize/2, row1Y + btnSize/2, 8)
    hitboxes.gear = { x = gearX, y = row1Y, w = btnSize, h = btnSize }

    -- Close / Quit Button
    local isCloseHover = (mx >= closeX and mx <= closeX + btnSize and my >= row1Y and my <= row1Y + btnSize)
    love.graphics.setColor(isCloseHover and {0.6, 0.15, 0.18, 0.9} or Theme.colors.recompToolBg)
    love.graphics.rectangle("fill", closeX, row1Y, btnSize, btnSize, 6, 6)
    love.graphics.setColor(Theme.colors.recompToolBorder)
    love.graphics.rectangle("line", closeX, row1Y, btnSize, btnSize, 6, 6)
    love.graphics.setColor(isCloseHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
    Theme.drawCloseIcon(closeX + btnSize/2, row1Y + btnSize/2, 7)
    hitboxes.close = { x = closeX, y = row1Y, w = btnSize, h = btnSize }

    -- Row 2: Toolbar (Y: 52 to 92)
    local row2Y = 52
    local toolH = 34
    local currentX = startX

    -- A. Game Version Selector Button [ R ▼ ]
    local selW = 60
    local isSelHover = (mx >= currentX and mx <= currentX + selW and my >= row2Y and my <= row2Y + toolH)
    local vColor = (selectedGame and selectedGame.versionColor) or Theme.colors.accentRed
    love.graphics.setColor(isSelHover and {vColor[1]*1.1, vColor[2]*1.1, vColor[3]*1.1, 1.0} or vColor)
    love.graphics.rectangle("fill", currentX, row2Y, selW, toolH, 6, 6)
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.rectangle("line", currentX, row2Y, selW, toolH, 6, 6)

    -- Text code e.g. "R"
    love.graphics.setColor(1, 1, 1, 1.0)
    love.graphics.setFont(Theme.fonts.header)
    local codeText = (selectedGame and selectedGame.code) or "R"
    love.graphics.print(codeText, currentX + 14, row2Y + 7)

    -- Small down arrow
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    Theme.drawDropdownArrow(currentX + 44, row2Y + toolH/2 + 1, 4)

    hitboxes.gameDropdown = { x = currentX, y = row2Y, w = selW, h = toolH }
    currentX = currentX + selW + 8

    -- Helper to draw square toolbar buttons
    local function drawToolBtn(id, drawIconFunc, hasBeta)
        local btnW = 38
        local isHover = (mx >= currentX and mx <= currentX + btnW and my >= row2Y and my <= row2Y + toolH)
        
        love.graphics.setColor(isHover and Theme.colors.recompToolHover or Theme.colors.recompToolBg)
        love.graphics.rectangle("fill", currentX, row2Y, btnW, toolH, 6, 6)
        love.graphics.setColor(Theme.colors.recompToolBorder)
        love.graphics.rectangle("line", currentX, row2Y, btnW, toolH, 6, 6)

        -- Icon
        love.graphics.setColor(isHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
        drawIconFunc(currentX + btnW/2, row2Y + (hasBeta and (toolH/2 - 4) or (toolH/2)), 7.5)

        -- Beta badge
        if hasBeta then
            love.graphics.setColor(0.92, 0.72, 0.20, 1.0)
            love.graphics.rectangle("fill", currentX + 6, row2Y + toolH - 10, btnW - 12, 8, 2, 2)
            love.graphics.setColor(0.08, 0.08, 0.10, 1.0)
            love.graphics.setFont(Theme.fonts.pixel)
            love.graphics.printf("BETA", currentX, row2Y + toolH - 11, btnW, "center")
        end

        hitboxes[id] = { x = currentX, y = row2Y, w = btnW, h = toolH }
        currentX = currentX + btnW + 7
    end

    -- B. Action Icons
    drawToolBtn("import", Theme.drawCloudImportIcon, false)
    drawToolBtn("search", Theme.drawSearchIcon, false)
    drawToolBtn("mods", Theme.drawGlobeIcon, true)
    drawToolBtn("shaders", Theme.drawScreenIcon, true)
    drawToolBtn("platformSwap", Theme.drawSwapIcon, false)

    local totalHeaderH = 96

    -- Subtle separator line below header
    love.graphics.setColor(Theme.colors.recompCardBorder)
    love.graphics.line(0, totalHeaderH, w, totalHeaderH)

    return totalHeaderH, hitboxes
end

function Header.drawDropdown(x, y, w, selectedGameId, Theme)
    local dropW = math.min(320, w - 28)
    local itemH = 46
    local games = PlatformManager.games
    local totalH = #games * itemH + 12
    local mx, my = love.mouse.getPosition()
    local dropHitboxes = {}

    -- Backdrop blur / shadow
    love.graphics.setColor(0.03, 0.03, 0.04, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Card popup
    love.graphics.setColor(Theme.colors.recompCardBg)
    love.graphics.rectangle("fill", x, y, dropW, totalH, 8, 8)
    love.graphics.setColor(Theme.colors.panelBorderFocus)
    love.graphics.rectangle("line", x, y, dropW, totalH, 8, 8)

    local itemY = y + 6
    for _, g in ipairs(games) do
        local isHover = (mx >= x + 6 and mx <= x + dropW - 6 and my >= itemY and my <= itemY + itemH - 4)
        local isSelected = (g.id == selectedGameId)

        if isSelected then
            love.graphics.setColor(0.20, 0.22, 0.30, 0.9)
            love.graphics.rectangle("fill", x + 6, itemY, dropW - 12, itemH - 4, 6, 6)
        elseif isHover then
            love.graphics.setColor(0.14, 0.15, 0.20, 0.8)
            love.graphics.rectangle("fill", x + 6, itemY, dropW - 12, itemH - 4, 6, 6)
        end

        -- Version initial badge
        local badgeW = 28
        local vColor = g.versionColor or Theme.colors.accentRed
        love.graphics.setColor(vColor)
        love.graphics.rectangle("fill", x + 12, itemY + 6, badgeW, itemH - 16, 4, 4)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf(g.code or "G", x + 12, itemY + 11, badgeW, "center")

        -- Game Title
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.setColor(isSelected and Theme.colors.textPrimary or Theme.colors.textSecondary)
        love.graphics.print(g.title, x + 48, itemY + 7)

        -- Platform badge
        love.graphics.setFont(Theme.fonts.pixel)
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.print(g.platform:upper() .. " • " .. (g.releaseYear or ""), x + 48, itemY + 23)

        table.insert(dropHitboxes, {
            gameId = g.id,
            x = x + 6,
            y = itemY,
            w = dropW - 12,
            h = itemH - 4
        })

        itemY = itemY + itemH
    end

    Header.dropdownHitboxes = dropHitboxes
    Header.dropdownBounds = { x = x, y = y, w = dropW, h = totalH }
end

function Header.mousepressed(x, y, hitboxes)
    if not hitboxes then return nil end

    if hitboxes.gear and x >= hitboxes.gear.x and x <= hitboxes.gear.x + hitboxes.gear.w and y >= hitboxes.gear.y and y <= hitboxes.gear.y + hitboxes.gear.h then
        return "shaders"
    end

    if hitboxes.close and x >= hitboxes.close.x and x <= hitboxes.close.x + hitboxes.close.w and y >= hitboxes.close.y and y <= hitboxes.close.y + hitboxes.close.h then
        love.event.quit()
        return "quit"
    end

    if hitboxes.gameDropdown and x >= hitboxes.gameDropdown.x and x <= hitboxes.gameDropdown.x + hitboxes.gameDropdown.w and y >= hitboxes.gameDropdown.y and y <= hitboxes.gameDropdown.y + hitboxes.gameDropdown.h then
        Header.isDropdownOpen = not Header.isDropdownOpen
        return "toggleDropdown"
    end

    if hitboxes.import and x >= hitboxes.import.x and x <= hitboxes.import.x + hitboxes.import.w and y >= hitboxes.import.y and y <= hitboxes.import.y + hitboxes.import.h then
        return "import"
    end

    if hitboxes.search and x >= hitboxes.search.x and x <= hitboxes.search.x + hitboxes.search.w and y >= hitboxes.search.y and y <= hitboxes.search.y + hitboxes.search.h then
        return "import"
    end

    if hitboxes.mods and x >= hitboxes.mods.x and x <= hitboxes.mods.x + hitboxes.mods.w and y >= hitboxes.mods.y and y <= hitboxes.mods.y + hitboxes.mods.h then
        return "mods"
    end

    if hitboxes.shaders and x >= hitboxes.shaders.x and x <= hitboxes.shaders.x + hitboxes.shaders.w and y >= hitboxes.shaders.y and y <= hitboxes.shaders.y + hitboxes.shaders.h then
        return "shaders"
    end

    if hitboxes.platformSwap and x >= hitboxes.platformSwap.x and x <= hitboxes.platformSwap.x + hitboxes.platformSwap.w and y >= hitboxes.platformSwap.y and y <= hitboxes.platformSwap.y + hitboxes.platformSwap.h then
        return "platformSwap"
    end

    return nil
end

return Header


