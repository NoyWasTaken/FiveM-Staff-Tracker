CREATE TABLE IF NOT EXISTS `staff_tracker` (`id` INT(10) NOT NULL AUTO_INCREMENT, `identifier` VARCHAR(32) NOT NULL, `date` VARCHAR(32) NOT NULL, `time` INT(10) NOT NULL, PRIMARY KEY(`id`), UNIQUE(`identifier`, `date`));