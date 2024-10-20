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

local spectrum = {}
local barHeights = {}


hook.Add("HUDPaint", "DrawRoundTime", function()
    local timeLeft = GetGlobal2Float("CurrentRoundTime", 0)

    if timeLeft < 0 then
        timeLeft = 0
    end

    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)

    local timerText = string.format("%02d:%02d", mins, secs)

    -- draw a timer at the top of the screen in a rounded rectangle

    draw.RoundedBox(8, ScrW() / 2 - 100, 25, 200, 50, Color(0,0,0,200))

    draw.SimpleText(timerText, "DermaLarge", ScrW() / 2, 50, Color(255,151,48), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- draw fft spectrum of the radio station at the bottom of the screen

    if IsValid(radio_station) then
        radio_station:FFT(spectrum, FFT_256)
        local spacing = 5
        local spectrumPower = 300
        local barWidth = 3
        local spectrumY = ScrH() - 150

        for i = 1, #spectrum do
            local barFrequency = 44100 / 256 / 2 / #spectrum
            barHeights[i] = barHeights[i] or 0

            local height = math.sqrt(spectrum[i])

            --height = height * barFrequency * spectrumPower + barWidth * 2
            height = height * spectrumPower + barWidth * 2

            if height < barHeights[i] then
                barHeights[i] = math.max(0, barHeights[i] - 2)
            else
                barHeights[i] = LerpExpo(FrameTime(), barHeights[i] or 0, height, 30)
            end

            local xPos = i * spacing - spacing * 0.5

            -- do proper visualization of the spectrum
            draw.RoundedBox(barWidth, xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth + 3, barWidth, barHeights[i] * 2, Color(0, 0, 0, 127))

            draw.RoundedBox(barWidth, xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, math.sqrt(height / spectrumPower) + 0.25))
            

            draw.RoundedBox(barWidth, -xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth + 3, barWidth, barHeights[i] * 2, Color(0, 0, 0, 127))

            draw.RoundedBox(barWidth, -xPos + math.floor(ScrW() * 0.5), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, math.sqrt(height / spectrumPower) + 0.25))
        
        end
    end
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)