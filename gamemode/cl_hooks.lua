hook.Add("NetworkEntityCreated", "SetRagdollColors", function(ent)
    if ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetNW2Entity("RagdollOwner")) then
        local col = ent:GetNW2Entity("RagdollOwner"):GetPlayerColor()
        ent.GetPlayerColor = function()
            return col
        end
    end
end)

radio_station = radio_station or nil -- garbage collection prevention

print("Creating radio station")
sound.PlayURL("https://radio.blueberry.coffee/radio.mp3", "noplay", function(station, errorID, err) -- play my friend's radio station for some background music while playing
    if IsValid(station) then
        print(station:GetClass())
        station:Play()
        station:SetVolume(0.25)
        radio_station = station
    end

end)
