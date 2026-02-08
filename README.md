🚗 DANIELGDM180_hud (Seatbelt + Fuel)

A lightweight and modern vehicle HUD for FiveM featuring a seatbelt system, fuel display, and clean UI with sound effects. Built with ox_lib notifications and LegacyFuel integration.

✨ Features

🚘 Vehicle HUD (only shows while in a vehicle)

⛓️ Seatbelt system with toggle key

🔊 Buckle / unbuckle sound effects

⛽ Fuel display (LegacyFuel support)

🧠 Optimized refresh rate (configurable)

📐 Adjustable HUD positioning & scale

⏸️ Automatically hides HUD when pause/map is open

🔔 ox_lib notifications

📦 Dependencies

This resource requires the following:

ox_lib

LegacyFuel

Make sure both are started before this resource.

ensure ox_lib
ensure LegacyFuel
ensure DANIELGDM180_hud

🛠 Installation

Download or clone this repository

Place the folder in your resources directory
Example:

resources/DANIELGDM180_hud


Add the resource to your server.cfg:

ensure DANIELGDM180_hud


Restart your server

⚙️ Configuration

All configuration is handled in config.lua.

Seatbelt Keybind
Config.ToggleSeatbeltKey = 'B'


Change 'B' to any valid FiveM control key.

HUD Refresh Rate
Config.RefreshRate = 200


Lower value = smoother updates (more CPU usage)

Higher value = better performance (less smooth)

🧠 HUD Behavior

HUD only appears when the player is inside a vehicle

HUD hides automatically when:

Pause menu is open

Map is open

Seatbelt status is synced to the UI only when it changes (performance-friendly)

🔊 Included Assets

fuel-icon.png – fuel indicator icon

buckle.ogg – seatbelt on sound

unbuckle.ogg – seatbelt off sound

All assets are loaded via ui.html.

📁 File Structure
DANIELGDM180_hud/
│
├── fxmanifest.lua
├── config.lua
├── client/
│   └── client.lua
└── html/
    ├── ui.html
    ├── fuel-icon.png
    └── sounds/
        ├── buckle.ogg
        └── unbuckle.ogg

🧪 Framework Support

✅ Standalone

✅ ESX

✅ QBCore
(No framework dependency — works client-side)

👤 Author

DANIELGDM180

📜 License

Free to use and modify for personal or server use.
Do not resell without permission.