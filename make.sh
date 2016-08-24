#!/bin/bash
#
# mysql_config_editor set --login-path=local --host=localhost --user=magazzino --password


PREFIX="/home/vilardid/magazzinodb"
PREFIX2="/var/www/html/magazzino/dati/log"

logfile=$PREFIX2/logdb.htm
tracefile=$PREFIX2/temp_trace.sql

BINMYSQL="/usr/bin/mysql"
BINDUMP="/usr/bin/mysqldump"

BINCD="cd"
BINECHO="/bin/echo"
BINTOUCH="/bin/touch"
BINDATE="/bin/date"
BINRM="/bin/rm"

A="<h3> -->"
B="</h3>"
C="<P>"
D="</P>"

foo() {
while read -r line ; do $BINECHO $C $line $D >> $logfile; done
}

MYARGS="-H -umagazzino -pmagauser -D magazzino"
MYARGS1="-H -uroot -p"

#MYARGS="--login-path=magazzino -D magazzino"
#MYARGS1="--login-path=root"

$BINCD $PREFIX
$BINRM $logfile
$BINTOUCH $logfile
$BINTOUCH $tracefile

$BINECHO "<link rel=\"stylesheet\" href=\"../../css/logdb.css\" type=\"text/css\" />" >> $logfile

$BINECHO "<h1>Eseguito il $($BINDATE +"%d/%m/%Y %H.%M.%S")</h1>" >> $logfile

$BINECHO $A "Backup del watchdog" $B >> $logfile
$BINDUMP -umagazzino -pmagauser magazzino trace > $tracefile
#$BINDUMP --login-path=magazzino magazzino trace > $tracefile

$BINECHO $A "Utenza con relativi permessi" $B >> $logfile
$BINMYSQL $MYARGS1 -e "source ${PREFIX}/make_magauser.sql \W;" | foo

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

## FORZATURA UTENTE VILARDID PER TEST
$BINMYSQL $MYARGS -e "CALL input_permission('VILARDID','Vilardi','2');"
## FINE FORZATURA

#$BINECHO $A "Carico i dati" $B >> $logfile
#$BINMYSQL $MYARGS -e "source ${PREFIX}/dati.sql \W;" >> $logfile
#pv "${PREFIX}/dati.sql" | $BINMYSQL $MYARGS | foo

#if [ -f ${PREFIX2}/database.sql ]; then
#$BINMYSQL $MYARGS -e "source ${PREFIX2}/database.sql \W;" >> $logfile
#pv "${PREFIX2}/database.sql" | $BINMYSQL $MYARGS | foo
#fi

$BINECHO -ne '#######################   (100%)\r'

$BINECHO $A "Restore del watchdog" $B >> $logfile
$BINMYSQL $MYARGS -e "source $tracefile \W;" | foo
$BINRM $tracefile
