#!/bin/sh
# should not have any space on the first param
borg create --stats /media/backup/backup-borg/daily::{hostname}-daily-{now:%Y-%m-%dT%H}	\
	~/Documents/Ustawienia \
	~/Documents/notebook_md \
	~/Code/Projekty \
	~/Code/SourceCode \
	--exclude **/node_modules \
	--exclude '/home/miro/*/.debris'	\
	--exclude **/build \
	--exclude '*.class'	>> ~/Documents/Ustawienia/logs/borg-pc/log_daily.txt 2>&1

	# --exclude **/.debris \
