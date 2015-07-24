#!/bin/bash
#
# mysql_config_editor set --login-path=local --host=localhost --user=magazzino --password


PREFIX="/home/vilardid/magazzinodb"
PREFIX2="/var/www/html/magazzino/dati/log"
logfile=$PREFIX2/logdb.htm

BINMYSQL="/usr/bin/mysql"
BINCD="cd"
BINECHO="/bin/echo"
BINTOUCH="/bin/touch"
BINDATE="/bin/date"

A="<h3> -->"
B="</h3>"
C="<P>"
D="</P>"

foo() {
while read -r line ; do $BINECHO $C.$line.$D >> $logfile; done
}

#MYARGS="-H -umagazzino -pmagauser -D magazzino"
MYARGS="--login-path=local -D magazzino"

$BINCD $PREFIX
$BINTOUCH $logfile

$BINECHO "<link rel=\"stylesheet\" href=\"../../css/logdb.css\" type=\"text/css\" />" >> $logfile

$BINECHO "<h1>Eseguito il $($BINDATE +"%d/%m/%Y %H.%M.%S")</h1>" >> $logfile

$BINECHO $A "Carico la base" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/base.sql \W;" | foo
$BINECHO $A "Carico le funzioni" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/fun.sql \W;" | foo
$BINECHO $A "Carico le procedure" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp.sql \W;" | foo
$BINECHO $A "Carico le procedure di input" $B >> $logfile

$BINECHO -ne '#####                     (33%)\r'

$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_inp.sql \W;" | foo
$BINECHO $A "Carico le procedure di aggiornamento dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_upd.sql \W;" | foo

$BINECHO $A "Carico le APIs pubbliche" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sp_pub.sql \W;" | foo
$BINECHO $A "Carico le viste sui dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/view.sql \W;" | foo
$BINECHO $A "Carico Session Handler" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/sh.sql \W;" | foo

$BINECHO -ne '##########                (50%)\r'

$BINECHO $A "Carico le viste per il service" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/vserv.sql \W;" | foo
$BINECHO $A "Strumenti di debug" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/debug.sql \W;" | foo

$BINECHO -ne '#############             (66%)\r'

$BINECHO $A "Carico i dati" $B >> $logfile
$BINMYSQL $MYARGS -e "source ${PREFIX}/dati.sql \W;" | foo

if [ -f ${PREFIX2}/database.sql ] 
then
$BINMYSQL $MYARGS -e "source ${PREFIX2}/database.sql \W;" | foo
fi

$BINECHO -ne '#######################   (100%)\r'
