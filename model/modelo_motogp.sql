-- CREACIÓN DE LA BASE DE DATOS:
CREATE DATABASE IF NOT EXISTS motogp_db;
USE motogp_db;


-- 1) TABLAS MAESTRAS (INDEPENDIENTES):

CREATE TABLE `countries` (
  `id_country` varchar(3) PRIMARY KEY COMMENT 'Código ISO (ej: SPA, ITA, GBR).',
  `country_name` varchar(100)
);

CREATE TABLE `categories` (
  `id_category` varchar(10) PRIMARY KEY COMMENT 'Identificador de la categoría (ej: MotoGP, Moto2).',
  `category_name` varchar(50)
);

CREATE TABLE `teams` (
  `id_team` int PRIMARY KEY AUTO_INCREMENT COMMENT 'Generación automática de IDs.',
  `team_name` varchar(100)
);

CREATE TABLE `bikes` (
  `id_bike` int PRIMARY KEY AUTO_INCREMENT COMMENT 'Constructor o marca de la moto.',
  `bike_name` varchar(50)
);


-- 2) TABLAS DEPENDIENTES DE LAS MAESTRAS:

CREATE TABLE `circuits` (
  `id_circuit` int PRIMARY KEY AUTO_INCREMENT,
  `circuit_name` varchar(100),
  `id_country` varchar(3),

  -- Integridad referencial: Un circuito debe estar en un país existente: 
  CONSTRAINT `fk_circuits_country` FOREIGN KEY (`id_country`) REFERENCES `countries` (`id_country`)
);

CREATE TABLE `riders` (
  `id_rider` int PRIMARY KEY AUTO_INCREMENT,
  `first_name` varchar(50),
  `last_name` varchar(50),
  `id_country` varchar(3),

  -- Integridad referencial: Un piloto debe tener asignado un país existente:  
  CONSTRAINT `fk_riders_country` FOREIGN KEY (`id_country`) REFERENCES `countries` (`id_country`)
);


-- 3) TABLAS QUE DEPENDEN DE CIRCUITOS Y CATEGORÍAS:

CREATE TABLE `races` (
  `id_race` int PRIMARY KEY AUTO_INCREMENT,
  `year` int,
  `sequence` int,
  `date` date,
  `race_name` varchar(100),
  `id_circuit` int,
  `id_category` varchar(10),
  
  -- Restricción de unicidad (evita insertar por error la misma carrera dos veces):
  CONSTRAINT `uq_race_event` UNIQUE (`year`, `sequence`, `id_category`),
  
  -- Claves foráneas:
  CONSTRAINT `fk_races_circuit` FOREIGN KEY (`id_circuit`) REFERENCES `circuits` (`id_circuit`),
  CONSTRAINT `fk_races_category` FOREIGN KEY (`id_category`) REFERENCES `categories` (`id_category`)
);


-- 4) TABLA DE RESULTADOS: 

CREATE TABLE `results` (
  `id_result` int PRIMARY KEY AUTO_INCREMENT,
  `id_race` int,
  `id_rider` int,
  `id_team` int,
  `id_bike` int,
  
  -- Atributos específicos de la participación en esa carrera:
  `rider_number` varchar(10) COMMENT 'El dorsal puede cambiar de una carrera a otra.',
  `position` int COMMENT 'Puede ser nulo o negativo si el piloto no termina.',
  `points` decimal(4,1) COMMENT 'Permite medios puntos si la carrera se suspende.',
  `speed` decimal(5,2) COMMENT 'Velocidad en km/h.',
  `time` varchar(50),
  
  -- Claves foráneas:
  CONSTRAINT `fk_results_race` FOREIGN KEY (`id_race`) REFERENCES `races` (`id_race`),
  CONSTRAINT `fk_results_rider` FOREIGN KEY (`id_rider`) REFERENCES `riders` (`id_rider`),
  CONSTRAINT `fk_results_team` FOREIGN KEY (`id_team`) REFERENCES `teams` (`id_team`),
  CONSTRAINT `fk_results_bike` FOREIGN KEY (`id_bike`) REFERENCES `bikes` (`id_bike`)
);