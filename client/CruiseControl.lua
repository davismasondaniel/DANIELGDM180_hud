-- FiveM Cruise Control Script (MPH Version with Command)

-- Global variables for cruise control state
local cruiseControlActive = false
local cruiseSpeed = 0.0 -- Stores the target speed for cruise control in MPH

-- Configuration
local notificationDuration = 3000 -- Duration of notifications in milliseconds

-- Function to display a notification
-- text: The message to display
-- duration: How long the message should be visible (in milliseconds)
local function showNotification(text, duration)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Function to get the current vehicle speed in MPH
-- vehicle: The vehicle entity
local function getVehicleSpeed(vehicle)
    -- GetEntitySpeed returns speed in meters per second (m/s)
    -- To convert to MPH, multiply by 2.23694 (m/s * 3600 s/hr / 1609.34 m/mile)
    return GetEntitySpeed(vehicle) * 2.23694
end

-- Function to set the vehicle speed for cruise control
-- vehicle: The vehicle entity
-- targetSpeed: The desired speed in MPH
local function setVehicleCruiseSpeed(vehicle, targetSpeed)
    local currentSpeed = getVehicleSpeed(vehicle)

    -- If the current speed is significantly lower than the target, apply throttle
    if currentSpeed < targetSpeed - 1.0 then -- -1.0 for a small buffer
        SetVehicleForwardSpeed(vehicle, 1.0) -- Full throttle
        SetVehicleBrake(vehicle, 0.0) -- Ensure brake is released
    -- If the current speed is significantly higher than the target, apply brake or reduce throttle
    elseif currentSpeed > targetSpeed + 1.0 then -- +1.0 for a small buffer
        SetVehicleBrake(vehicle, 1.0) -- Apply brake
        SetVehicleForwardSpeed(vehicle, 0.0) -- Ensure throttle is released
    else
        -- If close to target speed, try to maintain it with partial throttle
        -- This is a simple approach; more advanced systems might use PID controllers
        SetVehicleForwardSpeed(vehicle, 0.5) -- Half throttle to maintain
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
            SetTextFont(4)
            SetTextProportional(1)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropShadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("Cruise Control: ON (~g~" .. math.floor(cruiseSpeed) .. " MPH~w~)")
            DrawText(0.7, 0.9) -- Position on screen (X, Y)
        end
    end
end)

-- Register the /cruisecontrol command
RegisterCommand("cruisecontrol", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)

        if not cruiseControlActive then
            -- If cruise control is off, activate it
            cruiseControlActive = true
            -- Set the initial cruise speed to the current vehicle speed
            cruiseSpeed = getVehicleSpeed(currentVehicle)
            showNotification("Cruise Control ~g~ACTIVATED~w~ at ~b~" .. math.floor(cruiseSpeed) .. " MPH~w~", notificationDuration)
        else
            -- If cruise control is on, deactivate it
            cruiseControlActive = false
            showNotification("Cruise Control ~r~DEACTIVATED~w~", notificationDuration)
            -- Re-enable controls and reset throttle/brake
            if DoesEntityExist(currentVehicle) then
                SetVehicleThrottle(currentVehicle, 0.0)
                SetVehicleBrake(currentVehicle, 0.0)
            end
        end
    else
        showNotification("~r~You must be in a vehicle to use cruise control.~w~", notificationDuration)
    end
end, false) -- The 'false' makes it a client-side command accessible to all players