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
SELECT id_merce,tags,GROUP_CONCAT(DISTINCT CONCAT(posizione,'(',quantita,')')) AS posizioni,SUM(quantita) AS tot FROM vista_magazzino GROUP BY tags
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

