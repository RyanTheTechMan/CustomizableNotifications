if CLIENT then 
    CustomizableNotifications = CustomizableNotifications or {}
    CustomizableNotifications.Config = CustomizableNotifications.Config or {}
	CustomizableNotifications.Config.ShowContextMenu = true
end

if SERVER then
    CustomizableNotifications = CustomizableNotifications or {}
    CustomizableNotifications.Config = CustomizableNotifications.Config or {}

    //Open Menu Options
    CustomizableNotifications.Config.chatCommand = {"customizablenotifications", "cnotify", "customnotify"}
    CustomizableNotifications.Config.chatCommandPrefixes = {"!", "/"}
    CustomizableNotifications.Config.KeyBind = {}
end

CustomizableNotifications.DebugMode = false -- Enableing this will print messages to the client and server while things are happening.