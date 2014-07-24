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



DELIMITER //
DROP PROCEDURE IF EXISTS upd_magazzino //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_magazzino`( 
IN flag INT,
IN in_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_quantita INT
) 
BEGIN

DECLARE temp_quantita INT;

IF (flag=0) THEN
UPDATE MAGAZZINO SET quantita=in_quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione;
END IF;

IF (flag=1) THEN
SELECT quantita INTO temp_quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione;
UPDATE MAGAZZINO SET quantita=temp_quantita+in_quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione;
END IF;

END //
DELIMITER ;

