# CustomizableNotifications

[![Latest Version](https://img.shields.io/github/release/RyanTheTechMan/CustomizableNotifications.svg?style=flat-square)](https://github.com/RyanTheTechMan/CustomizableNotifications/releases)
[![Software License](https://img.shields.io/badge/license-CC--BY--SA--4.0-brightgreen.svg?style=flat-square)](https://github.com/RyanTheTechMan/CustomizableNotifications/blob/master/LICENSE.md)
![GitHub repo size](https://img.shields.io/github/repo-size/RyanTheTechMan/CustomizableNotifications?label=Size&style=flat-square)

**CustomizableNotifications** is a Garry's Mod Addon that allows you to let the CLIENTS take control of how notifications appear.

## Features

-   Simple Setup for Server Owners
-   Simple Global Varibles
-   Beautiful Client Interface
-   Copy/Paste Examples

## In-Game Screen Shots
--To Be Added

## Install
Download the latest release by [clicking here](https://github.com/RyanTheTechMan/CustomizableNotifications/releases/latest/download/customizable_notifications.zip) then extracting the zip into your Garry's Mod

## Usage (Developer Info)
### Basic Overview
Read Information in the `Using NotifySetup()` and `Using NotifyPlayer()` groups. It looks complicated, but it is pretty simple :)

### Using NotifySetup()
Usage:
```lua
NotifySetup(string uniqueIdentifier, string displayName, table default)
```
#### Info:
The NotifySetup function allows you to define a unique identifyer, show what the client sees the identifyer as, as well as defining the defaults for the notification.

If `displayName` is not given the `uniqueIdentifier` is used.

You can only create a `uniqueIdentifier` that has not been created before. Don't worry, you can still send messages in any lua file even if you didn't use `NotifySetup()` in it.

#### How To:
In order to set up the notifications paste the following code at the top of a lua file within `<addon>/autorun/` or `<addon>/autorun/server/`:
```lua
if SERVER then
  local notifySetupA
  local notifySetupB = function()
    if (not NotifySetup) then timer.Simple(1, notifySetupA()) else
      --TODO: Add NotifySetup() here 
    end
  end
  notifySetupA = function() notifySetupB() end
  notifySetupA()
end
```

The default table **MUST** include a messageType. Message types include `NOTIFY_TOPTEXT`, `NOTIFY_NOTIFICATION`, & `NOTIFY_CHAT`
```lua
messageType [number]
	ex: NOTIFY_TOPTEXT, NOTIFY_NOTIFICATION, NOTIFY_CHAT

holdTime [float] (NOTIFY_TOPTEXT, NOTIFY_NOTIFICATION)
	Default: 10
	The amount of time for the text stay visible on screen.

notificationType [NOTIFY] (NOTIFY_NOTIFICATION)
	Default: NOTIFY_GENERIC
	The notification type to be displayed.

fadeTime [float] (NOTIFY_TOPTEXT)
	Default: 0.25
	The amount of time for the text to fade in or out.

xPos [float] (NOTIFY_TOPTEXT)
	Default: -0.5 (meaning Center of screen)
	If value is -1 to 0 the number is used by a percentage of the screen.

yPos [float] (NOTIFY_TOPTEXT)
	If value is -1 to 0 the number is used by a percentage of the screen.
	Default: -0.08 (around an inch form the top of screen)

xTextAlign [TEXT_ALIGN] (NOTIFY_TOPTEXT)
	Default: TEXT_ALIGN_CENTER

yTextAlign [TEXT_ALIGN] (NOTIFY_TOPTEXT)
	Default: TEXT_ALIGN_CENTER

messageFont [string] (NOTIFY_TOPTEXT)
	Default: "Trebuchet24"
	The font to use for displaying the text.

setFirst [bool] (NOTIFY_TOPTEXT) (NOTIFY_TOPTEXT)
	Default: false
	Forces the text to apprear infront of all of the other items in the list.
```

**Keep in mind, even if you didn't pick `NOTIFY_TOPTEXT` you can still set defaults since a client may decide to use Top Text on their side.**

### Examples
```lua
NotifySetup("CoolAddon:EpicTest", "Some Cool Thing", {messageType = NOTIFY_CHAT})
NotifySetup("shield", "Shield", {messageType = NOTIFY_TOPTEXT, yPos = -0.5, holdTime = 12})
NotifySetup("test12444", "Just A Test", {messageType = NOTIFY_NOTIFICATION, xPos = 10, xTextAlign = TEXT_ALIGN_LEFT, messageFont = Trebuchet18, setFirst = true, holdTime = 5})
NotifySetup("everything", "Default", {messageType = NOTIFY_CHAT, holdTime = 10, notificationType = NOTIFY_GENERIC, fadeTime = 0.25, xPos = -0.5, yPos = -0.08, xTextAlign = TEXT_ALIGN_CENTER, yTextAlign = TEXT_ALIGN_CENTER, messageFont = "Trebuchet24", setFirst = false})
```

### Using NotifyPlayer()
Usage:
```lua
NotifyPlayer(Player ply, string uniqueIdentifier, table/string message, <Color> topTextColor)
```
The NotifyPlayer function is what you use to send a message to the player.

#### Info:
If the player is `nil` it will send the message to all players.

#### How To:
-- To Be Added

## Why is it free?
I feel since this is a developer tool, it shouldn't be put up for money. This is a tool everyone can use for the greater good.

## I want to help!
Okay! Just make a fork of the repository and make a pull request and I will be sure to check out your additions.
