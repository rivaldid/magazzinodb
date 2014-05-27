USE magazzino;

DELIMITER //
DROP PROCEDURE IF EXISTS input_etichette //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_etichette`( 
IN in_sel INT, 
IN in_label VARCHAR(45) 
) 
BEGIN 
IF NOT (SELECT EXISTS(SELECT 1 FROM etichette WHERE sel=in_sel AND label=in_label)) THEN 
INSERT INTO etichette(sel,label) VALUES(in_sel, in_label); 
END IF;
END //
DELIMITER ;

