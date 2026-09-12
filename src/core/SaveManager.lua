local SaveManager = {}

SaveManager.slots = {
    { id = 1, name = "Slot 1 (Principal)", status = "Ativo", date = "Hoje, 00:15", desc = "Save padrão do jogo" },
    { id = 2, name = "Slot 2 (Backup)", status = "Sincronizado", date = "Ontem, 23:40", desc = "Backup antes da Elite Four" },
    { id = 3, name = "Slot 3 (Ash Ketchum)", status = "Pronto", date = "08/09/2026", desc = "Save temático com Pikachu LV. 88" },
    { id = 4, name = "Slot 4 (Vazio)", status = "Livre", date = "--/--/----", desc = "Slot disponível para nova jornada" }
}

function SaveManager.getSlots(gameId)
    return SaveManager.slots
end

function SaveManager.selectSlot(gameId, slotId)
    for _, s in ipairs(SaveManager.slots) do
        if s.id == slotId then
            s.status = "Ativo"
        elseif s.status == "Ativo" then
            s.status = "Gravado"
        end
    end
end

return SaveManager
