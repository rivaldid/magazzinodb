DELIMITER //


-- ---------------------- session handler: WRITE ----------------------
DROP PROCEDURE IF EXISTS sh_write //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_write`(
IN in_rete VARCHAR(45),
IN in_page VARCHAR(45),
IN in_contents TEXT,
IN in_date INT UNSIGNED
)
BEGIN
IF (SELECT sh_record_exists(in_rete,in_page)) THEN
	UPDATE session_handler SET contents=in_contents,date=in_date WHERE rete=in_rete AND page=in_page;
ELSE
	INSERT INTO session_handler(rete,page,contents,date) VALUES (in_rete,in_page,in_contents,in_date);
END IF;
END //


-- ---------------------- session handler: READ ----------------------
DROP PROCEDURE IF EXISTS sh_read //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_read`(
IN in_rete VARCHAR(45),
IN in_page VARCHAR(45),
OUT out_contents TEXT
)
BEGIN
IF (SELECT sh_record_exists(in_rete,in_page)) THEN
	CALL sh_cleanup_retexpage(in_rete,in_page);
	SELECT contents INTO @out_contents FROM session_handler WHERE rete=in_rete AND page=in_page;
END IF;
END //


-- ---------------------- session handler: DESTROY ----------------------
DROP PROCEDURE IF EXISTS sh_destroy //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_destroy`(
IN in_rete VARCHAR(45),
IN in_page VARCHAR(45)
)
BEGIN
DELETE FROM session_handler WHERE rete=in_rete AND page=in_page;
END //


-- ---------------------- session handler: GARBAGE ----------------------
DROP PROCEDURE IF EXISTS sh_garbage //
CREATE DEFINER=`magazzino`@`localhost` PROCEDURE `sh_garbage`()
BEGIN
DELETE FROM session_handler WHERE date < (SELECT mezzorafa());
END //


DELIMITER ;
