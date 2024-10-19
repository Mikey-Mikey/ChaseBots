function CreateRagdollFromPlayer(ply)
    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ply:GetPos())
    ragdoll:SetModel(ply:GetModel())
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetNW2Entity("RagdollOwner", ply)


    for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
        local phys = ragdoll:GetPhysicsObjectNum(i)

        local matrix = ply:GetBoneMatrix(ragdoll:TranslatePhysBoneToBone(i))
        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngles()

        phys:SetPos(pos)
        phys:SetAngles(ang)

        phys:SetVelocity(ply:GetVelocity())
    end

    return ragdoll
end

hook.Add("PlayerInitialSpawn", "PlayerFirstSpawned", function(ply)
    if GetGlobal2Bool("RoundRunning", false) then
        ply:SetNWBool("Spectating", true)
        ply:SetColor(Color(255, 255, 255, 0))
        ply:DrawShadow(false)
    end

    if player.GetCount() <= 1 and not GetGlobal2Bool("RoundRunning", false) then
        GAMEMODE:StartRound()
    end
end)

hook.Add("PlayerDeathThink", "PreventRespawn", function(ply)
    return true
end)

hook.Add("OnEntityCreated", "RemoveClientRagdoll", function(ent)
    if ent:GetClass() == "hl2mp_ragdoll" then
        timer.Simple(0, function()
            ent:Remove()
        end)
    end
end)

hook.Add("Tick", "RoundTimer", function()
    if GetGlobal2Bool("RoundRunning", false) then
        SetGlobal2Float("CurrentRoundTime", GetGlobal2Float("RoundStartTime", 0) - RealTime() + GetGlobal2Float("BASE_ROUND_TIME", 300))
        if GetGlobal2Float("CurrentRoundTime", 0) <= 0 then
            GAMEMODE:EndRound()
        end
    end
end)

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "SpectateAttackerNextbot", function(data)
    local victim = Entity(data.entindex_killed)
    local deathPos = victim:GetPos()
    local deathEyeAngles = victim:EyeAngles()
    -- when the victim dies start spectating
    victim:SetNWBool("Spectating", true)
    CreateRagdollFromPlayer(victim)
    timer.Simple(0.02, function()
        victim:Spawn()
        victim:SetPos(deathPos)
        victim:SetEyeAngles(deathEyeAngles)
    end)

    -- If there are no players left, end the round
    local playersLeft = 0
    for k, ply in ipairs(player.GetAll()) do
        if not ply:GetNWBool("Spectating", false) then playersLeft = playersLeft + 1 end
    end

    if playersLeft == 0 then
        GAMEMODE:EndRound()
    end
end)


gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "RemovePlayerFromAliveList", function(data)
    local playersLeft = 0
    for k, ply in ipairs(player.GetAll()) do
        if ply:Alive() then playersLeft = playersLeft + 1 end
    end

    if playersLeft == 0 then
        GAMEMODE:EndRound()
    end
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "AddPlayerToAliveList", function(data)
    local ply = Player(data.userid)
    ply:SetModel("models/player/group01/male_07.mdl")
    local plyColor = HSVToColor(util.SharedRandom(ply:SteamID64(), 0, 360), 1, 1)
    ply:SetPlayerColor(Vector(plyColor.r, plyColor.g, plyColor.b))
    ply:SetJumpPower(200)
    if ply:GetNWBool("Spectating", false) then
        ply:SetColor(Color(255, 255, 255, 0))
        ply:DrawShadow(false)
        ply:SetNoTarget(true)
        victim:SetCollisionGroup(COLLISION_GROUP_WORLD)
    else
        ply:SetColor(Color(255, 255, 255, 255))
        ply:DrawShadow(true)
        ply:SetNoTarget(false)
        ply:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
end)

hook.Add("PlayerUse", "DisableSpectatorUse", function(ply, ent)
    if ply:GetNWBool("Spectating", false) then
        return false
    end
end)