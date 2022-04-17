#!/bin/sh
# should not have any space on the first param
borg create --stats --compression lzma /media/backup/backup-borg/monthly::{hostname}-monthly-{now:%Y-%m-%dT%H} / \
	--exclude .Private \
	--exclude .cache \
	--exclude /dev \
	--exclude /home \
	--exclude .thumbnails* \
	--exclude /.vifm-Trash*  \
	--exclude .locale/share/Trash \
	--exclude '*~' \
	--exclude '*.backup*' \
	--exclude /etc/mtab \
	--exclude /lost+found \
	--exclude /media \
	--exclude /mnt \
	--exclude /proc \
	--exclude /sys \
	--exclude /var/backups \
	--exclude /var/tmp \
	--exclude /tmp \
	--exclude /run/media  \
	--exclude /run/mount  \
	--exclude /var/cache \
	--exclude '*.class'	>> ~/Documents/Ustawienia/logs/borg-pc/log_monthly.txt 2>&1
	# --exclude .Private \
	# --exclude .cache/* \
	# --exclude .dropbox* \
	# --exclude /dev/* \
	# --exclude /home \
	# --exclude /etc/mtab \
	# --exclude .thumbnails* \
	# --exclude /.vifm-Trash*  \
	# --exclude .locale/share/?rash* \
	# --exclude *~ \
	# --exclude *.backup* \
	# --exclude /lost+found/* \
	# --exclude /media \
	# --exclude /mnt \
	# --exclude /proc/* \
	# --exclude /sys/* \
	# --exclude /var/backups/* \
	# --exclude /var/tmp/* \
	# --exclude /tmp \
	# --exclude /run/media  \
	# --exclude /run/mount  \

dunstify "backuped monthly"
