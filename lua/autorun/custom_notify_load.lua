if SERVER then
    AddCSLuaFile("customizable_notifications/sh_config.lua")
    AddCSLuaFile("customizable_notifications/sh_init.lua")
    AddCSLuaFile("customizable_notifications/client/cl_load_fonts.lua")
    AddCSLuaFile("customizable_notifications/client/cl_notifications.lua")

    include("customizable_notifications/sh_config.lua")
    include("customizable_notifications/sh_init.lua")

    include("customizable_notifications/server/sv_load_resources.lua")
    include("customizable_notifications/server/sv_init.lua")
    include("customizable_notifications/server/sv_open_menu.lua")
end

if CLIENT then
    include("customizable_notifications/sh_config.lua")
    include("customizable_notifications/sh_init.lua")

    include("customizable_notifications/client/cl_load_fonts.lua")
    include("customizable_notifications/client/cl_notifications.lua")
end