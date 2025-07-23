FiveM DANIELGDM180_hud
A comprehensive and customizable car HUD script for FiveM, featuring speed, fuel, gear, RPM, seatbelt status, and integrated cruise control. This resource aims to provide a clean and informative display for players while driving.

Features
Dynamic HUD: Displays real-time speed (MPH), current gear, RPM, and fuel level.

Seatbelt System:

Toggleable seatbelt with configurable keybind.

Visual and audio feedback for buckling/unbuckling.

Player ejection on hard impacts if the seatbelt is off.

Notifications for seatbelt status changes.

Cruise Control:

Toggleable cruise control with configurable keybind.

Sets current speed as cruise speed.

Maintains set speed automatically.

Notifications for activation/deactivation and speed setting.

Customizable HUD Position & Scale: In-game menu to adjust the HUD's vertical position, horizontal position, and overall scale. Settings are saved.

Notifications System: Custom in-game notifications for various events (seatbelt, cruise control, settings saved/reset).

Optimized: Configurable refresh rate for HUD updates to balance performance and smoothness.

Dependencies: Integrates with LegacyFuel for fuel display.

Installation
Download: Download the latest release from the GitHub repository

Extract: Extract the contents of the archive into your FiveM resources folder.

Rename: Ensure the folder is named something like DANIELGDM180_hud (or the name specified in fxmanifest.lua).

Add to server.cfg: Add ensure DANIELGDM180_hud (or your chosen folder name) to your server.cfg file.

Dependencies: Make sure you have LegacyFuel installed and running on your server. If not, you can find it on the FiveM forums or GitHub.

ensure LegacyFuel https://github.com/InZidiuZ/LegacyFuel
ensure DANIELGDM180_hud

Configuration
The main configuration file is config.lua. You can adjust keybinds and refresh rates here.

config.lua:

-- config.lua
-- This file is used to configure keybinds for the car HUD script.

Config = {}

-- Keybind for toggling the seatbelt
-- Default: "B" (keyboard)
-- You can find a list of FiveM keybinds here: https://docs.fivem.net/docs/game-references/controls/
Config.ToggleSeatbeltKey = 'B'

-- Refresh rate for the HUD updates in milliseconds
-- A lower value means more frequent updates (smoother but more resource intensive)
-- A higher value means less frequent updates (less smooth but less resource intensive)
-- Default: 200 (5 frames per second)
Config.RefreshRate = 200

Config.ToggleSeatbeltKey: Change 'B' to your desired key for toggling the seatbelt. Refer to the FiveM Controls documentation for a list of valid keybinds.

Config.RefreshRate: Adjust this value to control how often the HUD updates. Lower values (e.g., 100) provide smoother updates but use more resources. Higher values (e.g., 500) use fewer resources but updates will be less frequent.

Usage
Toggle Seatbelt: Press the configured Config.ToggleSeatbeltKey (default: B). You will hear a buckle/unbuckle sound and receive a notification.

Open HUD Settings: Use the command /hudsettings in chat. This will open a UI where you can adjust the HUD's scale and position.

Save: Click "Save" to apply and persist your HUD settings.

Reset: Click "Reset" to revert HUD settings to their default values.

Close: Click "Close" or press Escape or T to close the settings menu.

Cruise Control: Press the configured toggleKey (default: G in CruiseControl.lua - note this is currently the same as setSpeedKey).

The first press activates cruise control and sets the speed to your current vehicle speed.

A subsequent press deactivates cruise control.

You will receive notifications indicating the status.

Credits
Author: DANIELGDM180

Dependencies:

LegacyFuel (for fuel system integration)

Troubleshooting
HUD not appearing:

Ensure the resource is properly ensured in your server.cfg.

Check the FiveM console for any errors related to DANIELGDM180_hud.

Verify LegacyFuel is running correctly.

Keybinds not working:

Double-check config.lua for the correct keybinds.

Ensure there are no conflicting keybinds from other resources.

HUD settings not saving:

Ensure your server allows KVP (Key-Value Pair) storage.

Check the client console for any NUI callback errors.