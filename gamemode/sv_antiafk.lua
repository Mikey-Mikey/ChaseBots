--------------------------------------------------
local AFK_TIME = 240

local AFK_WARN_TIME = 120
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
                ply:SetNWBool("KickingSoon", true)
                ply.Warning = true
            elseif (CurTime() >= afktime) and ply.Warning then
                ply:SetNWBool("KickingSoon", false)
                ply.Warning = nil
                ply.NextAFK = nil
                ply:Kick("Kicked for being AFK")
            else
                ply:SetNWBool("KickingSoon", false)
            end
        end
    end
end)

hook.Add("KeyPress", "PlayerMoved", function(ply, key)
    ply.NextAFK = CurTime() + AFK_TIME
    ply.Warning = false
end)