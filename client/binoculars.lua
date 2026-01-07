local cam = nil

Config = Config or {}
Config.Binoculars = {
    normal = {
        zoom = false,
        baseFov = 38.0,
        swayMultiplier = 0.65, 
        distancePrecision = 5.0,
        compassMode = "cardinal"
    },
    improved = {
        zoom = true,
        minFov = 15.0,
        maxFov = 50.0,
        zoomStep = 2.5,
        swayMultiplier = 0.18, 
        distancePrecision = 1.0,
        compassMode = "degrees"
    }
}

RSG_UsingBinoculars = false

Config.Debug = GetResourceKvpString('Crossing-Binoculars:debug') == 'true'

local function debugPrint(message)
    if Config.Debug then
        print(message)
    end
end

debugPrint('[Crossing-Binoculars] Client script loaded')


CreateThread(function()
    Wait(2000)
    if Config.Debug then
        debugPrint('[Crossing-Binoculars] ox_lib exists: ' .. tostring(lib ~= nil))
    end
end)


local function getCompass()
    local heading = GetGameplayCamRot(2).z
    heading = (heading + 360) % 360

    local dirs = {"N","NE","E","SE","S","SW","W","NW"}
    local index = math.floor((heading + 22.5) / 45) % 8 + 1

    return dirs[index], math.floor(heading)
end


local function RotToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)

    return vector3(
        -math.sin(z) * math.cos(x),
         math.cos(z) * math.cos(x),
         math.sin(x)
    )
end


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


local function applyCameraSway(mult)
    local stamina = GetPlayerStamina(PlayerId()) / 100.0
    local sway = (1.0 - stamina) * mult

    
    local t = GetGameTimer() / 500.0

    SetGameplayCamRelativePitch(math.sin(t) * sway * 1.2, 1.0)
    SetGameplayCamRelativeHeading(math.cos(t) * sway * 1.2)
end


Config.ZoomInvert = false


local function attachCameraToEntity()
    AttachCamToEntity(cam, PlayerPedId(), 0.0, 0.0, 1.2, true) 
end


local baseCamRot = nil


local function disableMovementActions()
    DisableControlAction(0, 0x8FFC75D6, true) 
    DisableControlAction(0, 0xD9D0E1C0, true) 
end


local function fadeInCamera()
    DoScreenFadeOut(150)
    Wait(150)
    DoScreenFadeIn(150)
end


CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()
        local _, weapon = GetCurrentPedWeapon(ped, true)

       
        if weapon == GetHashKey('WEAPON_KIT_BINOCULARS')
        or weapon == GetHashKey('WEAPON_KIT_BINOCULARS_IMPROVED') then

            if IsControlPressed(0, 0xF84FA74F) then 
                local dir, deg = getCompass()
                local dist = getDistance()

                local distText = dist and (math.floor(dist) .. " m") or "--"
                local isImproved = weapon == GetHashKey('WEAPON_KIT_BINOCULARS_IMPROVED')
                local dirText = isImproved and (deg .. "° " .. dir) or dir

                
                lib.showTextUI(
                    ("Distance: %s\nDirection: %s"):format(
                        distText,
                        dirText
                    ),
                    {
                        position = "right-center",
                        style = { opacity = 0.9 } 
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


RegisterNetEvent('Crossing-Binoculars:client:EquipBinoculars', function(weaponName)
    local ped = PlayerPedId()

    if binocularsEquipped then
        
        RemoveWeaponFromPed(ped, GetHashKey(weaponName))
        SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
        binocularsEquipped = false
        debugPrint('[Crossing-Binoculars] Binoculars removed: ' .. weaponName)
        return
    end

   
    if HasPedGotWeapon(ped, GetHashKey(weaponName), false) then
        RemoveWeaponFromPed(ped, GetHashKey(weaponName))
        Wait(200) 
    end
    SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true) 
    GiveWeaponToPed(ped, GetHashKey(weaponName), 0, false, true)
    SetCurrentPedWeapon(ped, GetHashKey(weaponName), true)
    binocularsEquipped = true
    debugPrint('[Crossing-Binoculars] Binoculars equipped: ' .. weaponName)

    
    local zoom = Config.Binoculars.improved.baseFov

    
    CreateThread(function()
        while binocularsEquipped do
            Wait(0)

            local isHoldingRMB = IsControlPressed(0, 0xF84FA74F)

            
            if isHoldingRMB and not usingBinoculars then
                TriggerEvent(
                    'Crossing-Binoculars:client:UseBinoculars',
                    weaponName == 'WEAPON_KIT_BINOCULARS_IMPROVED'
                )
            end

            
            if not isHoldingRMB and usingBinoculars then
                StopBinoculars()
            end
        end
    end)

   
    local config = Config.Binoculars.normal

    
    if config.zoom then
        
        local step = Config.ZoomInvert and -config.zoomStep or config.zoomStep

        if IsControlJustPressed(0, 241) then 
            zoom = zoom - step
        elseif IsControlJustPressed(0, 242) then 
            zoom = zoom + step
        end

        zoom = math.clamp(zoom, config.minFov, config.maxFov)
        SetCamFov(cam, zoom)
    else
       
        SetCamFov(cam, config.baseFov)

        
        DisableControlAction(0, 241, true)
        DisableControlAction(0, 242, true)
    end
end)

