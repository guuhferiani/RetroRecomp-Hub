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
    elseif game.cartType == "snes" then
        CartridgeRenderer.drawSnesCartridge(game)
    elseif game.cartType == "ps1" then
        CartridgeRenderer.drawPs1JewelCase(game)
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

function CartridgeRenderer.drawSnesCartridge(game)
    local w, h = 260, 185
    local ox, oy = -w / 2, -h / 2

    -- Drop Shadow
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", ox + 12, oy + 12, w, h, 12, 12)

    -- SNES Grey Plastic Shell
    local baseGrey = game.cartColor or {0.74, 0.75, 0.78, 1.0}
    love.graphics.setColor(baseGrey)
    love.graphics.rectangle("fill", ox, oy, w, h, 12, 12)

    -- Top Recessed Grip Area (Darker Grey with ridges)
    local darkGrey = {baseGrey[1] * 0.85, baseGrey[2] * 0.85, baseGrey[3] * 0.85, 1.0}
    love.graphics.setColor(darkGrey)
    love.graphics.rectangle("fill", ox + 18, oy + 10, w - 36, 32, 6, 6)

    -- Top Vents
    love.graphics.setColor(0, 0, 0, 0.25)
    for i = 1, 4 do
        love.graphics.rectangle("fill", ox + 35, oy + 14 + (i * 6), w - 70, 3, 2, 2)
    end

    -- Left and Right Locking Slots
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", ox + 4, oy + h - 45, 10, 35, 3, 3)
    love.graphics.rectangle("fill", ox + w - 14, oy + h - 45, 10, 35, 3, 3)

    -- Bottom Center Lock Notch
    love.graphics.rectangle("fill", ox + (w - 30) / 2, oy + h - 12, 30, 12, 3, 3)

    -- Bevel Line
    love.graphics.setColor(1, 1, 1, 0.35)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", ox + 1, oy + 1, w - 2, h - 2, 12, 12)

    -- Label Recess
    local labelW, labelH = 210, 105
    local lx, ly = ox + (w - labelW) / 2, oy + 48
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", lx - 2, ly - 2, labelW + 4, labelH + 4, 6, 6)

    -- Label Background
    local lc = game.labelColor or {0.18, 0.45, 0.82}
    love.graphics.setColor(lc)
    love.graphics.rectangle("fill", lx, ly, labelW, labelH, 4, 4)

    -- Right Red/Purple Ribbon: SUPER NINTENDO
    love.graphics.setColor(0.85, 0.2, 0.25, 0.95)
    love.graphics.rectangle("fill", lx + labelW - 32, ly, 32, labelH, 0, 4, 4, 0)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf("SNES", lx + labelW - 32, ly + 20, 32, "center")
    love.graphics.printf("16-BIT", lx + labelW - 32, ly + 65, 32, "center")

    -- Game Title
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.printf(game.title, lx + 10, ly + 22, labelW - 46, "left")

    -- Subtitle
    local accent = game.cartAccent or {0.95, 0.85, 0.25, 1.0}
    love.graphics.setColor(accent)
    love.graphics.printf(game.subtitle or "SUPER NINTENDO", lx + 10, ly + 48, labelW - 46, "left")

    -- Nintendo Seal
    local sealX, sealY = lx + labelW - 55, ly + labelH - 22
    love.graphics.setColor(0.95, 0.85, 0.25, 0.8)
    love.graphics.circle("line", sealX, sealY, 12)
    love.graphics.printf("SEAL", sealX - 12, sealY - 6, 24, "center")

    -- Foil shine animation
    local shinePos = (CartridgeRenderer.shineTimer / 3.0) * (labelW * 2) - labelW / 2
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.20)
    love.graphics.polygon("fill", 
        lx + shinePos, ly,
        lx + shinePos + 35, ly,
        lx + shinePos + 10, ly + labelH,
        lx + shinePos - 25, ly + labelH
    )
    love.graphics.setBlendMode("alpha")
end

function CartridgeRenderer.drawPs1JewelCase(game)
    local w, h = 240, 240
    local ox, oy = -w / 2, -h / 2

    -- Soft Shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", ox + 14, oy + 14, w, h, 8, 8)

    -- CD Disc Peek (Offset behind jewel case to show the iconic Black Disc)
    local cdCenterX = ox + w - 10
    local cdCenterY = oy + (h / 2)
    local cdRadius = 90

    -- Iconic PlayStation 1 Black Disc Bottom
    love.graphics.setColor(0.08, 0.08, 0.10, 0.95)
    love.graphics.circle("fill", cdCenterX, cdCenterY, cdRadius)

    -- Iridescent Rainbow Data Tracks (animated foil shine on the CD)
    local cdAngle = CartridgeRenderer.shineTimer * 2.0
    love.graphics.setBlendMode("add")
    love.graphics.setColor(0.3, 0.8, 0.9, 0.25)
    love.graphics.arc("fill", cdCenterX, cdCenterY, cdRadius - 10, cdAngle, cdAngle + 0.8)
    love.graphics.setColor(0.9, 0.3, 0.7, 0.25)
    love.graphics.arc("fill", cdCenterX, cdCenterY, cdRadius - 10, cdAngle + 3.14, cdAngle + 3.94)
    love.graphics.setBlendMode("alpha")

    -- Outer Disc Ring
    love.graphics.setColor(0.4, 0.45, 0.55, 0.5)
    love.graphics.circle("line", cdCenterX, cdCenterY, cdRadius)

    -- Center Spindle Hole (Transparent hole with silver ring)
    love.graphics.setColor(0.05, 0.07, 0.10, 1.0)
    love.graphics.circle("fill", cdCenterX, cdCenterY, 26)
    love.graphics.setColor(0.7, 0.75, 0.85, 0.8)
    love.graphics.circle("line", cdCenterX, cdCenterY, 26)
    love.graphics.setColor(0.1, 0.1, 0.15, 1.0)
    love.graphics.circle("fill", cdCenterX, cdCenterY, 14)

    -- Jewel Case Acrylic Outer Frame
    love.graphics.setColor(0.15, 0.18, 0.24, 0.85)
    love.graphics.rectangle("fill", ox, oy, w, h, 6, 6)

    -- Left Spine: Iconic Black Textured PlayStation Spine
    local spineW = 28
    love.graphics.setColor(0.08, 0.09, 0.12, 1.0)
    love.graphics.rectangle("fill", ox, oy, spineW, h, 6, 0, 0, 6)
    love.graphics.setColor(0.3, 0.35, 0.45, 0.4)
    love.graphics.line(ox + spineW, oy, ox + spineW, oy + h)

    -- "PlayStation" text vertical on spine
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.printf("PS", ox, oy + 12, spineW, "center")
    love.graphics.printf("ONE", ox, oy + 28, spineW, "center")

    -- Cover Art Insert
    local coverW = w - spineW - 12
    local coverH = h - 16
    local cx, cy = ox + spineW + 6, oy + 8
    local lc = game.labelColor or {0.12, 0.12, 0.15}
    love.graphics.setColor(lc)
    love.graphics.rectangle("fill", cx, cy, coverW, coverH, 4, 4)

    -- Classic PS Geometric Logo (Red, Yellow, Green, Blue)
    local px, py = cx + 12, cy + 14
    love.graphics.setColor(0.9, 0.2, 0.2, 1.0)
    love.graphics.rectangle("fill", px, py, 6, 14, 2, 2)
    love.graphics.setColor(0.95, 0.8, 0.1, 1.0)
    love.graphics.rectangle("fill", px + 8, py, 6, 14, 2, 2)
    love.graphics.setColor(0.15, 0.75, 0.4, 1.0)
    love.graphics.rectangle("fill", px + 16, py, 6, 14, 2, 2)
    love.graphics.setColor(0.2, 0.5, 0.9, 1.0)
    love.graphics.rectangle("fill", px + 24, py, 6, 14, 2, 2)

    -- PlayStation Banner
    love.graphics.setColor(1, 1, 1, 0.95)
    love.graphics.print("PlayStation", px + 36, py)

    -- Game Title on Cover
    love.graphics.printf(game.title, cx + 12, cy + 65, coverW - 24, "center")

    -- Subtitle
    local accent = game.cartAccent or {0.85, 0.20, 0.20, 1.0}
    love.graphics.setColor(accent)
    love.graphics.printf(game.subtitle or "32-BIT CD-ROM", cx + 12, cy + 120, coverW - 24, "center")

    -- Compact Disc Digital Audio Badge
    love.graphics.setColor(0.7, 0.75, 0.85, 0.8)
    love.graphics.rectangle("line", cx + coverW - 65, cy + coverH - 30, 55, 18, 2, 2)
    love.graphics.printf("CD-ROM", cx + coverW - 65, cy + coverH - 28, 55, "center")

    -- Jewel Case Glass Reflection Sheen
    local shinePos = (CartridgeRenderer.shineTimer / 3.0) * (w * 2) - w / 2
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.polygon("fill", 
        ox + shinePos, oy,
        ox + shinePos + 50, oy,
        ox + shinePos + 20, oy + h,
        ox + shinePos - 30, oy + h
    )
    love.graphics.setBlendMode("alpha")
end

return CartridgeRenderer
