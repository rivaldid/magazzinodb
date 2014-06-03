USE magazzino;


DELIMITER //
DROP VIEW IF EXISTS vista_ordini //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_ordini` AS 
SELECT * FROM ORDINI JOIN REGISTRO ON id_registro_ordine = id_registro
//
DELIMITER ;


DELIMITER //
DROP VIEW IF EXISTS TRANSITI //
CREATE DEFINER=`magazzino`@`localhost` VIEW `TRANSITI` AS 
SELECT
OPERAZIONI.data,
CASE direzione WHEN 0 THEN (SELECT 'USCITA') WHEN 1 THEN (SELECT 'INGRESSO') END AS status,
posizione, CONCAT(REGISTRO.tipo,' - ',REGISTRO.numero) AS documento, tags, quantita, note,
CONCAT(vista_ordini.tipo,' - ',vista_ordini.numero) AS ordine, vista_ordini.trasportatore
FROM OPERAZIONI 
JOIN MERCE USING(id_merce)
JOIN REGISTRO USING(id_registro)
LEFT JOIN vista_ordini USING(id_operazioni)
ORDER BY data DESC
//
DELIMITER ;


DELIMITER //
DROP VIEW IF EXISTS vista_magazzino //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino` AS 
SELECT posizione,tags,quantita FROM MAGAZZINO JOIN MERCE USING(id_merce) WHERE quantita > 0 ORDER BY posizione,tags DESC
//
DELIMITER ;


DELIMITER //
DROP VIEW IF EXISTS vista_magazzino2 //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino2` AS 
SELECT tags, SUM(quantita) AS tot, GROUP_CONCAT(posizione) AS posizioni FROM vista_magazzino GROUP BY tags
//
DELIMITER ;
