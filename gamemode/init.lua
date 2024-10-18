AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hooks.lua")
AddCSLuaFile("cl_hud.lua")
include("shared.lua")
include("sv_hooks.lua")

SetGlobalFloat("BASE_ROUND_TIME", 300)
SetGlobalBool("RoundRunning", false)
SetGlobalFloat("RoundStartTime", 0)
SetGlobalFloat("CurrentRoundTime", GetGlobalFloat("BASE_ROUND_TIME", 300))

local function GetRandomPointOnNavMesh()
    local navareas = navmesh.GetAllNavAreas()
    navareas = FilterTable(navareas, function(area)
        for k, ply in ipairs(player.GetAll()) do
            local distSqr = ply:GetPos():DistToSqr(area:GetCenter())

            if distSqr < 400^2 then
                return false
            end
        end
        return area:IsValid()
    end)
    local navarea = navmesh.GetAllNavAreas()[math.random(1, #navmesh.GetAllNavAreas())]
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

    if player.GetCount() > 0 and not GetGlobalBool("RoundRunning", false) then
        GAMEMODE:StartRound()
    end
end)

function GM:StartRound()
    game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )

    SetGlobalBool("RoundRunning", true)
    SetGlobalFloat("RoundStartTime", RealTime())
    SetGlobalFloat("CurrentRoundTime", GetGlobalFloat("BASE_ROUND_TIME", 300))

    print("Round Started")

    for i, ply in ipairs(player.GetAll()) do
        ply:Spawn()
    end

    GAMEMODE.CurrentNextbots = {}

    for i, nextbotClass in ipairs(GAMEMODE.NextbotClassTable) do
        if #GAMEMODE.CurrentNextbots >= 10 then
            break
        end
        local randomPoint = GetRandomPointOnNavMesh()
        local bot = ents.Create(nextbotClass)
        bot:SetPos(randomPoint)
        bot:Spawn()
        GAMEMODE.CurrentNextbots[#GAMEMODE.CurrentNextbots + 1] = bot
    end
end

function GM:EndRound()
    SetGlobalBool("RoundRunning", false)
    timer.Create("RestartRound", 3, 1, function()
        GAMEMODE:StartRound()
    end)
end