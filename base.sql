DROP DATABASE `magazzino`;
CREATE DATABASE IF NOT EXISTS `magazzino`
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;
USE `magazzino`;

--
-- Table structure for table `ASSET`
--

DROP TABLE IF EXISTS `ASSET`;
CREATE TABLE `ASSET` (
  `id_asset` int(11) NOT NULL AUTO_INCREMENT,
  `id_merce` int(11) NOT NULL,
  `serial` varchar(45) DEFAULT NULL,
  `pt_number` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_asset`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `MAGAZZINO`
--

DROP TABLE IF EXISTS `MAGAZZINO`;
CREATE TABLE `MAGAZZINO` (
  `id_merce` int(11) NOT NULL,
  `posizione` varchar(45) NOT NULL,
  `quantita` int(11) NOT NULL,
  PRIMARY KEY (`id_merce`,`posizione`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `MERCE`
--

DROP TABLE IF EXISTS `MERCE`;
CREATE TABLE `MERCE` (
  `id_merce` int(11) NOT NULL AUTO_INCREMENT,
  `tags` text NOT NULL,
  PRIMARY KEY (`id_merce`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `OPERAZIONI`
--

DROP TABLE IF EXISTS `OPERAZIONI`;
CREATE TABLE `OPERAZIONI` (
  `id_operazioni` int(11) NOT NULL AUTO_INCREMENT,
  `id_utenti` int(11) NOT NULL DEFAULT -1,
  `direzione` int(11) NOT NULL,
  `id_registro` int(11) NOT NULL,
  `id_merce` int(11) NOT NULL,
  `quantita` int(11) NOT NULL,
  `posizione` varchar(45) NOT NULL,
  `data` date DEFAULT NULL,
  `note` text,
  PRIMARY KEY (`id_operazioni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `ORDINI`
--

DROP TABLE IF EXISTS `ORDINI`;
CREATE TABLE `ORDINI` (
  `id_operazioni` int(11) NOT NULL,
  `id_registro_ordine` int(11) DEFAULT NULL,
  `trasportatore` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_operazioni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `REGISTRO`
--

DROP TABLE IF EXISTS `REGISTRO`;
CREATE TABLE `REGISTRO` (
  `id_registro` int(11) NOT NULL AUTO_INCREMENT,
  `contatto` varchar(45) NOT NULL,
  `tipo` varchar(45) NOT NULL,
  `numero` varchar(256) NOT NULL,
  `gruppo` int(11) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `file` text DEFAULT NULL,
  PRIMARY KEY (`id_registro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `proprieta`
--

DROP TABLE IF EXISTS `proprieta`;
CREATE TABLE `proprieta` (
  `id_proprieta` int(11) NOT NULL AUTO_INCREMENT,
  `sel` int(11) NOT NULL,
  `label` text NOT NULL,
  PRIMARY KEY (`id_proprieta`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `UTENTI`
--

DROP TABLE IF EXISTS `UTENTI`;
CREATE TABLE `UTENTI` (
  `id_utenti` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(45) NOT NULL,
  PRIMARY KEY (`id_utenti`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- ACCOUNT DI RETE
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account` (
  `rete` varchar(45) NOT NULL,
  `cognome` varchar(45) NOT NULL,
  PRIMARY KEY (`rete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- PERMISSION ACCOUNT DI RETE
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
  `rete` varchar(45) NOT NULL,
  `progetto` varchar(45) NOT NULL,
  `livello` int NOT NULL,
  PRIMARY KEY (`rete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- TRACING ACCOUNT DI RETE
DROP TABLE IF EXISTS `trace`;
CREATE TABLE `trace` (
  `id_trace` INT(11) NOT NULL AUTO_INCREMENT,
  `REQUEST_TIME` INT UNSIGNED NOT NULL,
  `REQUEST_URI` TEXT NOT NULL,
  `HTTP_REFERER` TEXT NOT NULL,
  `REMOTE_ADDR` VARCHAR(45) NOT NULL,
  `REMOTE_USER` VARCHAR(45) NOT NULL,
  `PHP_AUTH_USER` VARCHAR(45) NOT NULL,
  `HTTP_USER_AGENT` TEXT NOT NULL,
  PRIMARY KEY (`id_trace`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
