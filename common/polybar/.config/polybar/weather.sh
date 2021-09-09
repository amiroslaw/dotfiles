#!/bin/sh
city="Warsaw,pl"
cityId=7531123
# 756135 → warszawa
apiKey="db518057f6d56bfabe96e3809f123561"
# curl -s "${api_prefix}forecast?${appid}${id}${units}${lang}" -o "$forecast"
# temp=$(curl -s "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=${apiKey}&q=${city}" | jq '.main.temp')
temp=$(curl -s "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=${apiKey}&q=${city}" | jq '.main.temp')
if [ -n "$temp" ]; then 
	echo "($temp+0.5)/1" | bc
fi
