hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)

hook.Add("EntityEmitSound", "FixQuietSounds", function(data)
    if not string.StartsWith(data.Entity:GetClass(), "npc_") then return end
    timer.Remove(data.Entity:EntIndex() .. "FixQuietSounds")
    timer.Create(data.Entity:EntIndex() .. "FixQuietSounds", 0, 0, function()
        if not IsValid(data.Entity) then return end
        data.Volume = 1
    end)

    return true
end)