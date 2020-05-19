util.AddNetworkString("CustomizableNotifications:Setup")
util.AddNetworkString("CustomizableNotifications:Message")

local notifySetupA
local notifySetupB = function()
    if (not CustomizableNotifications.pPrint) then timer.Simple(1, notifySetupA()) else
        NotifySetup = function(messageName, displayName, default)
            if list.HasEntry("CustomizableNotifications", messageName) then
                CustomizableNotifications.pPrint("Tried to add '" .. messageName .. "' even though it was already added!", true)
                return false
            end

            if default == nil then
                default = displayName
                displayName = messageName
            end

            list.Set("CustomizableNotifications", messageName, {
        	    messageType      = default.messageType,
                holdTime         = default.holdTime or 10,
                notificationType = default.notificationType or NOTIFY_GENERIC,
                fadeTime         = default.fadeTime or 0.25,
        	    xPos             = default.xPos or -0.5,
        	    yPos             = default.yPos or -0.08,
        	    xTextAlign       = default.xTextAlign or TEXT_ALIGN_CENTER,
        	    yTextAlign       = default.yTextAlign or TEXT_ALIGN_CENTER,
                messageFont      = default.messageFont or "Trebuchet24",
                setFirst         = default.setFirst or false,
                displayName      = displayName
            })
            local str = "Registered '" .. messageName .. "'"
            if displayName == messageName then str = str .. " (" .. displayName .. ")" end
            CustomizableNotifications.pPrint(str)
            CustomizableNotifications.pPrint("Sending '" .. messageName .. "'late-setup to all players.", 2)
            net.Start("CustomizableNotifications:Setup")
            net.WriteBit(0)
            net.WriteString(messageName)
            net.WriteTable(default)
            net.Broadcast()
            return true
        end

        NotifyPlayer = function(ply, messageName, msg, color)
            CustomizableNotifications.pPrint("Sending Message '" .. messageName .. "' to client.", 2)
            if not istable(msg) then msg = {msg} end
            net.Start("CustomizableNotifications:Message")
            net.WriteString(messageName)
            net.WriteTable(msg)
            net.WriteColor(color or Color(255, 255, 255))
            if ply == nil then net.Broadcast() else net.Send(ply) end
        end

        net.Receive("CustomizableNotifications:Setup", function(_, ply)
            CustomizableNotifications.pPrint("Sending setup to '" .. ply:Nick() .. "'", 2)
            net.Start("CustomizableNotifications:Setup")
            net.WriteBit(1)
            net.WriteTable(list.Get("CustomizableNotifications"))
            net.Send(ply)
        end)
    end
end
notifySetupA = function() notifySetupB() end
notifySetupA()