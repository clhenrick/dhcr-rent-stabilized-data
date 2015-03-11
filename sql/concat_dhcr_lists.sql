-- PostgreSQL
--  combine data for all years into one table in order to find all distinct addresses
--  these addresses can then be geocoded using the NYC GeoClient API

-- drop table
drop table dhcr_all

-- create a table to insert data from all years to
create table dhcr_all (
  zip integer,
  bldgno1 text,
  street_name1 text,
  street_suffix1 text,
  bldgno2 text,
  street_name2 text,
  street_suffix2 text,  
  bldgno3 text,
  street_name3 text,
  street_suffix3 text,  
  status1 text,
  status2 text,
  status3 text,
  block text,
  lot integer,
  boro_code integer
);

--  insert 2005 data, it lacks block and lot numbers, so they aren't inserted
insert into dhcr_all (
  zip,
  bldgno1,
  street_name1,
  street_suffix1,
  bldgno2,
  street_name2,
  street_suffix2,  
  bldgno3,
  street_name3,
  street_suffix3,  
  status1,
  status2,
  status3,  
  boro_code
) 
SELECT 
  "ZIP",
  "BLDGNO1",
  "STREET1",
  "STSUFX1",
  "BLDGNO2",
  "STREET2",
  "BLDGNO3",
  "STREET3",
  "STSUFX3",
  "STSUFX2",
  "STATUS1",
  "STATUS2",
  "STATUS3",
  "BORO_CODE"
FROM dhcr2005;

-- insert 2009 data
insert into dhcr_all (
  zip,
  bldgno1,
  street_name1,
  street_suffix1,
  bldgno2,
  street_name2,
  street_suffix2,  
  bldgno3,
  street_name3,
  street_suffix3,  
  status1,
  status2,
  status3,  
  block,
  lot,
  boro_code
) 
SELECT * FROM dhcr2009tmp;

-- insert 2011 data
insert into dhcr_all (
  zip,
  bldgno1,
  street_name1,
  street_suffix1,
  bldgno2,
  street_name2,
  street_suffix2,  
  bldgno3,
  street_name3,
  street_suffix3,  
  status1,
  status2,
  status3,  
  block,
  lot,
  boro_code
) 
SELECT * FROM dhcr2011;

-- insert 2012 data
insert into dhcr_all (
  zip,
  bldgno1,
  street_name1,
  street_suffix1,
  bldgno2,
  street_name2,
  street_suffix2,  
  bldgno3,
  street_name3,
  street_suffix3,  
  status1,
  status2,
  status3,  
  block,
  lot,
  boro_code
) 
SELECT * FROM dhcr2012;

-- insert 2013 data, it doesn't have a bldg03, street3, stsufx3 columns
insert into dhcr_all (
  zip,
  bldgno1,
  street_name1,
  street_suffix1,
  bldgno2,
  street_name2,
  street_suffix2,  
  status1,
  status2,
  status3,  
  block,
  lot,
  boro_code
) 
SELECT  
  "ZIP",
  "BLDGNO1",
  "STREET1",
  "STSUFX1",
  "BLDGNO2",
  "STREET2",
  "STSUFX2",
  "STATUS1",
  "STATUS2",
  "STATUS3",
  "BLOCK",
  "LOT",
  "BORO_CODE"
FROM dhcr2013;

-- should return about 210,000 rows
select count(*) from dhcr_all;

-- add columns for splitting building number into low and high numbers
alter table dhcr_all add column bldgno1_low text;
alter table dhcr_all add column bldgno1_high text;
alter table dhcr_all add column bldgno2_low text;
alter table dhcr_all add column bldgno2_high text;
alter table dhcr_all add column bldgno3_low text;
alter table dhcr_all add column bldgno3_high text;

-- split bldgno1 column into two separate numbers for geocoding with NYC Geoclient API
update dhcr_all set bldgno1_low = split_part(bldgno1, ' TO ', 1);
update dhcr_all set bldgno1_high = split_part(bldgno1, ' TO ', 2);
update dhcr_all set bldgno2_low = split_part(bldgno2, ' TO ', 1);
update dhcr_all set bldgno2_high = split_part(bldgno2, ' TO ', 2);
update dhcr_all set bldgno3_low = split_part(bldgno3, ' TO ', 1);
update dhcr_all set bldgno3_high = split_part(bldgno3, ' TO ', 2);

-- find all distinct addresses
-- select bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
--   bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
--   bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
--   boro_code, zip
-- from dhcr_all
-- group by bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
--   bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
--   bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
--   boro_code, zip

-- returns a measley 53,000 rows, DHCR's data is obviously not complete!
select count(*) from (
  select bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
    bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
    bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
    boro_code, zip
  from dhcr_all
  group by bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
    bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
    bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
    boro_code, zip
) as distinct_addresses;

-- create a temporary table of the distinct addresses
create table dhcr_all_tmp as (
  select bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
    bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
    bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
    boro_code, zip
  from dhcr_all
  group by bldgno1, bldgno1_low, bldgno1_high, street_name1, street_suffix1, 
    bldgno2, bldgno2_low, bldgno2_high, street_name2, street_suffix2, 
    bldgno3, bldgno3_low, bldgno3_high, street_name3, street_suffix3, 
    boro_code, zip
);  

-- delete table with duplicates
drop table dhcr_all;

-- rename tmp table
alter table dhcr_all_tmp rename to dhcr_all;