GM.Name = "Chase Bots"
GM.Author = "Mikey"
GM.Email = "N/A"
GM.Website = "N/A"
GM.IsSandboxDerived = true

GM.NextbotClassTable = {}
GM.CurrentNextbots = {}

ROLE_COLORS = {
    ["Owner"] = Color(255, 0, 98),
    ["Co-Owner"] = Color(180, 0, 69),
    ["Admin"] = Color(255, 0, 0),
    ["Regular"] = Color(0,119,255),
    ["Guest"] = Color(255, 211, 144),
}

ROLE_PRIORITY = {
    ["Owner"] = 1,
    ["Co-Owner"] = 2,
    ["Admin"] = 3,
    ["Regular"] = 4,
    ["Guest"] = 5,
}

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

        if targetPly == ply then return end

        if IsValid(targetPly) and targetPly:Alive() then
            pos = pos + (targetPly:GetShootPos() - ply:GetShootPos())
            mv:SetOrigin(pos)
            ply:SetEyeAngles(targetPly:EyeAngles())
            ply:SpectateEntity(targetPly)
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

        if targetPly == ply then return end

        if IsValid(targetPly) and targetPly:Alive() then
            pos = pos + (targetPly:GetShootPos() - ply:GetShootPos())
            mv:SetOrigin(pos)
            ply:SetEyeAngles(targetPly:EyeAngles())
            ply:SpectateEntity(targetPly)
            return
        end
    end

    if SERVER and mv:KeyPressed(IN_RELOAD) and IsFirstTimePredicted() then
        ply:SetNWBool("LockedToSpectatedPlayer", not ply:GetNWBool("LockedToSpectatedPlayer", false))

        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)

        local targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]

        if targetPly == ply then return end

        if ply:GetNWBool("LockedToSpectatedPlayer", false) then
            ply:SetObserverMode(OBS_MODE_IN_EYE)
        else
            ply:SetObserverMode(OBS_MODE_ROAMING)
            pos = pos + (targetPly:GetShootPos() - ply:GetShootPos())
            mv:SetOrigin(pos)
        end
    end

    if ply:GetNWBool("LockedToSpectatedPlayer", false) then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        if table.Count(alivePlayers) == 0 then
            ply:SetNWBool("LockedToSpectatedPlayer", false)
            ply:SetObserverMode(OBS_MODE_ROAMING)
            return
        end

        local targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]

        if targetPly == ply then
            ply:SetNWBool("LockedToSpectatedPlayer", false)
            ply:SetObserverMode(OBS_MODE_ROAMING)
            return
        end

        if not IsValid(targetPly) or not targetPly:Alive() then
            ply:SetNWInt("SpectateID", 1)
            targetPly = alivePlayers[ply:GetNWInt("SpectateID", 1)]
        end

        if SERVER and IsValid(targetPly) and targetPly:Alive() then
            pos = pos + (targetPly:GetShootPos() - ply:GetShootPos())
            mv:SetOrigin(pos)
            ply:SpectateEntity(targetPly)
            return
        end
    end

    mv:SetVelocity(vel)
    mv:SetOrigin(pos)

    return true

end)