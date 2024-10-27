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

GM.MaxNextbots = GM.MaxNextbots or 15
GM.MaxRoundsOnMap = 10

GM.AllowedNavareas = GM.AllowedNavareas or {}

GM.AllowedNextbotSpawnpoints = GM.AllowedNextbotSpawnpoints or {}

GM.CurrentNextbots = GM.CurrentNextbots or {}

local function GetRandomPointOnNavMesh()
    if table.Count(GAMEMODE.AllowedNextbotSpawnpoints) >= GAMEMODE.MaxNextbots then
        return GAMEMODE.AllowedNextbotSpawnpoints[table.Count(GAMEMODE.CurrentNextbots) + 1]
    end
    local navarea = nil
    local randomPoint = nil
    local navCount = table.Count(GAMEMODE.AllowedNavareas)

    for sample = 1, 5 do
        navarea = GAMEMODE.AllowedNavareas[math.random(1, navCount)]
        if not IsValid(navarea) then
            continue
        end
        randomPoint = navarea:GetCenter()

        local canSpawn = true
        local playerSpawns = ents.FindByClass("info_player_start")
        for k, spawn in pairs(playerSpawns) do
            if randomPoint:DistToSqr(spawn:GetPos()) < 4000^2 then
                canSpawn = false
                break
            end
        end

        if canSpawn then
            break
        end
    end
    GAMEMODE.AllowedNextbotSpawnpoints[#GAMEMODE.AllowedNextbotSpawnpoints + 1] = randomPoint
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
    timer.Create("NavmeshLoad", 0, 0, function()
        if navmesh.IsLoaded() then
            timer.Remove("NavmeshLoad")
            GAMEMODE.AllowedNavareas = navmesh.GetAllNavAreas()
            -- Get Navmesh size
            local navareas = navmesh.GetAllNavAreas()
            local min = Vector(0, 0, 0)
            local max = Vector(0, 0, 0)
            for k, navarea in pairs(navareas) do
                local navPos = navarea:GetCenter()
                min = Vector(math.min(min.x, navPos.x), math.min(min.y, navPos.y), math.min(min.z, navPos.z))
                max = Vector(math.max(max.x, navPos.x), math.max(max.y, navPos.y), math.max(max.z, navPos.z))
            end

            -- Base nextbot count on map size
            local mapSize = max - min
            local mapArea = math.sqrt(mapSize.x * mapSize.y)
            local nextbotCount = math.floor(mapArea / 10000 * 0.6)
            GAMEMODE.MaxNextbots = math.Clamp(nextbotCount, 10, 50)
        end
    end)
end)

function GM:StartRound()
    game.CleanUpMap(true, { "env_fire", "entityflame", "_firesmoke" })

    SetGlobal2Bool("RoundRunning", true)
    SetGlobal2Float("RoundStartTime", RealTime())
    SetGlobal2Float("CurrentRoundTime", GetGlobal2Float("BASE_ROUND_TIME", 300))

    for i, ply in ipairs(player.GetAll()) do
        ply:SetNWBool("Spectating", false)
        ply:GodDisable()
        ply:Spawn()
        ply:AllowFlashlight(true)
    end

    GAMEMODE.CurrentNextbots = {}

    print("Spawning " .. GAMEMODE.MaxNextbots .. " nextbots")

    timer.Create("SpawnNextbots", 0.25, GAMEMODE.MaxNextbots, function()
        local nextbotClass = GAMEMODE.NextbotClassTable[math.random(1, #GAMEMODE.NextbotClassTable)]

        if GAMEMODE.CurrentNextbots[nextbotClass] then
            return
        end

        local randomPoint = GetRandomPointOnNavMesh()
        local botSpawner = ents.Create("nextbot_spawnpoint")
        botSpawner:SetPos(randomPoint)

        local ang_tr = util.TraceLine({
            start = randomPoint + Vector(0,0,2),
            endpos = randomPoint + Vector(0, 0, -1000),
            mask = MASK_SOLID_BRUSHONLY,
        })

        botSpawner:SetAngles(ang_tr.HitNormal:Angle() - Angle(90,0,0))

        botSpawner.nextbotClass = nextbotClass
        botSpawner:Spawn()

        GAMEMODE.CurrentNextbots[nextbotClass] = true

        if table.Count(GAMEMODE.CurrentNextbots) >= GAMEMODE.MaxNextbots then
            timer.Remove("SpawnNextbots")
        end
    end)

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
        timer.Create("MapVoteEnd", 26, 1, function()
            GAMEMODE:ResetRounds()
            if player.GetCount() < 1 then
                SetGlobal2Bool("Empty", true)
                return
            end
        end)
        return
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