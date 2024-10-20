hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)

hook.Add("PlayerBindPress", "", function(_, bind)
    if string.StartsWith(bind, "inv") or string.StartsWith(bind, "slot") then
        return true
    end
end)