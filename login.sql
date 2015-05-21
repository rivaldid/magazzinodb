USE magazzino;

-- PUBLIC
-- get_permission(rete,progetto);
-- get_cognome(rete);
-- get_rete(cognome);
-- call input_trace(REQUEST_TIME,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT);

-- base
DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `rete` varchar(45) NOT NULL,
  `cognome` varchar(45) NOT NULL,
  PRIMARY KEY (`rete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permission` (
  `rete` varchar(45) NOT NULL,
  `progetto` varchar(45) NOT NULL,
  `livello` int NOT NULL,
  PRIMARY KEY (`rete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DROP TABLE IF EXISTS `trace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

-- function
DELIMITER //
DROP FUNCTION IF EXISTS `account_exists`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `account_exists`(in_rete VARCHAR(45)) RETURNS TINYINT(1)
RETURN (SELECT EXISTS(SELECT 1 FROM account WHERE rete=in_rete));//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS `permission_exists`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `permission_exists`(in_rete VARCHAR(45),in_progetto VARCHAR(45)) RETURNS TINYINT(1)
RETURN (SELECT EXISTS(SELECT 1 FROM permission WHERE rete=in_rete AND progetto=in_progetto));//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS `get_permission`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_permission`(in_rete VARCHAR(45),in_progetto VARCHAR(45)) RETURNS INT
BEGIN
DECLARE risultato INT;
IF (SELECT permission_exists(in_rete,in_progetto)) THEN 
	SET risultato=(SELECT livello FROM permission WHERE rete=in_rete AND progetto=in_progetto);
ELSE
	SET risultato=0;
END IF;
RETURN risultato;
END//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS `get_cognome`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_cognome`(in_rete VARCHAR(45)) RETURNS VARCHAR(45)
RETURN (SELECT cognome FROM account WHERE rete=in_rete);//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS `get_rete`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_rete`(in_cognome VARCHAR(45)) RETURNS VARCHAR(45)
RETURN (SELECT rete FROM account WHERE cognome=in_cognome);//
DELIMITER ;

-- procedure
DELIMITER //
DROP PROCEDURE IF EXISTS input_accounts //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_accounts`( 
IN in_rete VARCHAR(45), 
IN in_cognome VARCHAR(45) 
) 
BEGIN 
IF NOT (SELECT account_exists(in_rete)) THEN 
INSERT INTO account(rete,cognome) VALUES(in_rete, in_cognome); 
END IF;
END //
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS input_permission //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_permission`( 
IN in_rete VARCHAR(45), 
IN in_progetto VARCHAR(45), 
IN in_livello INT
) 
BEGIN 
IF (SELECT account_exists(in_rete)) THEN 
	IF (SELECT permission_exists(in_rete,in_progetto)) THEN 
		UPDATE permission SET livello=in_livello WHERE rete=in_rete AND progetto=in_progetto;
	ELSE
		INSERT INTO permission(rete,progetto,livello) VALUES(in_rete,in_progetto,in_livello); 
	END IF;
END IF;
END //
DELIMITER ;

-- mysql> select inet_aton('10.98.2.171'),inet_ntoa('174195371');
-- +--------------------------+------------------------+
-- | inet_aton('10.98.2.171') | inet_ntoa('174195371') |
-- +--------------------------+------------------------+
-- |                174195371 | 10.98.2.171            |
-- +--------------------------+------------------------+

DELIMITER //
DROP PROCEDURE IF EXISTS input_trace //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_trace`( 
IN IN_REQUEST_TIME INT UNSIGNED,
IN IN_REQUEST_URI TEXT,
IN IN_HTTP_REFERER TEXT,
IN IN_REMOTE_ADDR VARCHAR(45),
IN IN_REMOTE_USER VARCHAR(45),
IN IN_PHP_AUTH_USER VARCHAR(45),
IN IN_HTTP_USER_AGENT TEXT
) 
BEGIN 
IF (IN_PHP_AUTH_USER != 'vilardid') THEN
INSERT INTO trace(REQUEST_TIME,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT)
VALUES(IN_REQUEST_TIME,IN_REQUEST_URI,IN_HTTP_REFERER,IN_REMOTE_ADDR,IN_REMOTE_USER,IN_PHP_AUTH_USER,IN_HTTP_USER_AGENT);
END IF;
END //
DELIMITER ;

-- vista
DELIMITER //
-- DROP VIEW IF EXISTS vista_ordini //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_trace` AS 
SELECT id_trace,DATE_FORMAT(FROM_UNIXTIME(REQUEST_TIME),'%Y-%m-%d %H.%i.%s') AS data,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT FROM trace;
//
DELIMITER ;

-- dati
CALL input_accounts('LORUSSO6','Lorusso');
CALL input_accounts('VILARDID','Vilardi');
CALL input_accounts('MARCHIS6','Marchisotti');
CALL input_accounts('NICAST28','Nicastro');
CALL input_accounts('FUCITOF2','Fucito');
CALL input_accounts('PISCAZZI','Piscazzi');
CALL input_accounts('MURATO48','Muratore');
CALL input_accounts('MANZOGI9','Manzo');
CALL input_accounts('TUTTOLO5','Tuttolomondo');
CALL input_accounts('DALES177','DAlessio');
CALL input_accounts('LOMBA693','Lombardo');
CALL input_accounts('GENNARE3','Gennarelli');
CALL input_accounts('FLORIOCR','Florio');
CALL input_accounts('LUCATIFR','Lucati');

CALL input_permission('LORUSSO6','magazzino','2');
CALL input_permission('VILARDID','magazzino','2');
CALL input_permission('PISCAZZI','magazzino','2');
CALL input_permission('MURATO48','magazzino','2');
CALL input_permission('MANZOGI9','magazzino','2');
CALL input_permission('MARCHIS6','magazzino','1');
CALL input_permission('NICAST28','magazzino','1');
CALL input_permission('FUCITOF2','magazzino','1');
CALL input_permission('TUTTOLO5','magazzino','1');
CALL input_permission('DALES177','magazzino','1');
CALL input_permission('LOMBA693','magazzino','1');
CALL input_permission('GENNARE3','magazzino','1');
CALL input_permission('FLORIOCR','magazzino','1');
CALL input_permission('LUCATIFR','magazzino','1');

