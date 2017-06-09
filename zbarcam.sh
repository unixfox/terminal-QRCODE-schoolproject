#!/bin/bash
while :
do
	# ls /dev/video*
        cameraqr=0
        cameraphoto=1
        prescale="320x320"
        trap ctrl_c INT
	endScan=0;
	function ctrl_c() {
	 endScan=1;
	}
	tmp=/tmp/barcode.$$
	zbarcam /dev/video"$cameraqr" --prescale="$prescale" --raw > $tmp &
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
	#zenity --info --text "Bonjour $surname $name !\nVeuillez regardez la caméra Microsoft jusqu'à ce que le témoin vert apparait\npour prendre une photo de vous attestant que vous êtes bien $surname $name." --timeout=5 --title="Vérification de présence"
	zenity --info --text "Capture en cours...\nVeuillez regarder l'objectif." --timeout=1 --title="Vérification de présence" &
	fswebcam -d /dev/video"$cameraphoto" -r 640x480 --jpeg 100 -D 1 capture/webcam-shot-$(date +%s).jpg
	zenity --info --text "Merci ! Photo effectuée, bonne journée !" --timeout=2 --title="Vérification de présence"
done
