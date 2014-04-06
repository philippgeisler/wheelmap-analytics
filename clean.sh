#!/usr/bin/zsh

cat locations | while read city bbox
do
	echo "Getting stuff out of the way..."
	rm nodes_*.[ct]sv
	rm stats_*.csv
	rm -r "`date +'%Y-%m-%d'`-$city"
done
echo "done." 