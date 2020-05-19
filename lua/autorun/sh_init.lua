NOTIFY_TOPTEXT, NOTIFY_NOTIFICATION, NOTIFY_CHAT = 1,2,3
local function prettyPrint(message, err, modname1, modname2)
	if err then
		if err == 2 then
            if CustomizableNotifications.DebugMode then
			    MsgC(Color(230,180,20),"[")
			    MsgC(Color(20,200,230), modname1)
			    MsgC(Color(30,20,230), modname2)
			    MsgC(Color(230,180,20), "] ")
			    MsgC(Color(230,180,20), "Debug: ")
			    print(message)
            end
		else
			MsgC(Color(160,0,0),"[")
			MsgC(Color(240,0,0), modname1)
			MsgC(Color(160,0,0), modname2)
			MsgC(Color(240,0,0), "] ")
			MsgC(Color(160,0,0), "Error: ")
			print(message)
		end
	else
		MsgC(Color(0,0,160),"[")
		MsgC(Color(160,160,0), modname1)
		MsgC(Color(240,0,240), modname2)
		MsgC(Color(0,0,160), "] ")
		print(message)
	end
end

local notifySetupA
local notifySetupB = function()
    if (not CustomizableNotifications) then timer.Simple(1, notifySetupA()) else
        CustomizableNotifications.pPrint = function(message, err)
	        prettyPrint(message,err,"Customizable","Notifications")
        end
    end
end
notifySetupA = function() notifySetupB() end
notifySetupA()

