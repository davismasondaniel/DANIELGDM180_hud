# DANIELGDM180_hud

A lightweight, customizable vehicle HUD for FiveM built with `ox_lib` and `LegacyFuel`. Displays live speed, gear, RPM, fuel, engine health, and seatbelt status in a red/black scanline-styled readout, with a seatbelt/ejection system and a drag-free, slider-based position/scale editor.

## Features

- **Live vehicle readout** — MPH, gear, RPM, fuel %, and engine health %, updated on a configurable refresh rate.
- **Seatbelt system**
  - Toggle with a keybind (default `B`).
  - Blocks exiting the vehicle while buckled.
  - Automatically unbuckles (with sound + notification) on leaving the vehicle.
  - Ejects the driver with a ragdoll if unbuckled and the vehicle decelerates sharply (crash detection).
  - Buckle/unbuckle sound effects.
- **HUD auto-hide** — HUD disappears while the pause menu / map is open, and reappears automatically.
- **In-game HUD settings menu**
  - Adjustable scale, vertical position, and horizontal position via sliders.
  - Settings are saved per-player using KVP storage and persist across sessions.
  - Reset-to-default option.
- **ox_lib notifications** for seatbelt state, HUD saves, and resets.
- Styled UI: red/black DANIELGDM180 theme, `Share Tech Mono` font.

## Dependencies

- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`LegacyFuel`](https://github.com/Drift91/LegacyFuelEdit)

## Installation

1. Drop the resource folder into your server's `resources` directory as `DANIELGDM180_hud`.
2. Ensure `ox_lib` and `LegacyFuel` (or your fuel resource) are installed and started **before** this resource.
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure LegacyFuel
   ensure DANIELGDM180_hud
   ```
4. Restart your server or run `refresh` + `ensure DANIELGDM180_hud`.

## File Structure

```
DANIELGDM180_hud/
├── client/
│   └── client.lua
├── config.lua
├── fxmanifest.lua
└── html/
    ├── ui.html
    ├── engine-icon.png
    ├── fuel-icon.png
    └── sounds/
        ├── buckle.ogg
        └── unbuckle.ogg
```

> **Note:** `fxmanifest.lua` currently references `client/client.lua` and `html/ui.html` — make sure your files sit in matching subfolders (`client/` and `html/`), or update the manifest paths to match your layout.

## Configuration (`config.lua`)

| Setting | Description | Default |
|---|---|---|
| `Config.ToggleSeatbeltKey` | Keybind to toggle the seatbelt | `'B'` |
| `Config.RefreshRate` | HUD update interval in ms (lower = smoother, more resource use) | `100` |
| `Config.HUDSettings` | Keybind to open the HUD settings menu | `''` (unbound — bind via FiveM keybind settings or set a key here) |

## Commands / Keybinds

| Action | Default Key | Notes |
|---|---|---|
| Toggle seatbelt | `B` | Rebindable in-game (Settings → Key Bindings → FiveM) |
| Open HUD settings | Unbound | Set `Config.HUDSettings` or bind manually |

## HUD Settings Menu

Open with the `hudsettings` command/keybind. From the menu you can:
- **Scale** — 50%–150%
- **Vertical Position** — 0%–95% from bottom
- **Horizontal Position** — 5%–95% from left

Click **Save** to persist your layout (stored via KVP, so it survives restarts), **Reset** to restore defaults, or **Close**/`Esc` to exit without changes.

## Credits

Developed by **DANIELGDM180** for the DANIELGDM180 Server.
