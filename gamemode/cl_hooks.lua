hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)

local key_blacklist = {
    ["invnext"] = true,
    ["invprev"] = true,
    ["lastinv"] = true,
    ["slot1"] = true,
    ["slot2"] = true,
    ["slot3"] = true,
    ["slot4"] = true,
    ["slot5"] = true,
    ["slot6"] = true,
    ["slot7"] = true,
    ["slot8"] = true,
    ["slot9"] = true,
    ["slot0"] = true,
}

hook.Add("PlayerBindPress", "", function(_, bind)
    if key_blacklist[bind] then
        return true
    end
end)