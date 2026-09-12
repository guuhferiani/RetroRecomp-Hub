local PlatformManager = {}

PlatformManager.platforms = {
    { id = "all", name = "Todos", icon = "★", desc = "Coleção Completa" },
    { id = "gbc", name = "GB / GBC", icon = "🎮", desc = "Game Boy Color", color = {0.06, 0.75, 0.50, 1.0} },
    { id = "gba", name = "GBA", icon = "⚡", desc = "Game Boy Advance", color = {0.58, 0.38, 0.96, 1.0} },
    { id = "snes", name = "SNES", icon = "🕹️", desc = "Super Nintendo 16-bit", color = {0.85, 0.28, 0.35, 1.0} },
    { id = "ps1", name = "PS1", icon = "💿", desc = "PlayStation 32-bit CD", color = {0.18, 0.48, 0.92, 1.0} }
}

PlatformManager.games = {
    {
        id = "crystal",
        platform = "gbc",
        title = "Pokémon Crystal Version",
        subtitle = "Gen II • Game Boy Color",
        region = "EUA / Tradução PT-BR",
        releaseYear = "2000",
        engine = "gen1recomp",
        romFile = "roms/gbc/crystal.gbc",
        romFallback = "roms/gbc/Pokemon - Crystal Version (UE) (V1.1) [C][!].gbc",
        cartType = "gb",
        cartColor = {0.20, 0.45, 0.75, 0.85},
        cartAccent = {0.40, 0.80, 1.0, 1.0},
        labelColor = {0.15, 0.35, 0.65},
        badgeColor = {0.06, 0.75, 0.50, 0.25},
        badgeText = "NATIVO RECOMP",
        description = "A obra-prima de Johto rodando em recompilação nativa ultra suave a 60 FPS com suporte ao mod PT-BR v1.3.0 (Kanto Full e 251 Pokémon capturáveis).",
        features = { "60 FPS Nativo", "Wide Battle Support", "Save Editor Integrado", "Expansão 251 Pokémon" },
        savePath = "saves/crystal.sav",
        currentSlot = 1
    },
    {
        id = "yellow",
        platform = "gbc",
        title = "Pokémon Yellow Version",
        subtitle = "Special Pikachu Edition • Gen I",
        region = "EUA",
        releaseYear = "1998",
        engine = "gen1recomp",
        romFile = "roms/gbc/yellow.gbc",
        romFallback = "roms/gbc/Pokemon - Yellow Version (UE) [C][!].gbc",
        cartType = "gb",
        cartColor = {0.95, 0.78, 0.12, 1.0},
        cartAccent = {1.0, 0.90, 0.35, 1.0},
        labelColor = {0.85, 0.68, 0.08},
        badgeColor = {0.96, 0.72, 0.15, 0.25},
        badgeText = "NATIVO RECOMP",
        description = "O clássico que iniciou febres mundiais com Pikachu te seguindo no mapa, compatível com saves customizados e slots múltiplos.",
        features = { "Pikachu Follower", "Port Nativo Love2D", "Color Palette Suave", "Fast Text" },
        savePath = "saves/yellow.sav",
        currentSlot = 1
    },
    {
        id = "firered",
        platform = "gba",
        title = "Pokémon FireRed Version",
        subtitle = "Kanto Reimagined • Gen III",
        region = "EUA / Tradução PT-BR",
        releaseYear = "2004",
        engine = "gba",
        romFile = "roms/gba/FireRed.gba",
        cartType = "gba",
        cartColor = {0.88, 0.28, 0.12, 0.90},
        cartAccent = {1.0, 0.50, 0.30, 1.0},
        labelColor = {0.75, 0.22, 0.08},
        badgeColor = {0.58, 0.38, 0.96, 0.25},
        badgeText = "GBA ENGINE",
        description = "A clássica jornada por Kanto revitalizada para 32-bit com shaders modernos (LCD, CRT, Scale4x), Exp Share Moderno e corrida indoors.",
        features = { "GBA 32-bit", "Shaders LCD / CRT", "Corrida em Ambientes Fechados", "Tradução PT-BR" },
        savePath = "saves/firered.sav",
        currentSlot = 1
    },
    {
        id = "smw",
        platform = "snes",
        title = "Super Mario World",
        subtitle = "16-Bit Super Nintendo Classic",
        region = "EUA / Tradução PT-BR",
        releaseYear = "1990",
        engine = "snes9x",
        romFile = "roms/snes/smw.sfc",
        cartType = "snes",
        cartColor = {0.74, 0.75, 0.78, 1.0},
        cartAccent = {0.95, 0.85, 0.25, 1.0},
        labelColor = {0.18, 0.45, 0.82},
        badgeColor = {0.85, 0.28, 0.35, 0.25},
        badgeText = "SNES 16-BIT",
        description = "O marco dos jogos de plataforma 16-bit com Yoshi, 96 saídas de fases secretas e suporte a shaders CRT analógicos.",
        features = { "Mode 7 Graphics", "Suporte 96 Saídas", "Filtros CRT Trinitron", "Save State Instantâneo" },
        savePath = "saves/smw.srm",
        currentSlot = 1
    },
    {
        id = "sotn",
        platform = "ps1",
        title = "Castlevania: Symphony of the Night",
        subtitle = "32-Bit CD-ROM PlayStation",
        region = "EUA / Dublado PT-BR",
        releaseYear = "1997",
        engine = "duckstation",
        romFile = "roms/ps1/sotn.chd",
        cartType = "ps1",
        cartColor = {0.12, 0.12, 0.15, 0.95},
        cartAccent = {0.85, 0.20, 0.20, 1.0},
        labelColor = {0.08, 0.08, 0.10},
        badgeColor = {0.18, 0.48, 0.92, 0.25},
        badgeText = "PS1 32-BIT CD",
        description = "A obra-prima definitiva do gênero Metroidvania com Alucard, trilha sonora orquestrada com qualidade de CD e áudio Redbook.",
        features = { "Áudio Redbook CD", "Castelo Invertido 200.6%", "Dublagem e Textos PT-BR", "Black Disc Recomp" },
        savePath = "saves/sotn.mcr",
        currentSlot = 1
    }
}

function PlatformManager.getGamesByPlatform(platformId)
    if not platformId or platformId == "all" then
        return PlatformManager.games
    end
    local filtered = {}
    for _, g in ipairs(PlatformManager.games) do
        if g.platform == platformId then
            table.insert(filtered, g)
        end
    end
    return filtered
end

function PlatformManager.getGameById(gameId)
    for _, g in ipairs(PlatformManager.games) do
        if g.id == gameId then return g end
    end
    return PlatformManager.games[1]
end

return PlatformManager
