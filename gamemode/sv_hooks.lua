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

    navmesh.Load()
end)

hook.Add("PlayerInitialSpawn", "PlayerFirstSpawned", function(ply)
    if GAMEMODE.RoundRunning then
        ply:Spectate(OBS_MODE_CHASE)
        ply:SpectateEntity(ply)
    end
end)

hook.Add("PlayerDeathThink", "PreventRespawn", function(ply)
    return true
end)

hook.Add("OnEntityCreated", "RemoveClientRagdoll", function(ent)
    if ent:GetClass() == "hl2mp_ragdoll" then
        ent:Remove()
    end
end)