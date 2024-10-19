hook.Add("HUDPaint", "DrawRoundTime", function()
    local timeLeft = GetGlobal2Float("CurrentRoundTime", 0)

    if timeLeft < 0 then
        timeLeft = 0
    end

    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)

    local timerText = string.format("%02d:%02d", mins, secs)

    -- draw a timer at the top of the screen in a rounded rectangle

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(ScrW() / 2 - 100, 25, 200, 50)

    draw.SimpleText(timerText, "DermaLarge", ScrW() / 2, 50, Color(255,151,48), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)