#!/bin/bash

# https://www.investing.com/equities/cigames
# https://www.biznesradar.pl/notowania/CD-PROJEKT#1d_lin_lin
# https://www.stockwatch.pl/gpw/cdprojekt,notowania,wskazniki.aspx
api="https://www.biznesradar.pl/rekomendacje-spolki/"
# <span class="profile_quotation">

declare -A assets=( ["CDP"]="CD-PROJEKT" ["CIG"]="CI-GAMES" )

output=''
for asset in ${!assets[@]}
do
	resource=${assets[$asset]}
	value=$(curl -sf $api$resource | pup 'span.profile_quotation > span.q_ch_act text{}')
	change=$(curl -sf $api$resource | pup 'span.q_ch_pkt text{}')
	output+="${asset} ${value} ${change}; " 
	# hq
	# values=$(curl -sf $api$resource | hq span.q_ch_act text)
	# value=$(echo $values | awk '{print $1}')
	# change=$(curl -sf $api$resource | hq span.q_ch_pkt text)
	# time=$(curl -sf $api$resource | hq time.q_ch_date text)
	# change2=$(curl -sf $api$resource | hq span.q_ch_per text)
done

echo $output
