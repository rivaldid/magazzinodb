--
-- proprieta:
-- -- 1 TAGS
-- -- 2 posizioni
-- -- 3 destinazioni
-- -- 4 tipi di documento
-- -- 5 rubrica 
--

USE magazzino;


-- ---------------------- INPUT PROPRIETA ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_proprieta //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_proprieta`( 
IN in_sel INT, 
IN in_label VARCHAR(45) 
) 
BEGIN 
IF NOT (SELECT EXISTS(SELECT 1 FROM proprieta WHERE sel=in_sel AND label=in_label)) THEN 
INSERT INTO proprieta(sel,label) VALUES(in_sel, in_label); 
END IF;
END //
DELIMITER ;


-- ---------------------- INPUT REGISTRO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_registro //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_registro`( 
IN in_contatto VARCHAR(45),
IN in_tipo VARCHAR(45),
IN in_numero VARCHAR(45),
IN in_gruppo INT,
IN in_data DATE,
IN in_file VARCHAR(45),
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
DELIMITER ;


-- ---------------------- tokenizza tags ----------------------
DELIMITER //
DROP PROCEDURE IF EXISTS tokenizza_tags //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `tokenizza_tags`(IN tokens TEXT)
BEGIN
DECLARE i INT;
DECLARE token TEXT;
SET @i=1;

myloop: LOOP
	SET @token = split_string(tokens, ' ', @i);
	SET @i = @i + 1;
	IF (@token = '') THEN
		LEAVE myloop;
	ELSE
		CALL input_proprieta('1',@token);
	END IF;
END LOOP myloop;

END //
DELIMITER ;


-- ---------------------- fix proprieta tags ----------------------
-- note: genera un warning
-- | Error | 1329 | No data - zero rows fetched, selected, or processed |
DELIMITER //
DROP PROCEDURE IF EXISTS fix_proprieta_tags //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `fix_proprieta_tags`()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE in_tags TEXT;

DECLARE foo CURSOR FOR SELECT tags FROM MERCE;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN foo;
bar: LOOP 
	FETCH foo INTO in_tags;
	IF done THEN
		LEAVE bar;
	END IF;
	CALL tokenizza_tags(in_tags);
END LOOP bar;
CLOSE foo;

END //
DELIMITER ;


-- ---------------------- MERCE ---------------------- 
DELIMITER //
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
DELIMITER ;


-- ---------------------- OPERAZIONI ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_operazioni //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_operazioni`(
IN in_direzione INT,
IN in_id_registro INT,
IN in_id_merce INT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_data DATE,
IN in_note TEXT,
OUT out_id_operazione INT
)
BEGIN

-- posizione
IF (in_posizione IS NOT NULL) THEN
	
	CALL input_proprieta('2',in_posizione);
	
	-- il resto
	IF ((in_direzione IS NOT NULL) AND (in_id_registro IS NOT NULL) AND (in_id_merce IS NOT NULL) AND (in_quantita IS NOT NULL)) THEN
			
			INSERT INTO OPERAZIONI(direzione,id_registro,id_merce,quantita,posizione,data,note)
			VALUES (in_direzione,in_id_registro,in_id_merce,in_quantita,in_posizione,in_data,in_note);
			SET out_id_operazione = LAST_INSERT_ID();
	
	END IF;		

END IF;

END //
DELIMITER ;



-- ---------------------- CARICO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_ordini //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_ordini`(
IN in_id_operazione INT,
IN in_id_oda INT,
IN in_trasportatore VARCHAR(45)
)
BEGIN
IF (in_id_operazione IS NOT NULL) THEN

	IF NOT (SELECT EXISTS(SELECT 1 FROM ORDINI WHERE id_operazione = in_id_operazione)) THEN
		
		IF ((in_id_oda IS NOT NULL) OR (in_trasportatore IS NOT NULL)) THEN
			INSERT INTO ORDINI(id_operazione, id_registro_ordine, trasportatore) VALUES(in_id_operazione, in_id_oda, in_trasportatore);
		END IF;
		
	ELSE	
		IF (in_id_oda IS NOT NULL) THEN
			UPDATE ORDINI SET id_registro_ordine=in_id_oda WHERE id_operazione=in_id_operazione;
		END IF;
		
		IF (in_trasportatore IS NOT NULL) THEN
			UPDATE ORDINI SET trasportatore=in_trasportatore WHERE id_operazione=in_id_operazione;
		END IF;
	END IF;
	
END IF;
END //
DELIMITER ;


-- ---------------------- CARICO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS CARICO //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `CARICO`(
IN in_fornitore VARCHAR(45),
IN in_tipo_doc VARCHAR(45),
IN in_num_doc VARCHAR(45),
IN in_data_doc DATE,
IN in_scansione VARCHAR(45),
IN in_tags TEXT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_data_carico DATE,
IN in_note_carico TEXT,
IN in_trasportatore VARCHAR(45),
IN in_oda VARCHAR(45)
)
BEGIN

DECLARE my_id_registro INT;
DECLARE my_id_oda INT;
DECLARE my_id_merce INT;
DECLARE my_id_operazione INT;

-- DOCUMENTO
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, NULL, in_data_doc, in_scansione, @my_id_registro);

-- MERCE
CALL input_merce(in_tags, @my_id_merce);

-- OPERAZIONI
CALL input_operazioni('1', @my_id_registro, @my_id_merce, in_quantita, in_posizione, in_data_carico, in_note_carico, @my_id_operazione);

-- TRASPORTATORE*
IF (in_trasportatore IS NOT NULL) THEN
CALL input_proprieta('5',in_trasportatore);
END IF;

-- ODA*
IF (in_oda IS NOT NULL) THEN
CALL input_registro('Poste Italiane S.p.a.','ODA',in_oda, NULL, NULL, NULL, @my_id_oda);
ELSE
SET @my_id_oda = NULL;
END IF;

-- ORDINI
CALL input_ordini(@my_id_operazione, @my_id_oda, in_trasportatore);

END //
DELIMITER ;
