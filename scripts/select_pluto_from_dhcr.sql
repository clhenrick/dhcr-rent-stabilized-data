-- after importing dhcr_all_bbls and the map pluto 2014 v2 data sets into Postgres,
 -- you can query taxlots  from map pluto that are on the dhcr's rent stabilized building list

-- first, create a temporary table of all unique bbls from dhcr list
-- 47196 rows
create table dhcr_tmp_bbls as (select distinct bbl from dhcr_all_bbls);

-- second, query all map pluto data that matches dhcr bbls
-- 47177 rows
select * from map_pluto_2014v2 a, dhcr_tmp_bbls b where a.bbl = b.bbl;

-- create a table of all pluto tax lots that have matching bbls from dhcr_tmp_bbls
-- (19 bbls don't match, likely due to NYC Geoclient being more up to date than map pluto?)
create table map_pluto_dhcr_all as (
  select a.* from map_pluto_2014v2, dhcr_tmp_bbls b 
  where a.bbl = b.bbl
  );

-- create a table from map pluto data for anything built before 1974 with more than 6 residential units 
-- and is not a condo or public housing
-- 40318 rows
create table map_pluto_likely_rent_stabl as (
  select * from map_pluto_2014v2
  where yearbuilt < 1974 and unitsres > 6 
    and (ownername not ilike 'new york city housing authority' or ownername not ilike 'nycha')
    and bldgclass not ilike 'r%'
);

-- compare how many likely rent stabilized properties aren't in dhcr's list
-- 9008 rows
create table map_pluto_likely_rs_not_in_dhcr as (
  select * from map_pluto_likely_rent_stabl a 
  where a.bbl not in (
    select b.bbl from map_pluto_dhcr_all b
    )
);
