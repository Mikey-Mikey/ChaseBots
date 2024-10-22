AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hooks.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_playerchat.lua")
include("shared.lua")
include("sv_hooks.lua")
include("sv_antiafk.lua")
include("sv_playerchat.lua")

SetGlobal2Float("BASE_ROUND_TIME", 300) -- 5 minutes each round

SetGlobal2Bool("RoundRunning", GetGlobal2Bool("RoundRunning", false))
SetGlobal2Bool("Empty", GetGlobal2Bool("Empty", true))
SetGlobal2Float("RoundStartTime", GetGlobal2Float("RoundStartTime", 0))
SetGlobal2Float("CurrentRoundTime", GetGlobal2Float("CurrentRoundTime", 0))
SetGlobal2Int("CurrentRound", GetGlobal2Int("CurrentRound", 0))

GM.MaxNextbots = 15
GM.MaxRoundsOnMap = 10

GM.AllowedNavareas = {}

local function GetRandomPointOnNavMesh()
    local navarea = nil
    local randomPoint = nil

    for sample = 1, 25 do
        navarea = GAMEMODE.AllowedNavareas[math.random(1, table.Count(GAMEMODE.AllowedNavareas))]
        randomPoint = navarea:GetRandomPoint()
        for k, ply in player.Iterator() do
            if randomPoint:DistToSqr(ply:GetPos()) > 4000^2 then
                break
            end
        end
    end

    return randomPoint
end

hook.Add("InitPostEntity", "InitializeServerRound", function()
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
    GAMEMODE.AllowedNavareas = navmesh.GetAllNavAreas()
end)

function GM:StartRound()
    game.CleanUpMap(true, { "env_fire", "entityflame", "_firesmoke" })

    SetGlobal2Bool("RoundRunning", true)
    SetGlobal2Float("RoundStartTime", RealTime())
    SetGlobal2Float("CurrentRoundTime", GetGlobal2Float("BASE_ROUND_TIME", 300))

    for i, ply in ipairs(player.GetAll()) do
        ply:SetNWBool("Spectating", false)
        ply:Spawn()
    end

    GAMEMODE.CurrentNextbots = {}

    local chances = 100

    while table.Count(GAMEMODE.CurrentNextbots) < GAMEMODE.MaxNextbots do
        local nextbotClass = GAMEMODE.NextbotClassTable[math.random(1, #GAMEMODE.NextbotClassTable)]
        if GAMEMODE.CurrentNextbots[nextbotClass] then
            continue
        end
        local randomPoint = GetRandomPointOnNavMesh()
        local bot = ents.Create(nextbotClass)

        bot:SetPos(randomPoint)
        bot:Spawn()
        GAMEMODE.CurrentNextbots[nextbotClass] = true
        chances = chances - 1
    end

    print("Round Started")
    SetGlobal2Int("CurrentRound", GetGlobal2Int("CurrentRound", 0) + 1)
end

function GM:ResetRounds()
    SetGlobal2Int("CurrentRound", 0)
    GAMEMODE:StartRound()
end

function GM:EndRound()
    print("Round Ended")
    SetGlobal2Bool("RoundRunning", false)

    if GetGlobal2Int("CurrentRound", 0) == GAMEMODE.MaxRoundsOnMap then
        -- Run a votemap
        MapVote.Start(20, true, 24)
        timer.Create("MapVoteEnd", 24, 1, function()
            GAMEMODE:ResetRounds()
            if player.GetCount() < 1 then
                SetGlobal2Bool("Empty", true)
                return
            end
        end)
    end

    timer.Simple(1, function()
        if player.GetCount() < 1 then
            SetGlobal2Bool("Empty", true)
            return
        end

        if not timer.Exists("RoundRestart") then
            timer.Create("RoundRestart", 5, 1, function()
                GAMEMODE:StartRound()
            end)
        end
    end)
end

function GM:PlayerLoadout(ply)
    -- give the player the wheatleys parkour swep
    timer.Simple(0.1, function()
        if not IsValid(ply) or ply:GetNWBool("Spectating", false) then return end
        ply:Give("parkourmod")
    end)

    -- prevent the default loadout
    return true
end