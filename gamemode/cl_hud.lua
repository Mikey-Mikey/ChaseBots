radio_station = radio_station or nil -- garbage collection prevention

if IsValid(radio_station) then
    radio_station:Stop()
end

local loading_station = true

sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing
    if IsValid(station) then
        station:Play()
        station:SetVolume(0.75)
        radio_station = station
        loading_station = false
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

local radioEnabledCVar = CreateClientConVar("radio_enabled", "1", true, false, "Whether or not the radio should be enabled")



hook.Add("Think", "RadioThink", function()
    if (not IsValid(radio_station) or radio_station:GetState() == GMOD_CHANNEL_STOPPED) and radioEnabledCVar:GetBool() and not loading_station then
        loading_station = true
        sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err)
            if IsValid(station) then
                station:Play()
                station:SetVolume(0.75)
                radio_station = station
                loading_station = false
            end
        end)
    end

    if IsValid(radio_station) and not radioEnabledCVar:GetBool() then
        radio_station:Stop()
    end
end)


local spectrum = {}
local barHeights = {}

-- Create a font for the timer
surface.CreateFont("Timer", {
    font = "Roboto",
    size = 48,
    weight = 100,
    antialias = true,
    shadow = false
})

-- Create the same font but blurred
surface.CreateFont("TimerBlurred", {
    font = "Roboto",
    size = 48,
    weight = 100,
    antialias = true,
    shadow = false,
    scanlines = 4,
    blursize = 6
})

-- Create a font for the timer
surface.CreateFont("SmallTimer", {
    font = "Roboto",
    size = 36,
    weight = 100,
    antialias = true,
    shadow = false
})

-- Create the same font but blurred
surface.CreateFont("SmallTimerBlurred", {
    font = "Roboto",
    size = 36,
    weight = 100,
    antialias = true,
    shadow = false,
    scanlines = 4,
    blursize = 6
})

local TIMER_COLOR = Color(255,246,43)
local SPECTATE_COLOR = Color(255,246,43)


hook.Add("HUDPaint", "DrawRoundTime", function()
    local timeLeft = GetGlobal2Float("CurrentRoundTime", 0)

    if timeLeft < 0 then
        timeLeft = 0
    end

    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)

    local timerText = string.format("%02d:%02d", mins, secs)
    local timerX, timerY = ScrW() / 2, 75
    -- Draw a timer at the top of the screen
    draw.RoundedBox(8, timerX - 100, timerY - 25, 200, 50, Color(0,0,0,200))

    local timerColor = TIMER_COLOR

    if timeLeft < 60 and secs == 0 then
        timerColor = Color(0, 255, 0)
    elseif not GetGlobal2Bool("RoundRunning", false) then
        timerColor = Color(255, 0, 0)
    end

    draw.SimpleText(timerText, "TimerBlurred", timerX, timerY, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(timerText, "Timer", timerX, timerY, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Show the player that we're spectating
    if not LocalPlayer():Alive() and LocalPlayer():GetNWBool("LockedToSpectatedPlayer", false) then
        local spectateX, spectateY = ScrW() / 2, 150

        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= ply end)
        local targetPly = alivePlayers[LocalPlayer():GetNWInt("SpectateID", 1)]
        surface.SetFont("SmallTimer")

        local name = targetPly:Nick()

        local spectateTextWidth, _ = surface.GetTextSize("Spectating")
        local textWidth, _ = surface.GetTextSize(name)
        local width = math.max(spectateTextWidth + 24,textWidth + 24)
        local height = 85

        draw.RoundedBox(8, spectateX - width * 0.5, spectateY - height * 0.5, width, height, Color(0,0,0,200))


        draw.SimpleText("Spectating", "SmallTimerBlurred", spectateX, spectateY - height * 0.5 + 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "SmallTimerBlurred", spectateX, spectateY + height * 0.5 - 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText("Spectating", "SmallTimer", spectateX, spectateY - height * 0.5 + 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "SmallTimer", spectateX, spectateY + height * 0.5 - 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Draw audio visualizer if the radio is playing and the convar is set to true
    if radioVisualizerCVar:GetBool() and IsValid(radio_station) then
        radio_station:FFT(spectrum, FFT_256)
        local spacing = 3
        local spectrumPower = 200
        local barWidth = 1
        local spectrumX = 430
        local spectrumY = 75

        local borderThickness = 1


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

            -- Draw the bars
            draw.RoundedBox(0, xPos + math.floor(spectrumX) - borderThickness, spectrumY - barHeights[i] + barWidth - borderThickness, barWidth + borderThickness * 2, barHeights[i] * 2 + borderThickness * 2, Color(0, 0, 0))

            if i == 2 then continue end

            draw.RoundedBox(0, -xPos + math.floor(spectrumX) - borderThickness, spectrumY - barHeights[i] + barWidth - borderThickness, barWidth + borderThickness * 2, barHeights[i] * 2 + borderThickness * 2, Color(0, 0, 0))
        end

        for i = 2, #spectrum do
            local xPos = i * spacing - spacing * 2
            local brightness = math.min(math.sqrt(barHeights[i] / spectrumPower) * 2 + 0.25, 1)

            -- Draw the bars
            draw.RoundedBox(0, xPos + math.floor(spectrumX), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, brightness))

            if i == 2 then continue end

            draw.RoundedBox(0, -xPos + math.floor(spectrumX), spectrumY - barHeights[i] + barWidth, barWidth, barHeights[i] * 2, HSVToColor(0, 0, brightness))
        end
    end

    -- Draw text in the middle of the screen when LocalPlayer():GetNWBool("KickingSoon", false)

    if LocalPlayer():GetNWBool("KickingSoon", false) then
        draw.SimpleText("Warning: You will be kicked soon if you are inactive.", "DermaLarge", ScrW() / 2, ScrH() / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)



hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)