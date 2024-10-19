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

hook.Add("Move", "SpectatorMovement", function( ply, mv )
    if not ply:GetNWBool("Spectating", false) then return false end
    --
    -- Set up a speed, go faster if shift is held down
    --
    local speed = 0.0005 * FrameTime()
    if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end

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
    vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
    vel = vel + ang:Right() * mv:GetSideSpeed() * speed
    vel = vel + ang:Up() * mv:GetUpSpeed() * speed

    --
    -- We don't want our velocity to get out of hand so we apply
    -- a little bit of air resistance. If no keys are down we apply
    -- more resistance so we slow down more.
    --
    if ( math.abs( mv:GetForwardSpeed() ) + math.abs( mv:GetSideSpeed() ) + math.abs( mv:GetUpSpeed() ) < 0.1 ) then
        vel = vel * 0.90
    else
        vel = vel * 0.99
    end

    --
    -- Add the velocity to the position (this is the movement)
    --
    pos = pos + vel

    --
    -- We don't set the newly calculated values on the entity itself
    -- we instead store them in the movedata. They should get applied
    -- in the FinishMove hook.
    --
    mv:SetVelocity( vel )
    mv:SetOrigin( pos )

    --
    -- Return true to not use the default behavior
    --
    return true

end)