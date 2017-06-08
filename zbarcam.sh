#!/bin/bash
while :
do
	DATE=$(date)
	start="08:00:00"
    end="17:00:00"
	trap ctrl_c INT
	endScan=0;
	function ctrl_c() {
	 endScan=1;
	}
	tmp=/tmp/barcode.$$
	LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so zbarcam --raw > $tmp &
	pid=$!
	while [[ ! -s $tmp ]] ; do
	 sleep 1
	 if [ $endScan == 1 ]; then
	 	kill $pid
	 	exit 1
	 fi
	done
	kill $pid
	CODE=$(cat $tmp)
	rm $tmp
	echo $CODE
	surname="$(sqlite3 database.db 'select surname FROM "default" where id = '$CODE';')"
	name="$(sqlite3 database.db 'select name FROM "default" where id = '$CODE';')"
	zenity --info --text "Bonjour $surname $name !\n Veuillez regardez la caméra Microsoft pour prendre\n une photo de vous attestant que vous êtes bien $surname $name." --title="Vérification d'élève"
done