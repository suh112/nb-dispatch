
CREATE TABLE IF NOT EXISTS `nb_dispatch_calls` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `call_id` VARCHAR(32) NOT NULL,
    `code` VARCHAR(16) NOT NULL,
    `title` VARCHAR(128) NOT NULL,
    `description` TEXT NULL,
    `priority` TINYINT UNSIGNED NOT NULL DEFAULT 3,
    `coords` JSON NULL,
    `postal` VARCHAR(16) NULL,
    `status` VARCHAR(16) NOT NULL DEFAULT 'pending',
    `jobs` JSON NULL,
    `assigned_units` JSON NULL,
    `notes` JSON NULL,
    `created_at` DATETIME NOT NULL,
    `closed_at` DATETIME NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `call_id` (`call_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nb_dispatch_notes` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `call_id` VARCHAR(32) NOT NULL,
    `author` VARCHAR(64) NULL,
    `author_source` INT UNSIGNED NULL,
    `message` VARCHAR(280) NOT NULL,
    `created_at` DATETIME NOT NULL,
    PRIMARY KEY (`id`),
    KEY `call_id` (`call_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nb_dispatch_unit_history` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `call_id` VARCHAR(32) NOT NULL,
    `unit_source` INT UNSIGNED NULL,
    `callsign` VARCHAR(16) NULL,
    `job` VARCHAR(32) NULL,
    `action` VARCHAR(16) NOT NULL,
    `created_at` DATETIME NOT NULL,
    PRIMARY KEY (`id`),
    KEY `call_id` (`call_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
