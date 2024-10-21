util.AddNetworkString("PlayerChatted")

hook.Add("PlayerSay", "PlayerSay", function( ply, text, teamChat)
    net.Start("PlayerChatted")
    net.WriteEntity(ply)
    net.WriteString(text)
    net.Broadcast()

    return ""
end)