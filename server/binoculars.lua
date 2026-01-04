local RSGCore = exports['rsg-core']:GetCoreObject()

print('[Crossing-Binoculars] Server script loaded')

RSGCore.Functions.CreateUseableItem('weapon_kit_binoculars', function(source)
    print('[Crossing-Binoculars] Binoculars item used by player:', source)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if xPlayer then
        TriggerClientEvent('Crossing-Binoculars:client:RemoveBinoculars', source, 'WEAPON_KIT_BINOCULARS')
        Wait(100) -- Ensure removal is processed before re-equipping
        TriggerClientEvent('Crossing-Binoculars:client:EquipBinoculars', source, 'WEAPON_KIT_BINOCULARS')
    end
end)

RSGCore.Functions.CreateUseableItem('weapon_kit_binoculars_improved', function(source)
    print('[Crossing-Binoculars] Improved binoculars item used by player:', source)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if xPlayer then
        TriggerClientEvent('Crossing-Binoculars:client:RemoveBinoculars', source, 'WEAPON_KIT_BINOCULARS_IMPROVED')
        Wait(100) -- Ensure removal is processed before re-equipping
        TriggerClientEvent('Crossing-Binoculars:client:EquipBinoculars', source, 'WEAPON_KIT_BINOCULARS_IMPROVED')
    end
end)

RSGCore.Functions.CreateUseableItem('remove_weapon_kit_binoculars', function(source)
    print('[Crossing-Binoculars] Removing binoculars from player:', source)
    TriggerClientEvent('Crossing-Binoculars:client:RemoveBinoculars', source, 'WEAPON_KIT_BINOCULARS')
end)

RSGCore.Functions.CreateUseableItem('remove_weapon_kit_binoculars_improved', function(source)
    print('[Crossing-Binoculars] Removing improved binoculars from player:', source)
    TriggerClientEvent('Crossing-Binoculars:client:RemoveBinoculars', source, 'WEAPON_KIT_BINOCULARS_IMPROVED')
end)