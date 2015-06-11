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
SELECT doc_ingresso,doc_ordine,rete,DATE_FORMAT(data,'%d/%m/%Y') AS dataop,status,posizione,documento,DATE_FORMAT(data_doc,'%d/%m/%Y') AS data_doc,tags,quantita,note,ordine,id_merce,id_operazioni FROM TRANSITI;

DROP VIEW IF EXISTS vserv_report_transiti_mensile;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_report_transiti_mensile` AS
SELECT * FROM report_transiti_mensile;


DROP VIEW IF EXISTS vserv_magazzino;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_id` AS
SELECT tags,posizioni,tot,id_merce FROM vista_magazzino_parzxtot;


DROP VIEW IF EXISTS vserv_magazzino_contro_subsel1;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_contro_subsel1` AS
SELECT id_merce,quantita,posizione FROM OPERAZIONI JOIN REGISTRO USING(id_registro) WHERE direzione=0 AND contatto!='Aggiornamento';


DROP VIEW IF EXISTS vserv_magazzino_contro_subsel2;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_contro_subsel2` AS
SELECT id_merce,quantita,posizione FROM MAGAZZINO WHERE quantita>0;


DROP VIEW IF EXISTS vserv_magazzino_contro_jsubsel;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_contro_jsubsel` AS
SELECT 
	vserv_magazzino_contro_subsel1.id_merce,
	vserv_magazzino_contro_subsel1.quantita,
	vserv_magazzino_contro_subsel1.posizione 
FROM
	vserv_magazzino_contro_subsel1 
LEFT JOIN 
	vserv_magazzino_contro_subsel2
ON CONCAT(
		vserv_magazzino_contro_subsel1.id_merce,
		vserv_magazzino_contro_subsel1.quantita,
		vserv_magazzino_contro_subsel1.posizione)
	= CONCAT(
		vserv_magazzino_contro_subsel2.id_merce,
		vserv_magazzino_contro_subsel2.quantita,
		vserv_magazzino_contro_subsel2.posizione)
WHERE CONCAT(
	vserv_magazzino_contro_subsel2.id_merce,
	vserv_magazzino_contro_subsel2.quantita,
	vserv_magazzino_contro_subsel2.posizione) IS NULL;


DROP VIEW IF EXISTS vserv_magazzino_contro;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_contro` AS
SELECT 
	MERCE.tags AS tags, 
	GROUP_CONCAT(DISTINCT CONCAT(vserv_magazzino_contro_jsubsel.posizione,'(',vserv_magazzino_contro_jsubsel.quantita,')')) AS posizioni, 
	sum(vserv_magazzino_contro_jsubsel.quantita) AS tot 
FROM vserv_magazzino_contro_jsubsel
JOIN MERCE ON vserv_magazzino_contro_jsubsel.id_merce=MERCE.id_merce GROUP BY MERCE.tags ORDER BY MERCE.tags;


DROP VIEW IF EXISTS vserv_registro;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_registro` AS
SELECT contatto, tipo, numero, gruppo, data, file FROM REGISTRO;


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
