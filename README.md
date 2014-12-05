DHCR Rent Stabilized Data
=========================

Data containing the block and lot numbers of NYC addresses that have rent stabilized residential units registered with the [DHCR](http://www.nyshcr.org/).

## Process

From a FOIL request I was able to obtain the following years in xcell spreadsheet format:  

- 2002
- 2005
- 2009
- 2011
- 2012
- 2013

So far I've converted only the 2012 data to CSV format. This file contains the complete BBL number for each row. This data was then joined to 2012 Map Pluto v2 data. I then selected all rows that did not have null dhcr fields and exported as GeoJSON. This data is included in the `geojson` folder.

## To Do
When I have a minute I intend to write a script to convert the xlsx files to csv format with full BBL numbers, as well as provide the data joined to map pluto for corresponding years. 