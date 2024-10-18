hook.Add("InitPostEntity", "", function()
    local npcs = list.Get("NPC")
    for class, tbl in pairs(npcs) do
        if string.find(class, "npc_tf2_ghost") then
            continue
        end

        if scripted_ents.IsBasedOn(class, "base_nextbot") then
            GAMEMODE.NextbotClassTable[#GAMEMODE.NextbotClassTable + 1] = class
        end
    end
    if #player.GetAll() > 0 and not GAMEMODE.RoundRunning then
        GAMEMODE:StartRound()
    end
end)

function GM:EndRound()
    GAMEMODE.RoundRunning = false
    GAMEMODE.AlivePlayers = {}
    timer.Create("RestartRound", 3, 1, function()
        GAMEMODE:StartRound()
    end)
end