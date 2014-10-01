USE magazzino;


DELIMITER //
-- DROP VIEW IF EXISTS vserv_etichette //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_etichette` AS 
SELECT label FROM proprieta WHERE sel = 1;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_contatti //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_contatti` AS 
SELECT label FROM proprieta WHERE sel = 5;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_tipodoc //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_tipodoc` AS 
SELECT label FROM proprieta WHERE sel = 4;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_numdoc //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_numdoc` AS 
SELECT numero FROM REGISTRO;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_posizioni //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_posizioni` AS 
SELECT label FROM proprieta WHERE sel = 2;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_destinazioni //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_destinazioni` AS 
SELECT label FROM proprieta WHERE sel = 3;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_numoda //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_numoda` AS 
SELECT numero FROM REGISTRO WHERE tipo = 'ODA';
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_transiti //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_transiti` AS 
SELECT * FROM TRANSITI;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_magazzino //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino` AS 
SELECT * FROM vista_magazzino2;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_registro //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_registro` AS 
SELECT contatto, tipo, numero, gruppo, data, file FROM REGISTRO;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_merce //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_merce` AS 
SELECT * FROM MAGAZZINO LEFT JOIN MERCE USING(id_merce) WHERE quantita>0;
//
DELIMITER ;

DELIMITER //
-- DROP VIEW IF EXISTS vserv_magazzino_id //
CREATE DEFINER=`magazzino`@`localhost` VIEW `vserv_magazzino_id` AS 
SELECT * FROM vista_magazzino3;
//
DELIMITER ;


