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
