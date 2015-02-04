USE magazzino;

-- *********************************************************************
-- FUNZIONI DEPRECATE: upd_giacenza_magazzino - upd_posizione_magazzino
-- *********************************************************************

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


-- *********************************************************************
-- FUNZIONI DEPRECATE: upd_giacenza_magazzino - upd_posizione_magazzino
-- *********************************************************************

/*
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
*/

DELIMITER //
-- DROP PROCEDURE IF EXISTS aggiornamento_magazzino_quantita//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `aggiornamento_magazzino_quantita`( 
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_1st_quantita INT,
IN in_2nd_quantita INT,
IN in_data DATE
) 
BEGIN

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione AND quantita=in_1st_quantita)) THEN

CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,in_1st_quantita,in_posizione,in_posizione,in_data,in_data,CONCAT('Scarico di sistema per aggiornamento giacenze magazzino (da ',in_1st_quantita,' a ',in_2nd_quantita,')'),@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,(SELECT tags FROM MERCE WHERE id_merce=in_id_merce),in_2nd_quantita,in_posizione,in_data,CONCAT('Carico di sistema per aggiornamento giacenze magazzino (da ',in_1st_quantita,' a ',in_2nd_quantita,')'),NULL,NULL);
		
END IF; -- end esistenza

END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS aggiornamento_magazzino_posizione//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `aggiornamento_magazzino_posizione`( 
IN in_utente VARCHAR(45),
IN in_id_merce INT,
IN in_1st_posizione VARCHAR(45),
IN in_2nd_posizione VARCHAR(45),
IN in_quantita INT,
IN in_data DATE
) 
BEGIN

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_1st_posizione AND quantita=in_quantita)) THEN

CALL SCARICO(in_utente,'Aggiornamento',in_id_merce,in_quantita,in_1st_posizione,in_1st_posizione,in_data,in_data,CONCAT('Scarico di sistema per aggiornamento posizioni magazzino (da ',in_1st_posizione,' a ',in_2nd_posizione,')'),@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,(SELECT tags FROM MERCE WHERE id_merce=in_id_merce),in_quantita,in_2nd_posizione,in_data,CONCAT('Carico di sistema per aggiornamento posizioni magazzino (da ',in_1st_posizione,' a ',in_2nd_posizione,')'),NULL,NULL);

END IF;
END //
DELIMITER ;

-- OK MA DA NON USARE MAI!!!
DELIMITER //
-- DROP PROCEDURE IF EXISTS aggiornamento_magazzino_merce//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `aggiornamento_magazzino_merce`( 
IN in_utente VARCHAR(45),
IN in_1st_id_merce INT,
IN in_2nd_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_quantita INT,
IN in_data DATE
) 
BEGIN

DECLARE tags_1st TEXT;
DECLARE tags_2nd TEXT;
SET tags_1st = (SELECT tags FROM MERCE WHERE id_merce=in_1st_id_merce);
SET tags_2nd = (SELECT tags FROM MERCE WHERE id_merce=in_2nd_id_merce);

IF (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce=in_1st_id_merce AND posizione=in_posizione AND quantita=in_quantita)) THEN

CALL SCARICO(in_utente,'Aggiornamento',in_1st_id_merce,in_quantita,in_posizione,in_posizione,in_data,in_data,CONCAT('Scarico di sistema per aggiornamento merce magazzino (da ',tags_1st,' a ',tags_2nd,')'),@myvar);
CALL CARICO(in_utente,'Aggiornamento','Sistema',(SELECT next_system_doc()),in_data,NULL,tags_2nd,in_quantita,in_posizione,in_data,CONCAT('Carico di sistema per aggiornamento merce magazzino (da ',tags_1st,' a ',tags_2nd,')'),NULL,NULL);

END IF;
END //
DELIMITER ;


DELIMITER //
-- DROP PROCEDURE IF EXISTS aggiornamento_registro//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `aggiornamento_registro`(
IN in_id_registro INT,
IN in_gruppo INT,
IN in_data DATE,
IN in_file TEXT,
OUT ritorno INT
)
BEGIN

DECLARE temp_contatto VARCHAR(45);
DECLARE temp_tipo VARCHAR(45);
DECLARE temp_numero VARCHAR(45);

IF (SELECT EXISTS(SELECT 1 FROM REGISTRO WHERE id_registro=in_id_registro)) THEN
	SELECT contatto,tipo,numero FROM REGISTRO WHERE id_registro=in_id_registro INTO temp_contatto,temp_tipo,temp_numero;
	CALL input_registro(temp_contatto,temp_tipo,temp_numero,in_gruppo,in_data,in_file);
	SET @ritorno := 0;
ELSE
	SET @ritorno := 1;
END IF;

SELECT @ritorno AS risultato,CONCAT_WS(' ','aggiornamento_registro',in_id_registro,temp_contatto,temp_tipo,temp_numero,in_gruppo,in_data,in_file) AS riferimenti;

END //
DELIMITER ;


