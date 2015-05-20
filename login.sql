USE magazzino;

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `rete` varchar(45) NOT NULL,
  `cognome` varchar(45) NOT NULL,
  PRIMARY KEY (`account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

DELIMITER //
-- DROP PROCEDURE IF EXISTS input_accounts //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_accounts`( 
IN in_rete VARCHAR(45), 
IN in_cognome VARCHAR(45) 
) 
BEGIN 
IF NOT (SELECT EXISTS(SELECT 1 FROM account WHERE rete=in_rete)) THEN 
INSERT INTO account(rete,cognome) VALUES(in_rete, in_cognome); 
END IF;
END //
DELIMITER ;

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

