#!/usr/local/bin/bash

PREFIX=/home/apache/data/magazzino/projdb_dctomaga
BINMYSQL=/usr/local/bin/mysql
BINCD=/usr/bin/cd
BINECHO=/bin/echo
BINTOUCH=/usr/bin/touch
BINDATE=/bin/date

$BINCD $PREFIX
$BINTOUCH logfile
$BINECHO '==========>'$($BINDATE) >> logfile

$BINECHO "Carico la base" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source base.sql \W;' >> logfile
$BINECHO "Carico le funzioni" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source fun.sql \W;' >> logfile
$BINECHO "Carico le procedure" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp.sql \W;' >> logfile
$BINECHO "Carico le procedure di input" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_inp.sql \W;' >> logfile
$BINECHO "Carico le APIs pubbliche" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_pub.sql \W;' >> logfile
$BINECHO "Carico le viste sui dati" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source view.sql \W;' >> logfile
$BINECHO "Carico le procedure di aggiornamento dati" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source sp_upd.sql \W;' >> logfile
$BINECHO "Carico i dati" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source dati.sql \W;' >> logfile

$BINECHO "Carico le viste per il service" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source vserv.sql \W;' >> logfile
$BINECHO "Strumenti di debug" >> logfile
$BINMYSQL -umagazzino -pmagauser -D magazzino -e 'source debug.sql \W;' >> logfile
