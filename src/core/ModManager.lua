local ModManager = {}

ModManager.gameMods = {
    crystal = {
        { id = "ptbr_crystal", name = "Tradução PT-BR v1.3.0", author = "guuhferiani", category = "Localização", desc = "Tradução completa dos textos e diálogos em português do Brasil.", enabled = true },
        { id = "kanto_251", name = "Kanto Full & 251 Pokémon", author = "guuhferiani", category = "Expansão", desc = "Permite capturar todos os 251 Pokémon no mapa sem trocas.", enabled = true },
        { id = "ash_save", name = "Save do Ash (Slot 1 & 2)", author = "guuhferiani", category = "Save Data", desc = "Auto-restaura o progresso do Ash com time clássico.", enabled = false },
        { id = "run_indoors", name = "Correr em Ambientes Fechados", author = "Comunidade", category = "Gameplay", desc = "Remove restrições de corrida dentro de casas e ginásios.", enabled = true },
        { id = "exp_share", name = "Exp Share Moderno", author = "Comunidade", category = "Balanceamento", desc = "Distribui experiência para toda a equipe igual gerações modernas.", enabled = true }
    },
    yellow = {
        { id = "fast_text", name = "Texto Instantâneo", author = "Comunidade", category = "QoL", desc = "Acelera as caixas de diálogo e batalhas.", enabled = true },
        { id = "run_everywhere", name = "Corrida Automática", author = "Comunidade", category = "Gameplay", desc = "Segure B para correr em qualquer lugar.", enabled = true },
        { id = "color_sprites", name = "Sprites Coloridos Gen 2", author = "Comunidade", category = "Visual", desc = "Importa paletas coloridas avançadas para os 151 monstrinhos.", enabled = false }
    },
    firered = {
        { id = "ptbr_firered", name = "Tradução PT-BR FireRed", author = "Comunidade", category = "Localização", desc = "Diálogos e golpes 100% em português.", enabled = true },
        { id = "exp_share_modern", name = "Exp Share Moderno", author = "Comunidade", category = "Gameplay", desc = "Mecanismo moderno de compartilhamento de EXP.", enabled = true },
        { id = "fast_text_instant", name = "Instant Text Boxes", author = "Comunidade", category = "QoL", desc = "Diálogos aparecem sem atrasos de rolagem.", enabled = true },
        { id = "reusable_tms", name = "TMs Infinitos", author = "Comunidade", category = "QoL", desc = "TMs não quebram após o uso.", enabled = true },
        { id = "run_indoors_gba", name = "Correr em Interiores", author = "Comunidade", category = "Gameplay", desc = "Sapatos de corrida funcionam em prédios e cavernas.", enabled = true }
    }
}

function ModManager.getMods(gameId)
    return ModManager.gameMods[gameId] or {}
end

function ModManager.toggle(gameId, modId)
    local list = ModManager.gameMods[gameId] or {}
    for _, m in ipairs(list) do
        if m.id == modId then
            m.enabled = not m.enabled
            return m.enabled
        end
    end
    return false
end

function ModManager.getActiveCount(gameId)
    local list = ModManager.gameMods[gameId] or {}
    local count = 0
    for _, m in ipairs(list) do
        if m.enabled then count = count + 1 end
    end
    return count, #list
end

return ModManager
