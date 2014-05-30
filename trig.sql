DELIMITER //
DROP TRIGGER IF EXISTS aggiorna_magazzino //
CREATE DEFINER=`magazzino`@`localhost` TRIGGER `aggiorna_magazzino` AFTER INSERT ON OPERAZIONI
FOR EACH ROW
BEGIN
CALL input_magazzino(in_direzione, in_id_merce, in_posizione, in_quantita);
END //
DELIMITER ;
