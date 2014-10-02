DELIMITER //
-- DROP PROCEDURE IF EXISTS upd_instestazione_registro //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_instestazione_registro`( 
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
-- DROP PROCEDURE IF EXISTS upd_giacenza_magazzino //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_giacenza_magazzino`(
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_quantita INT,
IN in_data DATE
) 
BEGIN
DECLARE temp_quantita INT;
DECLARE temp_tags TEXT;

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione)) THEN

SET temp_quantita=(SELECT quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione);
SET temp_tags=(SELECT tags FROM MERCE WHERE id_merce=in_id_merce);

CALL SCARICO('Sistema','Aggiornamento giacenze sistema',in_id_merce,temp_quantita,in_posizione,in_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento giacenza magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento giacenze sistema','Sistema',(SELECT next_system_doc()),in_data,NULL,temp_tags,in_quantita,in_posizione,in_data,'Carico invocato dal sistema per aggiornamento giacenza magazzino',NULL,NULL);

END IF;

END //
DELIMITER ;



DELIMITER //
-- DROP PROCEDURE IF EXISTS upd_posizione_magazzino //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_posizione_magazzino`( 
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_vecchia_posizione VARCHAR(45),
IN in_nuova_posizione VARCHAR(45),
IN in_data DATE
) 
BEGIN
DECLARE temp_quantita INT;
DECLARE temp_tags TEXT;

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_vecchia_posizione)) THEN

SET temp_quantita=(SELECT quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_vecchia_posizione);
SET temp_tags=(SELECT tags FROM MERCE WHERE id_merce=in_id_merce);

CALL SCARICO('Sistema','Aggiornamento posizioni sistema',in_id_merce,temp_quantita,in_vecchia_posizione,in_vecchia_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento posizione magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento posizioni sistema','Sistema',(SELECT next_system_doc()),in_data,NULL,temp_tags,temp_quantita,in_nuova_posizione,in_data,'Carico invocato dal sistema per aggiornamento posizione magazzino',NULL,NULL);

END IF;

END //
DELIMITER ;
