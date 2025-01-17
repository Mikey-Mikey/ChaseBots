function CreateRagdollFromPlayer(ply)
    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll:SetPos(ply:GetPos())
    ragdoll:SetModel(ply:GetModel())
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetNW2Entity("RagdollOwner", ply)
    ragdoll:SetNW2Bool("IsGamemodeRagdoll", true)


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
    local rolePriority = ROLE_PRIORITY[ply:GetUserGroup()]
    if not rolePriority then
        ply:SetUserGroup("Guest")
    end

    if GetGlobal2Bool("RoundRunning", false) then
        ply:SetNWBool("Spectating", true)
    end

    timer.Simple(0.1, function()
        if GetGlobal2Bool("RoundRunning", false) then
            ply:KillSilent()
            ply:Spectate(OBS_MODE_ROAMING)
            ply:SetObserverMode(OBS_MODE_ROAMING)
        end
    end)

    timer.Simple(0.5, function()
        if GetGlobal2Bool("Empty", true) then
            SetGlobal2Bool("Empty", false)
            GAMEMODE:StartRound()
        end
    end)
end)

hook.Add("PlayerDeathThink", "PreventRespawn", function(ply)
    return true
end)

hook.Add("PlayerDeathSound", "RemoveDeathSound", function()
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
            for k, ply in ipairs(player.GetAll()) do
                ply:GodEnable()
            end
            GAMEMODE:EndRound()
        end
    end
end)

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "SpectateAttackerNextbot", function(data)
    local victim = Entity(data.entindex_killed)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    local deathPos = victim:GetPos() + Vector(0,0,60)
    local deathEyeAngles = victim:EyeAngles()
    -- when the victim dies start spectating
    victim:SetNWBool("Spectating", true)
    CreateRagdollFromPlayer(victim)
    timer.Simple(0.02, function()
        if not IsValid(victim) or not victim:IsPlayer() then return end
        victim:SetPos(deathPos)
        victim:SetEyeAngles(deathEyeAngles)
        victim:Spectate(OBS_MODE_ROAMING)

        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= victim end)

        if victim:GetNWBool("LockedToSpectatedPlayer", false) then
            victim:SpectateEntity(alivePlayers[victim:GetNWInt("SpectateID", 1)])
            victim:SetObserverMode(OBS_MODE_IN_EYE)
        else
            victim:SetObserverMode(OBS_MODE_ROAMING)
        end
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
    timer.Simple(0.1, function()
        local playersLeft = 0
        for k, ply in ipairs(player.GetAll()) do
            if ply:Alive() then playersLeft = playersLeft + 1 end
        end

        if playersLeft == 0 then
            GAMEMODE:EndRound()
            game.CleanUpMap(true, { "env_fire", "entityflame", "_firesmoke" })
        end
    end)
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "AddPlayerToAliveList", function(data)
    if SERVER then
        local ply = Player(data.userid)
        ply:SetModel("models/player/group01/male_07.mdl")
        local plyColor = HSVToColor(math.Rand(0,360), 1, 1)
        ply:SetPlayerColor(Vector(plyColor.r, plyColor.g, plyColor.b))
        ply:SetJumpPower(200)
        ply:SetViewEntity(ply)
    end
end)