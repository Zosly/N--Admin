# 🛡️ N-Admin - Menu Admin FiveM

Menu d'administration complet et professionnel pour serveurs RP FiveM avec interface moderne.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)
![License](https://img.shields.io/badge/license-Non--Commercial-red.svg)

---

## ⚠️ **IMPORTANT - LICENCE NON-COMMERCIALE**

> **✅ GRATUIT** - Ce menu est **totalement gratuit**  
> **❌ VENTE INTERDITE** - Vous **NE POUVEZ PAS** vendre ce menu  
> **💜 Créé par discord : nano.pasa** - Crédits obligatoires

---

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Permissions](#-permissions)
- [Screenshots](#-screenshots)
- [Support](#-support)

---

## ✨ Fonctionnalités

### 👥 Gestion des Joueurs
- ✅ Kick / Ban avec raisons
- ❄️ Freeze / Unfreeze
- 💚 Revive / Heal / Give Armor
- 🚀 Téléportation (Goto / Bring)
- 👁️ Spectate
- 💀 Kill
- 💰 Give Money (compatible ESX/QBCore)
- 🔍 Recherche de joueurs
- 📊 Affichage du ping

### 🚗 Gestion des Véhicules
- 🏎️ Spawn de véhicules (8 catégories, 50+ véhicules)
  - Super Cars
  - Sports
  - SUV
  - Police
  - Emergency
  - Motos
  - Hélicoptères
  - Avions
- 🔧 Réparer / Nettoyer / Retourner
- ⚙️ Tune Max automatique
- 🎨 Changer les couleurs
- 🗑️ Supprimer véhicule
- 🚀 Boost véhicule
- 🛡️ Mode God véhicule

### 🖥️ Gestion du Serveur
- 📢 Annonces globales
- 🌤️ Contrôle météo (12 types)
- 🕐 Contrôle de l'heure
- 🧹 Nettoyage de zone (radius configurable)
- 🚗 Clear tous les véhicules
- 🚶 Clear tous les PNJ
- 🔄 Gestion des ressources (start/stop/restart)

### 🛠️ Outils Personnels
- ✈️ Noclip (avec contrôles avancés)
- 🛡️ God Mode
- 👻 Mode Invisible
- 💚 Auto-heal
- 💀 Suicide
- 📍 TP au waypoint

### 📍 Téléportation Rapide
- 11 lieux prédéfinis
  - Legion Square
  - Hôpital
  - Commissariat LSPD
  - Pacific Bank
  - Aéroport
  - Mont Chiliad
  - Casino
  - Et plus...

### 🔒 Système de Permissions
- 4 grades configurables:
  - **Superadmin** - Accès total
  - **Admin** - Accès élevé
  - **Moderator** - Accès modéré
  - **Support** - Accès basique
- Permissions granulaires par action
- Support multi-identifiants (Steam, Discord, License)

### 📝 Système de Logs
- 📊 Logs Discord (webhooks)
- 💻 Logs console
- 📜 Historique des actions
- 🎨 Logs colorés par type d'action

---

## ⚡ Performances Ultra-Optimisées

**Impact serveur : 0.00ms - 0.01ms** 🚀

- ✅ **Threads optimisés** - Pas de Wait(0) inutiles
- ✅ **Natives cachées** - Appels ultra-rapides
- ✅ **Variables locales** - Performance maximale
- ✅ **Calculs pré-compilés** - Pas de répétition
- ✅ **10x plus performant** que les autres menus admin

📊 **[Voir le guide complet des performances →](PERFORMANCES.md)**

---

## 📦 Installation

### Prérequis
- Serveur FiveM configuré
- Accès au dossier `resources`

### Étapes

1. **Télécharger le menu**
   ```bash
   cd resources
   git clone https://github.com/votre-repo/fivem-admin-menu.git
   ```

2. **Ajouter au server.cfg**
   ```cfg
   ensure fivem-admin-menu
   ```

3. **Redémarrer le serveur**
   ```bash
   restart fivem-admin-menu
   ```

---

## ⚙️ Configuration

### 1. Configuration de base (`config.lua`)

#### Touche d'ouverture
```lua
Config.OpenMenuKey = 121 -- F10 par défaut
```

#### Webhook Discord
```lua
Config.Webhook = "VOTRE_WEBHOOK_DISCORD_ICI"
```

#### Logs console
```lua
Config.ConsoleLogs = true
```

### 2. Ajouter des admins

#### Méthode 1: Dans le fichier config.lua
```lua
Config.Admins = {
    ["steam:110000XXXXXXXX"] = "superadmin",
    ["discord:123456789012345678"] = "admin",
    ["license:1234567890abcdef"] = "moderator",
}
```

#### Méthode 2: En jeu (superadmin uniquement)
```
/addadmin [ID] [grade]
```

Exemple:
```
/addadmin 5 admin
/addadmin 12 moderator
```

### 3. Configurer les permissions

Les permissions par grade sont définies dans `config.lua` :

```lua
Config.Permissions = {
    superadmin = {
        "kick", "ban", "freeze", "teleport", "spectate", 
        "spawn_vehicle", "noclip", "god_mode", -- etc.
    },
    admin = {
        "kick", "freeze", "teleport", "spawn_vehicle", "noclip"
    },
    moderator = {
        "kick", "freeze", "teleport"
    },
    support = {
        "freeze", "teleport"
    }
}
```

### 4. Personnaliser les véhicules

Ajouter/modifier les catégories dans `config.lua` :

```lua
Config.Vehicles = {
    {
        label = "🏎️ Vos Super Cars",
        vehicles = {
            {name = "Ferrari", model = "t20"},
            {name = "Lamborghini", model = "zentorno"},
        }
    },
}
```

### 5. Ajouter des lieux de téléportation

```lua
Config.TeleportLocations = {
    {label = "🏢 Votre Lieu", coords = vector3(x, y, z)},
}
```

---

## 🎮 Utilisation

### Commandes

| Commande | Description | Permission |
|----------|-------------|-----------|
| `/admin` | Ouvrir le menu admin | Être admin |
| `F10` | Ouvrir le menu (par défaut) | Être admin |
| `/myrank` | Voir son grade | Être admin |
| `/admins` | Voir les admins en ligne | Tous |
| `/adminhelp` | Aide des commandes | Être admin |
| `/addadmin [ID] [grade]` | Ajouter un admin | Superadmin |

### Navigation dans le menu

- **ESC** ou **Bouton ✕** : Fermer le menu
- **Onglets** : Naviguer entre les sections
- **Clic** sur un joueur : Ouvrir le menu d'actions

### Contrôles Noclip

- **W/A/S/D** : Se déplacer
- **Space** : Monter
- **Ctrl** : Descendre
- **Shift** : Mode rapide (5x)
- **Alt** : Mode lent (0.2x)

---

## 🔐 Permissions

### Liste complète des permissions

#### Gestion des joueurs
- `kick` - Kick un joueur
- `ban` - Ban un joueur
- `unban` - Unban un joueur
- `freeze` - Freeze/Unfreeze
- `teleport` - Se téléporter
- `teleport_to` - TP vers un joueur
- `bring` - Bring un joueur
- `goto` - Aller vers un joueur
- `spectate` - Observer un joueur
- `revive` - Réanimer
- `heal` - Soigner
- `give_armor` - Donner armure
- `kill` - Tuer un joueur
- `slap` - Slap un joueur
- `give_money` - Donner de l'argent
- `set_job` - Changer le job
- `give_item` - Donner un item
- `clear_inventory` - Vider l'inventaire
- `manage_inventory` - Gérer l'inventaire

#### Serveur
- `announce` - Annonces globales
- `weather` - Changer la météo
- `time` - Changer l'heure
- `clear_area` - Nettoyer une zone
- `clear_cars` - Clear véhicules
- `clear_peds` - Clear PNJ
- `restart_resource` - Restart ressource
- `stop_resource` - Stop ressource
- `start_resource` - Start ressource
- `manage_server` - Gestion serveur

#### Véhicules
- `spawn_vehicle` - Spawn véhicule
- `delete_vehicle` - Supprimer véhicule
- `repair_vehicle` - Réparer véhicule
- `clean_vehicle` - Nettoyer véhicule
- `flip_vehicle` - Retourner véhicule
- `boost_vehicle` - Booster véhicule
- `god_vehicle` - God mode véhicule

#### Outils
- `noclip` - Noclip
- `invisible` - Mode invisible
- `god_mode` - Mode god
- `unlimited_stamina` - Stamina illimitée
- `super_jump` - Super saut
- `fast_run` - Course rapide
- `fast_swim` - Nage rapide

#### Administration
- `manage_permissions` - Gérer permissions
- `view_logs` - Voir les logs

---

## 🎨 Interface

### Caractéristiques de l'UI

- ✅ Design moderne et professionnel
- 🎨 Gradient colorés et animations fluides
- 📱 Responsive (s'adapte à toutes les résolutions)
- 🔍 Barre de recherche pour les joueurs
- 🎯 Navigation par onglets intuitive
- 🌈 Badges de grade colorés
- 📊 Affichage du ping en temps réel
- 🎭 Modals pour actions détaillées

### Thème

- **Couleurs principales** : Violet/Bleu (#667eea, #764ba2)
- **Background** : Dégradé sombre (#1e1e2e, #2a2a3e)
- **Effets** : Blur, shadows, transitions
- **Police** : Inter (Google Fonts)

---

## 🔧 Intégration Framework

### ESX
```lua
-- Dans give_money
TriggerEvent('esx:getSharedObject', function(obj)
    local xPlayer = obj.GetPlayerFromId(targetId)
    xPlayer.addMoney(amount)
end)
```

### QBCore
```lua
-- Dans give_money
local Player = QBCore.Functions.GetPlayer(targetId)
Player.Functions.AddMoney(moneyType, amount)
```

---

## 📝 Logs Discord

### Configuration du Webhook

1. Créer un webhook sur votre serveur Discord
2. Copier l'URL du webhook
3. Coller dans `config.lua` :
```lua
Config.Webhook = "https://discord.com/api/webhooks/..."
```

### Format des logs

Les logs incluent :
- 👤 Nom de l'administrateur
- 🎯 Action effectuée
- 👥 Cible (si applicable)
- 📝 Détails de l'action
- 🕐 Timestamp

---

## 🐛 Dépannage

### Le menu ne s'ouvre pas

1. Vérifier que vous êtes dans `Config.Admins`
2. Vérifier la touche configurée (`Config.OpenMenuKey`)
3. Vérifier les logs console pour erreurs
4. Essayer `/admin` au lieu de la touche

### Pas de permissions

1. Vérifier votre identifiant dans `Config.Admins`
2. Utiliser `/myrank` pour voir votre grade
3. Vérifier `Config.Permissions` pour votre grade

### Logs Discord ne fonctionnent pas

1. Vérifier l'URL du webhook
2. Tester le webhook avec Discord
3. Vérifier `Config.Webhook` dans config.lua

### Véhicules ne spawn pas

1. Vérifier le nom du modèle
2. Vérifier la permission `spawn_vehicle`
3. Regarder les logs console

---

## 📸 Screenshots

*Interface du menu avec gestion des joueurs*
*Spawn de véhicules par catégories*
*Contrôle serveur (météo, heure, nettoyage)*
*Outils personnels (noclip, god mode, etc.)*

---

## 🤝 Support

### Besoin d'aide ?

- 📧 Email: darklife.0992@gmail.com
- 💬 Discord: nano.pasa

### Contribuer

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📜 Licence

⚠️ **LICENCE NON-COMMERCIALE** ⚠️

✅ **Autorisé :**
- Utilisation gratuite
- Modification du code
- Partage gratuit
- Apprentissage

❌ **INTERDIT :**
- **VENTE du menu** (même modifié)
- Usage commercial
- Retrait des crédits
- Mise derrière un paywall

📄 Voir le fichier [LICENSE](LICENSE) pour les conditions complètes.

**© 2025 nano.pasa (Discord) - Tous droits réservés**

---

## 🙏 Remerciements

- FiveM Community
- Tous les contributeurs
- Les testeurs du serveur

---

## 📋 Changelog

### Version 1.0.0 (2025-01-10)
- 🎉 Release initiale
- ✅ Interface complète
- ✅ Système de permissions
- ✅ Logs Discord
- ✅ 50+ véhicules
- ✅ Toutes les fonctions admin

---

<p align="center">
  Fait avec ❤️ pour la communauté FiveM
</p>

<p align="center">
  ⭐ Si ce menu vous plaît, n'oubliez pas de mettre une étoile !
</p>

