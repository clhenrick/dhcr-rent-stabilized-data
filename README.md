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

## FOIL Request Info

__*The Request was stated as follows:*__


   Dear Records Access Officer,



   Please email the following records if possible:

   All data tables of the Rent Stabilized Building Lists for 2014 for all boroughs of New York City, similar to the one for the Bronx from the year 2012 found at this URL: 
   http://www.nycrgb.org/downloads/resources/sta_bldngs/2012BronxBldgs.pdf

   If possible please send me the lists in Comma Separated Value (CSV) format, a data format that can be read by most software. Data from PDFs cannot be analyzed with common software such as microsoft excel or libre office.
   If all of the requested records cannot be emailed to me, please inform me by email of the portions that can be emailed and advise me of the cost for reproducing the remainder of the records requested ($0.25 per page or actual cost of reproduction).

   If the requested records cannot be emailed to me due to the volume of records identified in response to my request, please advise me of the actual cost of copying all records onto a CD or floppy disk.

   If my request is too broad or does not reasonably describe the records, please contact me via email so that I may clarify my request, and when appropriate inform me of the manner in which records are filed, retrieved or generated.

   If it is necessary to modify my request, and an email response is not preferred, please contact me at the following telephone number: (xxx) xxx xxxx.

   If for any reason any portion of my request is denied, please inform me of the reasons for the denial in writing and provide the name, address and email address of the person or body to whom an appeal should be directed.

   Thank you for your assistance with this matter, I greatly appreciate it.
   

__*The Response of the DHCR was as follows:*__

2014 data is not expected to be available until late next year. 2013 data is expected to be available within the week. If you would like, we could send this to you in excel format when it is ready.

__*I then replied by asking if they could provide data for previous years as well.*__

Thank you very much for your help, I appreciate it. 

Is there anyway you could provide me with similar data for previous years back to 1990? Or if not that far then as far as possible? (eg: 2005, 2010).

__*To which they replied with the additional data in this repo with the following message:*__

We have listings for most years as far back as 2002. I have attached links to the files for the years we have available. 

Please note that the building list for each year only includes buildings whose owners have registered buildings containing rent stabilized units by the date of the database update. If an owner did not file, or filed late, the building will not appear in our list. Also, if a building contains rent controlled unit(s) but no rent stabilized units, the building will not appear on these lists. 

Let me know if you have further questions.