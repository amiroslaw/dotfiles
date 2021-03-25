#!/bin/sh
# should not have any space on the first param
borg create --stats /media/multi/backup/daily::{hostname}-daily-{now:%m-%dT%H}	\
	~/Documents/Ustawienia \
	~/Documents/notebook_md \
	~/Code/Projekty \
	~/Code/SourceCode \
	--exclude **/node_modules \
	--exclude '/home/miro/*/.debris'	\
	--exclude **/build \
	--exclude '*.class'	>> ~/Documents/Ustawienia/skrypty/moje/borg/log_daily.txt 2>&1

	# --exclude **/.debris \
