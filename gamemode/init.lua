AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_roundhandler.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_hooks.lua")
AddCSLuaFile("cl_hud.lua")
include("shared.lua")
include("sh_roundhandler.lua")
include("sv_hooks.lua")

SetGlobalBool("RoundRunning", false)
SetGlobalFloat("RoundStartTime", 0)
SetGlobalFloat("CurrentRoundTime", GAMEMODE.BASE_ROUND_TIME)

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

function GM:StartRound()
    game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )

    SetGlobalBool("RoundRunning", true)
    SetGlobalFloat("RoundStartTime", RealTime())
    SetGlobalFloat("CurrentRoundTime", GAMEMODE.BASE_ROUND_TIME)

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
    GAMEMODE.RoundRunning = false
    timer.Create("RestartRound", 3, 1, function()
        GAMEMODE:StartRound()
    end)
end