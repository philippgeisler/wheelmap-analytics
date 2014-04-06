#!/bin/bash

url='http://wheelmap.org/api/nodes' # base URL of API
key='s5ktzroxt9ytD53ZKTMB' # Your Wheelmap API key

cat locations | while read city bbox
do
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
	cat $(ls ./$dir/nodes.*) | jq .nodes[] > "nodes_$city.json"

	echo "Creating nodes.tsv for QGIS..."
	echo "name	id	node_type	category	latitude	longitude	wheels" > "nodes_$city.tsv"
	jq -c '.name + "__,__" + (.id | tostring) + "__,__" + .node_type.identifier + "__,__" + .category.identifier + "__,__" + (.lat | tostring) + "__,__" + (.lon | tostring) + "__,__" + .wheelchair' < "nodes_$city.json" | sed 's/__,__/\t/g' | sed 's/"//g' >> "nodes_$city.tsv"

	echo "Compiling statistics..."
	# Beware, D3 doesn't seem to be able to parse header row with spaces
	echo "category,wheels,count" > "stats_$city-categories.csv"
	jq -c '.category.identifier + " " + .wheelchair' < "nodes_$city.json" | sed 's/"//g' | sort | uniq -c | awk '{print $2 "," $3 "," $1}' >> "stats_$city-categories.csv"
	echo "node_type,wheels,count" > "stats_$city-subcategories.csv"
	jq -c '.node_type.identifier + " " + .wheelchair' < "nodes_$city.json" | sed 's/"//g' | sort | uniq -c | awk '{print $2 "," $3 "," $1}' >> "stats_$city-subcategories.csv"

	./transpose.sh -F, "stats_$city-subcategories.csv" > "stats_$city-subcategories-transposed.csv"

done
echo
echo "All done."