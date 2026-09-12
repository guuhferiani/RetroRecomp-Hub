local SavesModal = {}

function SavesModal.draw(game, w, h, Theme, SaveManager)
    -- Dimmed backdrop
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local modalW, modalH = 620, 480
    local mx_pos, my_pos = (w - modalW) / 2, (h - modalH) / 2

    local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    Theme.drawCard(mx_pos, my_pos, modalW, modalH, 16, false, true, accent)

    -- Modal Header
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("GERENCIADOR DE SAVES: " .. game.title, mx_pos + 28, my_pos + 24)

    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Selecione o slot que deseja carregar ou fazer backup", mx_pos + 28, my_pos + 50)

    -- Close Button (X)
    local closeX, closeY, closeS = mx_pos + modalW - 45, my_pos + 22, 28
    local curX, curY = love.mouse.getPosition()
    local isCloseHover = (curX >= closeX and curX <= closeX + closeS and curY >= closeY and curY <= closeY + closeS)
    love.graphics.setColor(isCloseHover and Theme.colors.accentRed or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("✕", closeX + 5, closeY + 2)

    -- Slots List
    local slots = SaveManager.getSlots(game.id)
    local itemY = my_pos + 85
    local itemW = modalW - 56
    local itemH = 75

    local slotButtons = {}

    for _, s in ipairs(slots) do
        local ix = mx_pos + 28
        local iy = itemY
        local isSelected = (s.id == (game.currentSlot or 1))
        local isItemHover = (curX >= ix and curX <= ix + itemW and curY >= iy and curY <= iy + itemH)

        Theme.drawCard(ix, iy, itemW, itemH, 10, isItemHover, isSelected, accent)

        love.graphics.setColor(isSelected and Theme.colors.textPrimary or Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.print(s.name, ix + 18, iy + 14)

        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print(s.desc .. " • Salvo em: " .. s.date, ix + 18, iy + 40)

        -- Action / Status Button on Right
        local btnW, btnH = 110, 36
        local bx, by = ix + itemW - btnW - 16, iy + (itemH - btnH) / 2
        local isBtnHover = (curX >= bx and curX <= bx + btnW and curY >= by and curY <= by + btnH)

        if isSelected then
            love.graphics.setColor(Theme.colors.accentGbc)
            love.graphics.rectangle("fill", bx, by, btnW, btnH, 8, 8)
            love.graphics.setColor(0.05, 0.07, 0.10, 1.0)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.printf("✓ ATIVO", bx, by + 8, btnW, "center")
        else
            Theme.drawCard(bx, by, btnW, btnH, 8, isBtnHover, false, accent)
            love.graphics.setColor(Theme.colors.textPrimary)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.printf("ATIVAR", bx, by + 8, btnW, "center")
            table.insert(slotButtons, { slotId = s.id, x = bx, y = by, w = btnW, h = btnH })
        end

        itemY = itemY + itemH + 12
    end

    return {
        closeBtn = { x = closeX, y = closeY, w = closeS, h = closeS },
        slotButtons = slotButtons,
        modalBounds = { x = mx_pos, y = my_pos, w = modalW, h = modalH }
    }
end

return SavesModal
