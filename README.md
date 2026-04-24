🚗 DANIELGDM180\_hud

A lightweight, modern vehicle HUD for FiveM featuring a seatbelt system with ejection physics, fuel and engine health displays, and an in-game customization menu. Built for performance and clean aesthetics using ox\_lib and LegacyFuel.



✨ Features

🚘 Smart HUD: Only appears when inside a vehicle.



⛓️ Seatbelt System:



Toggleable with a configurable keybind.



Prevents accidental vehicle exiting while buckled.



Ejection Physics: High-speed impacts without a seatbelt will launch the player through the windshield into a ragdoll state.



📊 Comprehensive Display:



Speedometer (MPH).



Gear Indicator \& RPM.



Fuel Level (LegacyFuel integration).



Engine Health Bar.



🛠️ In-Game Settings: Customize the HUD scale, vertical, and horizontal positioning via a NUI menu.



🔊 Immersive Audio: Custom buckle and unbuckle sound effects.



🧠 Optimized:



Configurable refresh rates.



Automatically hides when the pause menu or map is open.



Uses KVP to save your custom HUD layout across sessions.



📦 Dependencies

To use this resource, you must have the following installed:



ox\_lib https://github.com/CommunityOx/ox\_lib (For notifications)



LegacyFuel https://github.com/Drift91/LegacyFuelEdit (For fuel data)



🛠 Installation

Download or clone this repository.



Place the DANIELGDM180\_hud folder into your server's resources directory.



Add the following to your server.cfg:



Code snippet

ensure ox\_lib

ensure LegacyFuel

ensure DANIELGDM180\_hud

Restart your server.



⚙️ Configuration

Open config.lua to tweak the script to your liking:



Seatbelt Keybind: Config.ToggleSeatbeltKey (Default: 'B')



Settings Keybind: Config.HUDSettings (Set this to a key to open the customization menu)



Refresh Rate: Config.RefreshRate (Default: 100ms). Lower = smoother; Higher = better performance.



🎮 Commands

/toggleSeatbelt - Manually buckle/unbuckle (Bound to 'B' by default).



/hudsettings - Opens the UI menu to adjust the HUD position and scale.



📁 File Structure

Plaintext

DANIELGDM180\_hud/

├── fxmanifest.lua

├── config.lua        # Main configuration

├── README.md

├── client/

│   └── client.lua    # Main logic \& physics

└── html/

&#x20;   ├── ui.html       # HUD \& Settings Menu

&#x20;   ├── fuel-icon.png

&#x20;   ├── engine-icon.png

&#x20;   └── sounds/

&#x20;       ├── buckle.ogg

&#x20;       └── unbuckle.ogg

🧪 Framework Support

This script is Standalone. It does not require ESX or QBCore, though it is fully compatible with both.



👤 Author

DANIELGDM180



📜 License

Free to use and modify for personal or server use. Do not resell without permission.

