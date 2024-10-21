net.Receive("PlayerChatted", function()
    local ply = net.ReadEntity()
    local text = net.ReadString()
    roleColor = ROLE_COLORS[ply:GetUserGroup()] or color_white

    local role = table.KeyFromValue(ROLE_COLORS, roleColor)

    chat.AddText(Color(255,246,43), "[", roleColor, role, Color(255,246,43), "] ", roleColor, ply:Nick(), color_white, ": " .. text)
end)

timer.Create("ShowDiscordInvite", 240, 0, function()
    chat.AddText(Color(43,142,255), "Join our Discord server!: ", Color(187, 128, 255), "https://discord.gg/SHaYKb4AFw")
end)