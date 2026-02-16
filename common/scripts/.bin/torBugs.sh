#!/usr/bin/zsh

mkdir -p $HOME/.cache/pirokit

if [ -z $1 ]; then
  # query=$(echo "" | dmenu -p "Search Torrent: ")
  query=$(echo "" | rofi -dmenu -l 0 -p "Search Torrent: ")
else
  query=$1
fi
menu="dmenu -i -l 52"
baseurl="https://1337x.to"
cachedir="$HOME/.cache/pirokit"
query="${query// /%20}"
# query="$(sed 's/ /+/g' <<<$query)"

#curl -s https://1337x.to/category-search/$query/Movies/1/ > $cachedir/tmp.html
curl -s https://1337x.to/search/$query/1/ > $cachedir/tmp.html

# Get Titles
grep -o '<a href="/torrent/.*</a>' $cachedir/tmp.html |
  sed 's/<[^>]*>//g' > $cachedir/titles.bw

result_count=$(wc -l $cachedir/titles.bw | awk '{print $1}')
if [ "$result_count" -lt 1 ]; then
  notify-send "😔 No Result found. Try again 🔴"
  exit 0
fi


# Seeders and Leechers
grep -o '<td class="coll-2 seeds.*</td>\|<td class="coll-3 leeches.*</td>' $cachedir/tmp.html |
  sed 's/<[^>]*>//g' | sed 'N;s/\n/ /' > $cachedir/seedleech.bw

# Size
grep -o '<td class="coll-4 size.*</td>' $cachedir/tmp.html |
  sed 's/<span class="seeds">.*<\/span>//g' |
  sed -e 's/<[^>]*>//g' > $cachedir/size.bw

# Links
grep -E '/torrent/' $cachedir/tmp.html |
  sed -E 's#.*(/torrent/.*)/">.*/#\1#' |
  sed 's/td>//g' > $cachedir/links.bw



# Clearning up some data to display
sed 's/\./ /g; s/\-/ /g' $cachedir/titles.bw |
  sed 's/[^A-Za-z0-9 ]//g' | tr -s " " > $cachedir/tmp && mv $cachedir/tmp $cachedir/titles.bw

awk '{print NR " - ["$0"]"}' $cachedir/size.bw > $cachedir/tmp && mv $cachedir/tmp $cachedir/size.bw
awk '{print "[S:"$1 ", L:"$2"]" }' $cachedir/seedleech.bw > $cachedir/tmp && mv $cachedir/tmp $cachedir/seedleech.bw

# Getting the line number
LINE=$(paste -d\   $cachedir/size.bw $cachedir/seedleech.bw $cachedir/titles.bw | 
	dmenu -i -l 52 |
  cut -d\- -f1 |
  awk '{$1=$1; print}')

if [ -z "$LINE" ]; then
  notify-send "😔 No Result selected. Exiting... 🔴" -i "NONE"
  exit 0
fi
notify-send "🔍 Searching Magnet seeds 🧲" -i "NONE"
url=$(head -n $LINE $cachedir/links.bw | tail -n +$LINE)
fullURL="${baseurl}${url}/"

# Requesting page for magnet link
curl -s $fullURL > $cachedir/tmp.html
magnet=$(grep -o -m1 'magnet:.*" ' $cachedir/tmp.html | sed 's/..$//')

url.lua --tor "$magnet"
# magnet.sh "$magnet"
