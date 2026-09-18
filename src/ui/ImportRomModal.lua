local RomManager = require("src.core.RomManager")

local ImportRomModal = {
    mode = "browse", -- "browse" or "search"
    currentPath = nil,
    items = { folders = {}, files = {} },
    searchResults = {},
    selectedFile = nil,
    scrollOffset = 0,
    maxScroll = 0,
    statusMessage = nil,
    statusTimer = 0,
    isSearching = false
}

-- Draw crisp vector icons directly to prevent font missing-glyph '[]' issues
local function drawVectorFolder(x, y, scale)
    scale = scale or 1
    love.graphics.setColor(0.95, 0.75, 0.25, 1.0) -- Amber
    -- Folder body
    love.graphics.rectangle("fill", x, y + 3 * scale, 18 * scale, 12 * scale, 2 * scale, 2 * scale)
    -- Folder tab
    love.graphics.rectangle("fill", x, y, 8 * scale, 4 * scale, 1 * scale, 1 * scale)
end

local function drawVectorCartridge(x, y, scale, isGba)
    scale = scale or 1
    if isGba then
        love.graphics.setColor(0.65, 0.45, 0.95, 1.0) -- GBA Purple
    else
        love.graphics.setColor(0.15, 0.78, 0.65, 1.0) -- GBC Teal
    end
    -- Cartridge body
    love.graphics.rectangle("fill", x, y, 16 * scale, 16 * scale, 2 * scale, 2 * scale)
    -- Cartridge label
    love.graphics.setColor(0.10, 0.12, 0.18, 0.9)
    love.graphics.rectangle("fill", x + 3 * scale, y + 4 * scale, 10 * scale, 9 * scale, 1 * scale, 1 * scale)
    -- Notch
    love.graphics.setColor(0.95, 0.95, 0.95, 0.8)
    love.graphics.rectangle("fill", x + 5 * scale, y + 1 * scale, 6 * scale, 2 * scale)
end

local function drawVectorArrowUp(x, y, s)
    s = s or 12
    love.graphics.polygon("fill", x + s / 2, y, x, y + s * 0.7, x + s * 0.35, y + s * 0.7, x + s * 0.35, y + s, x + s * 0.65, y + s, x + s * 0.65, y + s * 0.7, x + s, y + s * 0.7)
end

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
    if ImportRomModal.mode == "browse" then
        ImportRomModal.items = RomManager.listDirectory(ImportRomModal.currentPath)
    else
        ImportRomModal.searchResults = RomManager.quickScanDevice(false)
    end
end

function ImportRomModal.triggerQuickScan()
    ImportRomModal.mode = "search"
    ImportRomModal.scrollOffset = 0
    ImportRomModal.selectedFile = nil
    ImportRomModal.searchResults = RomManager.quickScanDevice(true)
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
    love.graphics.setColor(0, 0, 0, 0.82)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Responsive modal dimensions for mobile portrait
    local modalW = math.min(760, math.max(340, w - 24))
    local modalH = math.min(620, math.max(440, h - 30))
    local mx_pos = math.floor((w - modalW) / 2)
    local my_pos = math.floor((h - modalH) / 2)

    local accent = (game and game.platform == "gba") and Theme.colors.accentGba or Theme.colors.accentGbc
    Theme.drawCard(mx_pos, my_pos, modalW, modalH, 16, false, true, Theme.colors.accentCyan or accent)

    local curX, curY = love.mouse.getPosition()
    local hitboxes = {
        modeBrowseBtn = nil,
        modeSearchBtn = nil,
        quickPaths = {},
        upBtn = nil,
        folders = {},
        files = {},
        cancelBtn = nil,
        importBtn = nil,
        closeBtn = nil,
        modalBounds = { x = mx_pos, y = my_pos, w = modalW, h = modalH }
    }

    -- 1. Modal Header
    love.graphics.setColor(Theme.colors.accentGbc or Theme.colors.buttonPlay)
    drawVectorCartridge(mx_pos + 20, my_pos + 20, 1.2, (game and game.platform == "gba"))

    love.graphics.setColor(Theme.colors.textPrimary)
    love.graphics.setFont(Theme.fonts.header)
    local headerTitle = game and ("IMPORTAR ROM: " .. game.title) or "EXPLORADOR DE ROMS"
    love.graphics.print(headerTitle, mx_pos + 46, my_pos + 18)

    -- Close Button (X)
    local closeX, closeY, closeS = mx_pos + modalW - 40, my_pos + 16, 28
    local isCloseHover = (curX >= closeX and curX <= closeX + closeS and curY >= closeY and curY <= closeY + closeS)
    love.graphics.setColor(isCloseHover and Theme.colors.accentRed or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.header)
    love.graphics.print("X", closeX + 8, closeY + 2)
    hitboxes.closeBtn = { x = closeX, y = closeY, w = closeS, h = closeS }

    -- 2. Mode Selector: [ Pastas ] vs [ 🔍 Busca Rapida ] vs [ 📂 Escolher Arquivo ]
    local tabY = my_pos + 52
    local totalTabW = modalW - 40
    local tabW = math.floor((totalTabW - 12) / 3)
    local tabH = 32

    -- Browse Tab
    local isBrowseActive = (ImportRomModal.mode == "browse")
    local isBrowseHover = (curX >= mx_pos + 20 and curX <= mx_pos + 20 + tabW and curY >= tabY and curY <= tabY + tabH)
    Theme.drawCard(mx_pos + 20, tabY, tabW, tabH, 6, isBrowseHover, isBrowseActive, accent)
    drawVectorFolder(mx_pos + 28, tabY + 9, 0.8)
    love.graphics.setColor(isBrowseActive and Theme.colors.textPrimary or Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Pastas", mx_pos + 46, tabY + 8)
    hitboxes.modeBrowseBtn = { x = mx_pos + 20, y = tabY, w = tabW, h = tabH }

    -- Search Tab (Quick Scan)
    local searchX = mx_pos + 20 + tabW + 6
    local isSearchActive = (ImportRomModal.mode == "search")
    local isSearchHover = (curX >= searchX and curX <= searchX + tabW and curY >= tabY and curY <= tabY + tabH)
    Theme.drawCard(searchX, tabY, tabW, tabH, 6, isSearchHover, isSearchActive, Theme.colors.accentCyan or accent)
    love.graphics.setColor(Theme.colors.accentCyan or {0.2, 0.8, 1, 1})
    drawVectorCartridge(searchX + 8, tabY + 8, 0.75, false)
    love.graphics.setColor(isSearchActive and Theme.colors.textPrimary or Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.print("Busca Rapida", searchX + 26, tabY + 8)
    hitboxes.modeSearchBtn = { x = searchX, y = tabY, w = tabW, h = tabH }

    -- Native Pick File Button
    local pickX = searchX + tabW + 6
    local pickW = mx_pos + modalW - 20 - pickX
    local isPickHover = (curX >= pickX and curX <= pickX + pickW and curY >= tabY and curY <= tabY + tabH)
    love.graphics.setColor(isPickHover and Theme.colors.accentCyan or Theme.colors.panelBg)
    love.graphics.rectangle("fill", pickX, tabY, pickW, tabH, 6, 6)
    love.graphics.setColor(Theme.colors.accentCyan or Theme.colors.buttonPlay)
    love.graphics.rectangle("line", pickX, tabY, pickW, tabH, 6, 6)
    love.graphics.setColor(isPickHover and {0.05, 0.08, 0.12, 1.0} or Theme.colors.accentCyan)
    love.graphics.setFont(Theme.fonts.small)
    love.graphics.printf("+ Arquivo", pickX, tabY + 8, pickW, "center")
    hitboxes.pickFileBtn = { x = pickX, y = tabY, w = pickW, h = tabH }

    local contentTopY = tabY + tabH + 8

    -- 3. Path Bar / Shortcuts (in Browse mode)
    if ImportRomModal.mode == "browse" then
        local qy = contentTopY
        local qx = mx_pos + 20
        local qh = 26
        local quickPaths = RomManager.getQuickPaths()

        for _, qp in ipairs(quickPaths) do
            local qLabel = qp.name
            local qw = Theme.fonts.small:getWidth(qLabel) + 16
            if qx + qw <= mx_pos + modalW - 20 then
                local isQHover = (curX >= qx and curX <= qx + qw and curY >= qy and curY <= qy + qh)
                local isQActive = (ImportRomModal.currentPath == qp.path)
                Theme.drawCard(qx, qy, qw, qh, 6, isQHover, isQActive, Theme.colors.accentCyan or accent)

                love.graphics.setColor(isQActive and Theme.colors.textPrimary or (isQHover and Theme.colors.textPrimary or Theme.colors.textSecondary))
                love.graphics.setFont(Theme.fonts.small)
                love.graphics.print(qLabel, qx + 8, qy + 5)

                table.insert(hitboxes.quickPaths, { path = qp.path, x = qx, y = qy, w = qw, h = qh })
                qx = qx + qw + 6
            end
        end

        local py = qy + qh + 8
        local upBtnW, upBtnH = 80, 28
        local isUpHover = (curX >= mx_pos + 20 and curX <= mx_pos + 20 + upBtnW and curY >= py and curY <= py + upBtnH)
        Theme.drawCard(mx_pos + 20, py, upBtnW, upBtnH, 6, isUpHover, false, Theme.colors.panelBorder)
        love.graphics.setColor(isUpHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
        drawVectorArrowUp(mx_pos + 28, py + 8, 11)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Subir", mx_pos + 46, py + 6)
        hitboxes.upBtn = { x = mx_pos + 20, y = py, w = upBtnW, h = upBtnH }

        -- Path display
        local pathBoxX = mx_pos + 20 + upBtnW + 8
        local pathBoxW = modalW - 40 - upBtnW - 8
        love.graphics.setColor(Theme.colors.panelBg)
        love.graphics.rectangle("fill", pathBoxX, py, pathBoxW, upBtnH, 6, 6)
        love.graphics.setColor(Theme.colors.panelBorder)
        love.graphics.rectangle("line", pathBoxX, py, pathBoxW, upBtnH, 6, 6)

        love.graphics.setColor(Theme.colors.textSecondary)
        love.graphics.setFont(Theme.fonts.small)
        local displayPath = ImportRomModal.currentPath or "/"
        if Theme.fonts.small:getWidth(displayPath) > pathBoxW - 16 then
            displayPath = "..." .. displayPath:sub(-32)
        end
        love.graphics.print(displayPath, pathBoxX + 8, py + 6)

        contentTopY = py + upBtnH + 8
    else
        -- Search Mode Hint
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Escaneamento automatico em Retrogame, Downloads e ROMs:", mx_pos + 20, contentTopY)
        contentTopY = contentTopY + 22
    end

    -- 4. File / Folder List View
    local listX = mx_pos + 20
    local listY = contentTopY
    local listW = modalW - 40
    local bottomAreaH = 86
    local listH = modalH - (listY - my_pos) - bottomAreaH

    -- Container frame
    love.graphics.setColor(0.08, 0.09, 0.13, 0.95)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 8, 8)
    love.graphics.setColor(Theme.colors.panelBorder)
    love.graphics.rectangle("line", listX, listY, listW, listH, 8, 8)

    love.graphics.setScissor(listX, listY, listW, listH)

    local itemH = 46
    local totalItems = 0
    local iy = listY + 6 - ImportRomModal.scrollOffset

    if ImportRomModal.mode == "browse" then
        totalItems = #ImportRomModal.items.folders + #ImportRomModal.items.files
        local totalContentH = totalItems * (itemH + 4) + 12
        ImportRomModal.maxScroll = math.max(0, totalContentH - listH)
        ImportRomModal.scrollOffset = math.max(0, math.min(ImportRomModal.scrollOffset, ImportRomModal.maxScroll))
        iy = listY + 6 - ImportRomModal.scrollOffset

        -- Render Folders
        for _, folder in ipairs(ImportRomModal.items.folders) do
            if iy + itemH >= listY and iy <= listY + listH then
                local isHover = (curX >= listX + 6 and curX <= listX + listW - 12 and curY >= iy and curY <= iy + itemH and curY >= listY and curY <= listY + listH)
                Theme.drawCard(listX + 6, iy, listW - 12, itemH, 6, isHover, false, Theme.colors.accentCyan or accent)

                drawVectorFolder(listX + 16, iy + 14, 1.1)

                love.graphics.setColor(isHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
                love.graphics.setFont(Theme.fonts.body)
                love.graphics.print(folder.name, listX + 44, iy + 13)

                -- Arrow indicator on right
                love.graphics.setColor(Theme.colors.textMuted)
                love.graphics.print(">", listX + listW - 28, iy + 13)

                table.insert(hitboxes.folders, { path = folder.path, x = listX + 6, y = iy, w = listW - 12, h = itemH })
            end
            iy = iy + itemH + 4
        end

        -- Render Files
        for _, file in ipairs(ImportRomModal.items.files) do
            if iy + itemH >= listY and iy <= listY + listH then
                local isSelected = (ImportRomModal.selectedFile and ImportRomModal.selectedFile.path == file.path)
                local isHover = (curX >= listX + 6 and curX <= listX + listW - 12 and curY >= iy and curY <= iy + itemH and curY >= listY and curY <= listY + listH)

                Theme.drawCard(listX + 6, iy, listW - 12, itemH, 6, isHover, isSelected, Theme.colors.accentGbc)

                drawVectorCartridge(listX + 16, iy + 13, 1.1, file.name:lower():match("%.gba$") ~= nil)

                love.graphics.setColor(isSelected and Theme.colors.textPrimary or (isHover and Theme.colors.textPrimary or Theme.colors.textSecondary))
                love.graphics.setFont(Theme.fonts.body)
                love.graphics.print(file.name, listX + 44, iy + 13)

                local sizeStr = RomManager.formatSize(file.size)
                love.graphics.setColor(Theme.colors.textMuted)
                love.graphics.setFont(Theme.fonts.small)
                love.graphics.printf(sizeStr, listX + listW - 100, iy + 15, 84, "right")

                table.insert(hitboxes.files, { file = file, x = listX + 6, y = iy, w = listW - 12, h = itemH })
            end
            iy = iy + itemH + 4
        end

        if totalItems == 0 then
            love.graphics.setColor(Theme.colors.textMuted)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.printf("Nenhum arquivo de ROM compatível nesta pasta.", listX + 16, listY + listH / 2 - 12, listW - 32, "center")
            love.graphics.setFont(Theme.fonts.small)
            love.graphics.printf("Toque na aba 'Busca Rapida de ROMs' acima para varrer o aparelho.", listX + 16, listY + listH / 2 + 10, listW - 32, "center")
        end
    else
        -- SEARCH MODE LIST
        local files = ImportRomModal.searchResults or {}
        totalItems = #files
        local totalContentH = totalItems * (itemH + 6) + 12
        ImportRomModal.maxScroll = math.max(0, totalContentH - listH)
        ImportRomModal.scrollOffset = math.max(0, math.min(ImportRomModal.scrollOffset, ImportRomModal.maxScroll))
        iy = listY + 6 - ImportRomModal.scrollOffset

        for _, file in ipairs(files) do
            if iy + itemH >= listY and iy <= listY + listH then
                local isSelected = (ImportRomModal.selectedFile and ImportRomModal.selectedFile.path == file.path)
                local isHover = (curX >= listX + 6 and curX <= listX + listW - 12 and curY >= iy and curY <= iy + itemH and curY >= listY and curY <= listY + listH)

                local isMatch = false
                if game then
                    local fn = file.name:lower()
                    if game.id == "red" and fn:match("red") then isMatch = true
                    elseif game.id == "firered" and fn:match("fire") then isMatch = true
                    elseif game.id == "blue" and fn:match("blue") then isMatch = true
                    elseif game.id == "crystal" and fn:match("crystal") then isMatch = true
                    elseif game.id == "yellow" and fn:match("yellow") then isMatch = true
                    elseif game.id == "smw" and fn:match("mario") then isMatch = true
                    end
                end

                Theme.drawCard(listX + 6, iy, listW - 12, itemH, 6, isHover, isSelected, isMatch and Theme.colors.accentCyan or Theme.colors.accentGbc)

                drawVectorCartridge(listX + 16, iy + 13, 1.1, file.name:lower():match("%.gba$") ~= nil)

                love.graphics.setColor(isSelected and Theme.colors.textPrimary or (isHover and Theme.colors.textPrimary or Theme.colors.textSecondary))
                love.graphics.setFont(Theme.fonts.body)
                love.graphics.print(file.name, listX + 44, iy + 6)

                -- Subtitle: folder path & size
                love.graphics.setColor(isMatch and Theme.colors.accentCyan or Theme.colors.textMuted)
                love.graphics.setFont(Theme.fonts.small)
                local folderStr = "Pasta: " .. (file.folder or "Armazenamento")
                if isMatch then folderStr = "[RECOMENDADO] " .. folderStr end
                love.graphics.print(folderStr, listX + 44, iy + 26)

                local sizeStr = RomManager.formatSize(file.size)
                love.graphics.setColor(Theme.colors.textMuted)
                love.graphics.printf(sizeStr, listX + listW - 90, iy + 15, 76, "right")

                table.insert(hitboxes.files, { file = file, x = listX + 6, y = iy, w = listW - 12, h = itemH })
            end
            iy = iy + itemH + 6
        end

        if totalItems == 0 then
            love.graphics.setColor(Theme.colors.textMuted)
            love.graphics.setFont(Theme.fonts.body)
            love.graphics.printf("Nenhuma ROM encontrada nas pastas comuns do aparelho.", listX + 16, listY + listH / 2 - 12, listW - 32, "center")
            love.graphics.setFont(Theme.fonts.small)
            love.graphics.printf("Use a aba 'Navegar Pastas' para selecionar manualmente seu arquivo.", listX + 16, listY + listH / 2 + 10, listW - 32, "center")
        end
    end

    -- Visible Scrollbar indicator
    if ImportRomModal.maxScroll > 0 then
        local totalContentH = totalItems * (itemH + 4) + 12
        local thumbH = math.max(28, (listH / totalContentH) * (listH - 8))
        local thumbY = listY + 4 + (ImportRomModal.scrollOffset / ImportRomModal.maxScroll) * ((listH - 8) - thumbH)
        love.graphics.setColor(0.3, 0.4, 0.55, 0.75)
        love.graphics.rectangle("fill", listX + listW - 5, thumbY, 3, thumbH, 2, 2)
    end

    love.graphics.setScissor()

    -- 5. Bottom Action Bar (Non-overlapping 2-row layout)
    local bottomY = my_pos + modalH - bottomAreaH + 6

    -- Row 1: Selected File Info or Instructions
    if ImportRomModal.selectedFile then
        love.graphics.setColor(Theme.colors.accentCyan or Theme.colors.accentGbc)
        love.graphics.setFont(Theme.fonts.body)
        local selName = ImportRomModal.selectedFile.name
        if Theme.fonts.body:getWidth(selName) > modalW - 48 then
            selName = selName:sub(1, 35) .. "..."
        end
        love.graphics.print("Selecionado: " .. selName, listX, bottomY)

        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Tamanho: " .. RomManager.formatSize(ImportRomModal.selectedFile.size), listX, bottomY + 18)
    else
        love.graphics.setColor(Theme.colors.textMuted)
        love.graphics.setFont(Theme.fonts.small)
        love.graphics.print("Toque em uma ROM na lista acima para seleciona-la e vincular ao jogo.", listX, bottomY + 6)
    end

    -- Row 2: Action Buttons
    local btnRowY = bottomY + 36
    local cancelBtnW = 90
    local cancelBtnH = 38
    local isCancelHover = (curX >= listX and curX <= listX + cancelBtnW and curY >= btnRowY and curY <= btnRowY + cancelBtnH)
    Theme.drawCard(listX, btnRowY, cancelBtnW, cancelBtnH, 6, isCancelHover, false, Theme.colors.panelBorder)
    love.graphics.setColor(isCancelHover and Theme.colors.textPrimary or Theme.colors.textSecondary)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("Fechar", listX, btnRowY + 9, cancelBtnW, "center")
    hitboxes.cancelBtn = { x = listX, y = btnRowY, w = cancelBtnW, h = cancelBtnH }

    local importBtnX = listX + cancelBtnW + 10
    local importBtnW = modalW - 40 - cancelBtnW - 10
    local importBtnH = 38
    local isBtnEnabled = (ImportRomModal.selectedFile ~= nil and game ~= nil)
    local isBtnHover = isBtnEnabled and (curX >= importBtnX and curX <= importBtnX + importBtnW and curY >= btnRowY and curY <= btnRowY + importBtnH)

    if isBtnEnabled then
        love.graphics.setColor(isBtnHover and Theme.colors.buttonPlayHover or Theme.colors.buttonPlay)
    else
        love.graphics.setColor(0.18, 0.22, 0.30, 0.6)
    end
    love.graphics.rectangle("fill", importBtnX, btnRowY, importBtnW, importBtnH, 8, 8)

    love.graphics.setColor(isBtnEnabled and {1, 1, 1, 1} or Theme.colors.textMuted)
    love.graphics.setFont(Theme.fonts.body)
    love.graphics.printf("IMPORTAR ROM SELECIONADA", importBtnX, btnRowY + 9, importBtnW, "center")
    hitboxes.importBtn = { x = importBtnX, y = btnRowY, w = importBtnW, h = importBtnH, enabled = isBtnEnabled }

    -- Toast / Status Message
    if ImportRomModal.statusMessage then
        local tw = modalW - 40
        local ty = my_pos + modalH - 50
        Theme.drawCard(mx_pos + 20, ty, tw, 36, 8, false, true, Theme.colors.accentGbc)
        love.graphics.setColor(Theme.colors.textPrimary)
        love.graphics.setFont(Theme.fonts.body)
        love.graphics.printf(ImportRomModal.statusMessage, mx_pos + 20, ty + 8, tw, "center")
    end

    return hitboxes
end

function ImportRomModal.mousepressed(x, y, button, hitboxes, game)
    if not hitboxes then return nil end

    -- Close & Cancel Buttons
    if hitboxes.closeBtn then
        local cb = hitboxes.closeBtn
        if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
            return "close"
        end
    end
    if hitboxes.cancelBtn then
        local cb = hitboxes.cancelBtn
        if x >= cb.x and x <= cb.x + cb.w and y >= cb.y and y <= cb.y + cb.h then
            return "close"
        end
    end

    -- Tab Switchers
    if hitboxes.modeBrowseBtn then
        local mb = hitboxes.modeBrowseBtn
        if x >= mb.x and x <= mb.x + mb.w and y >= mb.y and y <= mb.y + mb.h then
            ImportRomModal.mode = "browse"
            ImportRomModal.scrollOffset = 0
            ImportRomModal.refresh()
            return "tab"
        end
    end
    if hitboxes.modeSearchBtn then
        local sb = hitboxes.modeSearchBtn
        if x >= sb.x and x <= sb.x + sb.w and y >= sb.y and y <= sb.y + sb.h then
            ImportRomModal.triggerQuickScan()
            return "tab"
        end
    end
    if hitboxes.pickFileBtn then
        local pb = hitboxes.pickFileBtn
        if x >= pb.x and x <= pb.x + pb.w and y >= pb.y and y <= pb.y + pb.h then
            if game then
                RomManager.pickAndImport(game.id, function(ok, msg)
                    ImportRomModal.statusMessage = msg or (ok and "ROM Importada!" or "Falha ao importar")
                    ImportRomModal.statusTimer = 2.5
                end)
            end
            return "pick"
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
            if ImportRomModal.selectedFile and ImportRomModal.selectedFile.path == fl.file.path and game then
                local ok, msg = RomManager.importRomForGame(game.id, fl.file.path)
                ImportRomModal.statusMessage = msg or "ROM Importada!"
                ImportRomModal.statusTimer = 2.5
                return "imported"
            else
                ImportRomModal.selectedFile = fl.file
                return "select"
            end
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
