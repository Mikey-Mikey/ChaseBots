local roleColors = {
    ["Owner"] = Color(255, 0, 98),
    ["Co-Owner"] = Color(180, 0, 69),
    ["Admin"] = Color(255, 0, 0),
    ["Regular"] = Color(0,119,255),
    ["Guest"] = Color(255, 211, 144),
}

net.Receive("PlayerChatted", function()
    local ply = net.ReadEntity()
    local text = net.ReadString()
    roleColor = roleColors[ply:GetUserGroup()] or color_white

    local role = table.KeyFromValue(roleColors, roleColor)

    chat.AddText(Color(255,246,43), "[", roleColor, role, Color(255,246,43), "] ", roleColor, ply:Nick(), color_white, ": " .. text)
end)