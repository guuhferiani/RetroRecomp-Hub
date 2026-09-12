local TouchOverlay = {
    buttons = {},
    activeTouches = {}, -- id -> buttonId
    visible = true,
    opacity = 0.65
}

function TouchOverlay.init()
    TouchOverlay.buttons = {}
    TouchOverlay.activeTouches = {}
end

function TouchOverlay.updateLayout(w, h, isGba)
    local btnRadius = math.min(36, math.max(26, math.floor(h * 0.055)))
    local padMargin = math.min(130, math.max(90, math.floor(w * 0.11)))
    local padY = h - padMargin

    local dpadSize = btnRadius * 1.35
    local dpadCenterX = padMargin
    local dpadCenterY = padY

    -- D-Pad buttons
    TouchOverlay.buttons = {
        up = {
            id = "up", label = "▲",
            x = dpadCenterX, y = dpadCenterY - dpadSize,
            r = btnRadius, key = "up", pressed = false
        },
        down = {
            id = "down", label = "▼",
            x = dpadCenterX, y = dpadCenterY + dpadSize,
            r = btnRadius, key = "down", pressed = false
        },
        left = {
            id = "left", label = "◀",
            x = dpadCenterX - dpadSize, y = dpadCenterY,
            r = btnRadius, key = "left", pressed = false
        },
        right = {
            id = "right", label = "▶",
            x = dpadCenterX + dpadSize, y = dpadCenterY,
            r = btnRadius, key = "right", pressed = false
        },

        -- Action Buttons (A & B)
        b = {
            id = "b", label = "B",
            x = w - padMargin - (btnRadius * 1.5), y = padY + (btnRadius * 0.5),
            r = btnRadius * 1.1, key = "b", pressed = false,
            color = {0.85, 0.25, 0.25}
        },
        a = {
            id = "a", label = "A",
            x = w - padMargin + (btnRadius * 0.8), y = padY - (btnRadius * 0.6),
            r = btnRadius * 1.1, key = "return", pressed = false,
            color = {0.15, 0.75, 0.45}
        },

        -- Menu & Start / Select
        select = {
            id = "select", label = "SELECT",
            x = (w / 2) - 65, y = h - 35,
            w = 54, h = 22, isRect = true, key = "tab", pressed = false
        },
        start = {
            id = "start", label = "START",
            x = (w / 2) + 12, y = h - 35,
            w = 54, h = 22, isRect = true, key = "return", pressed = false
        },

        -- Mod & Save Quick Access
        btnMods = {
            id = "btnMods", label = "MODS",
            x = (w / 2) - 130, y = h - 35,
            w = 50, h = 22, isRect = true, key = "m", pressed = false
        },
        btnSaves = {
            id = "btnSaves", label = "SAVES",
            x = (w / 2) + 80, y = h - 35,
            w = 50, h = 22, isRect = true, key = "s", pressed = false
        }
    }

    -- Shoulder buttons for GBA
    if isGba then
        TouchOverlay.buttons.l = {
            id = "l", label = "L",
            x = 40, y = 35, w = 70, h = 30, isRect = true, key = "q", pressed = false
        }
        TouchOverlay.buttons.r = {
            id = "r", label = "R",
            x = w - 110, y = 35, w = 70, h = 30, isRect = true, key = "e", pressed = false
        }
    end
end

local function isInsideButton(btn, x, y)
    if btn.isRect then
        return x >= btn.x and x <= btn.x + btn.w and y >= btn.y and y <= btn.y + btn.h
    else
        local dx = x - btn.x
        local dy = y - btn.y
        return (dx * dx + dy * dy) <= (btn.r * btn.r)
    end
end

function TouchOverlay.draw(w, h, Theme, isGba)
    if not TouchOverlay.visible then return end

    TouchOverlay.updateLayout(w, h, isGba)

    love.graphics.push()

    for _, btn in pairs(TouchOverlay.buttons) do
        local alpha = btn.pressed and 0.90 or TouchOverlay.opacity
        local baseCol = btn.color or {0.25, 0.30, 0.40}

        if btn.isRect then
            -- Pill / Rounded Rectangle button
            if btn.pressed then
                love.graphics.setColor(baseCol[1], baseCol[2], baseCol[3], alpha)
            else
                love.graphics.setColor(0.12, 0.16, 0.22, alpha)
            end
            love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h, 6, 6)

            love.graphics.setColor(0.5, 0.6, 0.75, 0.8)
            love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h, 6, 6)

            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.setFont(Theme.fonts.small)
            love.graphics.printf(btn.label, btn.x, btn.y + 4, btn.w, "center")
        else
            -- Circular D-Pad or Action Button
            if btn.pressed then
                love.graphics.setColor(baseCol[1] * 1.2, baseCol[2] * 1.2, baseCol[3] * 1.2, alpha)
            else
                love.graphics.setColor(baseCol[1] * 0.4, baseCol[2] * 0.4, baseCol[3] * 0.4, alpha)
            end
            love.graphics.circle("fill", btn.x, btn.y, btn.r)

            -- Border glow
            local borderCol = btn.pressed and {1, 1, 1, 0.9} or {0.6, 0.7, 0.85, 0.5}
            love.graphics.setColor(borderCol)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", btn.x, btn.y, btn.r)

            -- Button Label
            love.graphics.setColor(1, 1, 1, btn.pressed and 1.0 or 0.85)
            love.graphics.setFont(Theme.fonts.header)
            love.graphics.printf(btn.label, btn.x - btn.r, btn.y - 10, btn.r * 2, "center")
        end
    end

    love.graphics.pop()
end

function TouchOverlay.touchpressed(id, x, y, dx, dy, pressure)
    if not TouchOverlay.visible then return nil end

    for btnKey, btn in pairs(TouchOverlay.buttons) do
        if isInsideButton(btn, x, y) then
            btn.pressed = true
            TouchOverlay.activeTouches[id] = btnKey
            -- Trigger simulated keypress
            if love.keypressed and btn.key then
                love.keypressed(btn.key)
            end
            return btnKey
        end
    end
    return nil
end

function TouchOverlay.touchmoved(id, x, y, dx, dy, pressure)
    if not TouchOverlay.visible then return end

    local currentBtnKey = TouchOverlay.activeTouches[id]
    if currentBtnKey and TouchOverlay.buttons[currentBtnKey] then
        local currentBtn = TouchOverlay.buttons[currentBtnKey]
        if not isInsideButton(currentBtn, x, y) then
            currentBtn.pressed = false
            TouchOverlay.activeTouches[id] = nil
        end
    end

    -- Check if finger moved into another button
    for btnKey, btn in pairs(TouchOverlay.buttons) do
        if isInsideButton(btn, x, y) and not btn.pressed then
            btn.pressed = true
            TouchOverlay.activeTouches[id] = btnKey
            if love.keypressed and btn.key then
                love.keypressed(btn.key)
            end
            break
        end
    end
end

function TouchOverlay.touchreleased(id, x, y, dx, dy, pressure)
    local btnKey = TouchOverlay.activeTouches[id]
    if btnKey and TouchOverlay.buttons[btnKey] then
        TouchOverlay.buttons[btnKey].pressed = false
        if love.keyreleased and TouchOverlay.buttons[btnKey].key then
            love.keyreleased(TouchOverlay.buttons[btnKey].key)
        end
    end
    TouchOverlay.activeTouches[id] = nil
end

return TouchOverlay
