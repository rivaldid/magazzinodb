DELIMITER //


DROP FUNCTION IF EXISTS `strip_htmltags` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `strip_htmltags`($str text)
RETURNS text
BEGIN
    DECLARE $start, $end INT DEFAULT 1;
    LOOP
        SET $start = LOCATE("<", $str, $start);
        IF (!$start) THEN RETURN $str; END IF;
        SET $end = LOCATE(">", $str, $start);
        IF (!$end) THEN SET $end = $start; END IF;
        SET $str = INSERT($str, $start, $end - $start + 1, "");
    END LOOP;
END //


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


DROP FUNCTION IF EXISTS `get_gruppo_da_documento` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_gruppo_da_documento`(in_id_registro INT)
RETURNS INT(11)
BEGIN
RETURN (SELECT gruppo FROM REGISTRO WHERE id_registro=in_id_registro);
END //


DROP FUNCTION IF EXISTS `get_next_gruppo` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_next_gruppo`()
RETURNS INT(11)
BEGIN
DECLARE foo INT(11);
SET foo=(SELECT MAX(gruppo)+1 FROM REGISTRO);
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo;
END //


-- FUNCTION ACCOUNT DI RETE:
DROP FUNCTION IF EXISTS `account_exists` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `account_exists`(in_rete VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM UTENTI WHERE rete=in_rete));
END //


DROP FUNCTION IF EXISTS `get_permission` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_permission`(in_rete VARCHAR(45))
RETURNS INT
BEGIN
RETURN (SELECT permission FROM UTENTI WHERE rete=in_rete);
END //


DROP FUNCTION IF EXISTS `get_cognome` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_cognome`(in_rete VARCHAR(45))
RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT cognome FROM UTENTI WHERE rete=in_rete);
END //


-- FUNCTION session_handler
DROP FUNCTION IF EXISTS `sh_record_exists` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `sh_record_exists`(in_rete VARCHAR(45), in_page VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN TRUE;
END //


-- FUNCTION mezzorafa
DROP FUNCTION IF EXISTS `mezzorafa` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `mezzorafa`()
RETURNS INT UNSIGNED
BEGIN
RETURN (SELECT UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 30 MINUTE)));
END //


-- FUNCTION linkeggia
DROP FUNCTION IF EXISTS `linkeggia` //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `linkeggia`(target TEXT, label TEXT)
RETURNS TEXT
BEGIN
IF ( COALESCE( target, '' ) = '' ) THEN
	RETURN target;
ELSE
	RETURN CONCAT('<a href=\"dati/registro/',target,'">',label,'</a>');
END IF;
END //


DELIMITER ;
