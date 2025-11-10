-- Gestion de la base de données
-- Créé par discord : nano.pasa

-- Configuration de la connexion MySQL
-- Assurez-vous d'avoir oxmysql ou mysql-async installé

local USE_DATABASE = true -- Mettre à false pour désactiver la base de données

-- Vérifier si oxmysql est disponible
local function IsDatabaseAvailable()
    if not USE_DATABASE then
        return false
    end
    
    if GetResourceState('oxmysql') == 'started' then
        return true
    elseif GetResourceState('mysql-async') == 'started' then
        return true
    end
    
    print("^3[N-Admin] Attention: Aucune ressource MySQL détectée. Les bans ne seront pas persistants.^7")
    return false
end

local DB_AVAILABLE = IsDatabaseAvailable()

-- ============================================
-- GESTION DES BANS
-- ============================================

-- Vérifier si un joueur est banni
function IsPlayerBanned(identifier)
    if not DB_AVAILABLE then return false end
    
    local result = MySQL.Sync.fetchAll('SELECT * FROM n_admin_bans WHERE identifier = @identifier AND is_active = 1 AND (is_permanent = 1 OR expire_date > NOW())', {
        ['@identifier'] = identifier
    })
    
    if result and #result > 0 then
        return true, result[1]
    end
    
    return false, nil
end

-- Bannir un joueur dans la base de données
function BanPlayerDB(identifier, playerName, reason, bannedBy, bannedByName, durationDays, isPermanent)
    if not DB_AVAILABLE then return false end
    
    local expireDate = nil
    if not isPermanent then
        expireDate = os.date('%Y-%m-%d %H:%M:%S', os.time() + (durationDays * 24 * 60 * 60))
    end
    
    MySQL.Async.execute('INSERT INTO n_admin_bans (identifier, player_name, reason, banned_by, banned_by_name, expire_date, is_permanent) VALUES (@identifier, @playerName, @reason, @bannedBy, @bannedByName, @expireDate, @isPermanent)', {
        ['@identifier'] = identifier,
        ['@playerName'] = playerName,
        ['@reason'] = reason,
        ['@bannedBy'] = bannedBy,
        ['@bannedByName'] = bannedByName,
        ['@expireDate'] = expireDate,
        ['@isPermanent'] = isPermanent and 1 or 0
    }, function(affectedRows)
        if affectedRows > 0 then
            print(string.format("^2[N-Admin] Ban enregistré pour %s (%s)^7", playerName, identifier))
        end
    end)
    
    return true
end

-- Débannir un joueur
function UnbanPlayerDB(identifier)
    if not DB_AVAILABLE then return false end
    
    MySQL.Async.execute('UPDATE n_admin_bans SET is_active = 0 WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            print(string.format("^2[N-Admin] Joueur débanni: %s^7", identifier))
        end
    end)
    
    return true
end

-- Obtenir la liste des bans actifs
function GetActiveBans(callback)
    if not DB_AVAILABLE then
        callback({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM v_active_bans ORDER BY ban_date DESC LIMIT 100', {}, function(result)
        callback(result or {})
    end)
end

-- ============================================
-- LOGS / HISTORIQUE
-- ============================================

-- Enregistrer une action dans les logs
function LogActionDB(adminIdentifier, adminName, adminRank, actionType, targetIdentifier, targetName, details)
    if not DB_AVAILABLE then return end
    
    MySQL.Async.execute('INSERT INTO n_admin_logs (admin_identifier, admin_name, admin_rank, action_type, target_identifier, target_name, details) VALUES (@adminIdentifier, @adminName, @adminRank, @actionType, @targetIdentifier, @targetName, @details)', {
        ['@adminIdentifier'] = adminIdentifier,
        ['@adminName'] = adminName,
        ['@adminRank'] = adminRank,
        ['@actionType'] = actionType,
        ['@targetIdentifier'] = targetIdentifier,
        ['@targetName'] = targetName,
        ['@details'] = details
    })
end

-- Obtenir l'historique d'un joueur
function GetPlayerHistory(identifier, callback)
    if not DB_AVAILABLE then
        callback({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM n_admin_logs WHERE target_identifier = @identifier ORDER BY action_date DESC LIMIT 50', {
        ['@identifier'] = identifier
    }, function(result)
        callback(result or {})
    end)
end

-- Obtenir les statistiques des admins
function GetAdminStats(callback)
    if not DB_AVAILABLE then
        callback({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM v_admin_stats ORDER BY total_actions DESC', {}, function(result)
        callback(result or {})
    end)
end

-- ============================================
-- WARNINGS / AVERTISSEMENTS
-- ============================================

-- Ajouter un warning
function AddWarningDB(identifier, playerName, reason, warnedBy, warnedByName)
    if not DB_AVAILABLE then return end
    
    MySQL.Async.execute('INSERT INTO n_admin_warnings (identifier, player_name, reason, warned_by, warned_by_name) VALUES (@identifier, @playerName, @reason, @warnedBy, @warnedByName)', {
        ['@identifier'] = identifier,
        ['@playerName'] = playerName,
        ['@reason'] = reason,
        ['@warnedBy'] = warnedBy,
        ['@warnedByName'] = warnedByName
    })
end

-- Obtenir les warnings d'un joueur
function GetPlayerWarnings(identifier, callback)
    if not DB_AVAILABLE then
        callback({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM n_admin_warnings WHERE identifier = @identifier ORDER BY warn_date DESC', {
        ['@identifier'] = identifier
    }, function(result)
        callback(result or {})
    end)
end

-- Compter les warnings d'un joueur
function CountPlayerWarnings(identifier, callback)
    if not DB_AVAILABLE then
        callback(0)
        return
    end
    
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM n_admin_warnings WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(count)
        callback(count or 0)
    end)
end

-- ============================================
-- PERMISSIONS
-- ============================================

-- Sauvegarder une permission dans la base de données
function SavePermissionDB(identifier, playerName, rank, addedBy)
    if not DB_AVAILABLE then return end
    
    MySQL.Async.execute('INSERT INTO n_admin_permissions (identifier, player_name, rank, added_by) VALUES (@identifier, @playerName, @rank, @addedBy) ON DUPLICATE KEY UPDATE rank = @rank, player_name = @playerName', {
        ['@identifier'] = identifier,
        ['@playerName'] = playerName,
        ['@rank'] = rank,
        ['@addedBy'] = addedBy
    })
end

-- Charger les permissions depuis la base de données
function LoadPermissionsFromDB(callback)
    if not DB_AVAILABLE then
        callback({})
        return
    end
    
    MySQL.Async.fetchAll('SELECT * FROM n_admin_permissions', {}, function(result)
        local permissions = {}
        if result then
            for _, row in pairs(result) do
                permissions[row.identifier] = row.rank
            end
        end
        callback(permissions)
    end)
end

-- ============================================
-- MAINTENANCE
-- ============================================

-- Nettoyer les bans expirés
function CleanupExpiredBans()
    if not DB_AVAILABLE then return end
    
    MySQL.Async.execute('UPDATE n_admin_bans SET is_active = 0 WHERE is_permanent = 0 AND expire_date < NOW() AND is_active = 1', {}, function(affectedRows)
        if affectedRows > 0 then
            print(string.format("^2[N-Admin] %d ban(s) expiré(s) nettoyé(s)^7", affectedRows))
        end
    end)
end

-- Nettoyer automatiquement toutes les heures
if DB_AVAILABLE then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(3600000) -- 1 heure
            CleanupExpiredBans()
        end
    end)
end

-- ============================================
-- EVENTS
-- ============================================

-- Vérifier les bans à la connexion
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    
    if not DB_AVAILABLE then return end
    
    deferrals.defer()
    deferrals.update("Vérification du statut...")
    
    Citizen.Wait(500)
    
    for _, identifier in pairs(identifiers) do
        local isBanned, banInfo = IsPlayerBanned(identifier)
        
        if isBanned then
            local message = string.format([[
╔═══════════════════════════════════════╗
║     VOUS ÊTES BANNI DU SERVEUR       ║
╠═══════════════════════════════════════╣
║                                       ║
║  Raison: %s
║                                       ║
║  Banni par: %s
║  Date: %s
║                                       ║
║  Durée: %s
║                                       ║
╚═══════════════════════════════════════╝

💜 N-Admin - Par nano.pasa
            ]], 
                banInfo.reason,
                banInfo.banned_by_name,
                banInfo.ban_date,
                banInfo.is_permanent == 1 and "Permanent" or "Temporaire"
            )
            
            deferrals.done(message)
            return
        end
    end
    
    deferrals.done()
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('IsPlayerBanned', IsPlayerBanned)
exports('BanPlayerDB', BanPlayerDB)
exports('UnbanPlayerDB', UnbanPlayerDB)
exports('LogActionDB', LogActionDB)
exports('GetPlayerHistory', GetPlayerHistory)
exports('AddWarningDB', AddWarningDB)
exports('GetPlayerWarnings', GetPlayerWarnings)
exports('SavePermissionDB', SavePermissionDB)
exports('LoadPermissionsFromDB', LoadPermissionsFromDB)

-- Message de démarrage
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    
    if DB_AVAILABLE then
        print("^2[N-Admin] Base de données connectée avec succès!^7")
        CleanupExpiredBans() -- Nettoyer au démarrage
    else
        print("^3[N-Admin] Mode sans base de données - Les bans ne seront pas persistants^7")
    end
end)

-- ============================================
-- COMMANDES ADMIN
-- ============================================

-- Commande pour voir les bans
RegisterCommand('bans', function(source)
    if not IsPlayerAdmin(source) then
        return
    end
    
    GetActiveBans(function(bans)
        TriggerClientEvent('chat:addMessage', source, {
            color = {0, 255, 255},
            multiline = true,
            args = {"N-Admin", string.format("Bans actifs: %d", #bans)}
        })
        
        for i, ban in pairs(bans) do
            if i <= 10 then -- Limiter à 10 pour ne pas spam
                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 255},
                    multiline = true,
                    args = {"", string.format("• %s - %s", ban.player_name, ban.reason)}
                })
            end
        end
    end)
end)

-- Commande pour débannir
RegisterCommand('unban', function(source, args)
    if not HasPermission(source, 'unban') then
        TriggerClientEvent('admin:notify', source, Config.Messages.no_permission)
        return
    end
    
    if #args < 1 then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 165, 0},
            multiline = true,
            args = {"N-Admin", "Usage: /unban [steam:xxx ou license:xxx]"}
        })
        return
    end
    
    local identifier = args[1]
    UnbanPlayerDB(identifier)
    
    TriggerClientEvent('admin:notify', source, "~g~Joueur débanni")
    SendLog('unban', source, string.format("Identifier: %s", identifier))
end)

