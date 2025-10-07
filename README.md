DANIELGDM180\_hud Resource (Speed, Seatbelt \& Fuel)

This resource provides a sleek, modern, and highly configurable in-vehicle heads-up display (HUD) for FiveM. It features real-time speed, a dynamic seatbelt system with crash physics, and fuel integration.



✨ Features

Real-time Speedometer: Displays current speed in a clear format.



Dynamic Seatbelt System:



Toggle seatbelt ON/OFF with a configurable keybind.



Plays distinct buckle and unbuckle sounds.



Ejection Physics: Players are violently ejected from the vehicle upon a high-speed collision if the seatbelt is not worn.



Fuel Integration: Displays current fuel level, requiring the LegacyFuel resource as a dependency.



Customizable UI: Players can easily adjust the HUD's scale, vertical position (bottom), and horizontal position (left) through a dedicated NUI settings menu. Settings are saved using KVP storage. /hudsettings



Notifications: Provides clean NUI notifications for seatbelt status changes and ejection events.



🛠️ Dependencies

This resource requires the following external resource to function correctly:



LegacyFuel: Required for the fuel display functionality.



🚀 Installation

Download: Download the resource files.



Place Folder: Place the DANIELGDM180\_hud folder into your server's resources directory.



Start Resource: Add the following line to your server.cfg:



ensure DANIELGDM180\_hud



(Replace DANIELGDM180\_hud with your actual folder name if different).



⚙️ Configuration

All user-configurable settings are located in config.lua.



Variable



Default Value



Description



Config.ToggleSeatbeltKey



'B'



The key used to buckle and unbuckle the seatbelt. Refer to the FiveM Controls page for valid key inputs.



Config.RefreshRate



200



The update frequency (in milliseconds) for the HUD data (speed, fuel). Lower is smoother but more resource-intensive.



🎮 Usage

Keybinds

Action



Key



Location



Toggle Seatbelt



B (Default)



Configured in config.lua



Open/Close HUD Settings



Escape



This is handled internally by the UI and uses the key to close the menu.



Seatbelt Physics

The seatbelt is OFF by default when you enter a vehicle. You must buckle up to prevent being ejected in a crash.



Customizing the HUD Position

The HUD's position and scale are saved automatically per user. You can adjust the settings by using the in-game UI menu, which is toggled when the player opens and closes it using the Escape key.

