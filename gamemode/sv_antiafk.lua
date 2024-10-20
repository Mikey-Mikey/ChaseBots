--------------------------------------------------
local AFK_TIME = 120

local AFK_WARN_TIME = 60
--------------------------------------------------

hook.Add("PlayerInitialSpawn", "MakeAFKVar", function(ply)
    ply.NextAFK = CurTime() + AFK_TIME
end)

hook.Add("Think", "HandleAFKPlayers", function()
    for _, ply in pairs (player.GetAll()) do
        if ( ply:IsConnected() and ply:IsFullyAuthenticated() ) then
            if (!ply.NextAFK) then
                ply.NextAFK = CurTime() + AFK_TIME
            end

            local afktime = ply.NextAFK
            if (CurTime() >= afktime - AFK_WARN_TIME) and (!ply.Warning) then
                ply:ChatPrint("Warning: You will be kicked soon if you are inactive.")
                ply.Warning = true
            elseif (CurTime() >= afktime) and ply.Warning then
                ply.Warning = nil
                ply.NextAFK = nil
                ply:Kick("Kicked for being AFK")
            end
        end
    end
end)

hook.Add("KeyPress", "PlayerMoved", function(ply, key)
    ply.NextAFK = CurTime() + AFK_TIME
    ply.Warning = false
end)