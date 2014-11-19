USE magazzino;


DELIMITER //
-- DROP PROCEDURE IF EXISTS upd_instestazione_registro//
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
-- DROP PROCEDURE IF EXISTS upd_giacenza_magazzino//
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

CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,temp_quantita,in_posizione,in_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento giacenza magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,temp_tags,in_quantita,in_posizione,in_data,'Carico invocato dal sistema per aggiornamento giacenza magazzino',NULL,NULL);

END IF;

END //
DELIMITER ;



DELIMITER //
-- DROP PROCEDURE IF EXISTS upd_posizione_magazzino//
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

CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,temp_quantita,in_vecchia_posizione,in_vecchia_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento posizione magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,temp_tags,temp_quantita,in_nuova_posizione,in_data,'Carico invocato dal sistema per aggiornamento posizione magazzino',NULL,NULL);

END IF;

END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS upd_doc_carico//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `upd_doc_carico`( 
IN in_id_operazioni INT,
IN in_fornitore VARCHAR(45),
IN in_tipo_doc VARCHAR(45),
IN in_num_doc VARCHAR(45),
IN in_gruppo INT,
IN in_data_doc DATE,
IN in_scansione VARCHAR(45),
OUT ritorno INT
) 
BEGIN
DECLARE my_id_registro INT;

IF (in_id_operazioni IS NOT NULL) THEN

	CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, in_gruppo, in_data_doc, in_scansione, @my_id_registro);

	IF (SELECT EXISTS(SELECT 1 FROM OPERAZIONI WHERE id_operazioni = in_id_operazioni)) THEN
		
		UPDATE OPERAZIONI SET id_registro=@my_id_registro WHERE id_operazioni=in_id_operazioni;
		SET @ritorno = 0;
		
	ELSE	
		
		SET @ritorno = 1;
		
	END IF;
	
END IF;

SELECT @ritorno AS 'risultato';
END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS delta_magazzino_001//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `delta_magazzino_001`( 
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_1st_quantita INT,
IN in_2nd_quantita INT,
IN in_data DATE
) 
BEGIN
DECLARE diff_quantita INT;

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione AND quantita=in_1st_quantita)) THEN

	IF (in_2nd_quantita<=in_1st_quantita) THEN
		
		SET @diff_quantita=in_1st_quantita-in_2nd_quantita;

		IF (@diff_quantita>=0) THEN
		
			CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,@diff_quantita,in_posizione,in_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento giacenze magazzino',@myvar);
			CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,(SELECT tags FROM MERCE WHERE id_merce=in_id_merce),in_2nd_quantita,in_posizione,in_data,'Carico invocato dal sistema per aggiornamento giacenze magazzino',NULL,NULL);
		
		END IF;  -- end test quantita
		
	END IF; -- end test richista

END IF; -- end esistenza

END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS delta_magazzino_010//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `delta_magazzino_010`( 
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_1st_posizione VARCHAR(45),
IN in_2nd_posizione VARCHAR(45),
IN in_quantita INT,
IN in_data DATE
) 
BEGIN

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_1st_posizione AND quantita=in_quantita)) THEN

CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,in_quantita,in_1st_posizione,in_1st_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento posizioni magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,(SELECT tags FROM MERCE WHERE id_merce=in_id_merce),in_quantita,in_2nd_posizione,in_data,'Carico invocato dal sistema per aggiornamento posizioni magazzino',NULL,NULL);

END IF;
END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS delta_magazzino_100//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `delta_magazzino_100`( 
IN in_utente VARCHAR(45),
IN in_1st_id_merce INT,
IN in_2nd_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_quantita INT,
IN in_data DATE
) 
BEGIN

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_1st_id_merce AND posizione=in_posizione AND quantita=in_quantita)) THEN

CALL SCARICO(in_utente,'Aggiornamento',in_1st_id_merce,in_quantita,in_posizione,in_posizione,in_data,in_data,'Scarico invocato dal sistema per aggiornamento merce magazzino',@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,(SELECT tags FROM MERCE WHERE id_merce=in_2nd_id_merce),in_quantita,in_posizione,in_data,'Carico invocato dal sistema per aggiornamento merce magazzino',NULL,NULL);

END IF;
END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS delta_magazzino//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `delta_magazzino`(
IN in_utente VARCHAR(45),
IN in_1st_tags TEXT,
IN in_1st_id_merce INT,
IN in_1st_posizione VARCHAR(45),
IN in_1st_quantita INT,
IN in_2nd_tags TEXT,
IN in_2nd_id_merce INT,
IN in_2nd_posizione VARCHAR(45),
IN in_2nd_quantita INT,
IN in_data DATE
) 
BEGIN


-- pre: mi assicuro di lavorare con id
IF (in_1st_tags IS NOT NULL) THEN
	CALL input_merce(in_1st_tags,in_1st_id_merce);
END IF;

IF (in_2nd_tags IS NOT NULL) THEN
	CALL input_merce(in_2nd_tags,in_2nd_id_merce);
END IF;



-- in base alla terna id-posizione-quantita, smisto alla sp designata

IF ((in_1st_id_merce IS NOT NULL) AND (in_1st_posizione IS NOT NULL) AND (in_1st_quantita IS NOT NULL)) THEN

-- 001
IF ((in_2nd_id_merce IS NULL) AND (in_2nd_posizione IS NULL) AND (in_2nd_quantita IS NOT NULL)) THEN
CALL delta_magazzino_001(in_utente,in_1st_id_merce,in_1st_posizione,in_1st_quantita,in_2nd_quantita,in_data);		
END IF;

-- 010
IF ((in_2nd_id_merce IS NULL) AND (in_2nd_posizione IS NOT NULL) AND (in_2nd_quantita IS NULL)) THEN
CALL delta_magazzino_010(in_utente,in_1st_id_merce,in_1st_posizione,in_2nd_posizione,in_1st_quantita,in_data);	
END IF;

-- 100
IF ((in_2nd_id_merce IS NOT NULL) AND (in_2nd_posizione IS NULL) AND (in_2nd_quantita IS NULL)) THEN
CALL delta_magazzino_100(in_utente,in_1st_id_merce,in_2nd_id_merce,in_1st_posizione,in_1st_quantita,in_data);	
END IF;

END IF; -- end test valori



END //
DELIMITER ;
