DELIMITER //
DROP PROCEDURE IF EXISTS upd_instestazione_registro //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_instazione_registro`( 
IN in_id_registro INT,
IN in_contatto VARCHAR(45)
) 
BEGIN
IF (in_contatto IS NOT NULL) THEN
CALL input_proprieta('5',in_contatto);
END IF;
UPDATE REGISTRO SET contatto = in_contatto WHERE id_registro = in_id_registro;
END //
DELIMITER ;
