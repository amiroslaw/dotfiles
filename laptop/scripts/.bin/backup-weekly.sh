#!/bin/sh
# should not have any space on the first param
borg create --compression zlib --stats ~/backup/weekly::{hostname}-weekly-{now:%m-%dT%H}	\
	~/Documents \
	~/Code \
	--exclude '/home/miro/*/.debris'	\
	--exclude **/node_modules	\
	--exclude **/build	\
	--exclude '*.class'	>> ~/Documents/Ustawienia/skrypty/moje/borg/laptop/log_weekly.txt 2>&1
	# --exclude **/.debris	\
