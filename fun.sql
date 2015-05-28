DELIMITER //

DROP FUNCTION IF EXISTS `split_string` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `split_string`(x TEXT, delim VARCHAR(12), pos INT)
RETURNS TEXT
BEGIN
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos), LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1), delim, '');
END //


DROP FUNCTION IF EXISTS `quantita_per_magazzino` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `quantita_per_magazzino`(x INT, y VARCHAR(45))
RETURNS INT
BEGIN
RETURN (SELECT quantita FROM MAGAZZINO WHERE id_merce=x AND posizione=y);
END //


DROP FUNCTION IF EXISTS `next_system_doc` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_system_doc`()
RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='Sistema');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo;
END //


DROP FUNCTION IF EXISTS `doc_exists` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `doc_exists`(in_fornitore VARCHAR(45), in_tipo_doc VARCHAR(45), in_num_doc VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM REGISTRO WHERE contatto=in_fornitore AND tipo=in_tipo_doc AND numero=in_num_doc));
END //


DROP FUNCTION IF EXISTS `next_reintegro_doc` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_reintegro_doc`()
RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='Reintegro');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo;
END //


DROP FUNCTION IF EXISTS `next_mds_doc` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_mds_doc`()
RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='MDS');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo;
END //


DROP FUNCTION IF EXISTS `get_provenienza` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_provenienza`(in_id_operazioni INT)
RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT IF(note LIKE '%PROVENIENZA%',TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',-1)),'LIMBO') AS provenienza FROM OPERAZIONI WHERE id_operazioni=in_id_operazioni);
END //


-- FUNCTION ACCOUNT DI RETE
DROP FUNCTION IF EXISTS `account_exists` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `account_exists`(in_rete VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM account WHERE rete=in_rete));
END //


DROP FUNCTION IF EXISTS `permission_exists` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `permission_exists`(in_rete VARCHAR(45),in_progetto VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM permission WHERE rete=in_rete AND progetto=in_progetto));
END //


DROP FUNCTION IF EXISTS `get_permission` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_permission`(in_rete VARCHAR(45),in_progetto VARCHAR(45))
RETURNS INT
BEGIN
DECLARE risultato INT;
IF (SELECT permission_exists(in_rete,in_progetto)) THEN
	SET risultato=(SELECT livello FROM permission WHERE rete=in_rete AND progetto=in_progetto);
ELSE
	SET risultato=0;
END IF;
RETURN risultato;
END //


DROP FUNCTION IF EXISTS `get_cognome` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_cognome`(in_rete VARCHAR(45))
RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT cognome FROM account WHERE rete=in_rete);
END //


DROP FUNCTION IF EXISTS `get_rete` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_rete`(in_cognome VARCHAR(45))
RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT rete FROM account WHERE cognome=in_cognome);
END //

DELIMITER ;

