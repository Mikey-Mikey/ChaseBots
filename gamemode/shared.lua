GM.Name = "Chase Bots"
GM.Author = "Mikey"
GM.Email = "N/A"
GM.Website = "N/A"
GM.IsSandboxDerived = true

GM.NextbotClassTable = {}
GM.CurrentNextbots = {}

hook.Add("RenderScreenspaceEffects", "DrawRoundTime", function()
    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)

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
        ply:SetGravity(1)
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
    if mv:KeyDown( IN_SPEED ) then move = move * 4 end
    if mv:KeyDown( IN_WALK ) then move = move * 0.5 end

    vel = LerpExpo(FrameTime(), vel, move * 400, accel)

    pos = pos + vel * FrameTime()

    ply:SetGravity(0)
    mv:SetVelocity(vel)
    mv:SetOrigin(pos)

    return true

end)

hook.Add("KeyPress", "SpectatorKeyPress", function(ply, key)
    if ply:Alive() then return end

    if key == IN_ATTACK then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)


        ply.PlayerSpectateID = (ply.PlayerSpectateID or 0) % table.Count(alivePlayers)

        local targetPly = alivePlayers[ply.PlayerSpectateID]

        if IsValid(targetPly) then
            ply:SetPos(targetPly:GetPos())
            ply:SetEyeAngles(targetPly:EyeAngles())
        end
    end

    if key == IN_ATTACK2 then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)


        ply.PlayerSpectateID = (ply.PlayerSpectateID or 0) % table.Count(alivePlayers)

        local targetPly = alivePlayers[ply.PlayerSpectateID + 1]

        if IsValid(targetPly) and targetPly:Alive() then
            ply:SetPos(targetPly:GetPos())
            ply:SetEyeAngles(targetPly:EyeAngles())
        end
    end
end)