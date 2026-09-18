local Theme = {}

Theme.colors = {
    bg = {0.055, 0.051, 0.067, 1.0},
    panelBg = {0.075, 0.070, 0.092, 0.98},
    panelCard = {0.095, 0.090, 0.120, 0.95},
    panelCardHover = {0.140, 0.130, 0.175, 0.98},
    panelBorder = {0.180, 0.165, 0.230, 0.85},
    panelBorderFocus = {0.35, 0.45, 0.60, 1.0},

    textPrimary = {0.96, 0.97, 0.99, 1.0},
    textSecondary = {0.68, 0.73, 0.82, 1.0},
    textMuted = {0.45, 0.50, 0.60, 1.0},

    -- Gen1Recomp++ Exact Styling Colors
    recompDarkBg = {0.055, 0.051, 0.067, 1.0},
    recompCardBg = {0.086, 0.082, 0.110, 0.98},
    recompCardBorder = {0.160, 0.150, 0.200, 1.0},
    recompActiveCardBg = {0.98, 0.98, 1.0, 1.0},
    recompActiveCardText = {0.07, 0.07, 0.09, 1.0},
    
    recompBlueBtn = {0.42, 0.73, 0.97, 1.0},
    recompBlueBtnHover = {0.55, 0.82, 1.0, 1.0},
    recompBlueBtnText = {0.04, 0.12, 0.22, 1.0},

    recompGreenBtn = {0.22, 0.85, 0.48, 1.0},
    recompGreenBtnHover = {0.30, 0.95, 0.58, 1.0},
    recompGreenBtnText = {0.03, 0.18, 0.08, 1.0},

    recompDeleteBtn = {0.88, 0.33, 0.38, 1.0},
    recompDeleteBtnHover = {0.96, 0.40, 0.46, 1.0},

    recompYellowBadge = {0.92, 0.72, 0.20, 1.0},
    recompGreenBadge = {0.22, 0.88, 0.52, 1.0},

    recompPillBg = {0.92, 0.92, 0.95, 1.0},
    recompPillHover = {1.0, 1.0, 1.0, 1.0},
    recompPillText = {0.08, 0.08, 0.10, 1.0},

    recompToolBg = {0.11, 0.10, 0.14, 1.0},
    recompToolBorder = {0.22, 0.20, 0.28, 1.0},
    recompToolHover = {0.18, 0.16, 0.24, 1.0},

    accentGbc = {0.06, 0.75, 0.50, 1.0},
    accentGba = {0.58, 0.38, 0.96, 1.0},
    accentCyan = {0.18, 0.78, 0.96, 1.0},
    accentGold = {0.96, 0.72, 0.15, 1.0},
    accentRed = {0.94, 0.26, 0.28, 1.0},
    accentBlue = {0.22, 0.58, 0.98, 1.0},

    buttonPlay = {0.06, 0.75, 0.45, 1.0},
    buttonPlayHover = {0.08, 0.85, 0.52, 1.0},
    buttonPlayGba = {0.55, 0.35, 0.95, 1.0},
    buttonPlayGbaHover = {0.65, 0.45, 1.0, 1.0}
}

Theme.fonts = {}

function Theme.init()
    Theme.fonts.logo = love.graphics.newFont(18)
    Theme.fonts.title = love.graphics.newFont(26)
    Theme.fonts.header = love.graphics.newFont(16)
    Theme.fonts.body = love.graphics.newFont(13)
    Theme.fonts.small = love.graphics.newFont(11)
    Theme.fonts.mono = love.graphics.newFont(11)
    Theme.fonts.pixel = love.graphics.newFont(10)
end

function Theme.drawCard(x, y, w, h, radius, isHovered, isSelected, accentColor)
    x = x or 0
    y = y or 0
    w = w or 100
    h = h or 40
    radius = radius or 8
    local bg = isSelected and Theme.colors.panelCardHover or (isHovered and Theme.colors.panelCardHover or Theme.colors.recompCardBg)
    local border = isSelected and (accentColor or Theme.colors.panelBorderFocus) or (isHovered and Theme.colors.panelBorderFocus or Theme.colors.recompCardBorder)

    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", x, y, w, h, radius, radius)

    love.graphics.setColor(border)
    love.graphics.setLineWidth(isSelected and 1.5 or 1)
    love.graphics.rectangle("line", x, y, w, h, radius, radius)
    love.graphics.setLineWidth(1)
end

function Theme.drawBadge(text, x, y, bgColor, textColor, borderColor)
    love.graphics.setFont(Theme.fonts.small)
    local tw = Theme.fonts.small:getWidth(text)
    local th = Theme.fonts.small:getHeight()
    local padX, padY = 8, 3
    local bw, bh = tw + padX * 2, th + padY * 2

    love.graphics.setColor(bgColor or {0.2, 0.25, 0.35, 0.9})
    love.graphics.rectangle("fill", x, y, bw, bh, 5, 5)

    if borderColor then
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(1.2)
        love.graphics.rectangle("line", x, y, bw, bh, 5, 5)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor(textColor or Theme.colors.textPrimary)
    love.graphics.print(text, x + padX, y + padY)

    return bw, bh
end

-- Pixel/Retro Gen1Recomp++ Title Logo
function Theme.drawLogo(x, y)
    love.graphics.setFont(Theme.fonts.title)
    local text = "Gen1Recomp++"
    
    -- Retro pixel yellow / gold color with blue outline shadow
    love.graphics.setColor(0.15, 0.30, 0.70, 0.9)
    for ox = -1.5, 1.5, 1.5 do
        for oy = -1.5, 1.5, 1.5 do
            love.graphics.print(text, x + ox, y + oy)
        end
    end
    
    love.graphics.setColor(0.96, 0.82, 0.20, 1.0)
    love.graphics.print(text, x, y)
    
    return Theme.fonts.title:getWidth(text), Theme.fonts.title:getHeight()
end

-- Native Vector Icons
function Theme.drawGearIcon(cx, cy, r)
    love.graphics.circle("line", cx, cy, r * 0.55)
    love.graphics.circle("fill", cx, cy, r * 0.25)
    for a = 0, 7 do
        local angle = a * (math.pi / 4)
        local x1 = cx + math.cos(angle) * (r * 0.5)
        local y1 = cy + math.sin(angle) * (r * 0.5)
        local x2 = cx + math.cos(angle) * r
        local y2 = cy + math.sin(angle) * r
        love.graphics.line(x1, y1, x2, y2)
    end
end

function Theme.drawCloseIcon(cx, cy, r)
    local d = r * 0.65
    love.graphics.line(cx - d, cy - d, cx + d, cy + d)
    love.graphics.line(cx + d, cy - d, cx - d, cy + d)
end

function Theme.drawCloudImportIcon(cx, cy, r)
    local h = r * 0.6
    love.graphics.line(cx, cy - h, cx, cy + h * 0.4)
    love.graphics.line(cx - h * 0.5, cy, cx, cy + h * 0.4)
    love.graphics.line(cx + h * 0.5, cy, cx, cy + h * 0.4)
    love.graphics.line(cx - r * 0.8, cy + h * 0.1, cx - r * 0.8, cy + h * 0.8)
    love.graphics.line(cx - r * 0.8, cy + h * 0.8, cx + r * 0.8, cy + h * 0.8)
    love.graphics.line(cx + r * 0.8, cy + h * 0.8, cx + r * 0.8, cy + h * 0.1)
end

function Theme.drawSearchIcon(cx, cy, r)
    local circleR = r * 0.45
    local cX = cx - r * 0.15
    local cY = cy - r * 0.15
    love.graphics.circle("line", cX, cY, circleR)
    love.graphics.line(cX + circleR * 0.7, cY + circleR * 0.7, cx + r * 0.75, cy + r * 0.75)
end

function Theme.drawGlobeIcon(cx, cy, r)
    love.graphics.circle("line", cx, cy, r * 0.7)
    love.graphics.line(cx - r * 0.7, cy, cx + r * 0.7, cy)
    love.graphics.line(cx, cy - r * 0.7, cx, cy + r * 0.7)
    love.graphics.ellipse("line", cx, cy, r * 0.35, r * 0.7)
end

function Theme.drawScreenIcon(cx, cy, r)
    local w = r * 1.3
    local h = r * 0.9
    love.graphics.rectangle("line", cx - w/2, cy - h/2 - r*0.1, w, h, 2, 2)
    love.graphics.line(cx - r*0.3, cy + h/2 + r*0.2, cx + r*0.3, cy + h/2 + r*0.2)
    love.graphics.line(cx, cy + h/2 - r*0.1, cx, cy + h/2 + r*0.2)
end

function Theme.drawSwapIcon(cx, cy, r)
    local l = r * 0.65
    love.graphics.line(cx - l, cy - r * 0.25, cx + l, cy - r * 0.25)
    love.graphics.line(cx + l - r * 0.3, cy - r * 0.5, cx + l, cy - r * 0.25)
    love.graphics.line(cx + l - r * 0.3, cy, cx + l, cy - r * 0.25)

    love.graphics.line(cx + l, cy + r * 0.25, cx - l, cy + r * 0.25)
    love.graphics.line(cx - l + r * 0.3, cy, cx - l, cy + r * 0.25)
    love.graphics.line(cx - l + r * 0.3, cy + r * 0.5, cx - l, cy + r * 0.25)
end

function Theme.drawDropdownArrow(cx, cy, size)
    love.graphics.polygon("fill", cx - size, cy - size * 0.6, cx + size, cy - size * 0.6, cx, cy + size * 0.8)
end

return Theme

