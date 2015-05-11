USE magazzino;

DELIMITER //
-- DROP FUNCTION IF EXISTS `split_string`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `split_string`(x TEXT, delim VARCHAR(12), pos INT) RETURNS TEXT
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos), LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1), delim, '');//
DELIMITER ;

DELIMITER //
-- DROP FUNCTION IF EXISTS `quantita_per_magazzino`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `quantita_per_magazzino`(x INT, y VARCHAR(45)) RETURNS INT
RETURN (SELECT quantita FROM MAGAZZINO WHERE id_merce=x AND posizione=y);//
DELIMITER ;


DELIMITER //
-- DROP FUNCTION IF EXISTS `next_system_doc`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_system_doc`() RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='Sistema');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo; 
END//
DELIMITER ;


DELIMITER //
-- DROP FUNCTION IF EXISTS `doc_exists`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `doc_exists`(in_fornitore VARCHAR(45), in_tipo_doc VARCHAR(45), in_num_doc VARCHAR(45)) RETURNS TINYINT(1)
RETURN (SELECT EXISTS(SELECT 1 FROM REGISTRO WHERE contatto=in_fornitore AND tipo=in_tipo_doc AND numero=in_num_doc));//
DELIMITER ;


DELIMITER //
-- DROP FUNCTION IF EXISTS `next_reintegro_doc`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_reintegro_doc`() RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='Reintegro');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo; 
END//
DELIMITER ;


DELIMITER //
-- DROP FUNCTION IF EXISTS `next_mds_doc`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `next_mds_doc`() RETURNS VARCHAR(45)
BEGIN
DECLARE foo VARCHAR(45);
SET foo=(SELECT MAX(CAST(numero AS UNSIGNED))+1 FROM REGISTRO WHERE tipo='MDS');
IF (foo IS NULL) THEN
SET foo='1';
END IF;
RETURN foo; 
END//
DELIMITER ;

DELIMITER //
-- DROP FUNCTION IF EXISTS `get_provenienza`//
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `get_provenienza`(in_id_operazioni INT) RETURNS VARCHAR(45)
RETURN (SELECT IF(note LIKE '%PROVENIENZA%',TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',-1)),'LIMBO') AS provenienza FROM OPERAZIONI WHERE id_operazioni=in_id_operazioni);//
DELIMITER ;
