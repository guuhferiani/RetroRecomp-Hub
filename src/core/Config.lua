local Config = {
    selectedPlatform = "all",
    selectedGameId = "crystal",
    activeShader = "crt",
    volume = 1.0,
    scanlines = false,
    fullscreen = false
}

local CONFIG_FILE = "hub_config.json"

function Config.load()
    if love.filesystem.getInfo(CONFIG_FILE) then
        local content = love.filesystem.read(CONFIG_FILE)
        if content then
            for k, v in content:gmatch('"([%w_]+)"%s*:%s*"([^"]+)"') do
                Config[k] = v
            end
            for k, v in content:gmatch('"([%w_]+)"%s*:%s*(%a+)') do
                if v == "true" then Config[k] = true
                elseif v == "false" then Config[k] = false end
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
    table.insert(lines, string.format('  "fullscreen": %s', tostring(Config.fullscreen)))
    table.insert(lines, "}")
    love.filesystem.write(CONFIG_FILE, table.concat(lines, "\n"))
end

return Config
