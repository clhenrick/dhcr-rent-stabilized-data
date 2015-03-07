DHCR Rent Stabilized Data
=========================

Data containing the street address(es), block and lot numbers of NYC properties that have rent stabilized apartments that are registered with the [DHCR](http://www.nyshcr.org/).

## Process

From a FOIL request I was able to obtain the following years in Excel spreadsheet format:  

- 2002
- 2005
- 2009
- 2011
- 2012
- 2013

Typically each file contains a sheet for each borough. Using a Node JS script I was able to combine the sheets in each excel file, add the row's respective borough code and output the data to CSV format. From here a BBL number can be concatenated and the data can be joined with NYC's Map PLUTO data, available from Bytes of the Big Apple data portal.

## Notes on the Data
### What it doesn't contain:
The data **does not** contain the actual apartment numbers or the number of rent stabilized apartments per building. It is only a list of addresses of properties that have at least one *registered rent stabilized unit* in them (see discrepancies below for more info).

This list also does not contain buildings that have rent controlled units. 

### What it does contain
Prior to 2009 the data is relatively organized and contains useful information. However 2005's data looks incomplete as the number of rows differ substantially from 2002 and 2009. 2002's data does not contain headers, nor block or lot numbers. The first column appears to be zipcodes so theoretically the data could be geocoded using the NYC Geoclient API.

### Discrepancies 
As the process of registering rent-stabilized apartments with the DHCR is completely voluntary by the landlord the data differs from year to year. As such it should not be assumed that the DHCR's rent stabilized building lists are completely authoritative. Generally speaking a building in NYC may contain rent-stabilized apartments if it was either:

1. Built before 1974, contains more than 6 residential units and is not a coop or condo.
2. Was built recently and the developer choose to take advantage of tax abatements such as J-51 which require a certain number of units to be placed in rent stabilization, often for a finite period.

Thus it may be necessary to do a more comprehensive analysis of Map PLUTO tax lot data as well as new development since 1974 that has received tax abatements to get a better estimate of properties with rent stabilized units.

## Script Usage

You can run the `index.js` script on the excel data to convert this data yourself. Make sure you have Node JS installed and accessible from the command line. `cd` to this repo after downloading it and do:

```
npm install
```
to grab the script's dependencies and then do:

```
node index.js 'xlsx/2013 DHCR-5 Boros.xlsx' 'dhcr2013.csv'
```
to process the data to CSV format. Change the name of the `xlsx` file to whatever file you'd like to convert as well as the `csv` file name to whatever you'd like to name the output.

**Note:** I manually either removed or added the `CITY` column from some of the `xlsx` files as they were not consistent across boroughs / sheets. I then saved the edited files with the `xls` extensions. As such the node script will parse excel files with either `xlsx` or `xls` extensions.




## FOIL Request Info

__*The Request was stated as follows:*__


   Dear Records Access Officer,



   Please email the following records if possible:

   All data tables of the Rent Stabilized Building Lists for 2014 for all boroughs of New York City, similar to the one for the Bronx from the year 2012 found at this URL: 
   http://www.nycrgb.org/downloads/resources/sta_bldngs/2012BronxBldgs.pdf

   If possible please send me the lists in Comma Separated Value (CSV) format, a data format that can be read by most software. Data from PDFs cannot be analyzed with common software such as Microsoft excel or libre office.
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
