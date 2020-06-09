util.AddNetworkString("CustomizableNotifications:OpenMenu")

--hook.Remove("PlayerSay", "CustomizableNotifications:OpenMenu")
--[[
hook.Add("PlayerSay", "CustomizableNotifications:OpenMenu", function(ply, text)
    if #text < 2 then return text end
    for _,p in ipairs(CustomizableNotifications.Config.chatCommandPrefixes) do
        if text:sub(1, #p) != p then continue end
        for _,s in ipairs(CustomizableNotifications.Config.chatCommand) do
            if text:sub(#p + 1, #text) != s then continue end
            net.Start("CustomizableNotifications:OpenMenu")
            net.Send(ply)
            return ""
        end
    end
end)]]

hook.Add("PlayerButtonDown", "CustomizableNotifications:OpenMenu", function(ply, button)
    for _,k in ipairs(CustomizableNotifications.Config.KeyBind) do
        if button == k then
            net.Start("CustomizableNotifications:OpenMenu")
            net.Send(ply)
        end
    end
end)