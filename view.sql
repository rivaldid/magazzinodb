DROP VIEW IF EXISTS vista_documenti;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_documenti` AS
SELECT 
	id_registro,
	IF(file IS NULL OR file = '', 
		CONCAT_WS(' - ',tipo,numero,gruppo), 
		CONCAT('<a href=\"dati/registro/',file,'">',CONCAT_WS(' - ',tipo,numero,gruppo),'</a>')
	) AS documento,
	contatto,
	data 
FROM REGISTRO 
ORDER BY data DESC;


DROP VIEW IF EXISTS vista_ordini;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_ordini` AS
SELECT * FROM ORDINI LEFT JOIN vista_documenti ON id_registro_ordine = id_registro;


DROP VIEW IF EXISTS TRANSITI;
CREATE DEFINER=`magazzino`@`localhost` VIEW `TRANSITI` AS
SELECT
OPERAZIONI.id_operazioni,
OPERAZIONI.id_merce,
UTENTI.rete,
OPERAZIONI.data,
CASE direzione WHEN 0 THEN (SELECT 'USCITA') WHEN 1 THEN (SELECT 'INGRESSO') END AS status, 
posizione,
vista_documenti.documento AS documento,
vista_documenti.data AS data_doc, 
tags,
IF(direzione=0,
	IF(note LIKE '%PROVENIENZA%',
		CONCAT(quantita,' (da ',TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',-1)),')'),
		quantita
	),
	quantita
) AS quantita,
CONCAT_WS(' ',
	IF(note='',
		'Nessuna annotazione',
		IF(note LIKE '%PROVENIENZA%',
			TRIM(SUBSTRING_INDEX(note,'PROVENIENZA',1)),
			note)
	),
	IF(vista_ordini.trasportatore='',
		'',
		CONCAT(' Trasportatore: ',vista_ordini.trasportatore))
) as note,
vista_ordini.documento AS doc_ordine
FROM OPERAZIONI
JOIN MERCE USING(id_merce)
JOIN vista_documenti USING(id_registro)
JOIN UTENTI USING (id_utenti)
LEFT JOIN vista_ordini USING(id_operazioni)
ORDER BY data DESC;


DROP VIEW IF EXISTS vista_magazzino;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino` AS
SELECT id_merce,posizione,tags,quantita FROM MAGAZZINO JOIN MERCE USING(id_merce) WHERE quantita > 0 ORDER BY posizione,tags DESC;


DROP VIEW IF EXISTS vista_magazzino_parzxtot;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_parzxtot` AS
-- SELECT tags, SUM(quantita) AS tot, GROUP_CONCAT(posizione) AS posizioni FROM vista_magazzino GROUP BY tags
SELECT id_merce,tags,GROUP_CONCAT(DISTINCT CONCAT(posizione,'(',quantita,')') SEPARATOR ' ') AS posizioni,SUM(quantita) AS tot FROM vista_magazzino GROUP BY tags;


DROP VIEW IF EXISTS vista_magazzino_detail_simple;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_detail_simple` AS
SELECT
MERCE.id_merce,
CONCAT_WS(' ',
	MERCE.tags,
	IF(MERCE.tags LIKE 'BRETELL%',
		NULL,
		GROUP_CONCAT(
			CONCAT_WS(' ','Caricati',OPERAZIONI.quantita,'con',vista_documenti.documento,'(',vista_documenti.contatto,')')
		SEPARATOR ' ')
	)
) AS merce,
MAGAZZINO.posizione,MAGAZZINO.quantita,
IF(MERCE.tags LIKE 'BRETELL%', 
	NULL,
	GROUP_CONCAT(
		CONCAT_WS(' ',vista_ordini.documento,OPERAZIONI.note) 
	SEPARATOR ' ')
) AS note
FROM MAGAZZINO
LEFT JOIN MERCE USING(id_merce)
LEFT JOIN OPERAZIONI USING(id_merce,posizione)
LEFT JOIN vista_documenti USING(id_registro)
LEFT JOIN vista_ordini USING(id_operazioni)
WHERE MAGAZZINO.quantita>0
GROUP BY MAGAZZINO.id_merce,MAGAZZINO.posizione ORDER BY MERCE.tags;


DROP VIEW IF EXISTS vista_magazzino_detail;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino_detail` AS
SELECT
MERCE.id_merce,
CONCAT_WS(' ',
	MERCE.tags,
	GROUP_CONCAT(
		CONCAT_WS(' ','Caricati',OPERAZIONI.quantita,'con',vista_documenti.documento,'(',vista_documenti.contatto,')')
	SEPARATOR ' ')
) AS merce,
MAGAZZINO.posizione,MAGAZZINO.quantita,
GROUP_CONCAT(
	CONCAT_WS(' ',vista_ordini.documento,OPERAZIONI.note) 
SEPARATOR ' ') AS note
FROM MAGAZZINO
LEFT JOIN MERCE USING(id_merce)
LEFT JOIN OPERAZIONI USING(id_merce,posizione)
LEFT JOIN vista_documenti USING(id_registro)
LEFT JOIN vista_ordini USING(id_operazioni)
WHERE MAGAZZINO.quantita>0
GROUP BY MAGAZZINO.id_merce,MAGAZZINO.posizione ORDER BY MERCE.tags;


-- DROP VIEW IF EXISTS vista_magazzino3;
-- CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_magazzino3` AS
-- SELECT id_merce, tags, SUM(quantita) AS tot, GROUP_CONCAT(posizione) AS posizioni FROM vista_magazzino GROUP BY tags;


DROP VIEW IF EXISTS contromagazzino_subsel1;
CREATE DEFINER=`magazzino`@`localhost` VIEW `contromagazzino_subsel1` AS
SELECT 
	id_merce,
	quantita,
	posizione,
	-- CONCAT(
	--	IF(REGISTRO.file IS NULL OR REGISTRO.file = '', NULL, CONCAT('<p><a href="dati/registro/',REGISTRO.file,'">')),
	--	'Scaricati ',OPERAZIONI.quantita,' con ',REGISTRO.tipo,' - ',REGISTRO.numero,' (',REGISTRO.contatto,')',
	--	IF(REGISTRO.file IS NULL OR REGISTRO.file = '',NULL,'</a></p>')
	-- ) AS documento,
	note 
FROM OPERAZIONI JOIN REGISTRO USING(id_registro) WHERE direzione=0 AND contatto!='Aggiornamento';


DROP VIEW IF EXISTS contromagazzino_subsel2;
CREATE DEFINER=`magazzino`@`localhost` VIEW `contromagazzino_subsel2` AS
SELECT id_merce,quantita,posizione FROM MAGAZZINO WHERE quantita>0;


DROP VIEW IF EXISTS contromagazzino_jsubsel;
CREATE DEFINER=`magazzino`@`localhost` VIEW `contromagazzino_jsubsel` AS
SELECT 
	contromagazzino_subsel1.id_merce,
	contromagazzino_subsel1.quantita,
	contromagazzino_subsel1.posizione,
	-- contromagazzino_subsel1.documento,
	contromagazzino_subsel1.note
FROM
	contromagazzino_subsel1 
LEFT JOIN 
	contromagazzino_subsel2
ON CONCAT(
		contromagazzino_subsel1.id_merce,
		contromagazzino_subsel1.quantita,
		contromagazzino_subsel1.posizione)
	= CONCAT(
		contromagazzino_subsel2.id_merce,
		contromagazzino_subsel2.quantita,
		contromagazzino_subsel2.posizione)
WHERE CONCAT(
	contromagazzino_subsel2.id_merce,
	contromagazzino_subsel2.quantita,
	contromagazzino_subsel2.posizione) IS NULL;


DROP VIEW IF EXISTS contromagazzino;
CREATE DEFINER=`magazzino`@`localhost` VIEW `contromagazzino` AS
SELECT 
	MERCE.tags AS merce, 
	GROUP_CONCAT(DISTINCT CONCAT(contromagazzino_jsubsel.posizione,'(',contromagazzino_jsubsel.quantita,')') SEPARATOR ' ') AS posizione, 
	sum(contromagazzino_jsubsel.quantita) AS quantita,
	MERCE.id_merce,
	-- GROUP_CONCAT(contromagazzino_jsubsel.documento SEPARATOR ' ') AS documento,
	GROUP_CONCAT(contromagazzino_jsubsel.note SEPARATOR ' ') AS note
FROM contromagazzino_jsubsel
JOIN MERCE ON contromagazzino_jsubsel.id_merce=MERCE.id_merce 
GROUP BY MERCE.tags ORDER BY MERCE.tags;


DROP VIEW IF EXISTS report_transiti_mensile;
CREATE DEFINER=`magazzino`@`localhost` VIEW `report_transiti_mensile` AS
SELECT DATE_FORMAT(data,'%d/%m/%Y') AS data,rete,status,posizione,
tags,quantita,CONCAT(strip_htmltags(documento),' del ',DATE_FORMAT(data_doc,'%d/%m/%Y')) AS riferimento,
note, strip_htmltags(doc_ordine) FROM TRANSITI WHERE 1 AND
data >= DATE_FORMAT(NOW(),'%Y-%m-01') - INTERVAL 1 MONTH AND
data < DATE_FORMAT(NOW(),'%Y-%m-01') ORDER BY data ASC;


-- VISTA ACCESSI ACCOUNT DI RETE
DROP VIEW IF EXISTS vista_trace;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_trace` AS
SELECT id_trace,DATE_FORMAT(FROM_UNIXTIME(REQUEST_TIME),'%Y-%m-%d %H.%i.%s') AS data,REQUEST_URI,HTTP_REFERER,REMOTE_ADDR,REMOTE_USER,PHP_AUTH_USER,HTTP_USER_AGENT FROM trace;


-- VISTA SESSION HANDLER
DROP VIEW IF EXISTS vista_sh;
CREATE DEFINER=`magazzino`@`localhost` VIEW `vista_sh` AS
SELECT rete,page,contents,DATE_FORMAT(FROM_UNIXTIME(date),'%Y-%m-%d %H.%i.%s') AS date_readable FROM session_handler;
