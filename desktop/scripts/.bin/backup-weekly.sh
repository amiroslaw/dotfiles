#!/bin/sh
# should not have any space on the first param
# debug borg create -n --compression zlib /media/multi/backup/weekly::{hostname}-weekly-{now:%m-%dT%H}	\
borg create --compression zlib --stats /media/multi/backup/weekly::{hostname}-weekly-{now:%m-%dT%H}	\
	~/Documents \
	~/Code \
	--exclude '/home/miro/*/.debris'	\
	--exclude **/node_modules	\
	--exclude **/build	\
	--exclude '*.class'	>> ~/Documents/Ustawienia/skrypty/moje/borg/log_weekly.txt 2>&1
	# --exclude **/.debris	\
