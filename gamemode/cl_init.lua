include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")

gameevent.Listen("player_activate")
hook.Add("player_activate", "player_activate_example", function(data)
    local userid = data.userid
    if userid == LocalPlayer():UserID() then
        sound.PlayURL("https://radio.blueberry.coffee/radio.ogg", "noplay", function(station) -- play my friend's radio station for some background music while playing
            if IsValid(station) then
                station:Play()
                station:SetVolume(0.5)
            end
        end)
    end
end)