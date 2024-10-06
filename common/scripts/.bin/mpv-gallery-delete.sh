days=7
min=$((days * 60 * 24))
# run first without -delete to be sure
find ~/.cache/thumbnails/mpv-gallery/ -maxdepth 1 -type f -amin +$min -delete
