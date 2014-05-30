USE magazzino;

DELIMITER //
DROP FUNCTION IF EXISTS split_string //
CREATE DEFINER=`magazzino`@`localhost` FUNCTION `split_string`(x TEXT, delim VARCHAR(12), pos INT) RETURNS TEXT
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos), LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1), delim, ''); //
DELIMITER ;

