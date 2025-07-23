-- FiveM Cruise Control Script

-- Global variables for cruise control state
local cruiseControlActive = false
local cruiseSpeed = 0.0 -- Stores the target speed for cruise control

-- Configuration
local toggleKey = 58 -- Default key for toggling cruise control (G)
local setSpeedKey = 58 -- Default key for setting current speed (G) - Now same as toggleKey
local notificationDuration = 3000 -- Duration of notifications in milliseconds

-- Function to display a notification
-- text: The message to display
-- duration: How long the message should be visible (in milliseconds)
local function showNotification(text, duration)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
    -- You might want to clear the notification after a duration, but FiveM's native
    -- DrawNotification handles basic display. For more advanced control, you'd need
    -- to use a custom UI or more complex native functions.
end

-- Function to get the current vehicle speed in KM/H
-- vehicle: The vehicle entity
local function getVehicleSpeed(vehicle)
    -- GetEntitySpeed returns speed in meters per second (m/s)
    -- To convert to KM/H, multiply by 3.6 (m/s * 3600 s/hr / 1000 m/km)
    return GetEntitySpeed(vehicle) * 3.6
end

-- Function to set the vehicle speed for cruise control
-- vehicle: The vehicle entity
-- targetSpeed: The desired speed in KM/H
local function setVehicleCruiseSpeed(vehicle, targetSpeed)
    local currentSpeed = getVehicleSpeed(vehicle)

    -- If the current speed is significantly lower than the target, apply throttle
    if currentSpeed < targetSpeed - 1.0 then -- -1.0 for a small buffer
        SetVehicleThrottle(vehicle, 1.0) -- Full throttle
    -- If the current speed is significantly higher than the target, apply brake or reduce throttle
    elseif currentSpeed > targetSpeed + 1.0 then -- +1.0 for a small buffer
        SetVehicleBrake(vehicle, 1.0) -- Apply brake
    else
        -- If close to target speed, try to maintain it with partial throttle
        -- This is a simple approach; more advanced systems might use PID controllers
        SetVehicleThrottle(vehicle, 0.5) -- Half throttle to maintain
        SetVehicleBrake(vehicle, 0.0) -- Release brake
    end
end

-- Main game loop for cruise control
CreateThread(function()
    while true do
        Wait(0) -- Wait a small amount of time to prevent script from hogging CPU

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        -- Check if the player is in a vehicle and cruise control is active
        if IsPedInAnyVehicle(playerPed, false) and cruiseControlActive then
            -- Disable vehicle controls to prevent player interference
            DisableControlAction(0, 71, true) -- Disable accelerate
            DisableControlAction(0, 72, true) -- Disable brake

            -- Apply the cruise control speed
            setVehicleCruiseSpeed(vehicle, cruiseSpeed)

            -- Display current cruise speed on screen
            -- This is a very basic display. For a better UI, consider using Scaleform or NUI.
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropShadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("Cruise Control: ON (~g~" .. math.floor(cruiseSpeed) .. " KM/H~w~)")
            DrawText(0.7, 0.9) -- Position on screen (X, Y)
        end
    end
end)

-- Keybind for toggling cruise control (G by default)
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustReleased(0, toggleKey) then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                if not cruiseControlActive then
                    -- If cruise control is off, activate it
                    cruiseControlActive = true
                    -- Set the initial cruise speed to the current vehicle speed
                    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                    cruiseSpeed = getVehicleSpeed(currentVehicle)
                    showNotification("Cruise Control ~g~ACTIVATED~w~ at ~b~" .. math.floor(cruiseSpeed) .. " KM/H~w~", notificationDuration)
                else
                    -- If cruise control is on, deactivate it
                    cruiseControlActive = false
                    showNotification("Cruise Control ~r~DEACTIVATED~w~", notificationDuration)
                    -- Re-enable controls and reset throttle/brake
                    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                    if DoesEntityExist(currentVehicle) then
                        SetVehicleThrottle(currentVehicle, 0.0)
                        SetVehicleBrake(currentVehicle, 0.0)
                    end
                end
            else
                showNotification("~r~You must be in a vehicle to use cruise control.~w~", notificationDuration)
            end
        end
    end
end)

-- Keybind for setting current speed as cruise speed (G by default, now same as toggleKey)
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustReleased(0, setSpeedKey) then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                cruiseSpeed = getVehicleSpeed(currentVehicle)
                cruiseControlActive = true -- Automatically activate when setting speed
                showNotification("Cruise Speed ~b~SET~w~ to ~g~" .. math.floor(cruiseSpeed) .. " KM/H~w~", notificationDuration)
            else
                showNotification("~r~You must be in a vehicle to set cruise speed.~w~", notificationDuration)
            end
        end
    end
end)