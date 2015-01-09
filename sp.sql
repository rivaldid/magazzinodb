USE magazzino;

-- ---------------------- tokenizza tags ----------------------
DELIMITER //
-- DROP PROCEDURE IF EXISTS tokenizza_tags //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `tokenizza_tags`(IN tokens TEXT)
BEGIN
DECLARE i INT;
DECLARE token TEXT;
SET @i=1;

myloop: LOOP
	SET @token = split_string(tokens, ' ', @i);
	SET @i = @i + 1;
	IF (@token = '') THEN
		LEAVE myloop;
	END IF;
	CALL input_proprieta('1',@token);
END LOOP myloop;

END //
DELIMITER ;


-- ---------------------- fix proprieta tags ----------------------
-- note: genera(va) un warning // FIXATO!
-- DECLARE CONTINUE HANDLER FOR NOT FOUND SET @done = TRUE;
-- | Error | 1329 | No data - zero rows fetched, selected, or processed |
DELIMITER //
-- DROP PROCEDURE IF EXISTS fix_proprieta_tags //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `fix_proprieta_tags`()
BEGIN

	DECLARE done INT DEFAULT FALSE;
	DECLARE cursor_val TEXT;
	DECLARE cursor_i CURSOR FOR SELECT tags FROM MERCE;
	DECLARE CONTINUE HANDLER FOR NOT FOUND
    BEGIN
		SELECT 1 INTO @done FROM (SELECT 1) AS t;
    END;
    
	OPEN cursor_i;
	
	read_loop: LOOP 
		FETCH cursor_i INTO cursor_val;
		IF @done THEN
			LEAVE read_loop;
		END IF;
		CALL tokenizza_tags(cursor_val);
	END LOOP;
	CLOSE cursor_i;

END //
DELIMITER ;
