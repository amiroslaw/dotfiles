#!/bin/bash
# change library path
# library=media/multi/Musics/

song_to_remove=$(mpc current)
playlist_pos=$(mpc -f %position% current)
	#Delete the song
	trash-put "$(mpc -f %file% current | sed 's/^/\/media\/multi\/Musics\//')"
	#Remove the song from playlist
	mpc del $playlist_pos
	#Write to log file
	notify-send "[`date`] -> $song_to_remove deleted."
	mpc update

#kdialog --title "Removing the song" --yesno "Do you really want to delete the song \n$(mpc | head -n 1)?"
 
##If Yes, then 0 is returned, else 1
#reply=$(echo $?)

#if [[ reply -eq 0 ]];then
#        song_to_remove=$(mpc | head -n 1)
#        playlist_pos=$(mpc -f %position% | head -n 1)
#        #Delete the song
#        rm "$(mpc -f %file% | head -n 1 | sed 's/^/\/media\/Data\/mpdLibrary\//')"
#        #Remove the song from playlist
#        mpc del $playlist_pos
#        #Write to log file
#        echo "[`date`] -> --$song_to_remove-- is now deleted..." >> ~/.mpdremove.log
#fi
