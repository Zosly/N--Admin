# 💾 Installation Base de Données - N-Admin

## 📋 Prérequis

- ✅ Serveur MySQL ou MariaDB
- ✅ **oxmysql** OU **mysql-async** installé sur votre serveur FiveM

---

## 🚀 Installation Rapide (3 minutes)

### **Étape 1 : Importer le fichier SQL**

#### **Méthode 1 : phpMyAdmin**
1. Connectez-vous à phpMyAdmin
2. Sélectionnez votre base de données FiveM
3. Cliquez sur "Importer"
4. Choisissez le fichier `n-admin.sql`
5. Cliquez sur "Exécuter"

#### **Méthode 2 : HeidiSQL**
1. Ouvrez HeidiSQL
2. Connectez-vous à votre base de données
3. Cliquez sur "Fichier" → "Exécuter fichier SQL"
4. Sélectionnez `n-admin.sql`
5. Cliquez sur "Exécuter"

#### **Méthode 3 : Ligne de commande**
```bash
mysql -u votre_user -p votre_base_de_donnees < n-admin.sql
```

### **Étape 2 : Installer oxmysql**

#### **Si vous n'avez pas oxmysql:**

1. Téléchargez : https://github.com/overextended/oxmysql/releases
2. Extrayez dans `resources/oxmysql`
3. Ajoutez dans `server.cfg` **AVANT** N-Admin:
```cfg
ensure oxmysql
ensure fivem-admin-menu
```

4. Configurez dans `server.cfg`:
```cfg
set mysql_connection_string "mysql://user:password@localhost/database?charset=utf8mb4"
```

### **Étape 3 : Activer la base de données**

Dans `server/database.lua`, ligne 6 :
```lua
local USE_DATABASE = true -- ✅ true pour activer (déjà fait)
```

### **Étape 4 : Redémarrer**

```bash
restart fivem-admin-menu
```

---

## ✅ Vérification

### **Console serveur :**
Vous devriez voir :
```
[N-Admin] Base de données connectée avec succès!
```

### **Test de ban :**
1. Bannissez un joueur en jeu
2. Vérifiez dans la table `n_admin_bans`
3. Le joueur ne peut plus se reconnecter ✅

---

## 📊 Tables Créées (6 tables)

| Table | Description | Utilité |
|-------|-------------|---------|
| **n_admin_bans** | Bans des joueurs | Bans persistants après restart |
| **n_admin_logs** | Historique actions | Traçabilité complète |
| **n_admin_permissions** | Permissions custom | Gestion droits avancée |
| **n_admin_warnings** | Avertissements | Système de warns |
| **n_admin_player_notes** | Notes joueurs | Infos sur les joueurs |
| **n_admin_saved_positions** | Positions sauvegardées | TP personnalisés |

---

## 🔧 Fonctionnalités de la Base de Données

### **1. Bans Persistants** ✅

**Avantages :**
- ✅ Bans survivent aux restarts serveur
- ✅ Support bans temporaires avec expiration auto
- ✅ Historique complet des bans
- ✅ Message de ban stylisé

**Exemple :**
```
╔═══════════════════════════════════════╗
║  VOUS AVEZ ÉTÉ BANNI DU SERVEUR      ║
╠═══════════════════════════════════════╣
║  Raison: Triche                       ║
║  Durée: Permanent                     ║
║  Par: Admin Jean                      ║
╚═══════════════════════════════════════╝
```

### **2. Historique Complet** 📝

Toutes les actions sont enregistrées :
- Qui a fait quoi
- Quand
- Sur qui
- Avec quels détails

**Commande :** `/history [ID]` (à implémenter)

### **3. Système de Warnings** ⚠️

- 3 warnings = ban auto (configurable)
- Historique des warnings
- Notifications au joueur

### **4. Notes sur Joueurs** 📓

Ajoutez des notes privées sur les joueurs :
- Comportement
- Historique
- Infos importantes

### **5. Stats Admins** 📊

Voyez qui fait quoi :
- Nombre d'actions par admin
- Type d'actions
- Dernière activité

---

## 🎯 Commandes SQL Disponibles

### **Nouvelle commande : /unban**

```
/unban steam:110000XXXXXXXX
/unban license:1234567890abcdef
```

Débannit un joueur directement !

### **Nouvelle commande : /bans**

```
/bans
```

Affiche la liste des bans actifs

---

## 📋 Durées de Ban Supportées

| Format | Exemple | Résultat |
|--------|---------|----------|
| **Heures** | `24h` | 24 heures |
| **Jours** | `7d` ou `7j` | 7 jours |
| **Semaines** | `2w` | 2 semaines (14j) |
| **Mois** | `1m` | 1 mois (30j) |
| **Permanent** | `permanent` | À vie |

**Exemples dans le menu :**
- "24h" = 24 heures
- "7j" = 7 jours
- "permanent" = Ban permanent

---

## 🔄 Maintenance Automatique

### **Nettoyage Auto des Bans Expirés**

Le script nettoie automatiquement toutes les heures !

**Manuel :**
```sql
CALL cleanup_expired_bans();
```

### **Voir l'historique d'un joueur**
```sql
CALL get_player_history('steam:110000XXXXXXXX');
```

---

## 🛠️ Configuration

### **Désactiver la base de données**

Si vous ne voulez pas utiliser SQL :

Dans `server/database.lua` :
```lua
local USE_DATABASE = false -- ❌ Désactive la BDD
```

Le menu fonctionnera mais :
- ❌ Bans non persistants
- ❌ Pas d'historique sauvegardé

### **Changer de MySQL à mysql-async**

Le code supporte les deux automatiquement !

---

## 🐛 Dépannage

### **Erreur : "Unable to connect to MySQL"**

1. Vérifiez `oxmysql` est bien installé
2. Vérifiez `mysql_connection_string` dans server.cfg
3. Testez la connexion MySQL

### **Bans ne fonctionnent pas**

1. Vérifiez les tables sont créées :
```sql
SHOW TABLES LIKE 'n_admin_%';
```

2. Vérifiez la console :
```
[N-Admin] Base de données connectée avec succès!
```

3. Vérifiez `USE_DATABASE = true`

### **Erreur "Table doesn't exist"**

Réimportez `n-admin.sql` dans phpMyAdmin

---

## 📊 Statistiques Base de Données

**Tables :** 6  
**Vues :** 3  
**Procédures :** 3  
**Triggers :** 1  
**Index :** 8 (optimisé)

**Taille estimée :** < 5 MB pour 1000 bans/10000 logs

---

## 🔐 Sécurité

✅ **Prepared Statements** - Protection injection SQL
✅ **Index optimisés** - Requêtes ultra-rapides
✅ **Triggers auto** - Cohérence des données
✅ **Vues sécurisées** - Accès contrôlé

---

## 🎯 Commandes MySQL Utiles

### **Voir les bans actifs**
```sql
SELECT * FROM v_active_bans;
```

### **Voir les stats admins**
```sql
SELECT * FROM v_admin_stats;
```

### **Voir joueurs les plus sanctionnés**
```sql
SELECT * FROM v_most_sanctioned_players LIMIT 10;
```

### **Débannir un joueur**
```sql
UPDATE n_admin_bans SET is_active = 0 WHERE identifier = 'steam:110000XXX';
```

### **Compter les warnings d'un joueur**
```sql
SELECT COUNT(*) FROM n_admin_warnings WHERE identifier = 'steam:110000XXX';
```

---

## 🆕 Futures Fonctionnalités SQL

- [ ] Dashboard web des bans
- [ ] Export des logs en CSV
- [ ] Système de rapports joueurs
- [ ] Historique détaillé avec replay
- [ ] Auto-ban sur seuil warnings
- [ ] Whitelist système

---

## 📞 Support

**Problème avec SQL ?**

1. Vérifiez les logs serveur
2. Testez la connexion MySQL
3. Contactez **nano.pasa** sur Discord

---

## ✅ Checklist Installation SQL

- [ ] MySQL/MariaDB installé
- [ ] oxmysql installé sur FiveM
- [ ] `n-admin.sql` importé dans la BDD
- [ ] Connection string configurée
- [ ] `USE_DATABASE = true` activé
- [ ] Serveur redémarré
- [ ] Message "Base de données connectée" visible
- [ ] Test de ban effectué

---

**💜 N-Admin avec SQL - Bans persistants et historique complet !**  
**Créé par discord : nano.pasa**

