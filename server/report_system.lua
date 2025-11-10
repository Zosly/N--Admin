-- Système de Reports
-- Créé par discord : nano.pasa

local activeReports = {}
local reportIdCounter = 1

-- Créer un nouveau report
RegisterNetEvent('admin:createReport')
AddEventHandler('admin:createReport', function(message)
    local source = source
    local playerName = GetPlayerName(source)
    local identifiers = GetPlayerIdentifiers(source)
    local coords = GetEntityCoords(GetPlayerPed(source))
    
    local report = {
        id = reportIdCounter,
        playerId = source,
        playerName = playerName,
        identifier = identifiers[1],
        message = message,
        coords = coords,
        status = 'pending', -- pending, taken, resolved
        takenBy = nil,
        takenByName = nil,
        timestamp = os.date('%H:%M:%S'),
        date = os.date('%d/%m/%Y')
    }
    
    activeReports[reportIdCounter] = report
    reportIdCounter = reportIdCounter + 1
    
    -- Notifier le joueur
    TriggerClientEvent('admin:notify', source, "~g~Report envoyé ! Un admin va vous répondre.")
    
    -- Notifier tous les admins
    local maxPlayers = GetNumPlayerIndices()
    for i = 0, maxPlayers - 1 do
        local playerId = GetPlayerFromIndex(i)
        if playerId ~= -1 and IsPlayerAdmin(playerId) then
            TriggerClientEvent('admin:newReport', playerId, report)
            TriggerClientEvent('admin:notify', playerId, string.format("~y~Nouveau report de %s", playerName))
        end
    end
    
    -- Log
    SendLog('report_created', source, message)
    
    -- Log Discord
    SendDiscordLog(
        "📢 Nouveau Report",
        string.format("**%s** a créé un report", playerName),
        16776960, -- Jaune
        {
            {name = "Joueur", value = string.format("%s (ID: %s)", playerName, source), inline = true},
            {name = "Message", value = message, inline = false},
            {name = "Heure", value = os.date('%H:%M:%S'), inline = true}
        }
    )
end)

-- Prendre en charge un report
RegisterNetEvent('admin:takeReport')
AddEventHandler('admin:takeReport', function(reportId)
    local source = source
    
    if not HasPermission(source, 'kick') then
        return
    end
    
    if activeReports[reportId] then
        local report = activeReports[reportId]
        
        report.status = 'taken'
        report.takenBy = source
        report.takenByName = GetPlayerName(source)
        
        -- Notifier le joueur qui a report
        if GetPlayerName(report.playerId) then
            TriggerClientEvent('admin:notify', report.playerId, 
                string.format("~g~%s s'occupe de votre report", report.takenByName))
        end
        
        -- Notifier tous les admins
        TriggerClientEvent('admin:updateReports', -1, activeReports)
        
        SendLog('report_taken', source, string.format("Report #%d de %s", reportId, report.playerName))
    end
end)

-- Résoudre un report
RegisterNetEvent('admin:resolveReport')
AddEventHandler('admin:resolveReport', function(reportId)
    local source = source
    
    if not HasPermission(source, 'kick') then
        return
    end
    
    if activeReports[reportId] then
        local report = activeReports[reportId]
        
        -- Notifier le joueur
        if GetPlayerName(report.playerId) then
            TriggerClientEvent('admin:notify', report.playerId, 
                "~g~Votre report a été résolu par un admin")
        end
        
        SendLog('report_resolved', source, string.format("Report #%d de %s résolu", reportId, report.playerName))
        
        -- Supprimer le report
        activeReports[reportId] = nil
        
        -- Notifier tous les admins
        TriggerClientEvent('admin:updateReports', -1, activeReports)
    end
end)

-- Répondre à un report
RegisterNetEvent('admin:replyReport')
AddEventHandler('admin:replyReport', function(reportId, message)
    local source = source
    
    if not HasPermission(source, 'kick') then
        return
    end
    
    if activeReports[reportId] then
        local report = activeReports[reportId]
        
        -- Envoyer la réponse au joueur
        if GetPlayerName(report.playerId) then
            TriggerClientEvent('chat:addMessage', report.playerId, {
                color = {102, 126, 234},
                multiline = true,
                args = {string.format("Admin %s", GetPlayerName(source)), message}
            })
            
            TriggerClientEvent('admin:notify', report.playerId, "~b~Réponse admin reçue (voir chat)")
        end
        
        TriggerClientEvent('admin:notify', source, "~g~Réponse envoyée")
        
        SendLog('report_reply', source, string.format("Réponse à report #%d: %s", reportId, message))
    end
end)

-- TP vers le joueur qui a report
RegisterNetEvent('admin:gotoReporter')
AddEventHandler('admin:gotoReporter', function(reportId)
    local source = source
    
    if not HasPermission(source, 'goto') then
        return
    end
    
    if activeReports[reportId] then
        local report = activeReports[reportId]
        
        if GetPlayerName(report.playerId) then
            local targetPed = GetPlayerPed(report.playerId)
            local targetCoords = GetEntityCoords(targetPed)
            TriggerClientEvent('admin:teleportToCoords', source, targetCoords)
            
            TriggerClientEvent('admin:notify', source, 
                string.format("~g~Téléporté vers %s", report.playerName))
        else
            TriggerClientEvent('admin:notify', source, "~r~Joueur déconnecté")
        end
    end
end)

-- Bring le joueur qui a report
RegisterNetEvent('admin:bringReporter')
AddEventHandler('admin:bringReporter', function(reportId)
    local source = source
    
    if not HasPermission(source, 'bring') then
        return
    end
    
    if activeReports[reportId] then
        local report = activeReports[reportId]
        
        if GetPlayerName(report.playerId) then
            local adminPed = GetPlayerPed(source)
            local adminCoords = GetEntityCoords(adminPed)
            TriggerClientEvent('admin:teleportToCoords', report.playerId, adminCoords)
            
            TriggerClientEvent('admin:notify', source, 
                string.format("~g~%s téléporté vers vous", report.playerName))
        else
            TriggerClientEvent('admin:notify', source, "~r~Joueur déconnecté")
        end
    end
end)

-- Obtenir tous les reports
RegisterNetEvent('admin:getReports')
AddEventHandler('admin:getReports', function()
    local source = source
    
    if not IsPlayerAdmin(source) then
        return
    end
    
    TriggerClientEvent('admin:receiveReports', source, activeReports)
end)

-- Commande /report pour les joueurs
RegisterCommand('report', function(source, args)
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 165, 0},
            multiline = true,
            args = {"N-Admin", "Usage: /report [votre message]"}
        })
        return
    end
    
    local message = table.concat(args, " ")
    TriggerServerEvent('admin:createReport', message)
end)

-- Nettoyer les reports des joueurs déconnectés
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Toutes les minutes
        
        for reportId, report in pairs(activeReports) do
            if not GetPlayerName(report.playerId) then
                -- Joueur déconnecté, supprimer le report après 5 minutes
                if report.status == 'pending' then
                    activeReports[reportId] = nil
                    TriggerClientEvent('admin:updateReports', -1, activeReports)
                end
            end
        end
    end
end)

-- Notification sonore pour les admins
RegisterNetEvent('admin:playReportSound')
AddEventHandler('admin:playReportSound', function()
    local source = source
    if IsPlayerAdmin(source) then
        TriggerClientEvent('admin:playSoundClient', source)
    end
end)

