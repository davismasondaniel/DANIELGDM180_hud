# DANIELGDM180_hud 2.0

Vehicle HUD — circular speedometer/RPM gauge, fuel and engine health bars, live odometer, gear indicator, and a seatbelt/ejection system. Red/black cyberpunk theme.

## Features

- **Circular gauge cluster** — speed readout with an RPM sweep ring (ticks labeled in thousands of RPM), gear indicator (auto-detects `R` vs `N` from velocity, since gear `0` covers both).
- **Fuel bar** — pulled from `LegacyFuel`.
- **Engine health bar** — pulled from the vehicle's engine health; turns red under 30%.
- **Live odometer** — pulled from `jg-vehiclemileage`, auto-detects miles/km and refreshes every 500ms (decoupled from the main HUD refresh rate).
- **Seatbelt system** — toggle key, blocks vehicle exit while buckled, and ejects the player (with ragdoll) on rapid deceleration while unbuckled.
- **HUD settings menu** — in-game sliders for scale, vertical, and horizontal position, saved per-player via KVP and restored on join.
- **Pause-menu aware** — HUD hides automatically when the pause menu/map is open.
- **Performance-conscious client** — single merged thread for HUD push + seatbelt/ejection logic, NUI messages only sent when a displayed value actually changes, cached export handles.

## Dependencies

- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`LegacyFuel`](https://github.com/Drift91/LegacyFuelEdit)
- [jg-vehiclemileage] use this one if vMenu (https://github.com/davismasondaniel/jg-vehiclemileage) or (https://github.com/jgscripts/jg-vehiclemileage)

## Installation

1. Copy this resource into your server's `resources` folder as `DANIELGDM180_hud`.
2. Make sure `ox_lib`, `LegacyFuel`, and `jg-vehiclemileage` are installed and started **before** this resource.
3. Add to your `server.cfg`:
   ```
   ensure ox_lib
   ensure LegacyFuel
   ensure jg-vehiclemileage
   ensure DANIELGDM180_hud
   ```
4. Restart the resource or your server.

## Configuration (`config.lua`)

| Setting | Default | Description |
|---|---|---|
| `Config.ToggleSeatbeltKey` | `'B'` | Keybind to toggle the seatbelt. |
| `Config.HUDSettings` | `''` (unbound) | Keybind to open the HUD settings menu. |
| `Config.RefreshRate` | `100` (ms) | HUD data push interval. Lower = smoother, more resource intensive. |
| `Config.KvpKey` | `'DANIELGDM180_hud_hud_settings'` | KVP namespace used to persist each player's HUD position/scale. |
| `Config.DefaultHudSettings` | `scale 0.80, bottom 2, left 91` | Default HUD position/scale on first run and when a player hits "Reset" in the settings menu. |

## Commands & Keybinds

| Command | Default Key | Description |
|---|---|---|
| `toggleSeatbelt` | `B` | Buckle/unbuckle the seatbelt (only while in a vehicle). |
| `hudsettings` | Unbound | Opens the HUD position/scale settings menu. `Esc` or `T` closes it. |

Both are registered with `RegisterKeyMapping`, so players can also rebind them from FiveM's native keybind settings.

## How it works

- `client/client.lua` runs a single merged thread that polls vehicle state (speed, RPM, fuel, engine health, gear/reverse, mileage) at `Config.RefreshRate` and pushes changed values to the NUI via `SendNUIMessage`. It also handles seatbelt-based exit blocking and the ejection-on-crash logic.
- `html/ui.html` renders the gauge cluster and side panel, plays the buckle/unbuckle sounds, and hosts the settings menu, which posts back to the client via NUI callbacks (`saveHudSettings`, `resetHudSettings`, `closeUI`, `uiReady`).
- HUD position/scale are persisted per-player with `SetResourceKvp`/`GetResourceKvpString` and reapplied automatically when the resource starts.

## File structure

```
DANIELGDM180_hud/
├── fxmanifest.lua
├── config.lua
├── client/
│   └── client.lua
└── html/
    ├── ui.html
    ├── fuel-icon.png
    ├── engine-icon.png
    └── sounds/
        ├── buckle.ogg
        └── unbuckle.ogg
```

## Credits

Developed by **DANIELGDM180**.
