--------------------------------------------------
local AFK_TIME = 120

local AFK_WARN_TIME = 80
--------------------------------------------------

hook.Add("PlayerInitialSpawn", "MakeAFKVar", function(ply)
    ply.NextAFK = CurTime() + AFK_TIME
end)

hook.Add("Think", "HandleAFKPlayers", function()
    for _, ply in pairs (player.GetAll()) do
        if ( ply:IsConnected() and ply:IsFullyAuthenticated() ) then
            if not ply.NextAFK or not ply:Alive() then
                ply.NextAFK = CurTime() + AFK_TIME
            end

            local afktime = ply.NextAFK

            ply:SetNWBool("KickingSoon", CurTime() >= afktime - AFK_WARN_TIME)

            if (CurTime() >= afktime - AFK_WARN_TIME) and not ply.Warning then
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