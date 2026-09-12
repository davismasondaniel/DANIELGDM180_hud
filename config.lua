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
-- Default: 100 (10 frames per second)
Config.RefreshRate = 100

-- Keybind for toggling the HUDSetting
-- Default: "" (keyboard)
-- You can find a list of FiveM keybinds here: https://docs.fivem.net/docs/game-references/controls/
Config.HUDSettings = ''

-- KVP key used to persist HUD position/scale settings (per-player, via SetResourceKvp)
-- Change this if it clashes with another resource's KVP namespace
Config.KvpKey = 'DANIELGDM180_hud_hud_settings'

-- Default HUD position/scale, used on first run and by the "Reset" button in the settings menu
Config.DefaultHudSettings = {
    scale = 0.84,
    bottom = 2,
    left = 91
}