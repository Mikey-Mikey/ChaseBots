include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")

function GM:StartRound()
    GAMEMODE.RoundRunning = true
    GAMEMODE.RoundStartTime = RealTime()
    GAMEMODE.CurrentRoundTime = GAMEMODE.BASE_ROUND_TIME

    print("Round Started")
    for i, ply in ipairs(player.GetAll()) do
        GAMEMODE.AlivePlayers[ply] = true
    end
end