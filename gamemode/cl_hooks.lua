hook.Add("InitPostEntity", "", function()
    local npcs = list.Get("NPC")
    for class, tbl in pairs(npcs) do
        if string.find(class, "npc_tf2_ghost") then
            continue
        end

        if scripted_ents.IsBasedOn(class, "base_nextbot") then
            GAMEMODE.NextbotClassTable[#GAMEMODE.NextbotClassTable + 1] = class
        end
    end

    GAMEMODE:StartRound()
end)

hook.Add("CalcView", "DeathView", function(ply, pos, angles, fov)
    if ply:GetObserverMode() ~= OBS_MODE_NONE then

        if not ply.deathEyePos then
            ply.deathEyePos = ply:GetPos() + Vector(0,0,72)
            timer.Simple(0.05, function()
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
        if not gui.IsGameUIVisible() and not ply:IsTyping() then
            ply.deathEyePos = ply.deathEyePos + move
        end

        view.origin = ply.deathEyePos
        view.angles = angles
        view.fov = fov
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