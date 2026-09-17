local RomManager = require("src.core.RomManager")

local GameDetailsView = {}

function GameDetailsView.draw(game, x, y, w, h, Theme, ModManager, SaveManager, CartridgeRenderer)
    local mx, my = love.mouse.getPosition()
    local hasRom, romPath, romSize = RomManager.getRomStatus(game)
    local actionBoxes = {
        slots = {},
        deleteSlot = {}
    }

    local padX = 14
    local contentX = x + padX
    local contentW = w - padX * 2
    local currY = y + 12

    -- 1. Game Title & ROM Status Badge
    love.graphics.setFont(Theme.fonts.title)
    local titleText = game.shortTitle or game.title
    local titleW = Theme.fonts.title:getWidth(titleText)
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.print(titleText, contentX, currY)

    -- Status Badge [ ROM REQUIRED ] or [ ROM VERIFIED ]
    local badgeX = contentX + titleW + 12
    local badgeY = currY + 4
    if hasRom then
        Theme.drawBadge("ROM VERIFIED", badgeX, badgeY, {0.22, 0.88, 0.52, 0.12}, Theme.colors.recompGreenBadge, Theme.colors.recompGreenBadge)
    else
        Theme.drawBadge("ROM REQUIRED", badgeX, badgeY, {0.92, 0.72, 0.20, 0.12}, Theme.colors.recompYellowBadge, Theme.colors.recompYellowBadge)
    end
    currY = currY + 42

    -- 2. ROM Card Container
    local romCardH = hasRom and 114 or 118
    local isRomCardHover = (mx >= contentX and mx <= contentX + contentW and my >= currY and my <= currY + romCardH)

    love.graphics.setColor(Theme.colors.recompCardBg)
    love.graphics.rectangle("fill", contentX, currY, contentW, romCardH, 8, 8)
    love.graphics.setColor(Theme.colors.recompCardBorder)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", contentX, currY, contentW, romCardH, 8, 8)

    if not hasRom then
        -- No ROM imported state
        love.graphics.setFont(Theme.fonts.header)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.print("No ROM imported", contentX + 14, currY + 12)

        love.graphics.setFont(Theme.fonts.small)
        love.graphics.setColor(Theme.colors.textSecondary)
        love.graphics.print("The ROM is verified before any files are created.\nCopy the ." .. game.platform .. " via USB or import from storage.", contentX + 14, currY + 34)

        -- Blue CTA Button: [ Import ROM ]
        local btnW = contentW - 28
        local btnH = 34
        local btnX = contentX + 14
        local btnY = currY + 70
        local isBtnHover = (mx >= btnX and mx <= btnX + btnW and my >= btnY and my <= btnY + btnH)

        love.graphics.setColor(isBtnHover and Theme.colors.recompBlueBtnHover or Theme.colors.recompBlueBtn)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 6, 6)

        love.graphics.setFont(Theme.fonts.header)
        love.graphics.setColor(Theme.colors.recompBlueBtnText)
        love.graphics.printf("Import ROM", btnX, btnY + 7, btnW, "center")

        actionBoxes.import = { x = btnX, y = btnY, w = btnW, h = btnH }
    else
        -- ROM Verified state
        love.graphics.setFont(Theme.fonts.header)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.print("ROM Ready & Verified", contentX + 14, currY + 12)

        love.graphics.setFont(Theme.fonts.small)
        love.graphics.setColor(Theme.colors.textSecondary)
        local safeRomName = tostring(romPath or ""):match("([^/\\]+)$") or tostring(romPath or "")
        love.graphics.print(safeRomName .. " (" .. tostring(romSize or "OK") .. ")", contentX + 14, currY + 32)

        -- Green Play CTA Button: [ ▶ JOGAR AGORA ]
        local playW = contentW - 28
        local playH = 36
        local playX = contentX + 14
        local playY = currY + 54
        local isPlayHover = (mx >= playX and mx <= playX + playW and my >= playY and my <= playY + playH)

        love.graphics.setColor(isPlayHover and Theme.colors.recompGreenBtnHover or Theme.colors.recompGreenBtn)
        love.graphics.rectangle("fill", playX, playY, playW, playH, 6, 6)

        love.graphics.setFont(Theme.fonts.header)
        love.graphics.setColor(Theme.colors.recompGreenBtnText)
        love.graphics.printf("▶  JOGAR AGORA", playX, playY + 8, playW, "center")

        actionBoxes.play = { x = playX, y = playY, w = playW, h = playH }

        -- Change ROM link
        local changeW = 85
        local changeH = 16
        local changeX = contentX + contentW - changeW - 14
        local changeY = currY + 94
        love.graphics.setFont(Theme.fonts.pixel)
        local isChangeHover = (mx >= changeX and mx <= changeX + changeW and my >= changeY and my <= changeY + changeH)
        love.graphics.setColor(isChangeHover and Theme.colors.accentGold or Theme.colors.textMuted)
        love.graphics.printf("Alterar ROM", changeX, changeY, changeW, "right")
        actionBoxes.changeRom = { x = changeX, y = changeY, w = changeW, h = changeH }
    end
    currY = currY + romCardH + 16

    -- 3. SAVE SLOT Section Header
    love.graphics.setFont(Theme.fonts.mono)
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.print("S A V E   S L O T", contentX, currY + 4)

    love.graphics.setFont(Theme.fonts.small)
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.print("4 slots", contentX + 140, currY + 4)

    -- [ Import save ] Button
    local impSaveW = 82
    local impSaveH = 22
    local impSaveX = contentX + contentW - impSaveW
    local isImpSaveHover = (mx >= impSaveX and mx <= impSaveX + impSaveW and my >= currY and my <= currY + impSaveH)

    love.graphics.setColor(isImpSaveHover and Theme.colors.recompToolHover or Theme.colors.recompToolBg)
    love.graphics.rectangle("fill", impSaveX, currY, impSaveW, impSaveH, 5, 5)
    love.graphics.setColor(Theme.colors.recompToolBorder)
    love.graphics.rectangle("line", impSaveX, currY, impSaveW, impSaveH, 5, 5)

    love.graphics.setFont(Theme.fonts.small)
    love.graphics.setColor(isImpSaveHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
    love.graphics.printf("Import save", impSaveX, currY + 3, impSaveW, "center")

    actionBoxes.importSave = { x = impSaveX, y = currY, w = impSaveW, h = impSaveH }
    currY = currY + 28

    -- 4. 4 Save Slot Cards
    local slotCardH = 48
    local slotGap = 6
    local activeSlot = game.currentSlot or 1

    for s = 1, 4 do
        local slotY = currY
        local isLoaded = (activeSlot == s)
        local isSlotHover = (mx >= contentX and mx <= contentX + contentW and my >= slotY and my <= slotY + slotCardH)

        if isLoaded then
            -- High contrast WHITE active card
            love.graphics.setColor(Theme.colors.recompActiveCardBg)
            love.graphics.rectangle("fill", contentX, slotY, contentW, slotCardH, 7, 7)
            love.graphics.setColor(0.85, 0.85, 0.90, 1.0)
            love.graphics.rectangle("line", contentX, slotY, contentW, slotCardH, 7, 7)

            -- Text inside active card
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.setColor(Theme.colors.recompActiveCardText)
            love.graphics.print("NOVO JOGO", contentX + 12, slotY + 8)

            love.graphics.setFont(Theme.fonts.small)
            love.graphics.setColor(0.35, 0.35, 0.40, 1.0)
            love.graphics.print("empty slot", contentX + 12, slotY + 26)

            -- [ LOADED ] Badge
            local badgeW = 60
            local badgeH = 18
            local badgeX = contentX + contentW - badgeW - 74
            local badgeY = slotY + 8
            love.graphics.setColor(0.12, 0.12, 0.16, 0.12)
            love.graphics.rectangle("fill", badgeX, badgeY, badgeW, badgeH, 4, 4)
            love.graphics.setColor(0.20, 0.20, 0.25, 0.7)
            love.graphics.rectangle("line", badgeX, badgeY, badgeW, badgeH, 4, 4)
            love.graphics.setFont(Theme.fonts.pixel)
            love.graphics.setColor(0.15, 0.15, 0.20, 1.0)
            love.graphics.printf("LOADED", badgeX, badgeY + 3, badgeW, "center")
        else
            -- Dark slot card
            love.graphics.setColor(isSlotHover and Theme.colors.panelCardHover or Theme.colors.recompCardBg)
            love.graphics.rectangle("fill", contentX, slotY, contentW, slotCardH, 7, 7)
            love.graphics.setColor(Theme.colors.recompCardBorder)
            love.graphics.rectangle("line", contentX, slotY, contentW, slotCardH, 7, 7)

            love.graphics.setFont(Theme.fonts.body)
            love.graphics.setColor(isSlotHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
            love.graphics.print("NOVO JOGO", contentX + 12, slotY + 8)

            love.graphics.setFont(Theme.fonts.small)
            love.graphics.setColor(Theme.colors.textMuted)
            love.graphics.print("empty slot", contentX + 12, slotY + 26)
        end

        -- Red [ Delete ] Pixel Button
        local delW = 50
        local delH = 20
        local delX = contentX + contentW - delW - 10
        local delY = slotY + slotCardH - delH - 8
        local isDelHover = (mx >= delX and mx <= delX + delW and my >= delY and my <= delY + delH)

        love.graphics.setColor(isDelHover and Theme.colors.recompDeleteBtnHover or Theme.colors.recompDeleteBtn)
        love.graphics.rectangle("fill", delX, delY, delW, delH, 4, 4)
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("line", delX, delY, delW, delH, 4, 4)

        love.graphics.setFont(Theme.fonts.pixel)
        love.graphics.setColor(0.12, 0.02, 0.03, 0.95)
        love.graphics.printf("Delete", delX, delY + 4, delW, "center")

        actionBoxes.deleteSlot[s] = { x = delX, y = delY, w = delW, h = delH }
        actionBoxes.slots[s] = { x = contentX, y = slotY, w = contentW - delW - 14, h = slotCardH }

        currY = currY + slotCardH + slotGap
    end
    currY = currY + 12

    -- 5. Footer Buttons & Disclaimer
    local footBtnGap = 6
    local footBtnW = math.floor((contentW - footBtnGap * 2) / 3)
    local footBtnH = 24

    local function drawPillBtn(text, bx)
        local isHover = (mx >= bx and mx <= bx + footBtnW and my >= currY and my <= currY + footBtnH)
        love.graphics.setColor(isHover and Theme.colors.recompPillHover or Theme.colors.recompPillBg)
        love.graphics.rectangle("fill", bx, currY, footBtnW, footBtnH, 12, 12)
        love.graphics.setFont(Theme.fonts.pixel)
        love.graphics.setColor(Theme.colors.recompPillText)
        love.graphics.printf(text, bx, currY + 6, footBtnW, "center")
    end

    drawPillBtn("RETRORECOMP", contentX)
    drawPillBtn("Check for updates", contentX + footBtnW + footBtnGap)
    drawPillBtn("Patch notes", contentX + (footBtnW + footBtnGap) * 2)

    actionBoxes.footer1 = { x = contentX, y = currY, w = footBtnW, h = footBtnH }
    actionBoxes.footer2 = { x = contentX + footBtnW + footBtnGap, y = currY, w = footBtnW, h = footBtnH }
    actionBoxes.footer3 = { x = contentX + (footBtnW + footBtnGap) * 2, y = currY, w = footBtnW, h = footBtnH }

    currY = currY + footBtnH + 10

    -- Disclaimer / Community Notice
    love.graphics.setFont(Theme.fonts.pixel)
    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.printf("Central unificada RetroRecomp Hub • Clone fiel Gen1Recomp++\nSuporte nativo a jogos retrô e emulação com shaders em tempo real.", contentX, currY, contentW, "center")

    return actionBoxes
end

return GameDetailsView


