include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")

local radio_station = nil -- garbage collection prevention
timer.Simple(1, function()
    print("Creating radio station")
    sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing

        if IsValid(station) then
            station:Play()
            station:SetVolume(0.5)
            radio_station = station
        end

    end)
end)