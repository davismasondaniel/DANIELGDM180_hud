local seatbeltOn = false
local lastSeatbeltStatus = false -- New variable to track the last sent seatbelt status

-- Default HUD settings
local defaultHudSettings = {
    scale = 1.0,
    bottom = 5,
    left = 90
}

-- Current HUD settings, loaded from KVP or default
local currentHudSettings = {}

-- Function to send a notification
local function sendNotification(message, type)
    SendNUIMessage({
        type = "notification",
        message = message,
        notificationType = type or "info" -- Default to 'info' if no type is provided
    })
end

-- Function to load HUD settings from KVP
local function loadHudSettings()
    local savedSettings = GetResourceKvpString("hud_settings")
    if savedSettings then
        currentHudSettings = json.decode(savedSettings)
        -- Ensure all keys exist, use default if not
        currentHudSettings.scale = currentHudSettings.scale or defaultHudSettings.scale
        currentHudSettings.bottom = currentHudSettings.bottom or defaultHudSettings.bottom
        currentHudSettings.left = currentHudSettings.left or defaultHudSettings.left
    else
        currentHudSettings = defaultHudSettings
    end
    -- Send loaded settings to UI immediately
    SendNUIMessage({
        type = "applySettings",
        settings = currentHudSettings
    })
end

-- Function to save HUD settings to KVP
local function saveHudSettings(settings)
    SetResourceKvp("hud_settings", json.encode(settings))
    currentHudSettings = settings
    sendNotification("HUD settings saved!", "success")
end

-- Function to reset HUD settings to default
local function resetHudSettings()
    SetResourceKvp("hud_settings", json.encode(defaultHudSettings))
    currentHudSettings = defaultHudSettings
    sendNotification("HUD settings reset to default!", "info")
end

-- Register command to toggle seatbelt
RegisterCommand("toggleSeatbelt", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    -- Only allow toggling if in a vehicle
    if IsPedInAnyVehicle(ped, false) then
        seatbeltOn = not seatbeltOn
        -- Only send seatbelt message and play sound if the status actually changed by the toggle command
        if seatbeltOn ~= lastSeatbeltStatus then
            SendNUIMessage({
                type = "seatbelt",
                status = seatbeltOn,
                playSound = seatbeltOn and "buckle" or "unbuckle"
            })
            lastSeatbeltStatus = seatbeltOn

            -- Add notification here
            if seatbeltOn then
                sendNotification("Seatbelt ON", "success")
            else
                sendNotification("Seatbelt OFF", "error")
            end
        end
    end
end, false)

-- Use the keybind from config.lua for seatbelt
RegisterKeyMapping("toggleSeatbelt", "Toggle Seatbelt", "keyboard", Config.ToggleSeatbeltKey)

-- Register command to open HUD settings menu
RegisterCommand("hudsettings", function()
    SetNuiFocus(true, true) -- Set NUI focus to true to allow interaction with the UI
    SendNUIMessage({
        type = "openSettings",
        settings = currentHudSettings -- Send current settings to populate sliders
    })
end, false)

-- Register key mapping for HUD settings (e.g., 'T' or 'F1' - adjust in config if needed)
--RegisterKeyMapping("hudsettings", "Open HUD Settings", "keyboard", "F10")

-- NUI Callbacks
RegisterNuiCallback("saveHudSettings", function(data, cb)
    saveHudSettings(data)
    cb('ok') -- Respond to the NUI callback
end)

RegisterNuiCallback("resetHudSettings", function(data, cb)
    resetHudSettings()
    cb('ok') -- Respond to the NUI callback
end)

RegisterNuiCallback("closeUI", function(data, cb)
    SetNuiFocus(false, false) -- Release NUI focus when UI is closed
    cb('ok')
end)

RegisterNuiCallback("uiReady", function(data, cb)
    -- This callback is fired when the UI is ready to receive messages
    loadHudSettings() -- Load and apply settings as soon as UI is ready
    cb('ok')
end)

-- Main HUD update loop
CreateThread(function()
    while true do
        Wait(Config.RefreshRate) -- Use Config.RefreshRate for HUD updates
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        -- Check if the ped is in *any* seat of a vehicle
        if IsPedInAnyVehicle(ped, false) then
            local speed = math.floor(GetEntitySpeed(vehicle) * 2.23694)
            -- Ensure LegacyFuel is available, otherwise this will error.
            -- If LegacyFuel is not always present, you might want to add a check like:
            -- local fuel = exports["LegacyFuel"] and exports["LegacyFuel"]:GetFuel(vehicle) or 100 -- Default to 100 if not available
            local fuel = exports["LegacyFuel"]:GetFuel(vehicle)
            local gear = GetVehicleCurrentGear(vehicle) -- Get the current gear
            local rpm = math.floor(GetVehicleCurrentRpm(vehicle) * 10000) -- Get the current RPM and convert to a more readable number (0-10000)

            SendNUIMessage({
                type = "hud",
                display = true,
                speed = speed,
                fuel = fuel,
                seatbelt = seatbeltOn,
                cruise = cruiseOn, -- Assuming cruiseOn is defined elsewhere if used
                gear = gear, -- Add gear to the message
                rpm = rpm -- Add RPM to the message
            })
        else
            SendNUIMessage({type = "hud", display = false})
        end
    end
end)

local wasInVehicle = false
local lastSpeed = 0

-- Seatbelt and ejection logic
CreateThread(function()
    while true do
        Wait(100)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if IsPedInAnyVehicle(ped, false) then
            wasInVehicle = true
            local currentSpeed = GetEntitySpeed(vehicle)

            -- Prevent player from exiting vehicle if seatbelt is on
            if seatbeltOn then
                DisableControlAction(0, 75, true) -- Disable "Leave Vehicle" control (0 is for INPUTGROUP_VEHICLE, 75 is INPUT_VEHICLE_EXIT)
            end

            -- Eject player if seatbelt is off and there's a rapid deceleration
            if not seatbeltOn and currentSpeed < lastSpeed - 10.0 and lastSpeed > 20.0 then
                local coords = GetEntityCoords(ped)
                local forwardVector = GetEntityForwardVector(vehicle)
                TaskLeaveVehicle(ped, vehicle, 16)
                Wait(200)
                SetEntityCoords(ped, coords.x + forwardVector.x, coords.y + forwardVector.y, coords.z - 0.5)
                SetEntityVelocity(ped, forwardVector.x * lastSpeed, forwardVector.y * lastSpeed, 0.0)
                sendNotification("You were ejected from the vehicle!", "warning") -- Notification for ejection
            end

            lastSpeed = currentSpeed
        else
            if wasInVehicle then
                -- Only set seatbeltOn to false and play sound if it was previously on
                if seatbeltOn then
                    seatbeltOn = false
                    SendNUIMessage({
                        type = "seatbelt",
                        status = seatbeltOn,
                        playSound = "unbuckle"
                    })
                    lastSeatbeltStatus = seatbeltOn
                    sendNotification("Seatbelt OFF (Left Vehicle)", "error") -- Notification when leaving vehicle with seatbelt on
                end
            end
            wasInVehicle = false
            lastSpeed = 0
        end
    end
end)

-- Initial load of HUD settings when the script starts
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        -- We need to wait for the UI to be ready before sending settings
        -- The "uiReady" NUI callback will trigger loadHudSettings
    end
end)
