hook.Add("PlayerSay", "PlayerSay", function( ply, text, teamChat)
    local newChat = "[" .. ply:Nick() .. "]" .. ": " .. text

    PrintMessage(HUD_PRINTTALK, newChat)

    return newChat
end)