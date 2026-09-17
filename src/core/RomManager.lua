local Config = require("src.core.Config")
local MobileBridge = require("src.core.MobileBridge")

local RomManager = {}

local SUPPORTED_EXTENSIONS = {
    gb = true, gbc = true, gba = true, sfc = true, smc = true,
    chd = true, bin = true, iso = true, cue = true, zip = true, ["7z"] = true
}

-- Return standard quick access directories based on platform
function RomManager.getQuickPaths()
    local paths = {}
    local saveDir = love.filesystem.getSaveDirectory()

    if MobileBridge.isMobile() then
        table.insert(paths, { name = "Retrogame", path = "/storage/emulated/0/Retrogame", iconType = "game" })
        table.insert(paths, { name = "Downloads", path = "/storage/emulated/0/Download", iconType = "download" })
        table.insert(paths, { name = "ROMs", path = "/storage/emulated/0/ROMs", iconType = "game" })
        table.insert(paths, { name = "Armazenamento", path = "/storage/emulated/0", iconType = "storage" })
        table.insert(paths, { name = "Dados Hub", path = saveDir, iconType = "hub" })
    else
        table.insert(paths, { name = "Pasta Hub", path = love.filesystem.getSource(), iconType = "hub" })
        table.insert(paths, { name = "Pasta ROMs", path = "roms", iconType = "game" })
        local userProfile = os.getenv("USERPROFILE") or os.getenv("HOME") or "."
        table.insert(paths, { name = "Downloads", path = userProfile .. "/Downloads", iconType = "download" })
        table.insert(paths, { name = "Documentos", path = userProfile .. "/Documents", iconType = "folder" })
        table.insert(paths, { name = "Saves Hub", path = saveDir, iconType = "storage" })
    end

    return paths
end

-- Check if an extension is supported for emulation
function RomManager.isSupportedFile(filename)
    if not filename then return false end
    local ext = filename:match("%.([^%.]+)$")
    if ext then
        ext = ext:lower()
        return SUPPORTED_EXTENSIONS[ext] or false
    end
    return false
end

-- Get file extension
function RomManager.getFileExtension(filename)
    if not filename then return "" end
    return (filename:match("%.([^%.]+)$") or ""):lower()
end

-- Check if a path is a directory (safe fallback)
local function isDirectory(path)
    if not path or path == "" then return false end
    local info = love.filesystem.getInfo(path)
    if info then return info.type == "directory" end

    -- On Windows or fallback:
    local isWin = (love.system and love.system.getOS() == "Windows")
    if isWin then
        local check = io.popen(string.format('if exist "%s\\*" (echo 1) else (echo 0)', path:gsub("/", "\\")))
        if check then
            local res = check:read("*l") or ""
            check:close()
            return res:match("1") ~= nil
        end
    end
    return false
end

-- Safe list directory items
function RomManager.listDirectory(currentPath)
    local items = {
        folders = {},
        files = {}
    }

    if not currentPath or currentPath == "" then
        return items
    end

    -- 1. Try love.filesystem if it's within game mount or save directory
    local loveItems = love.filesystem.getDirectoryItems(currentPath)
    if loveItems and #loveItems > 0 then
        for _, name in ipairs(loveItems) do
            local fullPath = currentPath .. "/" .. name
            local info = love.filesystem.getInfo(fullPath)
            if info then
                if info.type == "directory" then
                    table.insert(items.folders, { name = name, path = fullPath, isDir = true })
                elseif RomManager.isSupportedFile(name) then
                    table.insert(items.files, { name = name, path = fullPath, isDir = false, size = info.size or 0 })
                end
            end
        end
        table.sort(items.folders, function(a, b) return a.name:lower() < b.name:lower() end)
        table.sort(items.files, function(a, b) return a.name:lower() < b.name:lower() end)
        return items
    end

    -- 2. Native OS directory listing
    local isWin = (love.system and love.system.getOS() == "Windows")
    if isWin then
        local safePath = currentPath:gsub("/", "\\")
        -- List directories
        local dirHandle = io.popen(string.format('dir "%s" /B /A:D 2>nul', safePath))
        if dirHandle then
            for line in dirHandle:lines() do
                local cleanName = line:gsub("\r", ""):gsub("\n", "")
                if cleanName ~= "" and cleanName ~= "." and cleanName ~= ".." then
                    table.insert(items.folders, { name = cleanName, path = currentPath .. "/" .. cleanName, isDir = true })
                end
            end
            dirHandle:close()
        end
        -- List files
        local fileHandle = io.popen(string.format('dir "%s" /B /A:-D 2>nul', safePath))
        if fileHandle then
            for line in fileHandle:lines() do
                local cleanName = line:gsub("\r", ""):gsub("\n", "")
                if cleanName ~= "" and RomManager.isSupportedFile(cleanName) then
                    local fullPath = currentPath .. "/" .. cleanName
                    local f = io.open(fullPath, "rb")
                    local size = 0
                    if f then
                        size = f:seek("end") or 0
                        f:close()
                    end
                    table.insert(items.files, { name = cleanName, path = fullPath, isDir = false, size = size })
                end
            end
            fileHandle:close()
        end
    else
        -- Linux / Android: Use `ls -1p` which appends '/' to directory names
        local cmd = string.format('ls -1p "%s" 2>/dev/null', currentPath)
        local handle = io.popen(cmd)
        if handle then
            for line in handle:lines() do
                local rawLine = line:gsub("\r", ""):gsub("\n", "")
                if rawLine ~= "" and rawLine ~= "./" and rawLine ~= "../" and rawLine ~= "." and rawLine ~= ".." then
                    local isDir = rawLine:sub(-1) == "/"
                    local cleanName = isDir and rawLine:sub(1, -2) or rawLine
                    local fullPath = currentPath .. "/" .. cleanName

                    if isDir then
                        table.insert(items.folders, { name = cleanName, path = fullPath, isDir = true })
                    elseif RomManager.isSupportedFile(cleanName) then
                        local f = io.open(fullPath, "rb")
                        local size = 0
                        if f then
                            size = f:seek("end") or 0
                            f:close()
                        end
                        table.insert(items.files, { name = cleanName, path = fullPath, isDir = false, size = size })
                    end
                end
            end
            handle:close()
        end
    end

    -- Sort folders and files alphabetically
    table.sort(items.folders, function(a, b) return a.name:lower() < b.name:lower() end)
    table.sort(items.files, function(a, b) return a.name:lower() < b.name:lower() end)

    return items
end

-- Fast recursive scanner for ROM files on Android & PC
local cachedQuickScan = nil
local lastScanTime = 0

function RomManager.quickScanDevice(forceRefresh)
    local now = love.timer and love.timer.getTime() or os.time()
    if not forceRefresh and cachedQuickScan and (now - lastScanTime < 10) then
        return cachedQuickScan
    end

    local foundFiles = {}
    local seenPaths = {}
    local roots = {}

    if MobileBridge.isMobile() then
        table.insert(roots, "/storage/emulated/0/Retrogame")
        table.insert(roots, "/storage/emulated/0/Download")
        table.insert(roots, "/storage/emulated/0/ROMs")
        table.insert(roots, "/storage/emulated/0/Roms")
        table.insert(roots, "/sdcard/Download")
        table.insert(roots, "/sdcard/Retrogame")
        table.insert(roots, love.filesystem.getSaveDirectory())
    else
        table.insert(roots, "roms")
        table.insert(roots, "test_roms")
        local userProfile = os.getenv("USERPROFILE") or os.getenv("HOME") or "."
        table.insert(roots, userProfile .. "/Downloads")
        table.insert(roots, love.filesystem.getSaveDirectory())
    end

    local isWin = (love.system and love.system.getOS() == "Windows")

    local function scanDirRecursive(dirPath, depth)
        if depth > 4 then return end
        local listed = RomManager.listDirectory(dirPath)
        for _, file in ipairs(listed.files) do
            if not seenPaths[file.path] then
                seenPaths[file.path] = true
                file.folder = dirPath:match("[^/\\]+$") or dirPath
                table.insert(foundFiles, file)
            end
        end
        for _, folder in ipairs(listed.folders) do
            -- Avoid deep systemic folders
            local fn = folder.name:lower()
            if fn ~= "android" and fn ~= "dcim" and fn ~= "pictures" and fn ~= "cache" and fn ~= "audiobooks" and fn ~= "log" and fn ~= ".git" then
                scanDirRecursive(folder.path, depth + 1)
            end
        end
    end

    for _, root in ipairs(roots) do
        scanDirRecursive(root, 1)
    end

    table.sort(foundFiles, function(a, b) return a.name:lower() < b.name:lower() end)
    cachedQuickScan = foundFiles
    lastScanTime = now
    return foundFiles
end

-- Get parent directory
function RomManager.getParentDirectory(path)
    if not path or path == "" then return "" end
    local clean = path:gsub("\\", "/")
    local parent = clean:match("^(.*)/[^/]+/?$")
    if not parent or parent == "" then
        if clean:match("^%a:") then
            return clean:match("^(%a:)") .. "/"
        end
        return "/"
    end
    return parent
end

-- Format bytes into human readable format
function RomManager.formatSize(bytes)
    if not bytes or bytes <= 0 then return "0 KB" end
    if bytes >= 1024 * 1024 * 1024 then
        return string.format("%.2f GB", bytes / (1024 * 1024 * 1024))
    elseif bytes >= 1024 * 1024 then
        return string.format("%.1f MB", bytes / (1024 * 1024))
    else
        return string.format("%d KB", math.ceil(bytes / 1024))
    end
end

-- Get ROM status for a specific game
function RomManager.getRomStatus(game)
    if not game then return false, nil, "Nenhum jogo selecionado" end

    -- 1. Check custom user assigned ROM path in Config
    local customPath = Config.customRomPaths and Config.customRomPaths[game.id]
    if customPath and customPath ~= "" then
        local f = io.open(customPath, "rb")
        if f then
            local size = f:seek("end") or 0
            f:close()
            return true, customPath, RomManager.formatSize(size)
        end
        -- Also check love.filesystem
        local info = love.filesystem.getInfo(customPath)
        if info then
            return true, customPath, RomManager.formatSize(info.size)
        end
    end

    -- 2. Check internal / default paths
    local Router = require("src.core.Router")
    local defaultRom = Router.findRom(game)
    if defaultRom then
        local f = io.open(defaultRom, "rb")
        local size = 0
        if f then
            size = f:seek("end") or 0
            f:close()
        end
        return true, defaultRom, RomManager.formatSize(size)
    end

    return false, nil, "ROM não encontrada"
end

-- Link or copy a selected ROM to a game
function RomManager.importRomForGame(gameId, sourceFilePath)
    if not gameId or not sourceFilePath or sourceFilePath == "" then
        return false, "Arquivo inválido"
    end

    -- Store path in Config
    if not Config.customRomPaths then
        Config.customRomPaths = {}
    end
    Config.customRomPaths[gameId] = sourceFilePath
    Config.save()

    print(string.format("[ROM_MANAGER] Assigned ROM for %s -> %s", gameId, sourceFilePath))
    return true, "ROM importada com sucesso!"
end

-- Auto-assign dropped file to matching game based on platform / filename
function RomManager.handleDroppedFile(fileObject)
    local filename = fileObject:getFilename()
    if not RomManager.isSupportedFile(filename) then
        return false, "Formato de arquivo não suportado"
    end

    local ext = RomManager.getFileExtension(filename)
    local lowerName = filename:lower()

    local PlatformManager = require("src.core.PlatformManager")
    local matchedGame = nil

    -- Match by filename keywords
    for _, g in ipairs(PlatformManager.games) do
        if g.id == "red" and (lowerName:match("red") or lowerName:match("vermelh")) then
            matchedGame = g; break
        elseif g.id == "blue" and (lowerName:match("blue") or lowerName:match("azul")) then
            matchedGame = g; break
        elseif g.id == "crystal" and (lowerName:match("crystal") or lowerName:match("cristal")) then
            matchedGame = g; break
        elseif g.id == "yellow" and (lowerName:match("yellow") or lowerName:match("amarela") or lowerName:match("pikachu")) then
            matchedGame = g; break
        elseif g.id == "firered" and (lowerName:match("firered") or lowerName:match("fire") or lowerName:match("fogo")) then
            matchedGame = g; break
        elseif g.id == "smw" and (lowerName:match("mario") or lowerName:match("smw")) then
            matchedGame = g; break
        elseif g.id == "sotn" and (lowerName:match("sotn") or lowerName:match("symphony") or lowerName:match("castlevania")) then
            matchedGame = g; break
        end
    end

    -- Fallback match by platform extension
    if not matchedGame then
        for _, g in ipairs(PlatformManager.games) do
            if (ext == "gbc" or ext == "gb") and g.platform == "gbc" then
                matchedGame = g; break
            elseif ext == "gba" and g.platform == "gba" then
                matchedGame = g; break
            elseif (ext == "sfc" or ext == "smc") and g.platform == "snes" then
                matchedGame = g; break
            elseif (ext == "chd" or ext == "bin" or ext == "iso" or ext == "cue") and g.platform == "ps1" then
                matchedGame = g; break
            end
        end
    end

    if matchedGame then
        RomManager.importRomForGame(matchedGame.id, filename)
        return true, string.format("ROM associada a %s com sucesso!", matchedGame.title)
    end

    return false, "Nenhum jogo compatível identificado para este arquivo"
end

return RomManager
