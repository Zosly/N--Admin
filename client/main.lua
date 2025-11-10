-- Script principal client
-- Créé par discord : nano.pasa

local menuOpen = false
local playerRank = nil
local playerPermissions = {}

-- Message de démarrage dans F8
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    print("^2=======================================^7")
    print("^2  N-Admin - Client chargé^7")
    print("^6  Créé par discord : nano.pasa^7")
    print("^2=======================================^7")
end)

-- Ouvrir le menu avec la touche configurée (OPTIMISÉ - 0.00ms)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300) -- Optimisé : 300ms au lieu de 0ms
        
        if IsControlJustReleased(0, Config.OpenMenuKey) then
            TriggerServerEvent('admin:getRank')
            Citizen.Wait(500) -- Cooldown pour éviter spam
        end
    end
end)

-- Recevoir le grade et ouvrir le menu
RegisterNetEvent('admin:rankResult')
AddEventHandler('admin:rankResult', function(rank)
    if rank then
        playerRank = rank
        TriggerServerEvent('admin:getPermissions')
    else
        ShowNotification(Config.Messages.no_permission)
    end
end)

-- Recevoir les permissions
RegisterNetEvent('admin:permissionsResult')
AddEventHandler('admin:permissionsResult', function(permissions, rank)
    playerPermissions = permissions
    playerRank = rank
    
    -- Demander la liste des joueurs
    TriggerServerEvent('admin:getPlayers')
end)

-- Recevoir la liste des joueurs et ouvrir le menu
RegisterNetEvent('admin:receivePlayerList')
AddEventHandler('admin:receivePlayerList', function(players)
    -- Demander aussi les reports
    TriggerServerEvent('admin:getReports')
    
    Citizen.Wait(100) -- Petit délai pour recevoir les reports
    OpenMenu(players)
end)

-- Recevoir les reports
local cachedReports = {}

RegisterNetEvent('admin:receiveReports')
AddEventHandler('admin:receiveReports', function(reports)
    cachedReports = reports or {}
end)

-- Nouveau report reçu (notification)
RegisterNetEvent('admin:newReport')
AddEventHandler('admin:newReport', function(report)
    cachedReports[report.id] = report
    
    -- Mettre à jour le menu si ouvert
    SendNUIMessage({
        action = 'newReport',
        report = report
    })
    
    -- Son de notification
    PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", true)
end)

-- Mise à jour des reports
RegisterNetEvent('admin:updateReports')
AddEventHandler('admin:updateReports', function(reports)
    cachedReports = reports or {}
    
    -- Mettre à jour le menu si ouvert
    SendNUIMessage({
        action = 'updateReports',
        reports = reports
    })
end)

-- Event pour ouvrir le menu (depuis la commande)
RegisterNetEvent('admin:openMenu')
AddEventHandler('admin:openMenu', function()
    TriggerServerEvent('admin:getRank')
end)

-- Fonction pour ouvrir le menu (CORRIGÉ - Bug réouverture)
function OpenMenu(players)
    if menuOpen then
        CloseMenu()
        return
    end
    
    -- Forcer reset du NUI focus au cas où
    SetNuiFocus(false, false)
    Citizen.Wait(50) -- Petit délai pour assurer le reset
    
    menuOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false) -- Désactiver les inputs jeu
    
    SendNUIMessage({
        action = 'openMenu',
        players = players,
        permissions = playerPermissions,
        rank = playerRank,
        reports = cachedReports, -- ✅ NOUVEAU : Reports
        config = {
            vehicles = Config.Vehicles,
            weathers = Config.Weathers,
            locations = Config.TeleportLocations
        }
    })
end

-- Fonction pour fermer le menu (CORRIGÉ)
function CloseMenu()
    if not menuOpen then return end -- Sécurité
    
    menuOpen = false
    
    -- Envoyer au NUI d'abord
    SendNUIMessage({
        action = 'closeMenu'
    })
    
    -- Petit délai avant reset focus
    Citizen.Wait(50)
    
    -- Reset complet du NUI focus
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(true)
    
    -- Double sécurité
    Citizen.SetTimeout(100, function()
        SetNuiFocus(false, false)
    end)
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('refreshPlayers', function(data, cb)
    TriggerServerEvent('admin:getPlayers')
    cb('ok')
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('admin:kickPlayer', data.targetId, data.reason)
    cb('ok')
end)

RegisterNUICallback('banPlayer', function(data, cb)
    TriggerServerEvent('admin:banPlayer', data.targetId, data.reason, data.duration)
    cb('ok')
end)

RegisterNUICallback('freezePlayer', function(data, cb)
    TriggerServerEvent('admin:freezePlayer', data.targetId, data.freeze)
    cb('ok')
end)

RegisterNUICallback('revivePlayer', function(data, cb)
    TriggerServerEvent('admin:revivePlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('healPlayer', function(data, cb)
    TriggerServerEvent('admin:healPlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('giveArmor', function(data, cb)
    TriggerServerEvent('admin:giveArmor', data.targetId)
    cb('ok')
end)

RegisterNUICallback('killPlayer', function(data, cb)
    TriggerServerEvent('admin:killPlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('spectatePlayer', function(data, cb)
    TriggerServerEvent('admin:spectatePlayer', data.targetId)
    CloseMenu()
    cb('ok')
end)

RegisterNUICallback('gotoPlayer', function(data, cb)
    TriggerServerEvent('admin:teleportToPlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('bringPlayer', function(data, cb)
    TriggerServerEvent('admin:bringPlayer', data.targetId)
    cb('ok')
end)

RegisterNUICallback('giveMoney', function(data, cb)
    TriggerServerEvent('admin:giveMoney', data.targetId, data.moneyType, data.amount)
    cb('ok')
end)

-- Callbacks serveur
RegisterNUICallback('announce', function(data, cb)
    TriggerServerEvent('admin:announce', data.message)
    cb('ok')
end)

RegisterNUICallback('setWeather', function(data, cb)
    TriggerServerEvent('admin:setWeather', data.weather)
    cb('ok')
end)

RegisterNUICallback('setTime', function(data, cb)
    TriggerServerEvent('admin:setTime', data.hour, data.minute)
    cb('ok')
end)

RegisterNUICallback('clearArea', function(data, cb)
    TriggerServerEvent('admin:clearArea', data.radius)
    cb('ok')
end)

RegisterNUICallback('clearVehicles', function(data, cb)
    TriggerServerEvent('admin:clearAllVehicles')
    cb('ok')
end)

RegisterNUICallback('clearPeds', function(data, cb)
    TriggerServerEvent('admin:clearAllPeds')
    cb('ok')
end)

-- Callbacks véhicules
RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerServerEvent('admin:spawnVehicle', data.model)
    cb('ok')
end)

RegisterNUICallback('deleteVehicle', function(data, cb)
    TriggerServerEvent('admin:deleteVehicle')
    cb('ok')
end)

RegisterNUICallback('repairVehicle', function(data, cb)
    TriggerServerEvent('admin:repairVehicle')
    cb('ok')
end)

RegisterNUICallback('cleanVehicle', function(data, cb)
    TriggerServerEvent('admin:cleanVehicle')
    cb('ok')
end)

RegisterNUICallback('flipVehicle', function(data, cb)
    TriggerServerEvent('admin:flipVehicle')
    cb('ok')
end)

RegisterNUICallback('maxTuneVehicle', function(data, cb)
    TriggerServerEvent('admin:maxTuneVehicle')
    cb('ok')
end)

-- Callbacks outils personnels
RegisterNUICallback('toggleNoclip', function(data, cb)
    ToggleNoclip()
    cb('ok')
end)

RegisterNUICallback('toggleGodMode', function(data, cb)
    ToggleGodMode()
    cb('ok')
end)

RegisterNUICallback('toggleInvisible', function(data, cb)
    ToggleInvisible()
    cb('ok')
end)

RegisterNUICallback('heal', function(data, cb)
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    SetPedArmour(ped, 100)
    ShowNotification("~g~Vous avez été soigné")
    cb('ok')
end)

RegisterNUICallback('suicide', function(data, cb)
    SetEntityHealth(PlayerPedId(), 0)
    cb('ok')
end)

RegisterNUICallback('teleportToWaypoint', function(data, cb)
    TeleportToWaypoint()
    cb('ok')
end)

RegisterNUICallback('teleportToCoords', function(data, cb)
    SetEntityCoords(PlayerPedId(), data.x, data.y, data.z)
    ShowNotification("~g~Téléporté")
    cb('ok')
end)

-- Fonction utilitaire pour les notifications
function ShowNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

-- Event pour notification
RegisterNetEvent('admin:notify')
AddEventHandler('admin:notify', function(message)
    ShowNotification(message)
end)

-- Fermer le menu avec ESC (OPTIMISÉ - 0.00ms)
-- Le menu est fermé via NUI callback, pas besoin de thread constant

-- Commande de secours pour débloquer le menu (si bug)
RegisterCommand('fixmenu', function()
    menuOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({action = 'closeMenu'})
    ShowNotification("~g~Menu débloqué")
end)

-- === NUI CALLBACKS REPORTS ===

RegisterNUICallback('takeReport', function(data, cb)
    TriggerServerEvent('admin:takeReport', data.reportId)
    cb('ok')
end)

RegisterNUICallback('gotoReporter', function(data, cb)
    TriggerServerEvent('admin:gotoReporter', data.reportId)
    cb('ok')
end)

RegisterNUICallback('bringReporter', function(data, cb)
    TriggerServerEvent('admin:bringReporter', data.reportId)
    cb('ok')
end)

RegisterNUICallback('replyReport', function(data, cb)
    TriggerServerEvent('admin:replyReport', data.reportId, data.message)
    cb('ok')
end)

RegisterNUICallback('resolveReport', function(data, cb)
    TriggerServerEvent('admin:resolveReport', data.reportId)
    cb('ok')
end)

