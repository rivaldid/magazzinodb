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
DECLARE my_id_operazioni INT;

-- DOCUMENTO
CALL input_registro(in_fornitore, in_tipo_doc, in_num_doc, NULL, in_data_doc, in_scansione, @my_id_registro);

-- MERCE
CALL input_merce(in_tags, @my_id_merce);

-- OPERAZIONI
CALL input_operazioni('1', @my_id_registro, @my_id_merce, in_quantita, in_posizione, in_data_carico, in_note_carico, @my_id_operazioni);

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
