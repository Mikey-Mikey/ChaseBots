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

    if mv:KeyPressed(IN_ATTACK) and IsFirstTimePredicted() then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        ply.PlayerSpectateID = 0
        if not ply.PlayerSpectateID then
            ply.PlayerSpectateID = 0
        end

        ply.PlayerSpectateID = ply.PlayerSpectateID + 1

        if ply.PlayerSpectateID > table.Count(alivePlayers) then
            ply.PlayerSpectateID = 1
        end
        PrintTable(alivePlayers)
        local targetPly = alivePlayers[ply.PlayerSpectateID]

        if IsValid(targetPly) then
            pos = targetPly:GetPos()
            ply:SetEyeAngles(targetPly:EyeAngles())
        end
    end

    if mv:KeyPressed(IN_ATTACK2) and IsFirstTimePredicted() then
        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)

        if not ply.PlayerSpectateID then
            ply.PlayerSpectateID = 0
        end

        ply.PlayerSpectateID = ply.PlayerSpectateID - 1
        if ply.PlayerSpectateID < 1 then
            ply.PlayerSpectateID = table.Count(alivePlayers)
        end

        local targetPly = alivePlayers[ply.PlayerSpectateID]

        if IsValid(targetPly) and targetPly:Alive() then
            pos = targetPly:GetPos()
            ply:SetEyeAngles(targetPly:EyeAngles())
        end
    end

    ply:SetGravity(0)
    mv:SetVelocity(vel)
    mv:SetOrigin(pos)

    return true

end)