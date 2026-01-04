local usingBinoculars = false
local cam = nil

local zoom = 40.0
local minZoom = 15.0
local maxZoom = 70.0

RSG_UsingBinoculars = false

-- Load debug configuration
local debugMode = GetResourceKvpString('Crossing-Binoculars:debug') == 'true'

local function debugPrint(message)
    if debugMode then
        print(message)
    end
end

debugPrint('[Crossing-Binoculars] Client script loaded')

RegisterNetEvent('Crossing-Binoculars:client:UseBinoculars', function(isImproved)
    debugPrint('[Crossing-Binoculars] Event triggered | Improved:', isImproved)

    if usingBinoculars then
        StopBinoculars()
        return
    end

    usingBinoculars = true
    RSG_UsingBinoculars = true

    local ped = PlayerPedId()

    if isImproved then
        minZoom = 10.0
        maxZoom = 100.0 -- Extended zoom for improved binoculars
        zoom = 35.0
    else
        minZoom = 15.0
        maxZoom = 70.0 -- Standard zoom for normal binoculars
        zoom = 40.0
    end

    Wait(400)
    ClearPedTasksImmediately(ped)

    -- Animation (visual)
    RequestAnimDict('amb_rest@world_human_binoculars@male_a@idle_a')
    while not HasAnimDictLoaded('amb_rest@world_human_binoculars@male_a@idle_a') do
        Wait(0)
    end

    TaskPlayAnim(
        ped,
        'amb_rest@world_human_binoculars@male_a@idle_a',
        'idle_a',
        1.0, -1.0, -1, 1, 0, false, false, false
    )

    debugPrint('[Crossing-Binoculars] Animation started')

    -- Camera setup
    CreateThread(function()
        cam = CreateCam('DEFAULT_SCRIPTED_FLY_CAMERA', true)
        AttachCamToEntity(cam, ped, 0.0, 0.0, 1.0, true)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)

        debugPrint('[Crossing-Binoculars] Camera activated')

        while usingBinoculars do
            Wait(0)
            local zoomValue = (1.0 / (maxZoom - minZoom)) * (zoom - minZoom)
            SetCamFov(cam, zoomValue * 100.0)

            if IsControlJustPressed(0, 241) then -- Scroll up
                zoom = math.max(minZoom, zoom - 5.0)
                debugPrint('[Crossing-Binoculars] Zoom in:', zoom)
            elseif IsControlJustPressed(0, 242) then -- Scroll down
                zoom = math.min(maxZoom, zoom + 5.0)
                debugPrint('[Crossing-Binoculars] Zoom out:', zoom)
            elseif IsControlJustPressed(0, 177) then -- Backspace
                StopBinoculars()
            end
        end
    end)
end)

function StopBinoculars()
    ClearPedTasksImmediately(PlayerPedId())
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, false)
    usingBinoculars = false
    RSG_UsingBinoculars = false
    debugPrint('[Crossing-Binoculars] Binoculars stopped')
end

RegisterCommand('testbinoculars', function(source, args, rawCommand)
    local isImproved = args[1] == 'improved'
    TriggerEvent('Crossing-Binoculars:client:UseBinoculars', isImproved)
    debugPrint('[Crossing-Binoculars] Test command executed | Improved:', isImproved)
end, false)

RegisterNetEvent('Crossing-Binoculars:client:RemoveBinoculars', function(weaponName)
    local ped = PlayerPedId()
    if HasPedGotWeapon(ped, GetHashKey(weaponName), false) then
        RemoveWeaponFromPed(ped, GetHashKey(weaponName))
        debugPrint('[Crossing-Binoculars] Binoculars removed:', weaponName)
    end
end)

local binocularsEquipped = false -- Track binocular state

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

    -- Bind right mouse button for zoom functionality
    CreateThread(function()
        while binocularsEquipped and HasPedGotWeapon(ped, GetHashKey(weaponName), false) do
            Wait(0)
            if IsControlPressed(0, 25) then -- Right mouse button
                TriggerEvent('Crossing-Binoculars:client:UseBinoculars', weaponName == 'WEAPON_KIT_BINOCULARS_IMPROVED')
            end
        end
    end)
end)