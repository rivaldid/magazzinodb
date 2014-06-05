#!/usr/local/bin/bash

PREFIX=/home/vilardid/progetto_db_magazzino
BINMYSQL=/usr/local/bin/mysql
BINCD=/usr/bin/cd
BINECHO=/bin/echo

$BINCD $PREFIX
$BINECHO "Carico la base";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source base.sql';
$BINECHO "Carico le funzioni";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source fun.sql';
$BINECHO "Carico le procedure";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp.sql';
$BINECHO "Carico le procedure di input";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_inp.sql';
$BINECHO "Carico le APIs pubbliche";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_pub.sql';
$BINECHO "Carico i dati";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source dati.sql';
$BINECHO "Carico le viste sui dati";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source view.sql';
$BINECHO "Carico le procedure di aggiornamento dati";
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_upd.sql';
