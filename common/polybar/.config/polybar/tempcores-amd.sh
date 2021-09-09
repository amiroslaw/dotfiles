#!/bin/bash

# fork from Per-core temperatures :
# https://github.com/jaagr/polybar/wiki/User-contributed-modules#per-core-temperatures

# Get information from cores temp thanks to sensors
# rawData=$( sensors | awk '/temp1/ {printf "%3.0f", (($2+0)-32)*5/9;}' ) - farenhite to celcius in linux 4.14 kernel
tempCore=$( sensors | awk '/Tdie/ {printf "%3.0f", $2}' )

# Define constants :
degree="°C"
temperaturesValues=(40 50 60 70 80 90)
temperaturesColors=("#6bff49" "#f4cb24" "#ff8819" "#ff3205" "#f40202" "#ef02db")
temperaturesIcons=(     )

for iCore in ${!tempCore[*]}
do
    for iTemp in ${!temperaturesValues[*]}
    do
        if (( "${tempCore[$iCore]}" < "${temperaturesValues[$iTemp]}"  )); then
            tmpEcho="%{F${temperaturesColors[$iTemp]}}${tempCore[$iCore]}$degree%{F-}"
            finalEcho="$finalEcho $tmpEcho"
            break
        fi
    done
    total=$(( ${tempCore[$iCore]} + total ));
done

sum=$(( $total/${#tempCore[*]} ))

for iTemp in ${!temperaturesValues[*]}
do
    if (( "$sum" < "${temperaturesValues[$iTemp]}" )); then
        ## This line will color the icon too
        tmpEcho="%{F${temperaturesColors[$iTemp]}}${temperaturesIcons[$iTemp]}%{F-}"
        ## This line will NOT color the icon
        #tmpEcho="${temperaturesIcons[$iTemp]}"
        finalEcho=" $finalEcho $tmpEcho"
        break
    fi
done

echo $finalEcho
