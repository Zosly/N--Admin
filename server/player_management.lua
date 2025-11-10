-- Gestion des joueurs côté serveur
-- Créé par discord : nano.pasa

-- Kick un joueur
RegisterNetEvent('admin:kickPlayer')
AddEventHandler('admin:kickPlayer', function(targetId, reason)
    local source = source
    
    if not HasPermission(source, 'kick') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        local targetName = GetPlayerName(targetId)
        reason = reason or "Aucune raison spécifiée"
        
        SendLog('kick', source, reason, targetId)
        DropPlayer(targetId, string.format("Vous avez été kick du serveur.\nRaison: %s\nPar: %s", reason, GetPlayerName(source)))
        
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été kick", targetName))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Ban un joueur (avec base de données)
RegisterNetEvent('admin:banPlayer')
AddEventHandler('admin:banPlayer', function(targetId, reason, duration)
    local source = source
    
    if not HasPermission(source, 'ban') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        local targetName = GetPlayerName(targetId)
        reason = reason or "Aucune raison spécifiée"
        duration = duration or "Permanent"
        
        local identifiers = GetPlayerIdentifiers(targetId)
        local primaryIdentifier = identifiers[1] -- Premier ID (steam ou license)
        
        -- Sauvegarder dans la base de données
        local isPermanent = (duration == "Permanent" or duration == "permanent")
        local durationDays = 0
        
        if not isPermanent then
            -- Parser la durée (ex: "24h", "7d", "30j")
            local number = tonumber(string.match(duration, "%d+"))
            local unit = string.match(duration, "%a+")
            
            if number then
                if unit == "h" or unit == "hours" then
                    durationDays = number / 24
                elseif unit == "d" or unit == "j" or unit == "days" or unit == "jours" then
                    durationDays = number
                elseif unit == "w" or unit == "weeks" or unit == "semaines" then
                    durationDays = number * 7
                elseif unit == "m" or unit == "months" or unit == "mois" then
                    durationDays = number * 30
                else
                    durationDays = 7 -- Par défaut 7 jours
                end
            else
                isPermanent = true
            end
        end
        
        -- Enregistrer le ban
        local adminIdentifier = GetPlayerIdentifiers(source)[1]
        BanPlayerDB(primaryIdentifier, targetName, reason, adminIdentifier, GetPlayerName(source), durationDays, isPermanent)
        
        SendLog('ban', source, string.format("%s - Durée: %s", reason, duration), targetId)
        DropPlayer(targetId, string.format([[
╔═══════════════════════════════════════╗
║  VOUS AVEZ ÉTÉ BANNI DU SERVEUR      ║
╠═══════════════════════════════════════╣
║                                       ║
║  Raison: %s
║                                       ║
║  Durée: %s
║  Par: %s
║                                       ║
╚═══════════════════════════════════════╝

💜 N-Admin - Par nano.pasa
        ]], reason, duration, GetPlayerName(source)))
        
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été banni", targetName))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Freeze/Unfreeze un joueur
RegisterNetEvent('admin:freezePlayer')
AddEventHandler('admin:freezePlayer', function(targetId, freeze)
    local source = source
    
    if not HasPermission(source, 'freeze') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:freezeTarget', targetId, freeze)
        
        local action = freeze and "gelé" or "dégelé"
        SendLog('freeze', source, string.format("Joueur %s", action), targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été %s", GetPlayerName(targetId), action))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Revive un joueur
RegisterNetEvent('admin:revivePlayer')
AddEventHandler('admin:revivePlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'revive') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:reviveTarget', targetId)
        SendLog('revive', source, "Joueur réanimé", targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été réanimé", GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Heal un joueur
RegisterNetEvent('admin:healPlayer')
AddEventHandler('admin:healPlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'heal') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:healTarget', targetId)
        SendLog('heal', source, "Joueur soigné", targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été soigné", GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Donner de l'armure
RegisterNetEvent('admin:giveArmor')
AddEventHandler('admin:giveArmor', function(targetId)
    local source = source
    
    if not HasPermission(source, 'give_armor') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:giveArmorTarget', targetId)
        SendLog('give_armor', source, "Armure donnée", targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~Armure donnée à %s", GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Kill un joueur
RegisterNetEvent('admin:killPlayer')
AddEventHandler('admin:killPlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'kill') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:killTarget', targetId)
        SendLog('kill', source, "Joueur tué", targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été tué", GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Donner de l'argent
RegisterNetEvent('admin:giveMoney')
AddEventHandler('admin:giveMoney', function(targetId, moneyType, amount)
    local source = source
    
    if not HasPermission(source, 'give_money') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        -- Adapter selon votre framework (ESX, QBCore, etc.)
        -- ESX: TriggerEvent('esx:giveMoney', targetId, moneyType, amount)
        -- QBCore: Player.Functions.AddMoney(moneyType, amount)
        
        SendLog('give_money', source, string.format("%s$ (%s)", amount, moneyType), targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s$ donné à %s", amount, GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Obtenir la liste des joueurs
RegisterNetEvent('admin:getPlayers')
AddEventHandler('admin:getPlayers', function()
    local source = source
    
    if not IsPlayerAdmin(source) then
        return
    end
    
    local players = {}
    local maxPlayers = GetNumPlayerIndices()
    
    for i = 0, maxPlayers - 1 do
        local playerId = GetPlayerFromIndex(i)
        if playerId ~= -1 then
            local playerName = GetPlayerName(playerId)
            local identifiers = GetPlayerIdentifiers(playerId)
            local steamId = "N/A"
            local discordId = "N/A"
            
            for _, id in pairs(identifiers) do
                if string.match(id, "steam:") then
                    steamId = id
                elseif string.match(id, "discord:") then
                    discordId = id
                end
            end
            
            table.insert(players, {
                id = playerId,
                name = playerName,
                steam = steamId,
                discord = discordId,
                ping = GetPlayerPing(playerId)
            })
        end
    end
    
    TriggerClientEvent('admin:receivePlayerList', source, players)
end)

-- Spectate un joueur
RegisterNetEvent('admin:spectatePlayer')
AddEventHandler('admin:spectatePlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'spectate') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        TriggerClientEvent('admin:startSpectate', source, targetId)
        SendLog('spectate', source, "Observation du joueur", targetId)
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Teleport vers un joueur
RegisterNetEvent('admin:teleportToPlayer')
AddEventHandler('admin:teleportToPlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'goto') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        local targetPed = GetPlayerPed(targetId)
        local targetCoords = GetEntityCoords(targetPed)
        TriggerClientEvent('admin:teleportToCoords', source, targetCoords)
        SendLog('teleport', source, "Téléportation vers le joueur", targetId)
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

-- Bring un joueur
RegisterNetEvent('admin:bringPlayer')
AddEventHandler('admin:bringPlayer', function(targetId)
    local source = source
    
    if not HasPermission(source, 'bring') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if GetPlayerName(targetId) then
        local adminPed = GetPlayerPed(source)
        local adminCoords = GetEntityCoords(adminPed)
        TriggerClientEvent('admin:teleportToCoords', targetId, adminCoords)
        SendLog('bring', source, "Joueur téléporté", targetId)
        TriggerClientEvent('admin:notify', source, string.format("~g~%s a été téléporté vers vous", GetPlayerName(targetId)))
    else
        TriggerClientEvent('admin:notify', source, Config.Messages.player_not_found)
    end
end)

