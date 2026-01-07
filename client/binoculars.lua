local cam = nil

-- Configuration for binoculars
Config = Config or {}
Config.Binoculars = {
    normal = {
        zoom = false,
        baseFov = 38.0,
        swayMultiplier = 0.65, -- Updated sway multipliers for realism
        distancePrecision = 5.0, -- Updated distance precision for psychological impact
        compassMode = "cardinal"
    },
    improved = {
        zoom = true,
        minFov = 15.0,
        maxFov = 50.0,
        zoomStep = 2.5,
        swayMultiplier = 0.18, -- Updated sway multipliers for realism
        distancePrecision = 1.0,
        compassMode = "degrees"
    }
}

RSG_UsingBinoculars = false

-- Load debug configuration
Config.Debug = GetResourceKvpString('Crossing-Binoculars:debug') == 'true'

local function debugPrint(message)
    if Config.Debug then
        print(message)
    end
end

debugPrint('[Crossing-Binoculars] Client script loaded')

-- Check if ox_lib is available
CreateThread(function()
    Wait(2000)
    if Config.Debug then
        debugPrint('[Crossing-Binoculars] ox_lib exists: ' .. tostring(lib ~= nil))
    end
end)

-- Compass using gameplay camera
local function getCompass()
    local heading = GetGameplayCamRot(2).z
    heading = (heading + 360) % 360

    local dirs = {"N","NE","E","SE","S","SW","W","NW"}
    local index = math.floor((heading + 22.5) / 45) % 8 + 1

    return dirs[index], math.floor(heading)
end

-- Convert camera rotation to direction vector (RedM safe)
local function RotToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)

    return vector3(
        -math.sin(z) * math.cos(x),
         math.cos(z) * math.cos(x),
         math.sin(x)
    )
end

-- Distance using gameplay camera
local function getDistance()
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local forward = RotToDirection(camRot)
    local rayEnd = camCoords + (forward * 1000.0)

    local ray = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        rayEnd.x, rayEnd.y, rayEnd.z,
        -1, PlayerPedId(), 0
    )

    local _, hit, endCoords = GetShapeTestResult(ray)
    if hit == 1 then
        return #(camCoords - endCoords)
    end

    return nil
end

-- Enhanced camera sway logic for RedM compatibility
local function applyCameraSway(mult)
    local stamina = GetPlayerStamina(PlayerId()) / 100.0
    local sway = (1.0 - stamina) * mult

    -- Make sway visible through vanilla stabilization
    local t = GetGameTimer() / 500.0

    SetGameplayCamRelativePitch(math.sin(t) * sway * 1.2, 1.0)
    SetGameplayCamRelativeHeading(math.cos(t) * sway * 1.2)
end

-- Ensure Config.ZoomInvert is defined
Config.ZoomInvert = false

-- Adjusted camera attachment height for better alignment
local function attachCameraToEntity()
    AttachCamToEntity(cam, PlayerPedId(), 0.0, 0.0, 1.2, true) -- Adjusted height
end

-- Declare baseCamRot as a local variable
local baseCamRot = nil

-- Optional: Disable sprint and jump while using binoculars
local function disableMovementActions()
    DisableControlAction(0, 0x8FFC75D6, true) -- Sprint
    DisableControlAction(0, 0xD9D0E1C0, true) -- Jump
end

-- Optional: Fade-in camera for polished feel
local function fadeInCamera()
    DoScreenFadeOut(150)
    Wait(150)
    DoScreenFadeIn(150)
end

-- Removed the UseBinoculars event and related logic
-- Removed usingBinoculars and StopBinoculars logic

CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local _, weapon = GetCurrentPedWeapon(ped, true)

        -- Only when holding binoculars
        if weapon == GetHashKey('WEAPON_KIT_BINOCULARS')
        or weapon == GetHashKey('WEAPON_KIT_BINOCULARS_IMPROVED') then

            if IsControlPressed(0, 0xF84FA74F) then -- Correct RedM RMB input
                local dir, deg = getCompass()
                local dist = getDistance()

                local distText = dist and (math.floor(dist) .. " m") or "--"
                local isImproved = weapon == GetHashKey('WEAPON_KIT_BINOCULARS_IMPROVED')
                local dirText = isImproved and (deg .. "° " .. dir) or dir

                -- Updated UI string for clean and immersive display
                lib.showTextUI(
                    ("Distance: %s\nDirection: %s"):format(
                        distText,
                        dirText
                    ),
                    {
                        position = "right-center",
                        style = { opacity = 0.9 } -- Fade effect for premium feel
                    }
                )
            else
                lib.hideTextUI()
            end
        else
            lib.hideTextUI()
        end
    end
end)

RegisterCommand('testbinoculars', function(source, args, rawCommand)
    local isImproved = args[1] == 'improved'
    TriggerEvent('Crossing-Binoculars:client:UseBinoculars', isImproved)
    debugPrint('[Crossing-Binoculars] Test command executed | Improved:', isImproved)
end, false)

-- Updated EquipBinoculars to handle weapon-switch desync
RegisterNetEvent('Crossing-Binoculars:client:EquipBinoculars', function(weaponName)
    local ped = PlayerPedId()

    if binocularsEquipped then
        -- Remove binoculars if already equipped
        RemoveWeaponFromPed(ped, GetHashKey(weaponName))
        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
        binocularsEquipped = false
        debugPrint('[Crossing-Binoculars] Binoculars removed: ' .. weaponName)
        return
    end

    -- Equip binoculars if not already equipped
    if HasPedGotWeapon(ped, GetHashKey(weaponName), false) then
        RemoveWeaponFromPed(ped, GetHashKey(weaponName))
        Wait(200) -- Ensure the weapon is fully removed
    end
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true) -- Clear current weapon
    GiveWeaponToPed(ped, GetHashKey(weaponName), 0, false, true)
    SetCurrentPedWeapon(ped, GetHashKey(weaponName), true)
    binocularsEquipped = true
    debugPrint('[Crossing-Binoculars] Binoculars equipped: ' .. weaponName)

    -- Initialize zoom only when improved binoculars are used
    local zoom = Config.Binoculars.improved.baseFov

    -- Bind right mouse button for zoom functionality
    CreateThread(function()
        while binocularsEquipped do
            Wait(0)

            local isHoldingRMB = IsControlPressed(0, 0xF84FA74F)

            -- Start binoculars when RMB is held
            if isHoldingRMB and not usingBinoculars then
                TriggerEvent(
                    'Crossing-Binoculars:client:UseBinoculars',
                    weaponName == 'WEAPON_KIT_BINOCULARS_IMPROVED'
                )
            end

            -- Stop binoculars when RMB is released
            if not isHoldingRMB and usingBinoculars then
                StopBinoculars()
            end
        end
    end)

    -- Ensure `config` is initialized properly
    local config = Config.Binoculars.normal -- Replace with improved if needed

    -- Updated zoom logic for normal and improved binoculars
    if config.zoom then
        -- Improved binoculars ONLY
        local step = Config.ZoomInvert and -config.zoomStep or config.zoomStep

        if IsControlJustPressed(0, 241) then -- Scroll up
            zoom = zoom - step
        elseif IsControlJustPressed(0, 242) then -- Scroll down
            zoom = zoom + step
        end

        zoom = math.clamp(zoom, config.minFov, config.maxFov)
        SetCamFov(cam, zoom)
    else
        -- Normal binoculars: HARD LOCK
        SetCamFov(cam, config.baseFov)

        -- HARD disable zoom inputs
        DisableControlAction(0, 241, true)
        DisableControlAction(0, 242, true)
    end
end)

