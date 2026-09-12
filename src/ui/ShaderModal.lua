local ShaderModal = {}

function ShaderModal.draw(selectedGame, screenW, screenH, Theme, ShaderManager)
    -- Dark semi-transparent background overlay
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    local mw, mh = 660, 490
    local mx = (screenW - mw) / 2
    local my = (screenH - mh) / 2

    -- Modal card background
    Theme.drawCard(mx, my, mw, mh, 16, false, true, Theme.colors.accentGold)

    -- Header bar
    love.graphics.setColor(Theme.colors.accentGold)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("⚡ SELETOR DE SHADERS & FILTROS RETRÔ", mx + 28, my + 22)

    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Escolha o pós-processamento analógico para CRT, LCD ou gráficos nítidos.", mx + 28, my + 48)

    -- Close Button [X]
    local closeBtn = { x = mx + mw - 46, y = my + 18, w = 30, h = 30 }
    love.graphics.setColor(0.2, 0.25, 0.35, 0.8)
    love.graphics.rectangle("fill", closeBtn.x, closeBtn.y, closeBtn.w, closeBtn.h, 6, 6)
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("✕", closeBtn.x, closeBtn.y + 6, closeBtn.w, "center")

    -- Presets List
    local presets = ShaderManager.getPresets()
    local cardW = (mw - 76) / 2
    local cardH = 95
    local startY = my + 82
    local mouseX, mouseY = love.mouse.getPosition()

    local hitboxes = {
        closeBtn = closeBtn,
        modalBounds = { x = mx, y = my, w = mw, h = mh },
        presetButtons = {}
    }

    for i, p in ipairs(presets) do
        local col = ((i - 1) % 2)
        local row = math.floor((i - 1) / 2)
        local cx = mx + 28 + col * (cardW + 20)
        local cy = startY + row * (cardH + 16)

        local isActive = (p.id == ShaderManager.activeShaderId)
        local isHover = (mouseX >= cx and mouseX <= cx + cardW and mouseY >= cy and mouseY <= cy + cardH)

        -- Preset Card Background
        if isActive then
            love.graphics.setColor(0.14, 0.20, 0.30, 0.95)
            love.graphics.rectangle("fill", cx, cy, cardW, cardH, 10, 10)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.9)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", cx, cy, cardW, cardH, 10, 10)
            love.graphics.setLineWidth(1)
        elseif isHover then
            love.graphics.setColor(Theme.colors.panelCardHover)
            love.graphics.rectangle("fill", cx, cy, cardW, cardH, 10, 10)
            love.graphics.setColor(Theme.colors.panelBorderFocus)
            love.graphics.rectangle("line", cx, cy, cardW, cardH, 10, 10)
        else
            love.graphics.setColor(Theme.colors.panelCard)
            love.graphics.rectangle("fill", cx, cy, cardW, cardH, 10, 10)
            love.graphics.setColor(Theme.colors.panelBorder)
            love.graphics.rectangle("line", cx, cy, cardW, cardH, 10, 10)
        end

        -- Left Color Accent Bar
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], 1.0)
        love.graphics.rectangle("fill", cx, cy + 8, 4, cardH - 16, 2, 2)

        -- Preset Name & Tag
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.print(p.name, cx + 16, cy + 12)

        love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.9)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("• " .. p.tag, cx + 16, cy + 32)

        -- Preset Description
        love.graphics.setColor(Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.printf(p.desc, cx + 16, cy + 50, cardW - 32, "left")

        -- Active Status Badge
        if isActive then
            local badgeW, badgeH = 64, 20
            local bx, by = cx + cardW - badgeW - 12, cy + 12
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.25)
            love.graphics.rectangle("fill", bx, by, badgeW, badgeH, 4, 4)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], 1.0)
            love.graphics.printf("ATIVO ✓", bx, by + 3, badgeW, "center")
        end

        table.insert(hitboxes.presetButtons, {
            x = cx, y = cy, w = cardW, h = cardH,
            presetId = p.id
        })
    end

    return hitboxes
end

return ShaderModal
