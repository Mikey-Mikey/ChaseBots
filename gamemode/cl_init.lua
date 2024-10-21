ROLE_COLORS = {
    ["Owner"] = Color(255, 0, 98),
    ["Co-Owner"] = Color(180, 0, 69),
    ["Admin"] = Color(255, 0, 0),
    ["Regular"] = Color(0,119,255),
    ["Guest"] = Color(255, 211, 144),
}

include("shared.lua")
include("cl_hooks.lua")
include("cl_hud.lua")
include("cl_playerchat.lua")