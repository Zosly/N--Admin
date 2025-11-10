-- ============================================
-- N-Admin - Base de données SQL
-- Créé par discord : nano.pasa
-- ============================================

-- Table des bans
CREATE TABLE IF NOT EXISTS `n_admin_bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `banned_by` varchar(255) NOT NULL,
  `banned_by_name` varchar(255) NOT NULL,
  `ban_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expire_date` timestamp NULL DEFAULT NULL,
  `is_permanent` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table de l'historique des actions
CREATE TABLE IF NOT EXISTS `n_admin_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_identifier` varchar(255) NOT NULL,
  `admin_name` varchar(255) NOT NULL,
  `admin_rank` varchar(50) NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `target_identifier` varchar(255) DEFAULT NULL,
  `target_name` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `action_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `admin_identifier` (`admin_identifier`),
  KEY `action_type` (`action_type`),
  KEY `action_date` (`action_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table des permissions personnalisées
CREATE TABLE IF NOT EXISTS `n_admin_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `rank` varchar(50) NOT NULL,
  `added_by` varchar(255) NOT NULL,
  `added_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table des warnings
CREATE TABLE IF NOT EXISTS `n_admin_warnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `reason` text NOT NULL,
  `warned_by` varchar(255) NOT NULL,
  `warned_by_name` varchar(255) NOT NULL,
  `warn_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table des notes sur les joueurs
CREATE TABLE IF NOT EXISTS `n_admin_player_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `note` text NOT NULL,
  `note_type` enum('info','warning','positive','negative') NOT NULL DEFAULT 'info',
  `created_by` varchar(255) NOT NULL,
  `created_by_name` varchar(255) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table de sauvegarde des positions
CREATE TABLE IF NOT EXISTS `n_admin_saved_positions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `heading` float NOT NULL DEFAULT 0.0,
  `created_by` varchar(255) NOT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Vues utiles

-- Vue des bans actifs
CREATE OR REPLACE VIEW `v_active_bans` AS
SELECT 
  b.id,
  b.identifier,
  b.player_name,
  b.reason,
  b.banned_by_name,
  b.ban_date,
  b.expire_date,
  b.is_permanent,
  CASE 
    WHEN b.is_permanent = 1 THEN 'Permanent'
    WHEN b.expire_date > NOW() THEN CONCAT(TIMESTAMPDIFF(DAY, NOW(), b.expire_date), ' jours restants')
    ELSE 'Expiré'
  END as status
FROM n_admin_bans b
WHERE b.is_active = 1 
  AND (b.is_permanent = 1 OR b.expire_date > NOW());

-- Vue des statistiques admin
CREATE OR REPLACE VIEW `v_admin_stats` AS
SELECT 
  l.admin_name,
  l.admin_rank,
  COUNT(*) as total_actions,
  COUNT(CASE WHEN l.action_type = 'kick' THEN 1 END) as kicks,
  COUNT(CASE WHEN l.action_type = 'ban' THEN 1 END) as bans,
  COUNT(CASE WHEN l.action_type = 'warn' THEN 1 END) as warns,
  MAX(l.action_date) as last_action
FROM n_admin_logs l
GROUP BY l.admin_identifier, l.admin_name, l.admin_rank;

-- Vue des joueurs les plus sanctionnés
CREATE OR REPLACE VIEW `v_most_sanctioned_players` AS
SELECT 
  l.target_name,
  COUNT(*) as total_sanctions,
  COUNT(CASE WHEN l.action_type = 'kick' THEN 1 END) as kicks,
  COUNT(CASE WHEN l.action_type = 'ban' THEN 1 END) as bans,
  COUNT(CASE WHEN l.action_type = 'warn' THEN 1 END) as warns
FROM n_admin_logs l
WHERE l.target_identifier IS NOT NULL
GROUP BY l.target_identifier, l.target_name
ORDER BY total_sanctions DESC;

-- Insertion de données de test (optionnel - à commenter en production)

-- INSERT INTO n_admin_permissions (identifier, player_name, rank, added_by) 
-- VALUES ('steam:110000XXXXXXXX', 'Admin Test', 'superadmin', 'system');

-- Procédures stockées utiles

-- Procédure pour nettoyer les bans expirés
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS cleanup_expired_bans()
BEGIN
  UPDATE n_admin_bans 
  SET is_active = 0 
  WHERE is_permanent = 0 
    AND expire_date < NOW() 
    AND is_active = 1;
  
  SELECT ROW_COUNT() as bans_cleaned;
END //
DELIMITER ;

-- Procédure pour obtenir l'historique d'un joueur
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS get_player_history(IN player_id VARCHAR(255))
BEGIN
  SELECT 
    action_type,
    admin_name,
    details,
    action_date
  FROM n_admin_logs
  WHERE target_identifier = player_id
  ORDER BY action_date DESC
  LIMIT 50;
END //
DELIMITER ;

-- Procédure pour bannir un joueur
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS ban_player(
  IN p_identifier VARCHAR(255),
  IN p_player_name VARCHAR(255),
  IN p_reason TEXT,
  IN p_banned_by VARCHAR(255),
  IN p_banned_by_name VARCHAR(255),
  IN p_duration_days INT,
  IN p_is_permanent TINYINT
)
BEGIN
  DECLARE v_expire_date TIMESTAMP;
  
  IF p_is_permanent = 1 THEN
    SET v_expire_date = NULL;
  ELSE
    SET v_expire_date = DATE_ADD(NOW(), INTERVAL p_duration_days DAY);
  END IF;
  
  INSERT INTO n_admin_bans (
    identifier, 
    player_name, 
    reason, 
    banned_by, 
    banned_by_name,
    expire_date,
    is_permanent
  ) VALUES (
    p_identifier,
    p_player_name,
    p_reason,
    p_banned_by,
    p_banned_by_name,
    v_expire_date,
    p_is_permanent
  );
  
  -- Log l'action
  INSERT INTO n_admin_logs (
    admin_identifier,
    admin_name,
    admin_rank,
    action_type,
    target_identifier,
    target_name,
    details
  ) VALUES (
    p_banned_by,
    p_banned_by_name,
    'admin',
    'ban',
    p_identifier,
    p_player_name,
    CONCAT('Raison: ', p_reason, ' | Durée: ', 
      IF(p_is_permanent = 1, 'Permanent', CONCAT(p_duration_days, ' jours')))
  );
  
  SELECT LAST_INSERT_ID() as ban_id;
END //
DELIMITER ;

-- Trigger pour log automatique des warnings
DELIMITER //
CREATE TRIGGER IF NOT EXISTS after_warning_insert
AFTER INSERT ON n_admin_warnings
FOR EACH ROW
BEGIN
  INSERT INTO n_admin_logs (
    admin_identifier,
    admin_name,
    admin_rank,
    action_type,
    target_identifier,
    target_name,
    details
  ) VALUES (
    NEW.warned_by,
    NEW.warned_by_name,
    'admin',
    'warn',
    NEW.identifier,
    NEW.player_name,
    CONCAT('Avertissement: ', NEW.reason)
  );
END //
DELIMITER ;

-- Index pour optimisation des performances
CREATE INDEX idx_logs_date ON n_admin_logs(action_date DESC);
CREATE INDEX idx_bans_identifier ON n_admin_bans(identifier, is_active);
CREATE INDEX idx_warnings_identifier ON n_admin_warnings(identifier);

-- ============================================
-- NOTES D'INSTALLATION
-- ============================================
-- 1. Importez ce fichier dans votre base de données MySQL/MariaDB
-- 2. Configurez la connexion dans server/database.lua (à créer)
-- 3. Les bans seront maintenant persistants après restart serveur
-- 4. L'historique de toutes les actions sera sauvegardé
-- ============================================

-- ============================================
-- MAINTENANCE
-- ============================================
-- Pour nettoyer les bans expirés, exécutez:
-- CALL cleanup_expired_bans();
--
-- Pour voir l'historique d'un joueur:
-- CALL get_player_history('steam:110000XXXXXXXX');
-- ============================================

-- Version: 1.0.0
-- Créé par: discord : nano.pasa
-- Date: 2025-01-10

