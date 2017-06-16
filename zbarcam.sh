#!/bin/bash
while :
do
	# ls /dev/video*
    cameraqr=0
    cameraphoto=1
    # Dimension de la fenêtre du scan du QR Code
    prescale="320x320"
    # Récupérer la date actuelle sous forme de timestamp Unix
    DATE=$(date +"%Y-%m-%d_%H:%M:%S")
    # Dès qu'un CTRL + C est pressé ça quitte le programme.
    trap ctrl_c INT
	endScan=0;
	function ctrl_c() {
	 endScan=1;
	}
	# Variable définissant l'endroit où sera stocké le fichier temporaire concenant la valeur inscrit sur le QR Code.
	tmp=/tmp/barcode.$$
	# Lancement de Zbarcam
	zbarcam /dev/video"$cameraqr" --prescale="$prescale" --raw > $tmp &
	# Récupération du numéro du processus Zbarcam
	pid=$!
	# Boucle liée au CTRL + C
	while [[ ! -s $tmp ]] ; do
	 sleep 1
	 if [ $endScan == 1 ]; then
	 	kill $pid
	 	exit 1
	 fi
	done
	# On tue le processus une fois qu'on a récupéré la valeur inscrit sur le QR Code.
	kill $pid
	# Lecture du fichier temporaire et puis sauvegarde de sa valeur dans une variable.
	CODE=$(cat $tmp)
	# Suppression du fichier temporaire
	rm $tmp
	# Récupération du prénom depuis la base de données
	surname="$(sqlite3 database.db 'select surname FROM "default" where id = '$CODE';')"
	# Récupération du nom depuis la base de données
	name="$(sqlite3 database.db 'select name FROM "default" where id = '$CODE';')"
	# Affichage d'une boite de dialogue
	gxmessage -center -geometry 300x50 --wrap "Bonjour $surname $name !" -timeout 2 -title "Vérification de présence" &
	# Prise d'une photo de la personne via la deuxième caméra.
	fswebcam -d /dev/video"$cameraphoto" -r 640x480 --jpeg 100 -D 2 capture/"$surname"-"$name"-"$DATE".jpg
	# Affichage d'une boite de dialogue n°2
	gxmessage -center -geometry 300x50 --wrap "Bonne journée !" -timeout 2 -title "Présence Vérifiée"
done
