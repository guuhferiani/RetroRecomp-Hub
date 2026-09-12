local CartridgeRenderer = {
    shineTimer = 0,
    hoverTiltX = 0,
    hoverTiltY = 0
}

function CartridgeRenderer.update(dt, mx, my, cx, cy)
    CartridgeRenderer.shineTimer = (CartridgeRenderer.shineTimer + dt * 0.8) % 3.0

    -- Parallax tilt relative to cartridge center
    local dx = (mx - cx) / 200
    local dy = (my - cy) / 200
    dx = math.max(-1, math.min(1, dx))
    dy = math.max(-1, math.min(1, dy))
    CartridgeRenderer.hoverTiltX = CartridgeRenderer.hoverTiltX + (dx * 12 - CartridgeRenderer.hoverTiltX) * dt * 5
    CartridgeRenderer.hoverTiltY = CartridgeRenderer.hoverTiltY + (dy * 12 - CartridgeRenderer.hoverTiltY) * dt * 5
end

function CartridgeRenderer.draw(game, cx, cy, scale)
    scale = scale or 1.0
    love.graphics.push()
    love.graphics.translate(cx + CartridgeRenderer.hoverTiltX, cy + CartridgeRenderer.hoverTiltY)
    love.graphics.scale(scale, scale)

    if game.cartType == "gba" then
        CartridgeRenderer.drawGbaCartridge(game)
    else
        CartridgeRenderer.drawGbCartridge(game)
    end

    love.graphics.pop()
end

function CartridgeRenderer.drawGbCartridge(game)
    local w, h = 210, 240
    local ox, oy = -w / 2, -h / 2

    -- Soft Drop Shadow
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", ox + 10, oy + 12, w, h, 14, 14)

    -- Cartridge Outer Body (Plastic Shell)
    local c = game.cartColor or {0.20, 0.45, 0.75, 0.85}
    love.graphics.setColor(c[1], c[2], c[3], c[4] or 1.0)
    love.graphics.rectangle("fill", ox, oy, w, h, 14, 14)

    -- Top-Right Notch (Classic Game Boy feature)
    love.graphics.setColor(0.05, 0.07, 0.10, 1.0)
    love.graphics.rectangle("fill", ox + w - 24, oy, 24, 28, 4, 4)
    love.graphics.setColor(c[1] * 0.7, c[2] * 0.7, c[3] * 0.7, 1.0)
    love.graphics.rectangle("line", ox + w - 24, oy, 24, 28, 4, 4)

    -- Cartridge Border Highlight / Bevel
    love.graphics.setColor(1, 1, 1, 0.18)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", ox + 1, oy + 1, w - 2, h - 2, 14, 14)
    love.graphics.setLineWidth(1)

    -- Top Finger Grip Ridges
    love.graphics.setColor(0, 0, 0, 0.20)
    for i = 1, 5 do
        love.graphics.rectangle("fill", ox + 22, oy + 14 + (i * 7), w - 44, 3, 2, 2)
    end

    -- Embossed "Nintendo GAME BOY™" Area
    local pillW, pillH = 140, 24
    local px, py = ox + (w - pillW) / 2, oy + 62
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("fill", px, py, pillW, pillH, 12, 12)
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.printf("Nintendo GAME BOY", px, py + 5, pillW, "center")

    -- Label Recess Area
    local labelW, labelH = 160, 130
    local lx, ly = ox + (w - labelW) / 2, oy + 94
    love.graphics.setColor(0, 0, 0, 0.40)
    love.graphics.rectangle("fill", lx - 2, ly - 2, labelW + 4, labelH + 4, 8, 8)

    -- Sticker Label Graphic
    local lc = game.labelColor or {0.15, 0.35, 0.65}
    love.graphics.setColor(lc[1], lc[2], lc[3], 1.0)
    love.graphics.rectangle("fill", lx, ly, labelW, labelH, 6, 6)

    -- Decorative Label Banner
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.polygon("fill", lx, ly, lx + labelW, ly + 35, lx + labelW, ly, lx, ly)

    -- Game Title on Label
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.printf(game.title, lx + 8, ly + 25, labelW - 16, "center")

    -- Edition Badge on Label
    local accent = game.cartAccent or {1, 0.8, 0.2, 1}
    love.graphics.setColor(accent[1], accent[2], accent[3], 0.9)
    love.graphics.printf(game.subtitle or "EDITION", lx + 6, ly + 58, labelW - 12, "center")

    -- Nintendo Seal of Quality Circle
    local sealX, sealY, sealR = lx + labelW - 28, ly + labelH - 28, 16
    love.graphics.setColor(0.95, 0.85, 0.25, 0.9)
    love.graphics.circle("line", sealX, sealY, sealR)
    love.graphics.setColor(0.95, 0.85, 0.25, 0.2)
    love.graphics.circle("fill", sealX, sealY, sealR)
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("SEAL", sealX - 16, sealY - 6, 32, "center")

    -- Holographic Foil Shine Wave Animation
    local shinePos = (CartridgeRenderer.shineTimer / 3.0) * (labelW * 2) - labelW / 2
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.18)
    love.graphics.polygon("fill", 
        lx + shinePos, ly,
        lx + shinePos + 35, ly,
        lx + shinePos + 10, ly + labelH,
        lx + shinePos - 25, ly + labelH
    )
    love.graphics.setBlendMode("alpha")
end

function CartridgeRenderer.drawGbaCartridge(game)
    local w, h = 250, 175
    local ox, oy = -w / 2, -h / 2

    -- Drop Shadow
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", ox + 12, oy + 12, w, h, 10, 10)

    -- Cartridge Outer Body
    local c = game.cartColor or {0.88, 0.28, 0.12, 0.90}
    love.graphics.setColor(c[1], c[2], c[3], c[4] or 1.0)
    love.graphics.rectangle("fill", ox, oy, w, h, 10, 10)

    -- Top Lip Curve
    love.graphics.setColor(c[1] * 0.8, c[2] * 0.8, c[3] * 0.8, 1.0)
    love.graphics.rectangle("fill", ox + 15, oy, w - 30, 22, 6, 6)

    -- Embossed "GAME BOY ADVANCE" Text
    love.graphics.setColor(1, 1, 1, 0.65)
    love.graphics.printf("GAME BOY ADVANCE", ox, oy + 5, w, "center")

    -- Side Grip Grooves
    love.graphics.setColor(0, 0, 0, 0.25)
    for i = 1, 6 do
        love.graphics.rectangle("fill", ox + 6, oy + 32 + (i * 9), 6, 4, 2, 2)
        love.graphics.rectangle("fill", ox + w - 12, oy + 32 + (i * 9), 6, 4, 2, 2)
    end

    -- Label Recess Area
    local labelW, labelH = 195, 110
    local lx, ly = ox + (w - labelW) / 2, oy + 36
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", lx - 2, ly - 2, labelW + 4, labelH + 4, 6, 6)

    -- Sticker Label Graphic
    local lc = game.labelColor or {0.75, 0.22, 0.08}
    love.graphics.setColor(lc[1], lc[2], lc[3], 1.0)
    love.graphics.rectangle("fill", lx, ly, labelW, labelH, 4, 4)

    -- Title & Subtitle on Label
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.printf(game.title, lx + 6, ly + 20, labelW - 12, "center")

    local accent = game.cartAccent or {1, 0.5, 0.3, 1}
    love.graphics.setColor(accent[1], accent[2], accent[3], 0.9)
    love.graphics.printf(game.subtitle or "32-BIT GBA", lx + 6, ly + 46, labelW - 12, "center")

    -- Region / Rating Pill
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", lx + 12, ly + labelH - 26, 45, 16, 4, 4)
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("USA-E", lx + 12, ly + labelH - 24, 45, "center")

    -- Holographic Foil Shine Wave Animation
    local shinePos = (CartridgeRenderer.shineTimer / 3.0) * (labelW * 2) - labelW / 2
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.20)
    love.graphics.polygon("fill", 
        lx + shinePos, ly,
        lx + shinePos + 40, ly,
        lx + shinePos + 15, ly + labelH,
        lx + shinePos - 25, ly + labelH
    )
    love.graphics.setBlendMode("alpha")
end

return CartridgeRenderer
