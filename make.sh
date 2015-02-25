#!/usr/local/bin/bash

PREFIX=/usr/local/www/apache22/data/GMDBDCTO
PREFIX2=/usr/local/www/apache22/data/GMDCTO/log
logfile=$PREFIX2/logdb.htm

BINMYSQL=/usr/local/bin/mysql
BINCD=/usr/bin/cd
BINECHO=/bin/echo
BINTOUCH=/usr/bin/touch
BINDATE=/bin/date

A="<P>"
B=" <i class='fa fa-check-circle'></i></P>"

MYARGS="-H -umagazzino -pmagauser -D magazzino"

$BINCD $PREFIX
$BINTOUCH $logfile

$BINECHO "<HTML><HEAD>" >> $logfile
$BINECHO "<link rel='stylesheet' href='../020/css/outputmysql.css' type='text/css' />" >> $logfile
$BINECHO "<link rel='stylesheet' href='../020/lib/font-awesome/css/font-awesome.min.css' type='text/css' />" >> $logfile
$BINECHO "</HEAD><BODY>" >> $logfile

$BINECHO "<div id='bloccosuperiore'>" >> $logfile
$BINECHO "<p class='titolo'><i class='fa fa-1x fa-arrow-circle-right'></i> Eseguito il $($BINDATE +"%d/%m/%Y %H.%M.%S")</p>" >> $logfile

$BINECHO $A "Carico la base" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/base.sql \W;" >> $logfile
$BINECHO $A "Carico le funzioni" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/fun.sql \W;" >> $logfile
$BINECHO $A "Carico le procedure" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp.sql \W;" >> $logfile
$BINECHO $A "Carico le procedure di input" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_inp.sql \W;" >> $logfile
$BINECHO $A "Carico le procedure di aggiornamento dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_upd.sql \W;" >> $logfile

$BINECHO $A "Carico le APIs pubbliche" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_pub.sql \W;" >> $logfile
$BINECHO $A "Carico le viste sui dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/view.sql \W;" >> $logfile

$BINECHO $A "Carico le viste per il service" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/vserv.sql \W;" >> $logfile
$BINECHO $A "Strumenti di debug" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/debug.sql \W;" >> $logfile

$BINECHO "</div>" >> $logfile

$BINECHO $A "Carico i dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/dati.sql \W;" >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX2}/dati2.sql \W;" >> $logfile

$BINECHO "</BODY></HTML>" >> $logfile

