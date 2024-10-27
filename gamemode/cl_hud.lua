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
    font = "VCR OSD Mono",
    size = 64,
    weight = 100,
    antialias = false,
    shadow = false
})

-- Create the same font but blurred
surface.CreateFont("TimerBlurred", {
    font = "VCR OSD Mono",
    size = 64,
    weight = 100,
    antialias = false,
    shadow = false,
    scanlines = 4,
    blursize = 12
})

-- Create a font for the timer
surface.CreateFont("SmallTimer", {
    font = "VCR OSD Mono",
    size = 36,
    weight = 100,
    antialias = false,
    shadow = false
})

-- Create the same font but blurred
surface.CreateFont("SmallTimerBlurred", {
    font = "VCR OSD Mono",
    size = 36,
    weight = 100,
    antialias = false,
    shadow = false,
    scanlines = 4,
    blursize = 6
})

-- Scoreboard Fonts
surface.CreateFont("ScoreboardTitle", {
    font = "VCR OSD Mono",
    size = 64,
    weight = 100,
    antialias = false,
    shadow = false
})

-- Scoreboard Fonts
surface.CreateFont("ScoreboardInfo", {
    font = "VCR OSD Mono",
    size = 36,
    weight = 100,
    antialias = false,
    shadow = false
})

local BACKGROUND_COLOR = Color(0,0,0,200) -- Color(46,49,146,255)
local OUTLINE_COLOR = Color(245,146,32,255)

local TIMER_COLOR = Color(255,246,43)
local SPECTATE_COLOR = Color(255,246,43)

local timerPulse = 0

local lastSec = 0

hook.Add("HUDPaint", "DrawRoundTime", function()
    local timeLeft = GetGlobal2Int("CurrentRoundTime", 0)

    if timeLeft < 0 then
        timeLeft = 0
    end

    local mins = math.floor(timeLeft / 60)
    local secs = math.floor(timeLeft % 60)

    if secs ~= lastSec then
        timerPulse = 1
    else
        timerPulse = LerpExpo(FrameTime(), timerPulse, 0, 2)
    end

    local timerText = string.format("%02d:%02d", mins, secs)
    local timerX, timerY = ScrW() / 2, 0
    local timerWidth, timerHeight = 283, 110
    -- Draw a round counter at the top of the screen

    draw.RoundedBoxEx(0, timerX - timerWidth * 0.5, timerY, timerWidth, timerHeight, BACKGROUND_COLOR, false, false, true, true)
    --surface.SetDrawColor(OUTLINE_COLOR.r, OUTLINE_COLOR.g, OUTLINE_COLOR.b, OUTLINE_COLOR.a)
    -- Draw a timer at the top of the screen
    --surface.DrawOutlinedRect(timerX - timerWidth * 0.5, timerY, timerWidth, timerHeight, 4)


    local timerColor = TIMER_COLOR

    if timeLeft < 60 and secs == 0 then
        timerColor = Color(0, 255, 0)
    elseif not GetGlobal2Bool("RoundRunning", false) then
        timerColor = Color(255, 0, 0)
    end

    local roundCounterText = "Round " .. GetGlobal2Int("CurrentRound", 0)

    draw.SimpleText(roundCounterText, "SmallTimerBlurred", timerX, timerY + 25, Color(timerColor.r, timerColor.g, timerColor.b, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(roundCounterText, "SmallTimer", timerX, timerY + 25, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText(timerText, "TimerBlurred", timerX, timerY + 72, Color(timerColor.r, timerColor.g, timerColor.b, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(timerText, "TimerBlurred", timerX, timerY + 72, Color(timerColor.r, timerColor.g, timerColor.b, timerPulse * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(timerText, "Timer", timerX, timerY + 72, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    lastSec = secs

    -- Show the player that we're spectating
    if not LocalPlayer():Alive() and LocalPlayer():GetNWBool("LockedToSpectatedPlayer", false) then
        local spectateX, spectateY = ScrW() / 2, ScrH()

        local alivePlayers = player.GetAll()
        alivePlayers = FilterTable(alivePlayers, function(v) return v:Alive() and v ~= LocalPlayer() end)
        local targetPly = alivePlayers[LocalPlayer():GetNWInt("SpectateID", 1)]
        surface.SetFont("SmallTimer")

        local name = targetPly:Nick()

        local spectateTextWidth, _ = surface.GetTextSize("Spectating")
        local textWidth, _ = surface.GetTextSize(name)
        local width = math.max(spectateTextWidth + 24,textWidth + 24)
        local height = 85

        draw.RoundedBoxEx(0, spectateX - width * 0.5, spectateY - height, width, height, Color(0,0,0,200), true, true, false, false)


        draw.SimpleText("Spectating", "SmallTimerBlurred", spectateX, spectateY - height + 24, Color(SPECTATE_COLOR.r, SPECTATE_COLOR.g, SPECTATE_COLOR.b, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "SmallTimerBlurred", spectateX, spectateY - 24, Color(SPECTATE_COLOR.r, SPECTATE_COLOR.g, SPECTATE_COLOR.b, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText("Spectating", "SmallTimer", spectateX, spectateY - height + 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "SmallTimer", spectateX, spectateY - 24, SPECTATE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Draw audio visualizer if the radio is playing and the convar is set to true
    if radioVisualizerCVar:GetBool() and IsValid(radio_station) then
        radio_station:FFT(spectrum, FFT_256)
        local spacing = 1
        local spectrumPower = 750
        local barWidth = 1
        local spectrumX = ScrW() * 0.5
        local spectrumY = 109


        for i = 2, #spectrum do
            local barFrequency = 44100 / 256 / 2 / #spectrum
            barHeights[i] = barHeights[i] or 0

            local height = math.sqrt(spectrum[i]) + 0.001

            height = height * barFrequency * spectrumPower

            height = 20 * math.log10(height^2)
            height = math.max(0, height) + barWidth * 2
            --height = height * spectrumPower + barWidth

            if height < barHeights[i] then
                barHeights[i] = math.max(0, barHeights[i] - 2)
            else
                barHeights[i] = LerpExpo(FrameTime(), barHeights[i] or 0, height, 30)
            end

            local xPos = i * spacing - spacing * 2

            local brightness = math.min(barHeights[i] / spectrumPower * 10 + 0.25, 1)

            -- Draw the bars
            draw.RoundedBox(0, xPos + math.floor(spectrumX), spectrumY + barWidth, barWidth, barHeights[i], HSVToColor(0, 0, brightness))

            if i == 2 then continue end

            draw.RoundedBox(0, -xPos + math.floor(spectrumX), spectrumY + barWidth, barWidth, barHeights[i], HSVToColor(0, 0, brightness))
        end
    end

    if LocalPlayer():GetNWBool("KillingSoon", false) then
        draw.SimpleText("Warning: You will be killed soon if you are inactive.", "DermaLarge", ScrW() / 2, ScrH() / 2, Color(255, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end)


hook.Add("HUDShouldDraw", "HideDefaultHUD", function(name)
    if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudDamageIndicator" then
        return false
    end
end)

-- Custom Scoreboard

local function DrawPlayerRow(ply, x, y, w, h)
    if not IsValid(ply) then return end
    local roleColor = ROLE_COLORS[ply:GetUserGroup()] or color_white
    draw.RoundedBox(0, x - 2, y + h, w + 5, 6, OUTLINE_COLOR)

    draw.RoundedBox(0, x - 2, y - 2, w + 5, h + 4, Color(0,0,0))
    draw.RoundedBox(0, x - 2, y - 2, w + 5, h + 4, Color(roleColor.r, roleColor.g, roleColor.b, 20))

    if not ply:Alive() then
        draw.RoundedBox(0, x - 1, y - 1, w + 2, h + 2, Color(255, 0, 0, 10 + (math.sin(CurTime() * 5 + y) * 0.5 + 0.5) * 20))
        draw.SimpleText("Dead", "ScoreboardInfo", x + w * 0.75 - 48, y + h / 2 + 1, Color(0,0,0,127), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local name = ply:Nick()

    if #name > 24 then
        name = string.sub(name, 1, 16) .. "..."
    end

    draw.SimpleText(name, "ScoreboardInfo", x + 10, y + h / 2 + 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    local role = table.KeyFromValue(ROLE_COLORS, roleColor)
    draw.SimpleText(role, "ScoreboardInfo", x + w * 0.5, y + h / 2 + 1, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local ping = ply:Ping()
    draw.SimpleText(ping, "ScoreboardInfo", x + w - 48, y + h / 2 + 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local scoreboardShowing = false
local scoreboardScroll = 0
local scoreboardScrollVel = 0
local scrollingScoreboard = false
local lastMouseX, lastMouseY = input.GetCursorPos()
hook.Remove("StartCommand", "ScoreboardScroll")

hook.Add("ScoreboardShow", "ShowScoreboard", function()
    scoreboardShowing = true
    gui.EnableScreenClicker(true)

    return true
end)

hook.Add("ScoreboardHide", "HideScoreboard", function()
    scoreboardShowing = false
    gui.EnableScreenClicker(false)
    return true
end)

local function pointWithinRect(px,py,x1,y1,x2,y2)
    return px >= x1 and px <= x2 and py >= y1 and py <= y2
end

hook.Add("HUDDrawScoreBoard", "Scoreboard", function()
    if not scoreboardShowing then return end
    local mouseX, mouseY = input.GetCursorPos()

    local players = player.GetAll()
    table.sort(players, function(a, b) return a:Frags() > b:Frags() end)

    local w, h = 800, 600
    local x, y = ScrW() / 2 - w / 2, ScrH() / 2 - h / 2

    if input.IsMouseDown(MOUSE_LEFT) and pointWithinRect(mouseX,mouseY, x + 8, y + 90, x + w - 8, y + h - 8) then
        scrollingScoreboard = true
    end

    if not input.IsMouseDown(MOUSE_LEFT) then
        scrollingScoreboard = false
    end

    if scrollingScoreboard then
        scoreboardScroll = math.Clamp(scoreboardScroll + (mouseY - lastMouseY), -2648 + 14, 0)
        scoreboardScrollVel = mouseY - lastMouseY
    else
        scoreboardScroll = math.Clamp(scoreboardScroll + scoreboardScrollVel, -2648 + 14, 0)
        scoreboardScrollVel = scoreboardScrollVel + math.Clamp(scoreboardScrollVel * 0.94 - scoreboardScrollVel, -0.3, 0.3)
    end
    draw.RoundedBox(0, x, y, w, h, Color(48,48,48))
    surface.SetDrawColor(OUTLINE_COLOR.r, OUTLINE_COLOR.g, OUTLINE_COLOR.b, OUTLINE_COLOR.a)
    surface.DrawOutlinedRect(x, y, w, h, 4)

    draw.SimpleText("Scoreboard", "ScoreboardTitle", x + w / 2, y + 48, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local rowHeight = 48
    local rowY = y + 94
    -- Order the players by their role

    table.sort(players, function(a, b)
        if not IsValid(a) or not IsValid(b) then return false end
        local rolePriorityA = ROLE_PRIORITY[a:GetUserGroup()] or 0
        local rolePriorityB = ROLE_PRIORITY[b:GetUserGroup()] or 0
        return rolePriorityA < rolePriorityB
    end)

    draw.RoundedBox(0, x + 8, y + 90, w - 16, h - 8 - 90, BACKGROUND_COLOR)

    draw.RoundedBox(0, x + 8, y + 90, w - 16, h - 8 - 90, Color(0,0,0, 200))

    render.SetScissorRect(x + 8, y + 90, x + w - 8, y + h - 8, true)

    for i = 1, 64 do
        local col = Color(0,0,0, 230)
        if i % 2 == 0 then
            col = Color(48,48,48)
        else
            col = Color(27,27,27)
        end
        draw.RoundedBox(0, x + 10, rowY + i * rowHeight + 8 + scoreboardScroll, w - 20, rowHeight, col)
    end

    draw.SimpleText("Click + Drag", "ScoreboardTitle", x + w * 0.5, y + h * 0.5 + 48 - 10, Color(0, 0, 0, 127), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    for i, ply in pairs(players) do
        DrawPlayerRow(ply, x + 10, rowY + scoreboardScroll, w - 20, rowHeight)
        rowY = rowY + rowHeight + 8
    end

    render.SetScissorRect(0, 0, 0, 0, false)

    surface.SetDrawColor(OUTLINE_COLOR.r, OUTLINE_COLOR.g, OUTLINE_COLOR.b, OUTLINE_COLOR.a)
    surface.DrawOutlinedRect(x + 8, y + 90, w - 16, h - 8 - 90, 4)
    lastMouseX, lastMouseY = mouseX, mouseY
end)