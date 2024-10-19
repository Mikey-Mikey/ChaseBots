include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")

sound.PlayURL("https://radio.blueberry.coffee/radio.ogg", "noplay", function(station) -- play my friend's radio station for some background music while playing
    if IsValid(station) then
        station:Play()
        station:SetVolume(0.5)
    end
end)