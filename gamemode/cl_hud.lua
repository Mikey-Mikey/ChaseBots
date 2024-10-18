hook.Add("HUDPaint", "DrawRoundTime", function()

    local timeLeft = GAMEMODE.CurrentRoundTime
    if timeLeft < 0 then
        timeLeft = 0
    end

    draw.SimpleText("Time left: " .. math.ceil(timeLeft), "DermaLarge", ScrW() / 2, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)