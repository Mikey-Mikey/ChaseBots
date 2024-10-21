local roleColors = {
    ["superadmin"] = Color(0, 140, 255),
    ["admin"] = Color(0, 255, 0),
    ["user"] = color_white
}

net.Receive("PlayerChatted", function()
    local ply = net.ReadEntity()
    local text = net.ReadString()
    roleColor = roleColors[ply:GetUserGroup()] or color_white
    chat.AddText(Color(255,246,43), "[", roleColor, ply:Nick(), Color(255,246,43), "]: ", color_white, text)
end)