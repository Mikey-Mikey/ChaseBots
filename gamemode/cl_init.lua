ROLE_COLORS = {
    ["Owner"] = Color(255, 0, 98),
    ["Co-Owner"] = Color(180, 0, 69),
    ["Admin"] = Color(255, 0, 0),
    ["Regular"] = Color(0,119,255),
    ["Guest"] = Color(255, 211, 144),
}

ROLE_PRIORITY = {
    [1] = "Owner",
    [2] = "Co-Owner",
    [3] = "Admin",
    [4] = "Regular",
    [5] = "Guest",
}

include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")
include("cl_playerchat.lua")