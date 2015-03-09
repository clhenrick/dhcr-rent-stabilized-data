-- PostgreSQL
--  combine data for all years into one table 
-- to find distinct addresses & BBL numbers
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

-- 2013 doesn't have a bldg03, street3, stsufx3 columns
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

-- find and replace to make building numbers geocodable with the NYC Geoclient API
update dhcr_all set bldgno1 = replace(bldgno1, ' TO ', '-');
update dhcr_all set bldgno2 = replace(bldgno2, ' TO ', '-');
update dhcr_all set bldgno3 = replace(bldgno3, ' TO ', '-');
