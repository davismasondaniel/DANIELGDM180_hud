local seatbeltOn = false
local lastSeatbeltStatus = false -- Tracks the last sent seatbelt status
local uiHiddenByPause = false -- Tracks whether we hid the UI due to pause/map

-- Default HUD settings (configurable in config.lua)
local defaultHudSettings = Config.DefaultHudSettings

-- Current HUD settings, loaded from KVP or default
local currentHudSettings = {}

-- Cache export tables once instead of re-resolving them via the exports
-- metatable on every tick (cheap, but adds up at 10hz+ over long sessions).
local LegacyFuel = exports['LegacyFuel']
local VehicleMileage = exports['jg-vehiclemileage']

-- jg-vehiclemileage unit ("miles" or "kilometers"), fetched once and cached
local mileageUnit = nil
local mileageUnitAbbr = 'mi'
local mileageUnitTriesLeft = 5 -- stop retrying forever if the export never resolves

local function getMileageUnit()
    if mileageUnit or mileageUnitTriesLeft <= 0 then return end
    local ok, unit = pcall(function()
        return VehicleMileage:getUnit()
    end)
    if ok and unit then
        mileageUnit = unit
        mileageUnitAbbr = (unit == 'kilometers') and 'km' or 'mi'
    else
        mileageUnitTriesLeft = mileageUnitTriesLeft - 1
    end
end

-- Mileage doesn't need to be re-fetched at the full HUD refresh rate since
-- it's only ever displayed as a floored integer. Throttle it separately.
local MILEAGE_REFRESH_MS = 500
local lastMileageFetch = 0
local cachedMileage = 0

local function getMileage(now)
    if now - lastMileageFetch < MILEAGE_REFRESH_MS then
        return cachedMileage
    end
    lastMileageFetch = now

    getMileageUnit()

    local ok, mileageKm = pcall(function()
        return VehicleMileage:getMileage()
    end)
    if ok and mileageKm then
        local mileage = (mileageUnit == 'kilometers') and mileageKm or (mileageKm * 0.621371)
        cachedMileage = math.floor(mileage)
    end
    return cachedMileage
end

local function notify(type, title, description)
    lib.notify({
        title = title or 'Vehicle',
        description = description,
        type = type or 'inform' -- success | error | warning | inform
    })
end

-- Force the player into ragdoll for a duration (ms). Re-applies periodically
-- for reliability without spinning at Wait(0) (a 5s Wait(0) loop is a
-- needless full-tick-rate spin; ragdoll doesn't need re-checking every frame).
local function forceRagdoll(ped, durationMs)
    if not ped or ped == 0 then return end
    durationMs = durationMs or 3000

    -- Some scripts disable ragdoll; re-enable it.
    SetPedCanRagdoll(ped, true)

    local endTime = GetGameTimer() + durationMs
    CreateThread(function()
        while GetGameTimer() < endTime do
            if not IsPedRagdoll(ped) then
                SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
            end
            Wait(50)
        end
    end)
end

-- Function to load HUD settings from KVP
local function loadHudSettings()
    local savedSettings = GetResourceKvpString(Config.KvpKey)
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
        type = 'applySettings',
        settings = currentHudSettings
    })
end

-- Function to save HUD settings to KVP
local function saveHudSettings(settings)
    SetResourceKvp(Config.KvpKey, json.encode(settings))
    currentHudSettings = settings
    notify('success', 'HUD', 'HUD settings saved!')
end

-- Function to reset HUD settings to default
local function resetHudSettings()
    SetResourceKvp(Config.KvpKey, json.encode(defaultHudSettings))
    currentHudSettings = defaultHudSettings
    notify('info', 'HUD', 'HUD settings reset to default!')
end

-- Register command to toggle seatbelt
RegisterCommand('toggleSeatbelt', function()
    local ped = PlayerPedId()

    -- Only allow toggling if in a vehicle
    if IsPedInAnyVehicle(ped, false) then
        seatbeltOn = not seatbeltOn
        -- Only send seatbelt message and play sound if the status actually changed
        if seatbeltOn ~= lastSeatbeltStatus then
            SendNUIMessage({
                type = 'seatbelt',
                status = seatbeltOn,
                playSound = seatbeltOn and 'buckle' or 'unbuckle'
            })
            lastSeatbeltStatus = seatbeltOn

            if seatbeltOn then
                notify('success', 'HUD', 'Seatbelt ON')
            else
                notify('error', 'HUD', 'Seatbelt OFF')
            end
        end
    end
end, false)

RegisterKeyMapping('toggleSeatbelt', 'Toggle Seatbelt', 'keyboard', Config.ToggleSeatbeltKey)

-- Register command to open HUD settings menu
RegisterCommand('hudsettings', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openSettings',
        settings = currentHudSettings
    })
end, false)

RegisterKeyMapping('hudsettings', 'Open HUD Settings', 'keyboard', Config.HUDSettings)

-- NUI Callbacks
RegisterNuiCallback('saveHudSettings', function(data, cb)
    saveHudSettings(data)
    cb('ok')
end)

RegisterNuiCallback('resetHudSettings', function(data, cb)
    resetHudSettings()
    cb('ok')
end)

RegisterNuiCallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNuiCallback('uiReady', function(data, cb)
    loadHudSettings()
    cb('ok')
end)

-- Last payload actually sent to the NUI, so we can skip redundant
-- SendNUIMessage/postMessage calls when nothing the player would see changed
-- (e.g. idling with a full tank and no RPM movement).
local lastSent = {
    display = nil, speed = nil, fuel = nil, engine = nil,
    seatbelt = nil, gear = nil, rpm = nil, mileage = nil
}

local wasInVehicle = false
local lastSpeed = 0

-- Single merged loop: HUD data push + seatbelt/ejection logic.
-- Previously these were two separate CreateThread loops each doing their own
-- PlayerPedId()/GetVehiclePedIsIn() native calls at similar rates - merged
-- here to halve those native calls and the thread/Wait overhead per tick.
CreateThread(function()
    while true do
        Wait(Config.RefreshRate)

        -- Hide NUI while pause menu / map is open (ESC -> Map)
        local paused = IsPauseMenuActive()
        if paused then
            if not uiHiddenByPause then
                uiHiddenByPause = true
                SendNUIMessage({ type = 'pause', active = true })
                SendNUIMessage({ type = 'hud', display = false })
                lastSent.display = false
            end
            goto continue
        elseif uiHiddenByPause then
            uiHiddenByPause = false
            SendNUIMessage({ type = 'pause', active = false })
        end

        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)

        if inVehicle then
            local vehicle = GetVehiclePedIsIn(ped, false)
            wasInVehicle = true

            local currentSpeed = GetEntitySpeed(vehicle)
            local speed = math.floor(currentSpeed * 2.23694)
            local fuel = LegacyFuel:GetFuel(vehicle)
            local gear = GetVehicleCurrentGear(vehicle)
            local rpm = math.floor(GetVehicleCurrentRpm(vehicle) * 10000)
            local enginePercent = GetVehicleEngineHealth(vehicle) / 10
            local mileage = getMileage(GetGameTimer())

            -- Only touch the NUI bridge when something actually changed.
            if lastSent.display ~= true or speed ~= lastSent.speed or fuel ~= lastSent.fuel
                or enginePercent ~= lastSent.engine or seatbeltOn ~= lastSent.seatbelt
                or gear ~= lastSent.gear or rpm ~= lastSent.rpm or mileage ~= lastSent.mileage then

                SendNUIMessage({
                    type = 'hud',
                    display = true,
                    speed = speed,
                    fuel = fuel,
                    engine = enginePercent,
                    seatbelt = seatbeltOn,
                    gear = gear,
                    rpm = rpm,
                    mileage = mileage,
                    mileageUnit = mileageUnitAbbr
                })

                lastSent.display = true
                lastSent.speed = speed
                lastSent.fuel = fuel
                lastSent.engine = enginePercent
                lastSent.seatbelt = seatbeltOn
                lastSent.gear = gear
                lastSent.rpm = rpm
                lastSent.mileage = mileage
            end

            -- Prevent player from exiting vehicle if seatbelt is on
            if seatbeltOn then
                DisableControlAction(0, 75, true) -- INPUTGROUP_VEHICLE / INPUT_VEHICLE_EXIT
            end

            -- Eject player if seatbelt is off and there's a rapid deceleration
            if not seatbeltOn and currentSpeed < lastSpeed - 10.0 and lastSpeed > 20.0 then
                local coords = GetEntityCoords(ped)
                local forwardVector = GetEntityForwardVector(vehicle)
                TaskLeaveVehicle(ped, vehicle, 16)
                Wait(200)
                SetEntityCoords(ped, coords.x + forwardVector.x, coords.y + forwardVector.y, coords.z - 0.5)
                SetEntityVelocity(ped, forwardVector.x * lastSpeed, forwardVector.y * lastSpeed, 0.0)
                forceRagdoll(ped, 5000)
                notify('warning', 'HUD', 'You were ejected from the vehicle!')
            end

            lastSpeed = currentSpeed
        else
            if wasInVehicle then
                if lastSent.display ~= false then
                    SendNUIMessage({ type = 'hud', display = false })
                    lastSent.display = false
                end
                if seatbeltOn then
                    seatbeltOn = false
                    SendNUIMessage({
                        type = 'seatbelt',
                        status = seatbeltOn,
                        playSound = 'unbuckle'
                    })
                    lastSeatbeltStatus = seatbeltOn
                    notify('error', 'HUD', 'Seatbelt OFF (Left Vehicle)')
                end
            end
            wasInVehicle = false
            lastSpeed = 0
        end

        ::continue::
    end
end)
