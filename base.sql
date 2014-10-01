DROP DATABASE `magazzino`;
CREATE DATABASE IF NOT EXISTS `magazzino` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `magazzino`;
--
-- Host: localhost    Database: magazzino
-- ------------------------------------------------------
-- Server version	5.5.32

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ASSET`
--

DROP TABLE IF EXISTS `ASSET`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ASSET` (
  `id_asset` int(11) NOT NULL AUTO_INCREMENT,
  `id_merce` int(11) NOT NULL,
  `serial` varchar(45) DEFAULT NULL,
  `pt_number` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_asset`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MAGAZZINO`
--

DROP TABLE IF EXISTS `MAGAZZINO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MAGAZZINO` (
  `id_merce` int(11) NOT NULL,
  `posizione` varchar(45) NOT NULL,
  `quantita` int(11) NOT NULL,
  PRIMARY KEY (`id_merce`,`posizione`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `MERCE`
--

DROP TABLE IF EXISTS `MERCE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `MERCE` (
  `id_merce` int(11) NOT NULL AUTO_INCREMENT,
  `tags` text NOT NULL,
  PRIMARY KEY (`id_merce`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `OPERAZIONI`
--

DROP TABLE IF EXISTS `OPERAZIONI`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ORDINI`
--

DROP TABLE IF EXISTS `ORDINI`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ORDINI` (
  `id_operazioni` int(11) NOT NULL,
  `id_registro_ordine` int(11) DEFAULT NULL,
  `trasportatore` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_operazioni`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `REGISTRO`
--

DROP TABLE IF EXISTS `REGISTRO`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `REGISTRO` (
  `id_registro` int(11) NOT NULL AUTO_INCREMENT,
  `contatto` varchar(45) NOT NULL,
  `tipo` varchar(45) NOT NULL,
  `numero` varchar(45) NOT NULL,
  `gruppo` int(11) DEFAULT NULL,
  `data` date DEFAULT NULL,
  `file` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_registro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proprieta`
--

DROP TABLE IF EXISTS `proprieta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proprieta` (
  `sel` int(11) NOT NULL,
  `label` varchar(45) NOT NULL,
  PRIMARY KEY (`sel`,`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `UTENTI`
--

DROP TABLE IF EXISTS `UTENTI`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `UTENTI` (
  `id_utenti` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(45) NOT NULL,
  PRIMARY KEY (`id_utenti`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
