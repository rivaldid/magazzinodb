DROP VIEW IF EXISTS vserv_etichette;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_etichette` AS
SELECT label FROM proprieta WHERE sel = 1;


DROP VIEW IF EXISTS vserv_contatti;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_contatti` AS
SELECT label FROM proprieta WHERE sel = 5 ORDER BY label;


DROP VIEW IF EXISTS vserv_tipodoc;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_tipodoc` AS
SELECT label FROM proprieta WHERE sel = 4 ORDER BY label;


DROP VIEW IF EXISTS vserv_numdoc;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_numdoc` AS
SELECT numero FROM REGISTRO ORDER BY numero;


DROP VIEW IF EXISTS vserv_posizioni;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_posizioni` AS
SELECT label FROM proprieta WHERE sel = 2 ORDER BY label;


DROP VIEW IF EXISTS vserv_destinazioni;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_destinazioni` AS
SELECT label FROM proprieta WHERE sel = 3;


DROP VIEW IF EXISTS vserv_numoda;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_numoda` AS
SELECT numero FROM REGISTRO WHERE tipo = 'ODA' ORDER BY numero;


DROP VIEW IF EXISTS vserv_transiti;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_transiti` AS
SELECT rete,DATE_FORMAT(data,'%d/%m/%Y') AS dataop,status,posizione,documento,DATE_FORMAT(data_doc,'%d/%m/%Y') AS data_doc,tags,quantita,note,doc_ordine,id_merce,id_operazioni FROM TRANSITI;

DROP VIEW IF EXISTS vserv_report_transiti_mensile;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_report_transiti_mensile` AS
SELECT * FROM report_transiti_mensile;


-- viste magazzino: base, contro (subsel1 subsel2 jsubsel), detail, detail_simple (senza info sulle bretelle)
-- output: merce posizione quantita id_merce +detail: note

DROP VIEW IF EXISTS vserv_magazzino;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino` AS
SELECT tags AS merce,posizioni AS posizione,tot AS quantita,id_merce FROM vista_magazzino_parzxtot;


DROP VIEW IF EXISTS vserv_magazzino_contro;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_contro` AS
SELECT * FROM contromagazzino;


DROP VIEW IF EXISTS vserv_magazzino_detail;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_detail` AS
SELECT merce, posizione, quantita, id_merce, note FROM vista_magazzino_detail;


DROP VIEW IF EXISTS vserv_magazzino_detail_simple;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_detail_simple` AS
SELECT merce, posizione, quantita, id_merce, note FROM vista_magazzino_detail_simple;


-- fine viste magazzino


DROP VIEW IF EXISTS vserv_registro;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_registro` AS
SELECT contatto, documento, data FROM vista_documenti;


DROP VIEW IF EXISTS vserv_merce;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_merce` AS
SELECT * FROM MAGAZZINO LEFT JOIN MERCE USING(id_merce) WHERE quantita>0;


DROP VIEW IF EXISTS vserv_utenti;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_utenti` AS
SELECT rete FROM UTENTI;


DROP VIEW IF EXISTS vserv_tags2;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_tags2` AS
SELECT label from proprieta WHERE sel='1' and label LIKE 'UTP%' OR label LIKE 'FO%';


DROP VIEW IF EXISTS vserv_tags3;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_tags3` AS
SELECT label from proprieta WHERE sel='1' and label like '%M';


DROP VIEW IF EXISTS vserv_gruppi_doc;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_gruppi_doc` AS
SELECT id_registro,gruppo,CONCAT_WS(' - ',contatto,tipo,numero) as documento,data FROM REGISTRO WHERE tipo NOT IN ('MDS','Sistema','Aggiornamento') ORDER BY data DESC;
