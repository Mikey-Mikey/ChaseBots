AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hooks.lua")
AddCSLuaFile("cl_hud.lua")
include("shared.lua")
include("sv_hooks.lua")

SetGlobal2Float("BASE_ROUND_TIME", 300) -- 5 minutes each round
SetGlobal2Bool("RoundRunning", false)
SetGlobal2Float("RoundStartTime", 0)
SetGlobal2Float("CurrentRoundTime", 300)

local function GetRandomPointOnNavMesh()
    local navareas = navmesh.GetAllNavAreas()
    navareas = FilterTable(navareas, function(area)
        for k, ply in ipairs(player.GetAll()) do
            local distSqr = ply:GetPos():DistToSqr(area:GetCenter())

            if distSqr < 2000^2 then
                return false
            end
        end
        return area:IsValid()
    end)
    local navarea = navareas[math.random(1, table.Count(navareas))]
    local randomPoint = navarea:GetRandomPoint()
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
end)

function GM:StartRound()
    game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )

    SetGlobal2Bool("RoundRunning", true)
    SetGlobal2Float("RoundStartTime", RealTime())
    SetGlobal2Float("CurrentRoundTime", GetGlobal2Float("BASE_ROUND_TIME", 300))

    print("Round Started")

    for i, ply in ipairs(player.GetAll()) do
        ply:Spawn()
    end

    GAMEMODE.CurrentNextbots = {}

    while table.Count(GAMEMODE.CurrentNextbots) < 10 do
        local nextbotClass = GAMEMODE.NextbotClassTable[math.random(1, #GAMEMODE.NextbotClassTable)]
        if GAMEMODE.CurrentNextbots[nextbotClass] then
            continue
        end
        local randomPoint = GetRandomPointOnNavMesh()
        local bot = ents.Create(nextbotClass)

        bot:SetPos(randomPoint)
        bot:Spawn()
        GAMEMODE.CurrentNextbots[nextbotClass] = true
    end
end

function GM:EndRound()
    SetGlobal2Bool("RoundRunning", false)
    timer.Create("RestartRound", 3, 1, function()
        GAMEMODE:StartRound()
    end)
end

function GM:PlayerLoadout(ply)
    -- give the player the wheatleys parkour swep
    ply:Give("parkourmod")

    -- prevent the default loadout
    return true
end