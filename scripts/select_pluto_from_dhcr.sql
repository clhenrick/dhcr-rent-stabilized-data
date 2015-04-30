-- import the dhcr_all_geocoded into Postgres. Name it dhcr_rs_w_bbs.
-- 

-- total number of distinct bbls in the dhcr list
-- returns 47,150 rows
select count(distinct bbl) from dhcr_rs_w_bbls;


-- select the number of properties on dhcr list in the nyc map pluto data
-- returns 47,130 rows
select count(a.bbl) from 
	(
		select distinct bbl from map_pluto2014v2 
	) as a
	INNER JOIN
	(	  
  	select distinct on (bbl) bbl from dhcr_rs_w_bbls
  	  where bbl is not null
	) as b 
	ON a.bbl = b.bbl;


-- select number of properties in dhcr list NOT in the map pluto "likely rent-stabilized" query 
-- returns 12,549 rows
create table map_pluto2014v2_likely_rs as
	select count(a.bbl) from 
		(
			select distinct bbl from map_pluto2014v2 
			where yearbuilt < 1974 and unitsres >= 6 
			    and (ownername not ilike 'new york city housing authority' or ownername not ilike 'nycha')
			    and bldgclass not ilike 'r%'	
		) as a
		LEFT JOIN
		(	  
	  	select distinct bbl from dhcr_rs_w_bbls
	  	where bbl is not null
		) as b 
		ON a.bbl = b.bbl
		where b.bbl is null;


	--a combination of above two queries...
	SELECT * FROM 
	(
		SELECT not_dhcr.address, 
					not_dhcr.unitsres, 
					not_dhcr.borough, 
					not_dhcr.ownername, 
					not_dhcr.zipcode, 
					not_dhcr.yearbuilt, 
					not_dhcr.geom,
					not_dhcr.cd,
					not_dhcr.council,
					not_dhcr.bbl::bigint				
		FROM
			(
				select a.*
				from 
				(
					select * from map_pluto2014v2 
					where yearbuilt < 1974 and unitsres >= 6 
					    and (ownername not ilike 'new york city housing authority' or ownername not ilike 'nycha')
					    and bldgclass not ilike 'r%'	
				) as a
				LEFT JOIN
				(	  
			  	select * from dhcr_rs_w_bbls
			  	where bbl is not null
				) as b 
				ON a.bbl = b.bbl
				where b.bbl is null
			) as not_dhcr
			
		UNION

		SELECT dhcr.address, 
						dhcr.unitsres, 
						dhcr.borough, 
						dhcr.ownername, 
						dhcr.zipcode, 
						dhcr.yearbuilt, 
						dhcr.geom,
						dhcr.cd,
						dhcr.council,
						dhcr.bbl::bigint
		FROM
			(select c.address, 
							c.unitsres, 
							c.borough, 
							c.ownername, 
							c.zipcode, 
							c.yearbuilt, 
							c.bbl,
							c.cd,
							c.council,
							c.geom
				from 
				map_pluto2014v2 c,
				(	  
			  	select distinct bbl from dhcr_rs_w_bbls
			  	where bbl is not null
				) d
				WHERE c.bbl = d.bbl		
			) as dhcr
	) as all_the_rows;


-- Where are the properties located by borough that aren't in the DHCR list?
--  borough | total 
-- ---------+-------
--  MN      |  5142
--  BK      |  4612
--  BX      |  1332
--  QN      |  1297
--  SI      |   166

select borough, count(*) as total
from 
(
	select * from map_pluto2014v2 
	where yearbuilt < 1974 and unitsres >= 6 
	    and (ownername not ilike 'new york city housing authority' or ownername not ilike 'nycha')
	    and bldgclass not ilike 'r%'	
) as a
LEFT JOIN
(	  
	select * from dhcr_rs_w_bbls
	where bbl is not null
) as b 
ON a.bbl = b.bbl
where b.bbl is null
group by borough
order by total desc;


-- the above query works, but I then wanted to add a boolean to keep track of 
-- whether or not the property was registered with the DHCR
-- thus I separated the queries and made two tables:
CREATE TABLE map_pluto_not_dhcr as
	SELECT not_dhcr.address, 
				not_dhcr.unitsres, 
				not_dhcr.borough, 
				not_dhcr.ownername, 
				not_dhcr.zipcode, 
				not_dhcr.yearbuilt, 
				not_dhcr.geom,
				not_dhcr.cd,
				not_dhcr.council,
				not_dhcr.bbl::bigint				
	FROM
		(
			select a.*
			from 
			(
				select * from map_pluto2014v2 
				where yearbuilt < 1974 and unitsres >= 6 
				    and (ownername not ilike 'new york city housing authority' or ownername not ilike 'nycha')
				    and bldgclass not ilike 'r%'	
			) as a
			LEFT JOIN
			(	  
		  	select * from dhcr_rs_w_bbls
		  	where bbl is not null
			) as b 
			ON a.bbl = b.bbl
			where b.bbl is null
		) as not_dhcr;

CREATE TABLE map_pluto_dhcr_rs AS
	SELECT dhcr.address, 
					dhcr.unitsres, 
					dhcr.borough, 
					dhcr.ownername, 
					dhcr.zipcode, 
					dhcr.yearbuilt, 
					dhcr.geom,
					dhcr.cd,
					dhcr.council,
					dhcr.bbl::bigint
	FROM
		(select c.address, 
						c.unitsres, 
						c.borough, 
						c.ownername, 
						c.zipcode, 
						c.yearbuilt, 
						c.bbl,
						c.cd,
						c.council,
						c.geom
			from 
			map_pluto2014v2 c,
			(	  
		  	select distinct bbl from dhcr_rs_w_bbls
		  	where bbl is not null
			) d
			WHERE c.bbl = d.bbl		
		) as dhcr;


-- I then added a column to identify properties that are registered or not registered with the DHCR:
alter table map_pluto_not_dhcr add column registered boolean;
update map_pluto_not_dhcr set registered = false;

alter table map_pluto_dhcr_rs add column registered boolean;
update map_pluto_dhcr_rs set registered = true;


-- now these two tables can be combined and have a boolean value for whether or not 
-- they are on the DHCR's list. 
-- 59,679 rows total.
drop table map_pluto2014v2_likely_rs;
create table map_pluto_likely_rs as
	SELECT * 
	FROM
		map_pluto_not_dhcr
	UNION
	SELECT * 
	FROM
		map_pluto_dhcr_rs;


-- check to make sure the data looks good:
select count(*) from map_pluto_likely_rs where registered is null;
	-- returns 0 rows
select count(distinct bbl) from map_pluto_likely_rs;
  -- returns 59,679 rows
select count(*) from map_pluto_likely_rs where geom is null;
	-- returns 0 rows
select sum(unitsres) as total_res_units from map_pluto_likely_rs;
	-- returns 1,962,469


--  In CartoDB....
--  remove all properties owned by the NYC Housing Authority
delete FROM map_pluto_likely_rs where ownername ilike 'NYC HOUSING%';
delete from map_pluto_likely_rs where ownername ilike 'new york city%'

-- pgsql2shp converted boolean's to T / F, change to 'yes' / 'no' for infowindows
update map_pluto_likely_rs set registered = 'no' where registered = 'F';
update map_pluto_likely_rs set registered = 'yes' where registered = 'T';

-- change boro codes to actual names
update map_pluto_likely_rs set borough = 'Queens' where borough = 'QN';
update map_pluto_likely_rs set borough = 'Brooklyn' where borough = 'BK';
update map_pluto_likely_rs set borough = 'Staten Island' where borough = 'SI';
update map_pluto_likely_rs set borough = 'Bronx' where borough = 'BX';
update map_pluto_likely_rs set borough = 'Manhattan' where borough = 'MN';



