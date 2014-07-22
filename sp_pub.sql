-- ---------------------- CARICO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS CARICO //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `CARICO`(
IN in_fornitore VARCHAR(45),
IN in_tipo_doc VARCHAR(45),
IN in_num_doc VARCHAR(45),
IN in_data_doc VARCHAR(10),
IN in_scansione VARCHAR(45),
IN in_tags TEXT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_data_carico VARCHAR(10),
IN in_note_carico TEXT,
IN in_trasportatore VARCHAR(45),
IN in_oda VARCHAR(45)
)
BEGIN

DECLARE my_id_registro INT;
DECLARE my_id_oda INT;
DECLARE my_id_merce INT;
DECLARE my_id_operazioni INT;

DECLARE my_data_doc DATE;
DECLARE my_data_carico DATE;

-- fixdate
SET  @my_data_carico = STR_TO_DATE(in_data_carico,'%d/%m/%Y');
IF (in_data_doc IS NOT NULL) THEN
	SET @my_data_doc = STR_TO_DATE(in_data_doc,'%d/%m/%Y');
ELSE
	SET @my_data_doc = NULL;
END IF;

-- DOCUMENTO
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, NULL, @my_data_doc, in_scansione, @my_id_registro);

-- MERCE
CALL input_merce(in_tags, @my_id_merce);

-- OPERAZIONI
CALL input_operazioni('1', @my_id_registro, @my_id_merce, in_quantita, in_posizione, @my_data_carico, in_note_carico, @my_id_operazioni);

-- MAGAZZINO
CALL input_magazzino('1', @my_id_merce, in_posizione, in_quantita);

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
CALL input_ordini(@my_id_operazioni, @my_id_oda, in_trasportatore);

END //
DELIMITER ;


-- ---------------------- SCARICO ---------------------- 
DELIMITER //
DROP PROCEDURE IF EXISTS SCARICO //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `SCARICO`(
IN in_richiedente VARCHAR(45),
IN in_id_merce TEXT,
IN in_quantita INT,
IN in_posizione VARCHAR(45),
IN in_destinazione VARCHAR(45),
IN in_data_doc_scarico DATE,
IN in_data_scarico DATE,
IN in_note_scarico TEXT
)
BEGIN

DECLARE my_id_registro INT;
DECLARE my_mds VARCHAR(45);
DECLARE my_id_operazioni INT;
DECLARE my_quantita INT;

-- test scarico
SELECT quantita INTO my_quantita FROM MAGAZZINO WHERE id_merce=in_id_merce AND posizione=in_posizione;
IF (in_quantita<=my_quantita) THEN

	-- DOCUMENTO
	SELECT MAX(CAST(numero AS UNSIGNED))+1 INTO my_mds FROM REGISTRO WHERE tipo='MDS';
	CALL input_registro(in_richiedente, 'MDS', my_mds, NULL, in_data_doc_scarico, NULL, @my_id_registro);

	-- OPERAZIONI
	CALL input_operazioni('0', @my_id_registro, in_id_merce, in_quantita, in_destinazione, in_data_scarico, in_note_scarico, @my_id_operazioni);

	-- MAGAZZINO
	CALL input_magazzino('0', in_id_merce, in_posizione, in_quantita);

END IF; -- end if test scarico

END //
DELIMITER ;
