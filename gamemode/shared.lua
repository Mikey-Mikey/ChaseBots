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

hook.Add("PlayerDeathSound", "RemoveDeathSound", function()
    return true
end)

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
    --
    -- Set up a speed, go faster if shift is held down
    --
    -- frame
    local accel = 6

    --
    -- Get information from the movedata
    --
    local ang = mv:GetMoveAngles()
    local pos = mv:GetOrigin()
    local vel = mv:GetVelocity()

    --
    -- Add velocities. This can seem complicated. On the first line
    -- we're basically saying get the forward vector, then multiply it
    -- by our forward speed (which will be &gt; 0 if we're holding W, &lt; 0 if we're
    -- holding S and 0 if we're holding neither) - and add that to velocity.
    -- We do that for right and up too, which gives us our free movement.
    --



    local move = Vector(0,0,0)

    if mv:KeyDown( IN_FORWARD ) then move = move + ang:Forward() end
    if mv:KeyDown( IN_BACK ) then move = move - ang:Forward() end
    if mv:KeyDown( IN_MOVERIGHT ) then move = move + ang:Right() end
    if mv:KeyDown( IN_MOVELEFT ) then move = move - ang:Right() end
    if mv:KeyDown( IN_JUMP ) then move = move + ang:Up() end
    if mv:KeyDown( IN_DUCK ) then move = move - ang:Up() end
    if mv:KeyDown( IN_SPEED ) then move = move * 2 end
    if mv:KeyDown( IN_WALK ) then move = move * 0.5 end

    vel = LerpExpo(FrameTime(), vel, move * 400, accel)

    pos = pos + vel * FrameTime()

    ply:SetGravity(0)
    mv:SetVelocity(vel)
    mv:SetOrigin(pos)
    -- disable collision with world

    --
    -- Return true to not use the default behavior
    --
    return true

end)