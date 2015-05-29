DELIMITER //


-- ---------------------- INPUT PROPRIETA ----------------------
-- proprieta:
-- -- 1 TAGS
-- -- 2 posizioni
-- -- 3 destinazioni
-- -- 4 tipi di documento
-- -- 5 rubrica
--
DROP PROCEDURE IF EXISTS input_proprieta //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_proprieta`(
IN in_sel INT,
IN in_label TEXT
)
BEGIN
IF NOT (SELECT EXISTS(SELECT 1 FROM proprieta WHERE sel=in_sel AND label=in_label)) THEN
INSERT INTO proprieta(sel,label) VALUES(in_sel, in_label);
END IF;
END //


-- ---------------------- INPUT REGISTRO ----------------------
DROP PROCEDURE IF EXISTS input_registro //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_registro`(
IN in_contatto VARCHAR(45),
IN in_tipo VARCHAR(45),
IN in_numero VARCHAR(256),
IN in_gruppo INT,
IN in_data DATE,
IN in_file TEXT,
OUT out_id_registro INT
)
BEGIN

DECLARE max_gruppo INT;

-- test contatto per proprieta
IF (in_contatto IS NOT NULL) THEN
CALL input_proprieta('5',in_contatto);
END IF;

-- test tipo documento per proprieta
IF (in_tipo IS NOT NULL) THEN
CALL input_proprieta('4',in_tipo);
END IF;

-- test numero di documento
IF (in_numero IS NOT NULL) THEN

	-- test gruppo di appartenenza
	IF (in_gruppo IS NULL) THEN
		SELECT MAX(gruppo) INTO @max_gruppo FROM REGISTRO;
		IF (@max_gruppo IS NOT NULL) THEN
			SET in_gruppo = @max_gruppo + 1;
		ELSE
			SET in_gruppo = 1;
		END IF;
	END IF;

	-- test if not exists
	IF NOT (SELECT EXISTS(SELECT 1 FROM REGISTRO WHERE contatto=in_contatto AND tipo=in_tipo AND numero=in_numero)) THEN
		INSERT INTO REGISTRO(contatto,tipo,numero,gruppo,data,file) VALUES(in_contatto, in_tipo, in_numero, in_gruppo, in_data, in_file);
		SET out_id_registro = LAST_INSERT_ID();
	-- altrimenti aggiorna
	ELSE
		-- o il gruppo
		IF (in_gruppo IS NOT NULL) THEN
			UPDATE REGISTRO SET gruppo=in_gruppo WHERE contatto=in_contatto AND tipo=in_tipo AND numero=in_numero;
		END IF;
		-- o la data
		IF (in_data IS NOT NULL) THEN
			UPDATE REGISTRO SET data=in_data WHERE contatto=in_contatto AND tipo=in_tipo AND numero=in_numero;
		END IF;
		-- o il file
		IF (in_file IS NOT NULL) THEN
			UPDATE REGISTRO SET file=in_file WHERE contatto=in_contatto AND tipo=in_tipo AND numero=in_numero;
		END IF;

		SELECT id_registro INTO out_id_registro FROM REGISTRO WHERE contatto = in_contatto AND tipo = in_tipo AND numero = in_numero;

	END IF;

END IF;

END //


-- ---------------------- MERCE ----------------------
DROP PROCEDURE IF EXISTS input_merce //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_merce`(
IN in_tags TEXT,
OUT out_id_merce INT
)
BEGIN
IF (in_tags IS NOT NULL) THEN

	-- tags in proprieta
	CALL tokenizza_tags(in_tags);

	IF NOT (SELECT EXISTS(SELECT 1 FROM MERCE WHERE tags=in_tags)) THEN
		INSERT INTO MERCE(tags) VALUES(in_tags);
		SET out_id_merce = LAST_INSERT_ID();
	ELSE
		SELECT id_merce INTO out_id_merce FROM MERCE WHERE tags = in_tags;
	END IF;

END IF;
END //


-- ---------------------- OPERAZIONI ----------------------
DROP PROCEDURE IF EXISTS input_operazioni //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_operazioni`(
IN in_direzione INT,
IN in_id_utenti INT,
IN in_id_registro INT,
IN in_id_merce INT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_data DATE,
IN in_note TEXT,
OUT out_id_operazioni INT
)
BEGIN

-- posizione
IF (in_posizione IS NOT NULL) THEN

	CALL input_proprieta('2',in_posizione);

	-- il resto
	IF ((in_direzione IS NOT NULL) AND (in_id_registro IS NOT NULL) AND (in_id_merce IS NOT NULL) AND (in_quantita IS NOT NULL)) THEN

			INSERT INTO OPERAZIONI(direzione,id_utenti,id_registro,id_merce,quantita,posizione,data,note)
			VALUES (in_direzione,in_id_utenti,in_id_registro,in_id_merce,in_quantita,in_posizione,in_data,in_note);
			SET out_id_operazioni = LAST_INSERT_ID();

	END IF;

END IF;

END //


-- ---------------------- ORDINI ----------------------
DROP PROCEDURE IF EXISTS input_ordini //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_ordini`(
IN in_id_operazioni INT,
IN in_id_oda INT,
IN in_trasportatore VARCHAR(45)
)
BEGIN
IF (in_id_operazioni IS NOT NULL) THEN

	IF NOT (SELECT EXISTS(SELECT 1 FROM ORDINI WHERE id_operazioni = in_id_operazioni)) THEN

		IF ((in_id_oda IS NOT NULL) OR (in_trasportatore IS NOT NULL)) THEN
			INSERT INTO ORDINI(id_operazioni, id_registro_ordine, trasportatore) VALUES(in_id_operazioni, in_id_oda, in_trasportatore);
		END IF;

	ELSE
		IF (in_id_oda IS NOT NULL) THEN
			UPDATE ORDINI SET id_registro_ordine=in_id_oda WHERE id_operazioni=in_id_operazioni;
		END IF;

		IF (in_trasportatore IS NOT NULL) THEN
			UPDATE ORDINI SET trasportatore=in_trasportatore WHERE id_operazioni=in_id_operazioni;
		END IF;
	END IF;

END IF;
END //


-- ---------------------- MAGAZZINO ----------------------
DROP PROCEDURE IF EXISTS input_magazzino //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_magazzino`(
IN in_direzione INT,
IN in_id_merce INT,
IN in_posizione VARCHAR(45),
IN in_quantita INT
)
BEGIN

DECLARE stored_quantita INT;

IF NOT (SELECT EXISTS(SELECT 1 FROM MAGAZZINO WHERE id_merce = in_id_merce AND posizione = in_posizione)) THEN

	IF (in_direzione = 1) THEN
		INSERT INTO MAGAZZINO(id_merce, posizione, quantita) VALUES(in_id_merce, in_posizione, in_quantita);
	END IF;

ELSE

	SELECT quantita INTO stored_quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione;

	IF (in_direzione = 1) THEN
		UPDATE MAGAZZINO SET quantita = stored_quantita + in_quantita WHERE id_merce = in_id_merce AND posizione = in_posizione;
	END IF;

	IF (in_direzione = 0) THEN
		IF (stored_quantita >= in_quantita) THEN
			UPDATE MAGAZZINO SET quantita = stored_quantita - in_quantita WHERE id_merce = in_id_merce AND posizione = in_posizione;
		END IF;
	END IF;

END IF;
END //


-- ---------------------- INPUT UTENTI ----------------------
DROP PROCEDURE IF EXISTS input_utenti //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_utenti`(
IN in_rete VARCHAR(45),
OUT out_id_utenti INT
)
BEGIN
IF (SELECT account_exists(in_rete)) THEN
	SET out_id_utenti=(SELECT id_utenti FROM UTENTI WHERE rete=in_rete);
ELSE
	INSERT INTO UTENTI(rete) VALUES(in_rete);
	SET out_id_utenti=LAST_INSERT_ID();
END IF;
END //


-- ---------------------- INPUT PERMISSION ------------------
DROP PROCEDURE IF EXISTS input_permission //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_permission`(
IN in_rete VARCHAR(45),
IN in_cognome VARCHAR(45),
IN in_permisison INT
)
BEGIN
IF (SELECT account_exists(in_rete)) THEN
	UPDATE UTENTI SET cognome=in_cognome,permission=in_permission WHERE rete=in_rete;
ELSE
	INSERT INTO UTENTE(rete,cognome,permission) VALUES(in_rete,in_cognome,in_permission);
END IF;
END //


-- ---------------------- INPUT TRACE -----------------------
DROP PROCEDURE IF EXISTS input_trace //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_trace`(
IN IN_REQUEST_TIME INT UNSIGNED,
IN IN_REQUEST_URI TEXT,
IN IN_HTTP_REFERER TEXT,
IN IN_REMOTE_ADDR VARCHAR(45),
IN IN_REMOTE_USER VARCHAR(45),
IN IN_PHP_AUTH_USER VARCHAR(45),
IN IN_HTTP_USER_AGENT TEXT
)
BEGIN
IF (IN_PHP_AUTH_USER != 'vilardid') THEN
INSERT INTO trace(REQUEST_TIME,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT)
VALUES(IN_REQUEST_TIME,IN_REQUEST_URI,IN_HTTP_REFERER,IN_REMOTE_ADDR,IN_REMOTE_USER,IN_PHP_AUTH_USER,IN_HTTP_USER_AGENT);
END IF;
END //


DELIMITER ;

