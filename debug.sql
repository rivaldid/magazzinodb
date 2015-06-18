-- ------------------------- debugging TRANSITI -------------------------

DROP VIEW IF EXISTS seldist_op;
CREATE DEFINER=`magazzino`@`localhost` VIEW `seldist_op` AS
SELECT DISTINCT id_registro,id_merce,quantita,posizione FROM OPERAZIONI;

DROP VIEW IF EXISTS selfull_op;
CREATE DEFINER=`magazzino`@`localhost` VIEW `selfull_op` AS
SELECT id_registro,id_merce,quantita,posizione FROM OPERAZIONI;


