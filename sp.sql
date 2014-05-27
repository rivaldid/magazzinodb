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
IN in_file VARCHAR(45)
) 
BEGIN 

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
	
	-- test if not exists
	IF NOT (SELECT EXISTS(SELECT 1 FROM REGISTRO WHERE contatto=in_contatto AND tipo=in_tipo AND numero=in_numero)) THEN
		INSERT INTO REGISTRO(contatto,tipo,numero,gruppo,data,file) VALUES(in_contatto, in_tipo, in_numero, in_gruppo, in_data, in_file);
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

DECLARE max_gruppo INT;

-- DOCUMENTO
SELECT MAX(gruppo) INTO max_gruppo FROM REGISTRO;
SET max_gruppo = max_gruppo + 1;
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, max_gruppo, in_data_doc, in_scansione);


-- TRASPORTATORE*
IF (in_trasportatore IS NOT NULL) THEN
CALL input_etichette('5',in_trasportatore);
END IF;

END //
DELIMITER ;
