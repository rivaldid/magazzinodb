USE magazzino;


DELIMITER //
-- DROP VIEW IF EXISTS vista_ordini //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_ordini` AS 
SELECT * FROM ORDINI LEFT JOIN REGISTRO ON id_registro_ordine = id_registro
//
DELIMITER ;


DELIMITER //
-- DROP VIEW IF EXISTS TRANSITI //
CREATE DEFINER=`magazzino`@`localhost` VIEW `TRANSITI` AS 
SELECT
OPERAZIONI.id_operazioni,
OPERAZIONI.id_merce,
UTENTI.label AS utente,
OPERAZIONI.data,
CASE direzione WHEN 0 THEN (SELECT 'USCITA') WHEN 1 THEN (SELECT 'INGRESSO') END AS status, posizione, 
CONCAT(REGISTRO.contatto,' - ',REGISTRO.tipo,' - ',REGISTRO.numero) AS documento,
REGISTRO.data as data_doc, REGISTRO.file AS doc_ingresso, tags, 
IF(direzione=0,IF(note LIKE '%PROVENIENZA%',CONCAT(quantita,' (da ',TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',-1)),')'),quantita),quantita) AS quantita,
CONCAT_WS(' ',IF(note='','Nessuna annotazione',IF(note LIKE '%PROVENIENZA%',TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',1)),note)),IF(vista_ordini.trasportatore='','',CONCAT(' Trasportatore: ',vista_ordini.trasportatore))) as note,
CONCAT(vista_ordini.tipo,' - ',vista_ordini.numero) AS ordine, vista_ordini.file AS doc_ordine
FROM OPERAZIONI 
JOIN MERCE USING(id_merce)
JOIN REGISTRO USING(id_registro)
JOIN UTENTI USING (id_utenti)
LEFT JOIN vista_ordini USING(id_operazioni)
ORDER BY data DESC
//
DELIMITER ;


DELIMITER //
-- DROP VIEW IF EXISTS vista_magazzino //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino` AS 
SELECT id_merce,posizione,tags,quantita FROM MAGAZZINO JOIN MERCE USING(id_merce) WHERE quantita > 0 ORDER BY posizione,tags DESC
//
DELIMITER ;


DELIMITER //
-- DROP VIEW IF EXISTS vista_magazzino_parzxtot //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_parzxtot` AS 
-- SELECT tags, SUM(quantita) AS tot, GROUP_CONCAT(posizione) AS posizioni FROM vista_magazzino GROUP BY tags
SELECT id_merce,tags,GROUP_CONCAT(DISTINCT CONCAT(posizione,'(',quantita,')') SEPARATOR ' ') AS posizioni,SUM(quantita) AS tot FROM vista_magazzino GROUP BY tags
//
DELIMITER ;



DELIMITER //
-- DROP VIEW IF EXISTS vista_magazzino_ng //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_ng` AS 
SELECT
MERCE.id_merce,
CONCAT_WS(' ',
MERCE.tags,
IF(MERCE.tags LIKE 'BRETELL%',NULL,
	GROUP_CONCAT(
		CONCAT(
			IF(REGISTRO.file IS NULL OR REGISTRO.file = '', NULL, CONCAT('<p><a href="/GMDCTO/registro/',REGISTRO.file,'">')),
			'Caricati ',OPERAZIONI.quantita,' con ',REGISTRO.tipo,' - ',REGISTRO.numero,' (',REGISTRO.contatto,')',
            IF(REGISTRO.file IS NULL OR REGISTRO.file = '',NULL,'</a></p>')
            )
	SEPARATOR ' ')
)
) AS MERCE,
MAGAZZINO.posizione,MAGAZZINO.quantita,
IF(MERCE.tags LIKE 'BRETELL%', NULL,GROUP_CONCAT(CONCAT_WS(' ',vista_ordini.tipo,vista_ordini.numero,OPERAZIONI.note) SEPARATOR ' ')) AS NOTE
FROM MAGAZZINO
LEFT JOIN MERCE USING(id_merce)
LEFT JOIN OPERAZIONI USING(id_merce,posizione)
LEFT JOIN REGISTRO USING(id_registro)
LEFT JOIN vista_ordini USING(id_operazioni)
WHERE MAGAZZINO.quantita>0
GROUP BY MAGAZZINO.id_merce,MAGAZZINO.posizione ORDER BY MERCE.tags;
//
DELIMITER ;



DELIMITER //
-- DROP VIEW IF EXISTS vista_magazzino_ng_full //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_ng_full` AS 
SELECT
MERCE.id_merce,
CONCAT_WS(' ',
MERCE.tags,
GROUP_CONCAT(
	CONCAT(
		IF(REGISTRO.file IS NULL OR REGISTRO.file = '', NULL, CONCAT('<p><a href="/GMDCTO/registro/',REGISTRO.file,'">')),
		'Caricati ',OPERAZIONI.quantita,' con ',REGISTRO.tipo,' - ',REGISTRO.numero,' (',REGISTRO.contatto,')',
		IF(REGISTRO.file IS NULL OR REGISTRO.file = '',NULL,'</a></p>')
		)
SEPARATOR ' ')
) AS MERCE,
MAGAZZINO.posizione,MAGAZZINO.quantita,
GROUP_CONCAT(CONCAT_WS(' ',vista_ordini.tipo,vista_ordini.numero,OPERAZIONI.note) SEPARATOR ' ') AS NOTE
FROM MAGAZZINO
LEFT JOIN MERCE USING(id_merce)
LEFT JOIN OPERAZIONI USING(id_merce,posizione)
LEFT JOIN REGISTRO USING(id_registro)
LEFT JOIN vista_ordini USING(id_operazioni)
WHERE MAGAZZINO.quantita>0
GROUP BY MAGAZZINO.id_merce,MAGAZZINO.posizione ORDER BY MERCE.tags;
//
DELIMITER ;


-- DELIMITER //
-- DROP VIEW IF EXISTS vista_magazzino3 //
-- CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino3` AS 
-- SELECT id_merce, tags, SUM(quantita) AS tot, GROUP_CONCAT(posizione) AS posizioni FROM vista_magazzino GROUP BY tags
-- //
-- DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vista_documenti //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_documenti` AS 
SELECT id_registro,file,contatto,CONCAT_WS(' - ',tipo,numero,gruppo) as documento,data FROM REGISTRO WHERE NOT tipo='MDS' AND NOT tipo='Sistema' ORDER BY data DESC;
//
DELIMITER ;


DELIMITER //
-- DROP VIEW IF EXISTS report_transiti_mensile //
CREATE DEFINER=`magazzino`@`localhost` VIEW `report_transiti_mensile` AS 
SELECT DATE_FORMAT(data,'%d/%m/%Y') AS data,utente,status,posizione,
tags,quantita,CONCAT(documento,' del ',DATE_FORMAT(data_doc,'%d/%m/%Y')) AS riferimento,
note, ordine FROM TRANSITI WHERE 1 AND 
data >= DATE_FORMAT(NOW(),'%Y-%m-01') - INTERVAL 1 MONTH AND 
data < DATE_FORMAT(NOW(),'%Y-%m-01') ORDER BY data ASC;
//
DELIMITER ;
