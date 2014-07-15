#!/bin/bash

url='http://wheelmap.org/api/nodes' # base URL of API
key='' # Your Wheelmap API key
datadir="data"

if [ ! -d $datadir ]
then
	mkdir $datadir
fi

cd $datadir

# "location" will become "category" in the transposed file until fixed in ./transpose.sh
echo "location,wheels,count" > "stats_locations.csv"

cat locations | while read city s n w e
do
	bbox="$w,$n,$e,$s"

	echo
	echo "Gathering data for $city ($bbox)"

	dir="$(date +'%Y-%m-%d')-$city"
	
	if [ ! -d $dir ]
	then 
		mkdir $dir
		cd $dir

		for w in 'yes' 'no' 'limited' 'unknown'
		do
			# first only get one page of data, so we can check how much more data is to be fetched
			wget -q -O nodes.$w.1.json $url\?api_key=$key\&bbox=$bbox\&wheelchair=$w\&page=1\&per_page=500

			pages=$(jq .meta.num_pages < nodes.$w.1.json)
			
			echo -e -n "\nDownloading $pages pages of data (wheelchair=$w)\n."

			for p in $(seq 2 $pages)
			do
				wget -q -O nodes.$w.$p.json $url\?api_key=$key\&bbox=$bbox\&wheelchair=$w\&page=$p\&per_page=500
				echo -n .
				#sleep 1
			done
		done

		cd ..
	fi

	echo -e "\nCompiling nodes..."
	cat $(ls ./$dir/nodes.*) | jq '.nodes[]' > "nodes_$city.json"

	echo "Creating nodes.tsv for QGIS..."
	echo "name	id	node_type	category	latitude	longitude	wheels" > "../qgis/nodes_$city.tsv"
	jq -c '.name + "__,__" + (.id | tostring) + "__,__" + .node_type.identifier + "__,__" + .category.identifier + "__,__" + (.lat | tostring) + "__,__" + (.lon | tostring) + "__,__" + .wheelchair' < "nodes_$city.json" | sed 's/__,__/\t/g' | sed 's/"//g' >> "../qgis/nodes_$city.tsv"

	# info: D3 doesn't seem to be able to parse header row with spaces
	echo "Compiling statistics..."
	jq -c '.wheelchair' < "nodes_$city.json" | sed 's/"//g' | sort | uniq -c | awk -v location="$city" '{print location "," $2 "," $1}' >> "stats_locations.csv"
	echo "category,wheels,count" > "stats_$city-categories.csv"
	jq -c '.category.identifier + " " + .wheelchair' < "nodes_$city.json" | sed 's/"//g' | sort | uniq -c | awk '{print $2 "," $3 "," $1}' >> "stats_$city-categories.csv"
	echo "node_type,wheels,count" > "stats_$city-subcategories.csv"
	jq -c '.node_type.identifier + " " + .wheelchair' < "nodes_$city.json" | sed 's/"//g' | sort | uniq -c | awk '{print $2 "," $3 "," $1}' >> "stats_$city-subcategories.csv"

	../transpose.sh -F, "stats_$city-subcategories.csv" | awk 'NR!=2' > "stats_$city-subcategories-transposed.csv"
	../transpose.sh -F, "stats_locations.csv" | awk 'NR!=2' > "stats_locations-transposed.csv"

done
echo
echo "All done."
