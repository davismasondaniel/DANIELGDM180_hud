# DANIELGDM180_hud 2.0

Custom FiveM vehicle HUD by **DANIELGDM180**. Circular speedometer with RPM arc and gear indicator, fuel/engine side panel with a live odometer, a seatbelt system with ejection-on-crash, and an in-game HUD settings menu with saved positioning.

## Features

- **Speedometer** — analog gauge (mph) with tick marks, sweeping needle, and center digital readout.
- **RPM arc** — glowing arc around the gauge edge that fills with engine RPM.
- **Gear indicator** — shows current gear, `R` for reverse, `P` for park/neutral.
- **Fuel bar** — live fuel percentage via `LegacyFuel`.
- **Engine health bar** — live engine health percentage, turns red below 30%.
- **Live odometer** — per-vehicle mileage via `jg-vehiclemileage`, in miles or km depending on that resource's configured unit.
- **Seatbelt system**
  - Toggle with a configurable keybind (default `B`).
  - Buckle/unbuckle sound effects.
  - Locks you in the vehicle while buckled (disables the exit control).
  - If unbuckled and the vehicle decelerates hard (crash), you're ejected and ragdolled.
  - Auto-unbuckles (with notification) when you leave the vehicle.
- **HUD settings menu** — in-game sliders for scale, and vertical/horizontal position, opened with a configurable keybind. Settings persist across sessions via KVP.
- **Pause-menu aware** — HUD hides automatically when the pause menu/map is open.
- Optimized NUI updates: the UI only touches the DOM when a value actually changes, avoiding unnecessary CEF repaints/flicker.

## Dependencies

- [`ox_lib`](https://github.com/overextended/ox_lib)
- [`LegacyFuel`](https://github.com/Drift91/LegacyFuelEdit)
- [`jg-vehiclemileage`] use this one if vMenu (https://github.com/davismasondaniel/jg-vehiclemileage) or (https://github.com/jgscripts/jg-vehiclemileage)

Make sure all three are installed and started **before** this resource in your `server.cfg`.

## Installation

1. Drop this resource folder into your server's `resources` directory.
2. Add to `server.cfg`:
   ```
   ensure ox_lib
   ensure LegacyFuel
   ensure jg-vehiclemileage
   ensure DANIELGDM180_hud
   ```
3. Confirm the folder layout matches what `fxmanifest.lua` expects:
   ```
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
4. Restart the resource.

## Configuration

All settings are in `config.lua`:

| Setting | Default | Description |
|---|---|---|
| `Config.ToggleSeatbeltKey` | `'B'` | Keybind to toggle the seatbelt |
| `Config.RefreshRate` | `100` (ms) | How often the HUD data updates (lower = smoother, more resource usage) |
| `Config.HUDSettings` | `''` (unbound) | Keybind to open the HUD position/scale settings menu |
| `Config.KvpKey` | `'hud_settings'` | KVP key used to persist saved HUD position/scale |
| `Config.DefaultHudSettings` | `{scale=0.8, bottom=3, left=92}` | Default/reset HUD position and scale |

Players can rebind both keys themselves in FiveM's Keybind settings (under the resource's mapped controls).

## Commands / Keybinds

| Action | Default Key | Notes |
|---|---|---|
| Toggle seatbelt | `B` | Only works while in a vehicle |
| Open HUD settings | Unbound | Set `Config.HUDSettings` or rebind in-game |

In the HUD settings menu:
- **Scale**, **Bottom position**, **Left position** sliders adjust the HUD live.
- **Save** persists your settings (stored via KVP, survives restarts).
- **Reset** restores the default position/scale.
- `Esc` or `T` also closes the menu.

## How it works

- `client/client.lua` runs a loop every `Config.RefreshRate` ms that reads vehicle speed, fuel (`LegacyFuel`), engine health, RPM, gear, and mileage (`jg-vehiclemileage`), then pushes it to the NUI via `SendNUIMessage`.
- `html/ui.html` renders the gauge/panels and only updates DOM elements whose values actually changed, to minimize CEF repaint flicker.
- Seatbelt state is tracked client-side; the "leave vehicle" control is disabled while buckled, and a hard-deceleration check while unbuckled triggers an ejection + ragdoll.
- HUD position/scale settings are saved to a resource KVP (`hud_settings`) and reapplied on UI load.

## Credits

Developed by **DANIELGDM180** for the DANIELGDM180 Server.
