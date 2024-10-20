GM.Name = "Chase Bots"
GM.Author = "Mikey"
GM.Email = "N/A"
GM.Website = "N/A"
GM.IsSandboxDerived = true

GM.NextbotClassTable = {}
GM.CurrentNextbots = {}

function FilterTable(tbl, filter)
    local newTable = {}
    for k, v in pairs(tbl) do
        if filter(v) then
            newTable[table.Count(newTable) + 1] = v
        end
    end
    return newTable
end

local function lerp(from, to, t)
    return from + ( to - from ) * t
end

-- frame independent lerp function using math.exp and dt
function LerpExpo( dt, from, to, speed )
    return lerp(from, to, 1 - math.exp( -speed * dt ))
end

hook.Add("Move", "SpectatorMovement", function( ply, mv )
    if not ply:GetNWBool("Spectating", false) then
        return false
    end


    local accel = 12


    local ang = mv:GetMoveAngles()
    local pos = mv:GetOrigin()
    local vel = mv:GetVelocity()

    local move = Vector(0,0,0)

    if mv:KeyDown( IN_FORWARD ) then move = move + ang:Forward() end
    if mv:KeyDown( IN_BACK ) then move = move - ang:Forward() end
    if mv:KeyDown( IN_MOVERIGHT ) then move = move + ang:Right() end
    if mv:KeyDown( IN_MOVELEFT ) then move = move - ang:Right() end
    if mv:KeyDown( IN_JUMP ) then move = move + ang:Up() end
    if mv:KeyDown( IN_DUCK ) then move = move - ang:Up() end

    if move:LengthSqr() > 0 then
        move:Normalize()
    end

    if mv:KeyDown( IN_SPEED ) then move = move * 4 end
    if mv:KeyDown( IN_WALK ) then move = move * 0.5 end

    vel = LerpExpo(FrameTime(), vel, move * 400, accel)

    pos = pos + vel * FrameTime()

    if mv:KeyPressed(IN_ATTACK) and SERVER and IsFirstTimePredicted() then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        if table.Count(alivePlayers) == 0 then return end

        ply:SetNWInt("SpectateID", ply:GetNWInt("SpectateID", 1) - 1)

        if ply:GetNWInt("SpectateID", 1) < 1 then
            ply:SetNWInt("SpectateID", table.Count(alivePlayers))
        end

        local targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]

        if IsValid(targetPly) and targetPly:Alive() then
            pos = targetPly:EyePos() + (ply:GetPos() - ply:EyePos())
            vel = targetPly:GetVelocity()
            ply:SetPos(pos)
            mv:SetVelocity(vel)
            mv:SetOrigin(pos)
            ply:SetEyeAngles(targetPly:EyeAngles())
            return
        end
    end

    if mv:KeyPressed(IN_ATTACK2) and SERVER and IsFirstTimePredicted() then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        if table.Count(alivePlayers) == 0 then return end

        ply:SetNWInt("SpectateID", ply:GetNWInt("SpectateID", 1) + 1)

        if ply:GetNWInt("SpectateID", 1) > table.Count(alivePlayers) then
            ply:SetNWInt("SpectateID", 1)
        end

        local targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]

        if IsValid(targetPly) and targetPly:Alive() then
            pos = targetPly:EyePos() + (ply:GetPos() - ply:EyePos())
            vel = targetPly:GetVelocity()
            ply:SetPos(pos)
            mv:SetVelocity(vel)
            mv:SetOrigin(pos)
            ply:SetEyeAngles(targetPly:EyeAngles())
            return
        end
    end

    if SERVER and mv:KeyPressed(IN_RELOAD) and IsFirstTimePredicted() then
        ply:SetNWBool("LockedToSpectatedPlayer", not ply:GetNWBool("LockedToSpectatedPlayer", false))
        if ply:GetNWBool("LockedToSpectatedPlayer", false) then
            ply:SetObserverMode(OBS_MODE_IN_EYE)
        else
            ply:SetObserverMode(OBS_MODE_ROAMING)
        end
    end

    if ply:GetNWBool("LockedToSpectatedPlayer", false) then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        if table.Count(alivePlayers) == 0 then return end

        local targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]

        if not IsValid(targetPly) or not targetPly:Alive() then
            if CLIENT then
                for k, other in ipairs(player.GetAll()) do
                    other:SetNoDraw(false)
                end
            end
            ply:SetNWInt("SpectateID", 1)
            targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]
        end

        if SERVER and IsValid(targetPly) and targetPly:Alive() then
            ply:SpectateEntity(targetPly)
            return
        end
    end

    mv:SetVelocity(vel)
    mv:SetOrigin(pos)

    return true

end)