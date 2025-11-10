fx_version 'cerulean'
game 'gta5'

author 'nano.pasa (Discord)'
description 'N-Admin - Menu Admin Complet pour Serveur RP FiveM - Créé par discord : nano.pasa'
version '1.0.0'

-- ⚠️ LICENCE NON-COMMERCIALE ⚠️
-- ✅ Utilisation et partage GRATUIT autorisés
-- ❌ VENTE INTERDITE - Ne pas vendre ce menu
-- ❌ Retrait des crédits INTERDIT
-- © 2025 nano.pasa - Tous droits réservés

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- Support oxmysql (optionnel)
    'server/database.lua',
    'server/permissions.lua',
    'server/logs.lua',
    'server/report_system.lua', -- ✅ NOUVEAU : Système de reports
    'server/player_management.lua',
    'server/server_management.lua',
    'server/vehicle_management.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/player_actions.lua',
    'client/vehicle_actions.lua',
    'client/server_actions.lua',
    'client/teleport.lua',
    'client/noclip.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}

