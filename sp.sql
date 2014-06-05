USE magazzino;

-- ---------------------- tokenizza tags ----------------------
DELIMITER //
DROP PROCEDURE IF EXISTS tokenizza_tags //
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
	ELSE
		CALL input_proprieta('1',@token);
	END IF;
END LOOP myloop;

END //
DELIMITER ;


-- ---------------------- fix proprieta tags ----------------------
-- note: genera un warning
-- | Error | 1329 | No data - zero rows fetched, selected, or processed |
DELIMITER //
DROP PROCEDURE IF EXISTS fix_proprieta_tags //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `fix_proprieta_tags`()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE in_tags TEXT;

DECLARE foo CURSOR FOR SELECT tags FROM MERCE;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN foo;
bar: LOOP 
	FETCH foo INTO in_tags;
	IF done THEN
		LEAVE bar;
	END IF;
	CALL tokenizza_tags(in_tags);
END LOOP bar;
CLOSE foo;

END //
DELIMITER ;
