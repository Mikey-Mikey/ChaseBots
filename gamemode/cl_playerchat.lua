local roleColors = {
    ["Owner"] = Color(0, 140, 255),
}

net.Receive("PlayerChatted", function()
    local ply = net.ReadEntity()
    local text = net.ReadString()
    roleColor = roleColors[ply:GetUserGroup()] or color_white

    local role = table.GetKeys(roleColors)[table.KeyFromValue(roleColors, roleColor)]

    chat.AddText(Color(255,246,43), "[", roleColor, role, Color(255,246,43), "] ", roleColor, ply:Nick(), color_white, ": " .. text)
end)