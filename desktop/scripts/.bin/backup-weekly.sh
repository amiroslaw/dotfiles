#!/bin/sh
# should not have any space on the first param
# debug borg create -n --compression zlib /media/multi/backup/weekly::{hostname}-weekly-{now:%m-%dT%H}	\
borg create --compression zlib --stats /media/backup/backup-borg/weekly::{hostname}-weekly-{now:%Y-%m-%dT%H}	\
	~/Documents \
	~/Code \
	--exclude '/home/miro/*/.debris'	\
	--exclude **/node_modules	\
	--exclude **/build	\
	--exclude **/target	\
	--exclude '*.class'	>> ~/Documents/Ustawienia/logs/borg-pc/log_weekly.txt 2>&1
	# --exclude **/.debris	\

dunstify "backuped weekly"
