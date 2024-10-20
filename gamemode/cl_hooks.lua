hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)


-- Disable weapon switching
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

hook.Add("RenderScreenspaceEffects", "DrawRoundTime", function()
    local nearbyNextbots = ents.FindInSphere(LocalPlayer():GetPos(), 400)
    nearbyNextbots = FilterTable(nearbyNextbots, function(v) return v:IsNextBot() end)

    local grayAmount = 0

    for i, nextbot in ipairs(nearbyNextbots) do
        local dist = LocalPlayer():GetPos():DistToSqr(nextbot:GetPos())
        grayAmount = math.max(grayAmount, 1 - (dist / 400^2))
    end

    util.ScreenShake(LocalPlayer():GetPos(), grayAmount * 3, 100, 0.1, 10, true)

    DrawColorModify({
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1 - grayAmount,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
end)