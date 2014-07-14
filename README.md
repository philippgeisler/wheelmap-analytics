## Wheelmap Analytics

*WIP*

(At some point) interactive visualizations of the grand total of Wheelmap.org’s data.

### Background

Trying to visualize the accessibility of public transport routes in Hamburg, Germany, we got stuck realizing there was insufficient or incoherent data. Most importantly, vast amounts of points of interest had never been documented in the first place. From here, we tried to get the data in bulk to quantify the documentation progress, map coverage of documentation of accessibility, and compare the overall accessibility of areas/cities.

At the time of commit, the zsh script '''get.sh''' compiles a set of JSON and CSV data files for a given set of (at the moment) city names and their  bounding box data. (The set of city name/bounding boxes itself can be retrieved by script.)

A simple first visualization of the aggregated data using D3 can be found in the '''html''' folder.
