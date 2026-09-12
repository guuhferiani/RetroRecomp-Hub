local Theme = {}

Theme.colors = {
    bg = {0.05, 0.07, 0.10, 1.0},
    panelBg = {0.09, 0.12, 0.17, 0.95},
    panelCard = {0.13, 0.17, 0.23, 0.90},
    panelCardHover = {0.17, 0.22, 0.30, 0.98},
    panelBorder = {0.20, 0.26, 0.35, 0.70},
    panelBorderFocus = {0.35, 0.45, 0.60, 1.0},

    textPrimary = {0.96, 0.97, 0.99, 1.0},
    textSecondary = {0.68, 0.73, 0.82, 1.0},
    textMuted = {0.45, 0.50, 0.60, 1.0},

    accentGbc = {0.06, 0.75, 0.50, 1.0},
    accentGba = {0.58, 0.38, 0.96, 1.0},
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
    Theme.fonts.title = love.graphics.newFont(24)
    Theme.fonts.header = love.graphics.newFont(18)
    Theme.fonts.body = love.graphics.newFont(14)
    Theme.fonts.small = love.graphics.newFont(11)
    Theme.fonts.mono = love.graphics.newFont(12)
end

function Theme.drawCard(x, y, w, h, radius, isHovered, isSelected, accentColor)
    radius = radius or 10
    local bg = isSelected and Theme.colors.panelCardHover or (isHovered and Theme.colors.panelCardHover or Theme.colors.panelCard)
    local border = isSelected and (accentColor or Theme.colors.panelBorderFocus) or (isHovered and Theme.colors.panelBorderFocus or Theme.colors.panelBorder)

    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", x, y, w, h, radius, radius)

    love.graphics.setColor(border)
    love.graphics.setLineWidth(isSelected and 2 or 1)
    love.graphics.rectangle("line", x, y, w, h, radius, radius)
    love.graphics.setLineWidth(1)
end

function Theme.drawBadge(text, x, y, bgColor, textColor)
    love.graphics.setFont(Theme.fonts.small)
    local tw = Theme.fonts.small:getWidth(text)
    local th = Theme.fonts.small:getHeight()
    local padX, padY = 8, 3
    local bw, bh = tw + padX * 2, th + padY * 2

    love.graphics.setColor(bgColor or {0.2, 0.25, 0.35, 0.9})
    love.graphics.rectangle("fill", x, y, bw, bh, 6, 6)

    love.graphics.setColor(textColor or Theme.colors.textPrimary)
    love.graphics.print(text, x + padX, y + padY)

    return bw, bh
end

return Theme
