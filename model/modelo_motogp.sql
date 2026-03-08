CREATE TABLE `countries` (
  `id_country` varchar(3) PRIMARY KEY COMMENT 'Código ISO',
  `country_name` varchar(100)
);

CREATE TABLE `categories` (
  `id_category` varchar(10) PRIMARY KEY COMMENT 'ej: MotoGP, Moto2',
  `category_name` varchar(50)
);

CREATE TABLE `teams` (
  `id_team` int PRIMARY KEY AUTO_INCREMENT,
  `team_name` varchar(100)
);

CREATE TABLE `bikes` (
  `id_bike` int PRIMARY KEY AUTO_INCREMENT,
  `bike_name` varchar(50)
);

CREATE TABLE `circuits` (
  `id_circuit` int PRIMARY KEY AUTO_INCREMENT,
  `circuit_name` varchar(100),
  `id_country` varchar(3)
);

CREATE TABLE `riders` (
  `id_rider` int PRIMARY KEY AUTO_INCREMENT,
  `first_name` varchar(50),
  `last_name` varchar(50),
  `id_country` varchar(3)
);

CREATE TABLE `races` (
  `id_race` int PRIMARY KEY AUTO_INCREMENT,
  `year` int,
  `sequence` int,
  `date` date,
  `race_name` varchar(100),
  `id_circuit` int,
  `id_category` varchar(10)
);

CREATE TABLE `results` (
  `id_result` int PRIMARY KEY AUTO_INCREMENT,
  `id_race` int,
  `id_rider` int,
  `id_team` int,
  `id_bike` int,
  `rider_number` varchar(10) COMMENT 'El dorsal puede cambiar',
  `position` int COMMENT 'Puede ser nulo si no termina',
  `points` decimal(4,1),
  `speed` decimal(5,2),
  `time` varchar(50)
);

CREATE UNIQUE INDEX `races_index_0` ON `races` (`year`, `sequence`, `id_category`);

ALTER TABLE `circuits` ADD FOREIGN KEY (`id_country`) REFERENCES `countries` (`id_country`);

ALTER TABLE `riders` ADD FOREIGN KEY (`id_country`) REFERENCES `countries` (`id_country`);

ALTER TABLE `races` ADD FOREIGN KEY (`id_circuit`) REFERENCES `circuits` (`id_circuit`);

ALTER TABLE `races` ADD FOREIGN KEY (`id_category`) REFERENCES `categories` (`id_category`);

ALTER TABLE `results` ADD FOREIGN KEY (`id_race`) REFERENCES `races` (`id_race`);

ALTER TABLE `results` ADD FOREIGN KEY (`id_rider`) REFERENCES `riders` (`id_rider`);

ALTER TABLE `results` ADD FOREIGN KEY (`id_team`) REFERENCES `teams` (`id_team`);

ALTER TABLE `results` ADD FOREIGN KEY (`id_bike`) REFERENCES `bikes` (`id_bike`);
