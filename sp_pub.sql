DELIMITER //

-- ---------------------- CARICO ----------------------
DROP PROCEDURE IF EXISTS CARICO //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `CARICO`(
IN in_utente VARCHAR(45),
IN in_fornitore VARCHAR(45),
IN in_tipo_doc VARCHAR(45),
IN in_num_doc VARCHAR(256),
IN in_data_doc DATE,
IN in_scansione TEXT,
IN in_tags TEXT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_data_carico DATE,
IN in_note_carico TEXT,
IN in_trasportatore VARCHAR(45),
IN in_oda VARCHAR(45)
)
BEGIN

DECLARE my_id_utente INT;
DECLARE my_id_registro INT;
DECLARE my_id_oda INT;
DECLARE my_id_merce INT;
DECLARE my_id_operazioni INT;

-- UTENTE
CALL input_utenti(in_utente,@my_id_utente);

-- DOCUMENTO
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, NULL, in_data_doc, in_scansione, @my_id_registro);

-- MERCE
CALL input_merce(in_tags, @my_id_merce);

-- OPERAZIONI
CALL input_operazioni('1', @my_id_utente, @my_id_registro, @my_id_merce, in_quantita, in_posizione, in_data_carico, in_note_carico, @my_id_operazioni);

-- MAGAZZINO
CALL input_magazzino('1', @my_id_merce, in_posizione, in_quantita);

-- TRASPORTATORE*
IF (in_trasportatore IS NOT NULL) THEN
	CALL input_proprieta('5',in_trasportatore);
END IF;

-- per utente Sistema
IF (in_fornitore='Sistema') THEN
	SET in_num_doc := (SELECT next_system_doc());
END IF;

-- ODA*
IF (in_oda IS NOT NULL) AND (in_oda != '') THEN
	CALL input_registro('Poste Italiane S.p.a.','ODA',in_oda, NULL, NULL, NULL, @my_id_oda);
ELSE
	SET @my_id_oda := NULL;
END IF;

-- ORDINI
CALL input_ordini(@my_id_operazioni, @my_id_oda, in_trasportatore);

END //


-- ---------------------- SCARICO ----------------------
DROP PROCEDURE IF EXISTS SCARICO //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `SCARICO`(
IN in_mds INT,
IN in_utente VARCHAR(45),
IN in_richiedente VARCHAR(45),
IN in_id_merce TEXT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_destinazione VARCHAR(45),
IN in_data_doc_scarico DATE,
IN in_data_scarico DATE,
IN in_note_scarico TEXT,
OUT ritorno INT
)
BEGIN

DECLARE my_id_utente INT;
DECLARE my_id_registro INT;
DECLARE my_mds VARCHAR(45);
DECLARE my_id_operazioni INT;
DECLARE my_quantita INT;

-- test scarico
SET my_quantita := (SELECT quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione);

IF (my_quantita IS NULL) THEN

	SET @ritorno := 1;

ELSE

	IF (in_quantita>my_quantita) THEN

		SET @ritorno := 2;

	ELSE

		-- UTENTE
		CALL input_utenti(in_utente,@my_id_utente);

		-- DOCUMENTO
		IF (in_mds IS NULL) THEN
			SELECT MAX(CAST(numero AS UNSIGNED))+1 INTO my_mds FROM REGISTRO WHERE tipo='MDS';
			CALL input_registro(in_richiedente, 'MDS', my_mds, NULL, in_data_doc_scarico, NULL, @my_id_registro);
		ELSE
			CALL input_registro(in_richiedente, 'MDS', in_mds, NULL, in_data_doc_scarico, NULL, @my_id_registro);
		END IF;

		-- OPERAZIONI
		CALL input_operazioni('0', @my_id_utente, @my_id_registro, in_id_merce, in_quantita, in_destinazione, in_data_scarico, CONCAT(in_note_scarico,' PROVENIENZA ',in_posizione), @my_id_operazioni);

		-- MAGAZZINO
		CALL input_magazzino('0', in_id_merce, in_posizione, in_quantita);

		SET @ritorno := 0;

	END IF;

END IF;

SELECT @ritorno AS risultato, CONCAT_WS(' ','SCARICO',in_utente,in_richiedente,in_id_merce,in_quantita,in_posizione,in_destinazione,in_mds,my_mds,in_data_doc_scarico,in_data_scarico,in_note_scarico) AS riferimenti;

END //


/*-- ---------------------- AGGIORNAMENTO MAGAZZINO ----------------------
-- DROP PROCEDURE IF EXISTS aggiornamento_magazzino//
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `aggiornamento_magazzino`(
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
CALL aggiornamento_magazzino_quantita(in_utente,in_1st_id_merce,in_1st_posizione,in_1st_quantita,in_2nd_quantita,in_data);
END IF;

-- 010
IF ((in_2nd_id_merce IS NULL) AND (in_2nd_posizione IS NOT NULL) AND (in_2nd_quantita IS NULL)) THEN
CALL aggiornamento_magazzino_posizione(in_utente,in_1st_id_merce,in_1st_posizione,in_2nd_posizione,in_1st_quantita,in_data);
END IF;

-- 100
IF ((in_2nd_id_merce IS NOT NULL) AND (in_2nd_posizione IS NULL) AND (in_2nd_quantita IS NULL)) THEN
CALL aggiornamento_magazzino_merce(in_utente,in_1st_id_merce,in_2nd_id_merce,in_1st_posizione,in_1st_quantita,in_data);
END IF;

END IF; -- end test valori


END //
DROP PROCEDURE aggiornamento_magazzino;
*/


-- ---------------------- REVERT ----------------------
DROP PROCEDURE IF EXISTS revert //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `revert`(
IN in_utente VARCHAR(45),
IN in_id_operazioni INT
)
BEGIN

DECLARE my_id_merce INT;
DECLARE my_direzione VARCHAR(45);
DECLARE my_posizione VARCHAR(45);
DECLARE my_quantita INT;
DECLARE my_note TEXT;

SELECT id_merce,direzione,posizione,quantita,note INTO @my_id_merce,@my_direzione,@my_posizione,@my_quantita,@my_note FROM OPERAZIONI WHERE id_operazioni=in_id_operazioni;

IF @my_direzione THEN
	-- rev di un ingresso: quindi uscita
	-- SELECT CONCAT("Annullamento relativo al transito di carico #",in_id_operazioni);
	CALL SCARICO(NULL,in_utente,'Annullamento',@my_id_merce,@my_quantita,@my_posizione,'Pozzo',CURDATE(),CURDATE(),CONCAT('Annullamento relativo al transito di carico #',in_id_operazioni),@myvar);
ELSE
	-- rev di una uscita: quindi ingresso
	-- SELECT CONCAT("Annullamento relativo al transito di scarico #",in_id_operazioni);
	CALL CARICO(in_utente,'Annullamento','Sistema',(SELECT next_system_doc()),CURDATE(),NULL,(SELECT tags FROM MERCE WHERE id_merce=@my_id_merce),@my_quantita,(SELECT get_provenienza(in_id_operazioni)),CURDATE(),CONCAT("Annullamento relativo al transito di scarico #",in_id_operazioni),NULL,NULL);
END IF;

END //


-- PUBLIC API ACCOUNT DI RETE
-- get_permission(rete,progetto);
-- get_cognome(rete);
-- get_rete(cognome);
-- call input_trace(REQUEST_TIME,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT);


-- ---------------------- session handler: WRITE ----------------------
DROP PROCEDURE IF EXISTS sh_write //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_write`(
IN in_rete VARCHAR(45),
IN in_page VARCHAR(45),
IN in_data TEXT,
IN in_timestamp INT UNSIGNED
)
BEGIN
IF (SELECT sh_record_exists(in_rete,in_page)) THEN
	UPDATE session_handler SET data=in_data AND timestamp=in_timestamp WHERE rete=in_rete AND page=in_page;
ELSE
	INSERT INTO session_handler(rete,page,data,timestamp) VALUES (in_rete,in_page,in_data,in_timestamp);
END IF;
END //


-- ---------------------- session handler: READ ----------------------
DROP PROCEDURE IF EXISTS sh_read //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_read`(
IN in_rete VARCHAR(45),
IN in_page VARCHAR(45),
OUT out_data TEXT
)
BEGIN
IF (SELECT sh_record_exists(in_rete,in_page)) THEN
	SELECT data INTO @out_data FROM session_handler WHERE rete=in_rete AND page=in_page;
END IF;
END //


-- ---------------------- session handler: GARBAGE ----------------------
DROP PROCEDURE IF EXISTS sh_garbage //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_garbage`()
BEGIN
-- DELETE FROM session_handler WHERE timestasmp < 
-- select rete, from_unixtime(timestamp/1000, '%d-%m-%Y %H.%i.%s') from session_handler where timestamp < unix_timestamp(CURRENT_TIMESTAMP - INTERVAL 30 MINUTE)*1000;
END //


DELIMITER ;
