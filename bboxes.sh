#!/usr/bin/zsh
url='http://open.mapquestapi.com/nominatim/v1/search.php'
# url='http://nominatim.openstreetmap.org/search'

if [ -e locations ]
then 
	rm locations
fi

for c in Berlin Dortmund Frankfurt Hamburg München 
do 
	wget -O "bbox-$c.json" "$url?city=$c&countrycodes=de&limit=1&format=json"
	jq -c '.[].display_name,(.[].boundingbox|.[])' "bbox-$c.json" | tr '\n' ' ' | sed 's/"//g' | sed 's/,.*[a-z]\ /\ /'  >> locations
	echo >> locations
done
