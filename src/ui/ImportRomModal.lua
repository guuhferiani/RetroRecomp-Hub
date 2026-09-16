local RomManager = require("src.core.RomManager")

local ImportRomModal = {
    currentPath = nil,
    items = { folders = {}, files = {} },
    selectedFile = nil,
    scrollOffset = 0,
    maxScroll = 0,
    statusMessage = nil,
    statusTimer = 0,
    isDragging = false,
    dragStartY = 0,
    dragStartScroll = 0
}

function ImportRomModal.initPath(initialPath)
    if not ImportRomModal.currentPath or ImportRomModal.currentPath == "" then
        local quick = RomManager.getQuickPaths()
        ImportRomModal.currentPath = initialPath or (quick[1] and quick[1].path) or "."
        ImportRomModal.refresh()
    end
end

function ImportRomModal.setPath(newPath)
    ImportRomModal.currentPath = newPath
    ImportRomModal.selectedFile = nil
    ImportRomModal.scrollOffset = 0
    ImportRomModal.refresh()
end

function ImportRomModal.refresh()
    ImportRomModal.items = RomManager.listDirectory(ImportRomModal.currentPath)
end

function ImportRomModal.update(dt)
    if ImportRomModal.statusTimer > 0 then
        ImportRomModal.statusTimer = ImportRomModal.statusTimer - dt
        if ImportRomModal.statusTimer <= 0 then
            ImportRomModal.statusMessage = nil
        end
    end
end

function ImportRomModal.draw(game, w, h, Theme)
    -- Dimmed backdrop
    love.graphics.setColor(0, 0, 0, 0.80)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Responsive modal dimensions
    local modalW = math.min(760, math.max(340, w - 40))
    local modalH = math.min(580, math.max(420, h - 50))
    local mx_pos = math.floor((w - modalW) / 2)
    local my_pos = math.floor((h - modalH) / 2)

    local accent = (game and game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    Theme.drawCard(mx_pos, my_pos, modalW, modalH, 16, false, true, Theme.colors.accentCyan or accent)

    local curX, curY = love.mouse.getPosition()
    local hitboxes = {
        quickPaths = {},
        upBtn = nil,
        folders = {},
        files = {},
        importBtn = nil,
        closeBtn = nil,
        modalBounds = { x = mx_pos, y = my_pos, w = modalW, h = modalH }
    }

    -- 1. Modal Header
    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.header)
    local headerTitle = game and ("📥 IMPORTAR ROM: " .. game.title) or "📥 EXPLORADOR DE ROMS"
    love.graphics.print(headerTitle, mx_pos + 24, my_pos + 20)

    love.graphics.setColor(Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Navegue pelas pastas do celular ou PC para selecionar seu arquivo de ROM (.gbc, .gba, .sfc, .chd)", mx_pos + 24, my_pos + 46)

    -- Close Button (X)
    local closeX, closeY, closeS = mx_pos + modalW - 44, my_pos + 18, 30
    local isCloseHover = (curX >= closeX and curX <= closeX + closeS and curY >= closeY and curY <= closeY + closeS)
    love.graphics.setColor(isCloseHover and Theme.colors.accentRed or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("✕", closeX + 6, closeY + 2)
    hitboxes.closeBtn = { x = closeX, y = closeY, w = closeS, h = closeS }

    -- 2. Quick Access Shortcut Pills
    local quickPaths = RomManager.getQuickPaths()
    local qy = my_pos + 72
    local qx = mx_pos + 24
    local qh = 28

    for _, qp in ipairs(quickPaths) do
        local qLabel = qp.icon .. " " .. qp.name
        local qw = Theme.fonts.small:getWidth(qLabel) + 18
        if qx + qw <= mx_pos + modalW - 24 then
            local isQHover = (curX >= qx and curX <= qx + qw and curY >= qy and curY <= qy + qh)
            local isQActive = (ImportRomModal.currentPath == qp.path)
            Theme.drawCard(qx, qy, qw, qh, 6, isQHover, isQActive, Theme.colors.accentCyan or accent)

            love.graphics.setColor(isQActive and Theme.colors.textPrimary or (isQHover and Theme.colors.textPrimary or Theme.colors.textSecondary))
            love.graphics.setFont(Theme.fonts.small)
            love.graphics.print(qLabel, qx + 9, qy + 6)

            table.insert(hitboxes.quickPaths, { path = qp.path, x = qx, y = qy, w = qw, h = qh })
            qx = qx + qw + 8
        end
    end

    -- 3. Path Bar & Up Button
    local py = qy + 36
    local upBtnW, upBtnH = 86, 30
    local isUpHover = (curX >= mx_pos + 24 and curX <= mx_pos + 24 + upBtnW and curY >= py and curY <= py + upBtnH)
    Theme.drawCard(mx_pos + 24, py, upBtnW, upBtnH, 6, isUpHover, false, Theme.colors.panelBorder)
    love.graphics.setColor(isUpHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("⬆ Subir", mx_pos + 38, py + 7)
    hitboxes.upBtn = { x = mx_pos + 24, y = py, w = upBtnW, h = upBtnH }

    -- Path text box
    local pathBoxX = mx_pos + 24 + upBtnW + 10
    local pathBoxW = modalW - 48 - upBtnW - 10
    love.graphics.setColor(Theme.colors.panelBg)
    love.graphics.rectangle("fill", pathBoxX, py, pathBoxW, upBtnH, 6, 6)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.rectangle("line", pathBoxX, py, pathBoxW, upBtnH, 6, 6)

    love.graphics.setColor(Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.small)
    local displayPath = ImportRomModal.currentPath or "/"
    if Theme.fonts.small:getWidth(displayPath) > pathBoxW - 20 then
        displayPath = "..." .. displayPath:sub(-35)
    end
    love.graphics.print("📂 " .. displayPath, pathBoxX + 10, py + 7)

    -- 4. File & Folder List Area (Scrolled)
    local listX = mx_pos + 24
    local listY = py + upBtnH + 12
    local listW = modalW - 48
    local bottomAreaH = 68
    local listH = modalH - (listY - my_pos) - bottomAreaH

    -- List container background
    love.graphics.setColor(0.08, 0.10, 0.14, 0.95)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 8, 8)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.rectangle("line", listX, listY, listW, listH, 8, 8)

    -- Clip to list view
    love.graphics.setScissor(listX, listY, listW, listH)

    local itemH = 40
    local totalItems = #ImportRomModal.items.folders + #ImportRomModal.items.files
    local totalContentH = totalItems * (itemH + 6) + 10
    ImportRomModal.maxScroll = math.max(0, totalContentH - listH)
    ImportRomModal.scrollOffset = math.max(0, math.min(ImportRomModal.scrollOffset, ImportRomModal.maxScroll))

    local iy = listY + 8 - ImportRomModal.scrollOffset

    -- Render Folders first
    for _, folder in ipairs(ImportRomModal.items.folders) do
        if iy + itemH >= listY and iy <= listY + listH then
            local isHover = (curX >= listX + 8 and curX <= listX + listW - 16 and curY >= iy and curY <= iy + itemH and curY >= listY and curY <= listY + listH)
            Theme.drawCard(listX + 8, iy, listW - 16, itemH, 6, isHover, false, Theme.colors.accentCyan or accent)

            love.graphics.setColor(1, 0.85, 0.35, 1.0)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.print("📁", listX + 20, iy + 9)

            love.graphics.setColor(isHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
            love.graphics.print(folder.name, listX + 48, iy + 10)

            table.insert(hitboxes.folders, { path = folder.path, x = listX + 8, y = iy, w = listW - 16, h = itemH })
        end
        iy = iy + itemH + 6
    end

    -- Render Files
    for _, file in ipairs(ImportRomModal.items.files) do
        if iy + itemH >= listY and iy <= listY + listH then
            local isSelected = (ImportRomModal.selectedFile and ImportRomModal.selectedFile.path == file.path)
            local isHover = (curX >= listX + 8 and curX <= listX + listW - 16 and curY >= iy and curY <= iy + itemH and curY >= listY and curY <= listY + listH)

            Theme.drawCard(listX + 8, iy, listW - 16, itemH, 6, isHover, isSelected, Theme.colors.accentGbc)

            love.graphics.setColor(Theme.colors.accentGbc)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.print("🎮", listX + 20, iy + 9)

            love.graphics.setColor(isSelected and Theme.colors.textPrimary or (isHover and Theme.colors.textPrimary or Theme.colors.textSecondary))
            love.graphics.print(file.name, listX + 48, iy + 10)

            -- File Size tag
            local sizeStr = RomManager.formatSize(file.size)
            love.graphics.setColor(Theme.colors.textMuted)
            love.graphics.setFont(Theme.fonts.small)
            love.graphics.printf(sizeStr, listX + listW - 120, iy + 12, 100, "right")

            table.insert(hitboxes.files, { file = file, x = listX + 8, y = iy, w = listW - 16, h = itemH })
        end
        iy = iy + itemH + 6
    end

    if totalItems == 0 then
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf("Nenhuma ROM compatível (.gbc, .gba, .sfc, .chd) nesta pasta.", listX + 20, listY + listH / 2 - 10, listW - 40, "center")
    end

    love.graphics.setScissor()

    -- 5. Bottom Action Bar: Selected File & Import Button
    local bottomY = my_pos + modalH - bottomAreaH + 10
    local actionBtnW = math.min(220, math.floor(modalW * 0.38))
    local infoAreaW = modalW - 48 - actionBtnW - 14

    if ImportRomModal.selectedFile then
        love.graphics.setColor(Theme.colors.accentCyan or Theme.colors.accentGbc)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.print("✓ Selecionado: " .. ImportRomModal.selectedFile.name, listX, bottomY + 2)

        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Tamanho: " .. RomManager.formatSize(ImportRomModal.selectedFile.size), listX, bottomY + 24)
    else
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Selecione um arquivo de ROM acima para vincular ao jogo.", listX, bottomY + 12)
    end

    -- Import Button
    local btnX = mx_pos + modalW - 24 - actionBtnW
    local btnH = 42
    local isBtnEnabled = (ImportRomModal.selectedFile ~= nil and game ~= nil)
    local isBtnHover = isBtnEnabled and (curX >= btnX and curX <= btnX + actionBtnW and curY >= bottomY and curY <= bottomY + btnH)

    if isBtnEnabled then
        love.graphics.setColor(isBtnHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
    else
        love.graphics.setColor(0.2, 0.25, 0.35, 0.5)
    end
    love.graphics.rectangle("fill", btnX, bottomY, actionBtnW, btnH, 8, 8)

    love.graphics.setColor(isBtnEnabled and {1, 1, 1, 1} or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("📥 IMPORTAR ROM", btnX, bottomY + 11, actionBtnW, "center")
    hitboxes.importBtn = { x = btnX, y = bottomY, w = actionBtnW, h = btnH, enabled = isBtnEnabled }

    -- Toast / Status Message
    if ImportRomModal.statusMessage then
        local tw = modalW - 48
        local ty = my_pos + modalH - 52
        Theme.drawCard(mx_pos + 24, ty, tw, 36, 8, false, true, Theme.colors.accentGbc)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf(ImportRomModal.statusMessage, mx_pos + 24, ty + 8, tw, "center")
    end

    return hitboxes
end

function ImportRomModal.mousepressed(x, y, button, hitboxes, game)
    if not hitboxes then return nil end

    -- Close Button
    if hitboxes.closeBtn then
        local cb = hitboxes.closeBtn
        if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
            return "close"
        end
    end

    -- Quick path pills
    for _, qp in ipairs(hitboxes.quickPaths or {}) do
        if x >= qp.x and x <= qp.x + qp.w and y >= qp.y and y <= qp.y + qp.h then
            ImportRomModal.setPath(qp.path)
            return "nav"
        end
    end

    -- Up button
    if hitboxes.upBtn then
        local ub = hitboxes.upBtn
        if x >= ub.x and x <= ub.x + ub.w and y >= ub.y and y <= ub.y + ub.h then
            local parent = RomManager.getParentDirectory(ImportRomModal.currentPath)
            if parent and parent ~= "" then
                ImportRomModal.setPath(parent)
            end
            return "nav"
        end
    end

    -- Folders
    for _, f in ipairs(hitboxes.folders or {}) do
        if x >= f.x and x <= f.x + f.w and y >= f.y and y <= f.y + f.h then
            ImportRomModal.setPath(f.path)
            return "nav"
        end
    end

    -- Files
    for _, fl in ipairs(hitboxes.files or {}) do
        if x >= fl.x and x <= fl.x + fl.w and y >= fl.y and y <= fl.y + fl.h then
            ImportRomModal.selectedFile = fl.file
            return "select"
        end
    end

    -- Import Button
    if hitboxes.importBtn and hitboxes.importBtn.enabled then
        local ib = hitboxes.importBtn
        if x >= ib.x and x <= ib.x + ib.w and y >= ib.y and y <= ib.y + ib.h then
            if game and ImportRomModal.selectedFile then
                local ok, msg = RomManager.importRomForGame(game.id, ImportRomModal.selectedFile.path)
                ImportRomModal.statusMessage = msg or "ROM Importada!"
                ImportRomModal.statusTimer = 2.5
                return "imported"
            end
        end
    end

    -- Click outside modal
    local mb = hitboxes.modalBounds
    if mb and (x < mb.x or x > mb.x + mb.w or y < mb.y or y > mb.y + mb.h) then
        return "close"
    end

    return nil
end

function ImportRomModal.wheelmoved(dx, dy)
    ImportRomModal.scrollOffset = math.max(0, math.min(ImportRomModal.scrollOffset - dy * 45, ImportRomModal.maxScroll))
end

function ImportRomModal.touchmoved(dy)
    ImportRomModal.scrollOffset = math.max(0, math.min(ImportRomModal.scrollOffset - dy, ImportRomModal.maxScroll))
end

return ImportRomModal
