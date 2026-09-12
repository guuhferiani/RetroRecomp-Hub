local ModsModal = {}

function ModsModal.draw(game, w, h, Theme, ModManager)
    -- Dimmed backdrop
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, w, h)

    local modalW, modalH = 680, 520
    local mx_pos, my_pos = (w - modalW) / 2, (h - modalH) / 2

    local accent = (game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    Theme.drawCard(mx_pos, my_pos, modalW, modalH, 16, false, true, accent)

    -- Modal Header
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("GERENCIADOR DE MODS: " .. game.title, mx_pos + 28, my_pos + 24)

    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Ative ou desative modificações para esta ROM", mx_pos + 28, my_pos + 50)

    -- Close Button (X)
    local closeX, closeY, closeS = mx_pos + modalW - 45, my_pos + 22, 28
    local curX, curY = love.mouse.getPosition()
    local isCloseHover = (curX >= closeX and curX <= closeX + closeS and curY >= closeY and curY <= closeY + closeS)
    love.graphics.setColor(isCloseHover and Theme.colors.accentRed or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("✕", closeX + 5, closeY + 2)

    -- Mods List
    local mods = ModManager.getMods(game.id)
    local itemY = my_pos + 80
    local itemW = modalW - 56
    local itemH = 68

    local toggles = {}

    for _, mod in ipairs(mods) do
        local ix = mx_pos + 28
        local iy = itemY
        local isItemHover = (curX >= ix and curX <= ix + itemW and curY >= iy and curY <= iy + itemH)

        Theme.drawCard(ix, iy, itemW, itemH, 10, isItemHover, mod.enabled, accent)

        -- Mod Name & Category
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.print(mod.name, ix + 16, iy + 12)

        Theme.drawBadge(mod.category or "Geral", ix + 16 + Theme.fonts.body:getWidth(mod.name) + 12, iy + 10, {0.2, 0.25, 0.35, 0.7}, Theme.colors.textSecondary)

        -- Mod Description
        love.graphics.setColor(Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print(mod.desc or "", ix + 16, iy + 38)

        -- Author tag
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.print("Por: " .. (mod.author or "Autor"), ix + 16, iy + 52)

        -- Toggle Switch
        local swW, swH = 54, 28
        local swX, swY = ix + itemW - swW - 16, iy + (itemH - swH) / 2
        local isSwHover = (curX >= swX and curX <= swX + swW and curY >= swY and curY <= swY + swH)

        love.graphics.setColor(mod.enabled and Theme.colors.accentGbc or {0.2, 0.25, 0.35, 0.9})
        love.graphics.rectangle("fill", swX, swY, swW, swH, 14, 14)

        local knobX = mod.enabled and (swX + swW - 24) or (swX + 4)
        love.graphics.setColor(1, 1, 1, 0.95)
        love.graphics.circle("fill", knobX + 10, swY + 14, 10)

        table.insert(toggles, { modId = mod.id, x = swX, y = swY, w = swW, h = swH })

        itemY = itemY + itemH + 10
    end

    return {
        closeBtn = { x = closeX, y = closeY, w = closeS, h = closeS },
        toggles = toggles,
        modalBounds = { x = mx_pos, y = my_pos, w = modalW, h = modalH }
    }
end

return ModsModal
