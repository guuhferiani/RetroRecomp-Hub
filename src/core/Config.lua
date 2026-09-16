local Config = {
    selectedPlatform = "all",
    selectedGameId = "crystal",
    activeShader = "crt",
    volume = 1.0,
    scanlines = false,
    fullscreen = false,
    customRomPaths = {}
}

local CONFIG_FILE = "hub_config.json"

function Config.load()
    if love.filesystem.getInfo(CONFIG_FILE) then
        local content = love.filesystem.read(CONFIG_FILE)
        if content then
            for k, v in content:gmatch('"([%w_]+)"%s*:%s*"([^"]+)"') do
                if not k:match("^rom_") then
                    Config[k] = v
                end
            end
            for k, v in content:gmatch('"([%w_]+)"%s*:%s*(%a+)') do
                if v == "true" then Config[k] = true
                elseif v == "false" then Config[k] = false end
            end
            -- Parse custom ROM paths
            Config.customRomPaths = {}
            for gameId, path in content:gmatch('"rom_([%w_]+)"%s*:%s*"([^"]+)"') do
                Config.customRomPaths[gameId] = path:gsub("\\\\", "\\")
            end
        end
    end
end

function Config.save()
    local lines = { "{" }
    table.insert(lines, string.format('  "selectedPlatform": "%s",', tostring(Config.selectedPlatform)))
    table.insert(lines, string.format('  "selectedGameId": "%s",', tostring(Config.selectedGameId)))
    table.insert(lines, string.format('  "activeShader": "%s",', tostring(Config.activeShader or "crt")))
    table.insert(lines, string.format('  "scanlines": %s,', tostring(Config.scanlines)))
    table.insert(lines, string.format('  "fullscreen": %s,', tostring(Config.fullscreen)))

    -- Save custom ROM paths
    local romEntries = {}
    for gameId, path in pairs(Config.customRomPaths or {}) do
        local safePath = path:gsub("\\", "\\\\")
        table.insert(romEntries, string.format('  "rom_%s": "%s"', gameId, safePath))
    end
    if #romEntries > 0 then
        table.insert(lines, table.concat(romEntries, ",\n"))
    else
        -- Remove trailing comma on last line if no rom entries
        lines[#lines] = lines[#lines]:gsub(",$", "")
    end

    table.insert(lines, "}")
    love.filesystem.write(CONFIG_FILE, table.concat(lines, "\n"))
end

return Config

