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
CASE direzione WHEN 0 THEN (SELECT 'USCITA') WHEN 1 THEN (SELECT 'INGRESSO') END AS status,
posizione, CONCAT(REGISTRO.contatto,' - ',REGISTRO.tipo,' - ',REGISTRO.numero) AS documento, REGISTRO.file AS doc_ingresso, tags, quantita, note,
CONCAT(vista_ordini.tipo,' - ',vista_ordini.numero) AS ordine, vista_ordini.file AS doc_ordine, vista_ordini.trasportatore
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
SELECT * FROM REGISTRO WHERE NOT tipo='MDS' AND NOT tipo='Sistema';
//
DELIMITER ;
