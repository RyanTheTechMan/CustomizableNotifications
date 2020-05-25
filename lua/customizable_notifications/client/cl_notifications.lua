NOTIFY_AUTHOR, NOTIFY_DISABLED = 4,5
local fileLocation = "customizable_notifications.txt"
local FileData = {} 
if file.Exists(fileLocation, "DATA") then
    local fl = file.Read(fileLocation, "DATA")
    if fl != "" then
        FileData = util.JSONToTable(fl)
    end
end

function draw.Circle(x, y, radius, seg)
 local cir = {}

 table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
 for i = 0, seg do
 	local a = math.rad((i / seg) * -360)
 	table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
 end

 local a = math.rad(0) -- This is needed for non absolute segment counts
 table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    
 surface.DrawPoly(cir)
end

CustomizableNotifications = CustomizableNotifications or {}
CustomizableNotifications.Notifications = {}

if CustomizableNotifications.Config.ShowContextMenu then
	list.Set("DesktopWindows", "CustomizableNotifications", {
		title		= "Notifications",
		icon		= "customizable_notifications/bell.png",
		onewindow	= false,
		init		= function(icon, window)
			RunConsoleCommand("-menu_context");
			RunConsoleCommand("customizablenotifications_menu");
		end
	});
end


local messageQueue = {}
local selectedMessage = nil

local function menuCustomizableNotifications()

    local shiftAlpha = 255
    local shiftAlphaAllowed = 200

    local shiftPanelsToHideA = {}
    local shiftPanelsToHideB = {}

    CustomizableNotifications.frame = vgui.Create("DFrame")
    local frame = CustomizableNotifications.frame
    frame:SetTitle("")
    frame:SetSize(900, 600)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.OnClose = function() CustomizableNotifications.frame = nil end
    frame.Paint = function(s,w,h)
        shiftAlpha = math.Clamp(shiftAlpha - FrameTime() * (CustomizableNotifications.quickShift and 800 or -800), 0, 255)
        
        if shiftAlpha > 1 then
            for _,pan in ipairs(shiftPanelsToHideA) do
                pan:Show()
            end
        else
            for _,pan in ipairs(shiftPanelsToHideA) do
                pan:Hide()
            end
        end
        if shiftAlpha < 254 then
            for _,pan in ipairs(shiftPanelsToHideB) do
                pan:Show()
            end
        else
            for _,pan in ipairs(shiftPanelsToHideB) do
                pan:Hide()
            end
        end 
    
        draw.RoundedBox(30, 0, 0, w,h, Color(15, 15, 15, 235))
        draw.SimpleText("Notification Settings", "CustomizableNotifications:TitleFont", w/2, 25, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

    local sizeX, sizeY = frame:GetSize()

    local closeOffset = 45
    local closeButtonColors = {Color(190, 100, 10, 255), Color(255, 50, 40, 255)}
    local closeButtonColor = closeButtonColors[1]
    local closeButtonPartA
    local closeButtonPartB
    local closeButton = frame:Add("DButton")
    closeButton:SetPos(sizeX - 50,5)
    closeButton:SetSize(40,40)
    closeButton:SetText("")
    function closeButton:Paint(s,w,h)
        if self:IsHovered() then
            if closeOffset < 90 then
                closeOffset = math.Clamp(closeOffset + FrameTime() * 250, 0, 135)
                closeButtonColor = closeButtonColors[1]
            elseif closeOffset < 135 then
                closeOffset = math.Clamp(closeOffset + FrameTime() * 250, 0, 135)
                closeButtonColor = closeButtonColors[2]
            end
        else
            if closeOffset > 90 then
                closeOffset = math.Clamp(closeOffset - FrameTime() * 250, 0, 135)
                closeButtonColor = closeButtonColors[2]
            elseif closeOffset > 45 then
                closeOffset = math.Clamp(closeOffset - FrameTime() * 250, 0, 135)
                closeButtonColor = closeButtonColors[1]
            end
        end
    end
    closeButton.DoClick = function()
        frame:Close()
    end

    closeButtonPartA = closeButton:Add("DSprite")
    closeButtonPartA:SetPos(20, 20)
    closeButtonPartA:SetMaterial(Material("customizable_notifications/closeButtonPart"))
    closeButtonPartA:SetSize(40, 40)
    closeButtonPartA.defaultFunc = closeButtonPartA.Paint
    function closeButtonPartA:Paint(s,w,h)
        self:SetRotation(-closeOffset)
        self:SetColor(closeButtonColor)
        closeButtonPartA:defaultFunc(s,w,h)
    end

    closeButtonPartB = closeButton:Add("DSprite")
    closeButtonPartB:SetPos(20,20)
    closeButtonPartB:SetMaterial(Material("customizable_notifications/closeButtonPart"))
    closeButtonPartB:SetColor(Color(190, 100, 10, 255))
    closeButtonPartB:SetSize(40, 40)
    closeButtonPartB.defaultFunc = closeButtonPartB.Paint
    function closeButtonPartB:Paint(s,w,h)
        self:SetRotation(closeOffset)
        self:SetColor(closeButtonColor)
        closeButtonPartB:defaultFunc(s,w,h)
    end

    local examples = frame:Add("DPanel")
    examples:SetPos(15, 45)
    examples:SetSize(sizeX, sizeY*.21)
    examples.Paint = function (s,w,h)
        --surface.SetDrawColor(255, 15, 15, 235)
	    --surface.DrawRect(0, 0, w, h)
    end

    local examOffset = 62
    local offsetBoost = 170 + 20
    local grayScaleIntensity = 196
    local selectColor = 120

    local esizeX, esizeY = examples:GetSize()

    local example3 = examples:Add("DPanel")
    example3:SetPos(examOffset, 0)
    example3:SetSize(offsetBoost - 20, esizeY)
    example3.Paint = function(s,w,h)
        draw.RoundedBox(10, 0, 25, w, h-30, Color(example3.Hovered and selectColor or grayScaleIntensity,grayScaleIntensity,grayScaleIntensity, 235))
        draw.RoundedBox(0, 5, h-25, 40, 6, Color(81, 156, 224, 235))
        draw.SimpleText("Chat Message (CM)", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local example3B = example3:Add("DButton")
    example3B:SetPos(0, 25)
    example3B:SetSize(150,96)
    example3B:SetText("")
    function example3B:Paint(s,w,h) self:GetParent().Hovered = self:IsHovered() end
    example3B.DoClick = function()
        chat.AddText(Color(255,0,0), "This is what a ", Color(0,255, 100), "chat message", Color(255,0,0), " looks like.")
    end

    examOffset = examOffset + offsetBoost

    local example1 = examples:Add("DPanel")
    example1:SetPos(examOffset,0)
    example1:SetSize(offsetBoost - 20, esizeY)
    example1.Paint = function(s,w,h)
        draw.RoundedBox(10, 0, 25, w, h-30, Color(example1.Hovered and selectColor or grayScaleIntensity,grayScaleIntensity,grayScaleIntensity, 235))
        draw.RoundedBox(0, 25, 35, w-50, 6, Color(81, 156, 224, 235))
        draw.SimpleText("Top Text (TT)", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local example1B = example1:Add("DButton")
    example1B:SetPos(0, 25)
    example1B:SetSize(150,96)
    example1B:SetText("")
    function example1B:Paint(s,w,h) self:GetParent().Hovered = self:IsHovered() end
    example1B.DoClick = function()
        if selectedMessage == nil or selectedMessage.msg != "This is what Top Text looks like." then
            table.insert(messageQueue, 1,
            {
                xPos        = -0.5,
                yPos        = -0.08,
                xTextAlign  = TEXT_ALIGN_CENTER,
                yTextAlign  = TEXT_ALIGN_CENTER,
                fadeTime    = 0.25,
                holdTime    = 10,
                messageFont = "Trebuchet24",
                color       = Color(100,100,255),
                msg         = "This is what Top Text looks like."
            })
        end
    end

    examOffset = examOffset + offsetBoost

    local example2 = examples:Add("DPanel")
    example2:SetPos(examOffset, 0)
    example2:SetSize(offsetBoost - 20, esizeY)
    example2.Paint = function(s,w,h)
        draw.RoundedBox(10, 0, 25, w, h-30, Color(example2.Hovered and selectColor or grayScaleIntensity,grayScaleIntensity,grayScaleIntensity, 235))
        draw.RoundedBox(0, w-35, h-25, 30, 6, Color(81, 156, 224, 235))
        draw.SimpleText("Notification (N)", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local example2B = example2:Add("DButton")
    example2B:SetPos(0, 25)
    example2B:SetSize(150,96)
    example2B:SetText("")
    function example2B:Paint(s,w,h) self:GetParent().Hovered = self:IsHovered() end
    example2B.DoClick = function()
        notification.AddLegacy("This is what a notification looks like!", NOTIFY_GENERIC, 5)
        surface.PlaySound("buttons/button15.wav")
    end
    
    examOffset = examOffset + offsetBoost

    local example4 = examples:Add("DPanel")
    example4:SetPos(examOffset, 0)
    example4:SetSize(offsetBoost - 20, esizeY)
    example4.Paint = function(s,w,h)
        draw.RoundedBox(10, 0, 25, w, h-30, Color(grayScaleIntensity,grayScaleIntensity,grayScaleIntensity, 235))
        --draw.RoundedBox(0, 25, 35, w-50, 6, Color(81, 156, 224, 235))
        draw.DrawText("?","CustomizableNotifications:Other",w/2, h/2 - 8, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER)
        draw.SimpleText("Author Custom (A)", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    --[[local example4B = example4:Add("DButton")
    example4B:SetPos(0, 25)
    example4B:SetSize(150,96)
    example4B:SetText("")
    function example4B:Paint(s,w,h) self:GetParent().Hovered = self:IsHovered() end
    --function example4B:UpdateColours(skin) return {} end
    example4B.DoClick = function() end]]

    local collumOffset = 0
    local collumOffsetAmount = 50

    local textCM = frame:Add("DPanel")
    textCM:SetPos(sizeX - 350 + collumOffset, esizeY + 50)
    textCM:SetSize(40,30)
    textCM.Paint = function(s,w,h)
        draw.SimpleText("CM", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, shiftAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideA, textCM)

    local textCONSOLE = frame:Add("DPanel")
    textCONSOLE:SetPos(sizeX - 350 + collumOffset - 15, esizeY + 50)
    textCONSOLE:SetSize(70,30)
    textCONSOLE.Paint = function(s,w,h)
        draw.SimpleText("Console", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, -(shiftAlpha-255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideB, textCONSOLE)

    collumOffset = collumOffset + collumOffsetAmount

    local TT = frame:Add("DPanel")
    TT:SetPos(sizeX - 350 + collumOffset, esizeY + 50)
    TT:SetSize(40,30)
    TT.Paint = function(s,w,h)
        draw.SimpleText("TT", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, shiftAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    table.insert(shiftPanelsToHideA, TT)

    collumOffset = collumOffset + collumOffsetAmount

    local N = frame:Add("DPanel")
    N:SetPos(sizeX - 350 + collumOffset, esizeY + 50)
    N:SetSize(40,30)
    N.Paint = function(s,w,h)
        draw.SimpleText("N", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, shiftAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideA, N)

    local textSOUND = frame:Add("DPanel")
    textSOUND:SetPos(sizeX - 350 + collumOffset - 15, esizeY + 50)
    textSOUND:SetSize(70,30)
    textSOUND.Paint = function(s,w,h)
        draw.SimpleText("Sound", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, -(shiftAlpha-255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideB, textSOUND)

    collumOffset = collumOffset + collumOffsetAmount

    local A = frame:Add("DPanel")
    A:SetPos(sizeX - 350 + collumOffset, esizeY + 50)
    A:SetSize(40,30)
    A.Paint = function(s,w,h)
        draw.SimpleText("A", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, shiftAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideA, A)

    collumOffset = collumOffset + collumOffsetAmount

    local D = frame:Add("DPanel")
    D:SetPos(sizeX - 350 + collumOffset + collumOffsetAmount - 15, esizeY + 50)
    D:SetSize(70,30)
    D.Paint = function(s,w,h)
        draw.SimpleText("Disabled", "CustomizableNotifications:ExampleFont", w/2, 12, Color(255,255,255, shiftAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    table.insert(shiftPanelsToHideA, D)

    local itemSelection = {}

    local onButtonSelect = function(master, id)
        for _,v in ipairs(itemSelection[master]) do
            v.selected = v.id == id
        end
        if FileData[master] == nil then FileData[k] = {} end
        FileData[master].messageType = id
        CustomizableNotifications.Notifications[master].messageType = id
        file.Write(fileLocation, util.TableToJSON(FileData))
    end


    local notificationListPanel = frame:Add("DPanel")
    notificationListPanel:SetPos(0, esizeY + 80)
    notificationListPanel:SetSize(sizeX, sizeY - esizeY - 80)
    notificationListPanel.Paint = function(s,w,h) end

    local notificationListScrollbar = notificationListPanel:Add("DScrollPanel")
    notificationListScrollbar:Dock(FILL)

    local notificationList = notificationListScrollbar:Add("DIconLayout")
    notificationList:Dock(FILL)
    notificationList:SetSpaceY(10)

    local itemOffset = 40
    for k,v in pairs(CustomizableNotifications.Notifications) do
        if FileData[k] == nil or not istable(FileData[k]) then FileData[k] = {} end
    	local item = notificationList:Add("DPanel")
    	item:SetSize(sizeX, 60)
        item.OwnLine = true
        item.Paint = function(s,w,h)
            draw.RoundedBox(10, itemOffset, 0, sizeX - itemOffset - itemOffset, h, Color(100, 100, 100, 235))
        end

        local title = item:Add("DPanel")
        title:SetPos(itemOffset, 0)
        title:SetSize(300, 60)
        title.Paint = function(s,w,h)
            draw.SimpleText(v.displayName, "CustomizableNotifications:Item", 15, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local quickShiftMenu = item:Add("DPanel")
        quickShiftMenu:SetPos(sizeX - 350, 0)
        quickShiftMenu:SetSize(sizeX - 350 + 150, 60)
        quickShiftMenu.Paint = function(s,w,h)
            --draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 235))
        end

        local createQuickShiftButton = function(offset, def, clickFunc, buttonImgSelected, buttonImgNotSelected)
            local checkBoxIcon
            local checkBox = quickShiftMenu:Add("DCheckBox")
            checkBox:SetPos(3.5 + offset, 13)
            checkBox:SetSize(35, 35)
            checkBox:SetChecked(def)
            checkBox.Paint = function(s,w,h) end
            function checkBox:OnChange()
                clickFunc(self:GetChecked())
                checkBoxIcon:SetMaterial(self:GetChecked() and buttonImgSelected or buttonImgNotSelected)
            end

            local materialSelected
            checkBoxIcon = checkBox:Add("DSprite")
            if not (buttonImgSelected and buttonImgNotSelected) then
                buttonImgSelected = Material("customizable_notifications/checkbox")
                buttonImgNotSelected = Material("customizable_notifications/checkbox")
            end

            checkBoxIcon:SetMaterial(checkBox:GetChecked() and buttonImgSelected or buttonImgNotSelected)

            checkBoxIcon:SetPos(17.5,17.5)
            checkBoxIcon:SetSize(35, 35)
            checkBoxIcon.defaultFunc = checkBoxIcon.Paint
            function checkBoxIcon:Paint(s,w,h)
                self:SetColor((checkBox:GetChecked() and Color(48, 184, 24, -(shiftAlpha-255)) or Color(184, 18, 18, -(shiftAlpha-255))))
                self:defaultFunc(s,w,h)
            end
            table.insert(shiftPanelsToHideB, checkBox)
        end
        local printInConsole = false
        if FileData[k].printInConsole != nil then
            printInConsole = FileData[k].printInConsole
        else
            printInConsole = CustomizableNotifications.Notifications[k].printInConsole
        end
        createQuickShiftButton(0, printInConsole, function(b)
            FileData[k].printInConsole = b
            CustomizableNotifications.Notifications[k].printInConsole = b
            file.Write(fileLocation, util.TableToJSON(FileData))
        end)
        local soundEnabled = false
        if FileData[k].soundEnabled != nil then
            soundEnabled = FileData[k].soundEnabled
        else
            soundEnabled = CustomizableNotifications.Notifications[k].soundEnabled
        end
        createQuickShiftButton(100, soundEnabled, function(b)
            FileData[k].soundEnabled = b
            CustomizableNotifications.Notifications[k].soundEnabled = b
            file.Write(fileLocation, util.TableToJSON(FileData))
        end, Material("customizable_notifications/speaker"), Material("customizable_notifications/speaker_mute"))

        local buttons = item:Add("DIconLayout")
        table.insert(shiftPanelsToHideA, buttons)
        buttons:SetPos(sizeX - 350, 0)
        buttons:SetSize(sizeX - 350 + 150, 60)
        --buttons:Dock(FILL)
        --buttons:SetSpaceY(10)
        buttons:SetSpaceX(10)
        local createButton = function(id, offset)
            if not offset then offset = 0 end
            for i=1, offset do
                local buttonBacking = buttons:Add("DPanel")
                buttonBacking:SetSize(40, 60)
                buttonBacking.Paint = function(s,w,h) end
            end

            local buttonBacking = buttons:Add("DButton")
            buttonBacking:SetSize(40, 60)
            buttonBacking:SetText("")

            buttonBacking.Paint = function(s,w,h)
                surface.SetDrawColor(60, 60, 60, shiftAlpha)
                draw.NoTexture()
                draw.Circle(w/2, h/2, 16, 256)
            end

            local button = buttonBacking:Add("DButton")
            button:SetPos(0, 0)
            button:SetSize(40, 60)
            button:SetText("")
            button.Paint = function(s,w,h)
                if buttonBacking.selected then
                    surface.SetDrawColor(49, 139, 222, shiftAlpha)
                else
                    surface.SetDrawColor(71, 71, 71, shiftAlpha)
                end
                draw.NoTexture()
                draw.Circle(w/2, h/2, 11, 256)
            end
            button.DoClick = function()
                if shiftAlpha < shiftAlphaAllowed then return end
                buttonBacking.selected = not buttonBacking.selected
                onButtonSelect(k, id)
            end
            buttonBacking.DoClick = function()
                if shiftAlpha < shiftAlphaAllowed then return end
                buttonBacking.selected = not buttonBacking.selected
                onButtonSelect(k, id)
            end 
            if FileData[k].messageType == nil then
                if id == v.messageType then
                    buttonBacking.selected = true
                    
                end
            else
                buttonBacking.selected = FileData[k].messageType == id
            end                

            buttonBacking.id = id
            return buttonBacking
        end
        itemSelection[k] = {}
        
        table.insert(itemSelection[k], createButton(NOTIFY_CHAT))
        table.insert(itemSelection[k], createButton(NOTIFY_TOPTEXT))
        table.insert(itemSelection[k], createButton(NOTIFY_NOTIFICATION))

        local authorDefined = (v.xPos == -0.5 and v.yPos == -0.08 and v.xTextAlign == TEXT_ALIGN_CENTER and v.yTextAlign == TEXT_ALIGN_CENTER and v.messageFont == "Trebuchet24")

        if not authorDefined then table.insert(itemSelection[k], createButton(NOTIFY_AUTHOR)) end

        table.insert(itemSelection[k], createButton(NOTIFY_DISABLED, authorDefined and 2 or 1))
    end
end
concommand.Add("customizablenotifications_menu", menuCustomizableNotifications)

hook.Add("Think", "CustomizableNotifications:ShiftKey", function()
    local changed = false
    for _,k in ipairs(CustomizableNotifications.Config.QuickShiftKeys) do
        if input.IsButtonDown(k) then
            CustomizableNotifications.quickShift = true
            changed = true
            break
        end
    end
    if not changed then CustomizableNotifications.quickShift = false end
end)

net.Receive("CustomizableNotifications:Message", function()
    local messageName = net.ReadString()
    local msgData = net.ReadTable()
    local ttColor = net.ReadColor()
    
    local clientMsgSetting = CustomizableNotifications.Notifications[messageName]
    
    if clientMsgSetting == nil then --TODO: Then send a message to the server asking for this varible.
        CustomizableNotifications.pPrint("'" .. messageName .. "' is missing on the client", 2)
        net.Start("CustomizableNotifications:Setup") --TODO: THIS IS A TEMP FIX
        net.SendToServer()
        return 
    end

    local stringOut = ""
    for _,v in ipairs(msgData) do
        if clientMsgSetting.messageType != NOTIFY_CHAT then
            if IsColor(v) then continue end
        end
        stringOut = stringOut .. tostring(v)
    end
    CustomizableNotifications.pPrint("Recieved Message '" .. messageName .. "' with the following arguments: " .. stringOut, 2)
    
    if clientMsgSetting.printInConsole then
        table.insert(msgData, 1, "[" .. clientMsgSetting.displayName .. "] ")
        table.insert(msgData, "\n")
        MsgC(unpack(msgData))
    end
    local sound = clientMsgSetting.soundEnabled and clientMsgSetting.sound or nil 
    if clientMsgSetting.messageType == NOTIFY_TOPTEXT then
        table.insert(messageQueue, clientMsgSetting.setFirst and 1 or #messageQueue == 0 and 1 or #messageQueue,
        {
            xPos        = clientMsgSetting.xPos,
            yPos        = clientMsgSetting.yPos,
            xTextAlign  = clientMsgSetting.xTextAlign,
            yTextAlign  = clientMsgSetting.yTextAlign,
            fadeTime    = clientMsgSetting.fadeTime,
            holdTime    = clientMsgSetting.holdTime,
            messageFont = clientMsgSetting.messageFont,
            sound       = sound,
            color       = ttColor,
            msg         = stringOut
        })
    elseif clientMsgSetting.messageType == NOTIFY_NOTIFICATION then
        notification.AddLegacy(stringOut, clientMsgSetting.notificationType,clientMsgSetting.holdTime)
        if sound then surface.PlaySound(sound) end
    elseif clientMsgSetting.messageType == NOTIFY_CHAT then
        chat.AddText(table.unpack(msgData))
        if sound then surface.PlaySound(sound) end
    end
end)

local displayMessageStopTime
hook.Remove("HUDPaint", "CustomizableNotifications:OnScreenMessage")
hook.Add("HUDPaint", "CustomizableNotifications:OnScreenMessage", function()
    if selectedMessage == nil then
        if #messageQueue != 0 then
            selectedMessage = messageQueue[1]
            table.remove(messageQueue, 1)
        end
    else
        local xPos = selectedMessage["xPos"]
        local yPos = selectedMessage["yPos"]
        local xTextAlign = selectedMessage["xTextAlign"]
        local yTextAlign = selectedMessage["yTextAlign"]
        local fadeTime = selectedMessage["fadeTime"]
        local holdTime = selectedMessage["holdTime"]
        local messageFont = selectedMessage["messageFont"]
        local color = selectedMessage["color"]
        local msg = selectedMessage["msg"]
        local sound = selectedMessage["sound"]

        if selectedMessage["stoptime"] == nil then
            selectedMessage["stoptime"] = CurTime() + holdTime
            if sound then surface.PlaySound(sound) end
        end

        if xPos < 0 then
            xPos = ScrW()*math.abs(xPos)
            selectedMessage["xPos"] = xPos
        end

        if yPos < 0 then
            yPos = ScrH()*math.abs(yPos)
            selectedMessage["yPos"] = yPos
        end

        if selectedMessage["stoptime"] <= CurTime() then
            selectedMessage = nil
        else --TODO: fix to allow multiple colors
            draw.SimpleText(msg, messageFont, xPos, yPos, color, xTextAlign, yTextAlign)
        end
    end
end)

net.Receive("CustomizableNotifications:OpenMenu", function()
    menuCustomizableNotifications()
end)

local setupMoveHappened = false
hook.Add("SetupMove", "CustomizableNotifications:RetrieveNotificationList", function()
    if setupMoveHappened then hook.Remove("SetupMove", "CustomizableNotifications:RetrieveNotificationList") setupMoveHappened = true end
    CustomizableNotifications.pPrint("Retriving Notification List from Server.", 2)
    net.Start("CustomizableNotifications:Setup")
    net.SendToServer()
    hook.Remove("SetupMove", "CustomizableNotifications:RetrieveNotificationList")
end)

net.Receive("CustomizableNotifications:Setup", function() 
    if net.ReadBit() == 0 then
        local messageName = net.ReadString()
        local defaults = net.ReadTable()
        CustomizableNotifications.Notifications[messageName] = defaults
    else
        for k,v in pairs(net.ReadTable()) do
            CustomizableNotifications.Notifications[k] = v
        end
    end
    for k,v in pairs(CustomizableNotifications.Notifications) do
        if FileData[k] != nil then
            if FileData[k].messageType != nil then
                CustomizableNotifications.Notifications[k].messageType = FileData[k].messageType
            end
            if FileData[k].soundEnabled != nil then
                CustomizableNotifications.Notifications[k].soundEnabled = FileData[k].soundEnabled
            end
        end
    end
end)