#!/usr/local/bin/bash

PREFIX=/home/vilardid/progetto_db_magazzino
BINMYSQL=/usr/local/bin/mysql
BINCD=/usr/bin/cd

$BINCD $PREFIX

$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source base.sql';
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source fun.sql';
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp.sql';
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source dati.sql';
