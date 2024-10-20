radio_station = radio_station or nil -- garbage collection prevention

if IsValid(radio_station) then
    radio_station:Stop()
end

sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing
    if IsValid(station) then
        station:Play()
        station:SetVolume(0.25)
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
        local spectrumWidth = ScrW() / 2
        local spectrumHeight = 100
        local spectrumX = ScrW() / 2 - spectrumWidth / 2
        local spectrumY = ScrH() - spectrumHeight - 25

        draw.RoundedBox(8, spectrumX, spectrumY, spectrumWidth, spectrumHeight, Color(0,0,0,200))
        local barWidth = spectrumWidth / table.Count(spectrum)
        for i = 1, #spectrum do
            local height = spectrum[i] * spectrumHeight
            barHeights[i] = Lerp(0.1, barHeights[i] or 0, height)
            -- do proper visualization of the spectrum
            draw.RoundedBox(0, spectrumX + (i - 1) * barWidth, spectrumY + spectrumHeight - barHeights[i], barWidth, barHeights[i], HSVToColor(i / #spectrum * 360, 1, 1))
        end
    end
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)