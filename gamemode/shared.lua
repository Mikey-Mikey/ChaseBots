GM.Name = "Chase Bots"
GM.Author = "Mikey"
GM.Email = "N/A"
GM.Website = "N/A"
GM.IsSandboxDerived = true

GM.AlivePlayers = {}
GM.RoundRunning = false
GM.BASE_ROUND_TIME = 240
GM.CurrentRoundTime = 240
GM.RoundStartTime = 0
GM.NextbotClassTable = {}
GM.CurrentNextbots = {}

function FilterTable(tbl, filter)
    local newTable = {}
    for k, v in pairs(tbl) do
        if filter(v) then
            newTable[k] = v
        end
    end
    return newTable
end

hook.Add("RenderScreenspaceEffects", "DrawRoundTime", function()
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "AddPlayerToAliveList", function(data)
    local ply = Player(data.userid)
    if CLIENT then return end
    ply:SetShouldServerRagdoll(true)
    ply:SetModel("models/player/group01/male_07.mdl")
    local plyColor = HSVToColor(util.SharedRandom(ply:SteamID64(), 0, 360), 1, 1)
    ply:SetPlayerColor(Vector(plyColor.r, plyColor.g, plyColor.b))
end)

gameevent.Listen( "player_connect" )
hook.Add("player_connect", "PlayerConnect", function( data )
    local ply = Player(data.userid)
    if GAMEMODE.RoundRunning and SERVER then
        ply:Spectate(OBS_MODE_CHASE)
        ply:SpectateEntity(ply)
    end
end)

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

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "SpectateAttackerNextbot", function(data)
    local victim = Entity(data.entindex_killed)
    local attacker = Entity(data.entindex_attacker)

    if SERVER then
        victim:Spectate(OBS_MODE_CHASE)
        victim:SpectateEntity(victim)
        local deathRagdoll = CreateRagdollFromPlayer(victim)
    end

    GAMEMODE.AlivePlayers[victim] = nil

    if table.Count(GAMEMODE.AlivePlayers) == 0 then
        GAMEMODE:EndRound()
    end
end)


gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "RemovePlayerFromAliveList", function(data)
    local ply = Player(data.userid)
    GAMEMODE.AlivePlayers[ply] = nil
end)

hook.Add("PlayerDeathSound", "RemoveDeathSound", function()
    return true
end)

hook.Add("Tick", "RoundTimer", function()
    if GAMEMODE.RoundRunning then
        GAMEMODE.CurrentRoundTime = GAMEMODE.RoundStartTime - RealTime() + GAMEMODE.BASE_ROUND_TIME
        if GAMEMODE.CurrentRoundTime <= 0 then
            GAMEMODE:EndRound()
        end
    end
end)