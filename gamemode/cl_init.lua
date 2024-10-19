include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")

timer.Simple(1, function()
    print("Creating radio station")
    sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing
        print("Created radio station")
        if IsValid(station) then
            print("Playing radio station")
            station:Play()
            station:SetVolume(0.5)
        end

        print(station .. " " .. errorID .. " " .. err)

        if errorID ~= 0 then
            print("Error playing radio station: " .. err)
        end
    end)
end)