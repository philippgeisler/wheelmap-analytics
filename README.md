## Wheelmap Analytics

*WIP*

(At some point) interactive visualizations of the grand total of Wheelmap.org’s data for given area(s).

### Background

Trying to visualize the accessibility of public transport routes in Hamburg, Germany, we got stuck realizing there was insufficient or incoherent data. Most importantly, vast amounts of points of interest had never been documented in the first place. From here, we tried to get the data in bulk to quantify the documentation progress, map coverage of documentation of accessibility, and compare the overall accessibility of areas/cities.

### Aggregating  Wheelmap.org data

Data on Wheelmap.org can be retrieved by providing at least one set of four bounding box geocoordinates in the file `data/locations` and then running `get.sh` from its directory. This bash script will then query the [Wheelmap API](http://wheelmap.org/en/api/docs) for all available node data within the given area. The data is returned in a paged JSON format, so for each area several or rather dozens of single JSON files will be downloaded and saved to a subdirectory in the format `aGivenNameForArea-yyyy-mm-dd`.

Other than its name suggests, `get.sh` will continue to process the data in some ways, creating a couple of (more or less) human readable files which also serve as basis for the basic visualizations (see below).

`get.sh` will call `transpose.sh` which is an `awk` script reformatting the aggregated data. `transpose.sh` could be easily adjusted to work with other data in similar format to the same effect.

The entire pre-processing of the data is mostly unneccessary as we will most likely continue to use D3 for a web visualization, and D3 will happily work with the original JSON format of the data. But it’s been a nice exercise and might be useful for getting an idea of the possibilities of command-line data processing.

Running `clean.sh` will remove  all data files of the current day. This can be used when during testing or due to errors `get.sh` has been quit prematurely.

For access to the Wheelmap API you will need an API key, which you can get by signing up for the site. The key has to be added to `get.sh` at the beginning of the script.

### `bboxes.sh`

This script will generate a `data/locations` file. It uses the array of (city) names given (line 10, currently the five largest German cities) to query the [MapQuest Nominatim Search API](http://developer.mapquest.com/web/products/open/nominatim) to retrieve the bounding box data for each of those names. 

### Visualization

There are a couple of attempts at creating D3 bar charts of the data in the `html` directory, none of which is finished in any way. `stats_loc.html` and `stats_detail.html` do work, though, and will use the pre-processed data from the `get.sh` script for creating stacked bar charts. The former will display aggregate results for each area, the latter will display the data for a single area split up by node type, i.e. by type of a point of interest in Wheelmap, e.g. "public transport".

The way to go is the `stats_json.html` variant using (much more sensibly) JSON data. The other experiments will be removed in time.

### Dependencies

In addition to the standard \*nix text processing tools, `get.sh` uses [`jq`](https://stedolan.github.io/jq/), a command-line JSON processor. `jq` source is available on [GitHub](https://github.com/stedolan/jq).

