radio_station = radio_station or nil -- garbage collection prevention

if IsValid(radio_station) then
    radio_station:Stop()
end

sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing
    if IsValid(station) then
        station:Play()
        station:SetVolume(0.75)
        radio_station = station
    end

end)

concommand.Add("radio_reload", function()
    if IsValid(radio_station) then
        radio_station:Stop()
    end

    sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err)
        if IsValid(station) then
            station:Play()
            station:SetVolume(0.75)
            radio_station = station
        end

    end)
end)

-- convar for if the visualizer should be shown
local radioVisualizerCVar = CreateClientConVar("radio_visualizer", "1", true, false, "Whether or not the radio visualizer should be shown")

local spectrum = {}
local barHeights = {}

-- Create a font for the timer
surface.CreateFont("Timer", {
    font = "Arial",
    size = 48,
    weight = 600,
    antialias = true,
    scanlines = 4,
    shadow = false
})

surface.CreateFont("TimerNoScan", {
    font = "Arial",
    size = 48,
    weight = 600,
    antialias = true,
    shadow = false
})

-- Create the same font but blurred
surface.CreateFont("TimerBlurred", {
    font = "Arial",
    size = 48,
    weight = 600,
    antialias = true,
    shadow = false,
    scanlines = 4,
    blursize = 6
})

local TIMER_COLOR = Color(255, 205, 131)


hook.Add("HUDPaint", "DrawRoundTime", function()
    local timeLeft = GetGlobal2Float("CurrentRoundTime", 0)

    if timeLeft < 0 then
        timeLeft = 0
    end

    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)

    local timerText = string.format("%02d:%02d", mins, secs)

    -- Draw a timer at the top of the screen
    draw.RoundedBox(8, ScrW() / 2 - 100, 25, 200, 50, Color(0,0,0,200))

    local timerColor = TIMER_COLOR

    if timeLeft == 0 then
        timerColor = Color(0, 255, 0)
    end

    draw.SimpleText(timerText, "HudNumbers", ScrW() / 2, 50, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    --draw.SimpleText(timerText, "HudNumbers", ScrW() / 2, 50, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    --draw.SimpleText(timerText, "HudNumbers", ScrW() / 2, 50, Color(timerColor.r,timerColor.g,timerColor.b, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Draw audio visualizer if the radio is playing and the convar is set to true
    if radioVisualizerCVar:GetBool() and IsValid(radio_station) then
        radio_station:FFT(spectrum, FFT_256)
        local spacing = 5
        local spectrumPower = 300
        local barWidth = 3
        local spectrumY = ScrH() - 150

        for i = 2, #spectrum do
            -- local barFrequency = 44100 / 256 / 2 / #spectrum
            barHeights[i] = barHeights[i] or 0

            local height = math.sqrt(spectrum[i])

            -- height = height * barFrequency * spectrumPower + barWidth * 2
            height = height * spectrumPower + barWidth

            if height < barHeights[i] then
                barHeights[i] = math.max(0, barHeights[i] - 2)
            else
                barHeights[i] = LerpExpo(FrameTime(), barHeights[i] or 0, height, 30)
            end

            local xPos = i * spacing - spacing * 2
            local brightness = math.min(math.sqrt(height / spectrumPower) * 2 + 0.25, 1)

            -- Draw the bars
            draw.RoundedBox(barWidth, xPos + math.floor(ScrW() * 0.5) - 1, spectrumY - barHeights[i] + barWidth - 1, barWidth + 2, barHeights[i] * 2 + 2, Color(0, 0, 0))

            draw.RoundedBox(barWidth, xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, brightness))

            if i == 2 then continue end

            draw.RoundedBox(barWidth, -xPos + math.floor(ScrW() * 0.5) - 1, spectrumY - barHeights[i] + barWidth - 1, barWidth + 2, barHeights[i] * 2 + 2, Color(0, 0, 0))

            draw.RoundedBox(barWidth, -xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, brightness))
        end
    end
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)