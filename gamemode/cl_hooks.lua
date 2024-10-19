hook.Add("CalcView", "DeathView", function(ply, pos, angles, fov)
    if not ply:Alive() then
        if not ply.deathEyePos then
            ply.deathEyePos = ply:GetPos() + Vector(0,0,72)
            timer.Simple(0.05, function() -- waits for 0.05 seconds and then sets the players eye angles to the velocity direction angle
                local eyeAng = ply:GetVelocity():Angle()
                eyeAng.p = 0
                ply:SetEyeAngles(eyeAng)
            end)
        end
        local view = {}

        local move = Vector(0, 0, 0)
        move[1] = (ply:KeyDown(IN_FORWARD) and 1 or 0) - (ply:KeyDown(IN_BACK) and 1 or 0)
        move[2] = (ply:KeyDown(IN_MOVELEFT) and 1 or 0) - (ply:KeyDown(IN_MOVERIGHT) and 1 or 0)
        move[3] = (input.IsKeyDown(KEY_E) and 1 or 0) + (input.IsKeyDown(KEY_Q) and -1 or 0)

        if move:LengthSqr() > 0 then
            move:Normalize()
            move = move * 600 * FrameTime() * (1 + (ply:KeyDown(IN_SPEED) and 1 or 0)) / (1 + (ply:KeyDown(IN_WALK) and 1 or 0))
        end
        move:Rotate(angles)

        if not gui.IsGameUIVisible() and not ply:IsTyping() then -- only apply movement if player is focusing the actual game instead of ui
            ply.deathEyePos = ply.deathEyePos + move
        end

        view.origin = ply.deathEyePos
        view.angles = angles
        view.fov = fov
        view.drawviewer = true
        ply:SetPos(ply.deathEyePos - Vector(0,0,72))
        return view
    else
        ply.deathEyePos = nil
    end
end)

hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)