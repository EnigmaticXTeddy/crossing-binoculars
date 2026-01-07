local RSGCore = exports['rsg-core']:GetCoreObject()

print('[Crossing-Binoculars] Server script loaded (Client-authoritative)')

-- Normal Binoculars
RSGCore.Functions.CreateUseableItem('weapon_kit_binoculars', function(source)
    TriggerClientEvent(
        'Crossing-Binoculars:client:EquipBinoculars',
        source,
        'WEAPON_KIT_BINOCULARS'
    )
end)

-- Improved Binoculars
RSGCore.Functions.CreateUseableItem('weapon_kit_binoculars_improved', function(source)
    TriggerClientEvent(
        'Crossing-Binoculars:client:EquipBinoculars',
        source,
        'WEAPON_KIT_BINOCULARS_IMPROVED'
    )
end)