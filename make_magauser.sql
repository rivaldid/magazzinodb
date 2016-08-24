CALL administration.drop_user('magazzino',@res);
SELECT @res;
CREATE USER 'magazzino'@'%' IDENTIFIED BY 'magauser';
DROP DATABASE IF EXISTS `magazzino`;
CREATE DATABASE `magazzino`;
GRANT ALL PRIVILEGES ON magazzino.* TO 'magazzino'@'%';
FLUSH PRIVILEGES;
