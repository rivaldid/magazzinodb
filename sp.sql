--
-- etichette:
-- -- 1 TAGS
-- -- 2 posizioni
-- -- 3 destinazioni
-- -- 4 tipi di documento
-- -- 5 rubrica 
--

USE magazzino;


-- ---------------------- INPUT ETICHETTE ---------------------- 
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


-- ---------------------- INPUT REGISTRO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_registro //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_registro`( 
IN in_contatto VARCHAR(45),
IN in_tipo VARCHAR(45),
IN in_numero VARCHAR(45),
IN in_gruppo VARCHAR(45),
IN in_data DATE,
IN in_file VARCHAR(45),
OUT out_id_registro INT
) 
BEGIN

DECLARE max_gruppo INT;

-- test contatto per etichette
IF (in_contatto IS NOT NULL) THEN
CALL input_etichette('5',in_contatto);
END IF;

-- test tipo documento per etichette
IF (in_tipo IS NOT NULL) THEN
CALL input_etichette('4',in_tipo);
END IF;

-- test numero di documento
IF (in_numero IS NOT NULL) THEN

	-- test gruppo di appartenenza
	IF (in_gruppo IS NULL) THEN
		SELECT MAX(gruppo) INTO @max_gruppo FROM REGISTRO;
		SET in_gruppo = @max_gruppo + 1;
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


-- -- ---------------------- tokenizza tags ----------------------
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
		CALL input_etichette('1',@token);
	END IF;
END LOOP myloop;

END //
DELIMITER ;


-- -- ---------------------- MERCE ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS input_merce //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `input_merce`( 
IN in_tags TEXT,
OUT out_id_merce INT
)
BEGIN
IF (in_tags IS NOT NULL) THEN
	
	-- tags in etichette
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
DECLARE my_id_merce INT;

-- DOCUMENTO
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, NULL, in_data_doc, in_scansione, @my_id_registro);

-- MERCE
CALL input_merce(in_tags, my_id_merce);

-- TRASPORTATORE*
-- IF (in_trasportatore IS NOT NULL) THEN
-- CALL input_etichette('5',in_trasportatore);
-- END IF;

END //
DELIMITER ;
