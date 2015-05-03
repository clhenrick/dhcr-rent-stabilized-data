-- first import the dhcr_all_geocoded into Postgres. Name it dhcr_rs_w_bbs.

-- total number of DISTINCT bbls in the dhcr list
-- returns 47,150 rows
SELECT Count(DISTINCT bbl) FROM dhcr_rs_w_bbls;


-- SELECT the number of properties ON dhcr list in the nyc map pluto data
-- returns 47,130 rows
SELECT Count(a.bbl) FROM 
	(
		SELECT DISTINCT bbl FROM map_pluto2014v2 
	) AS a
	INNER JOIN
	(	  
  	SELECT DISTINCT ON (bbl) bbl FROM dhcr_rs_w_bbls
  	  WHERE bbl IS NOT NULL
	) AS b 
	ON a.bbl = b.bbl;


-- SELECT number of properties in dhcr list NOT in the map pluto "likely rent-stabilized" query 
-- returns 12,549 rows
CREATE TABLE map_pluto2014v2_likely_rs AS
	SELECT COUNT(a.bbl) FROM 
		(
			SELECT DISTINCT bbl FROM map_pluto2014v2 
			WHERE yearbuilt < 1974 AND unitsres >= 6 
			    AND (ownername NOT ILIKE 'new york city housing authority' or ownername NOT ILIKE 'nycha')
			    AND bldgclASs NOT ILIKE 'r%'	
		) AS a
		LEFT JOIN
		(	  
	  	SELECT DISTINCT bbl FROM dhcr_rs_w_bbls
	  	WHERE bbl IS NOT NULL
		) AS b 
		ON a.bbl = b.bbl
		WHERE b.bbl IS NULL;


	--a combinatiON of above two queries...
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
				SELECT a.*
				FROM 
				(
					SELECT * FROM map_pluto2014v2 
					WHERE yearbuilt < 1974 AND unitsres >= 6 
					    AND (ownername NOT ILIKE 'new york city housing authority' OR ownername NOT ILIKE 'nycha')
					    AND bldgclass NOT ILIKE 'r%'	
				) AS a
				LEFT JOIN
				(	  
			  	SELECT * FROM dhcr_rs_w_bbls
			  	WHERE bbl IS NOT NULL
				) AS b 
				ON a.bbl = b.bbl
				WHERE b.bbl IS NULL
			) AS not_dhcr
			
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
			(SELECT c.address, 
							c.unitsres, 
							c.borough, 
							c.ownername, 
							c.zipcode, 
							c.yearbuilt, 
							c.bbl,
							c.cd,
							c.council,
							c.geom
				FROM 
				map_pluto2014v2 c,
				(	  
			  	SELECT DISTINCT bbl FROM dhcr_rs_w_bbls
			  	WHERE bbl IS NOT NULL
				) d
				WHERE c.bbl = d.bbl		
			) AS dhcr
	) AS all_the_rows;


-- Where are the properties located by borough that aren't in the DHCR list?
--  borough | total 
-- ---------+-------
--  MN      |  5142
--  BK      |  4612
--  BX      |  1332
--  QN      |  1297
--  SI      |   166

SELECT borough, COUNT(*) AS total
FROM 
(
	SELECT * FROM map_pluto2014v2 
	WHERE yearbuilt < 1974 AND unitsres >= 6 
	    AND (ownername NOT ILIKE 'new york city housing authority' OR ownername NOT ILIKE 'nycha')
	    AND bldgclASs NOT ILIKE 'r%'	
) AS a
LEFT JOIN
(	  
	SELECT * FROM dhcr_rs_w_bbls
	WHERE bbl IS NOT NULL
) AS b 
ON a.bbl = b.bbl
WHERE b.bbl IS NULL
GROUP BY borough
ORDER BY total DESC;


-- the above query works, but I then wanted to add a boolean to keep track of 
-- whether or not the property was registered with the DHCR
-- thus I separated the queries and made two tables:
CREATE TABLE map_pluto_not_dhcr AS
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
			SELECT a.*
			FROM 
			(
				SELECT * FROM map_pluto2014v2 
				WHERE yearbuilt < 1974 AND unitsres >= 6 
				    AND (ownername not ILIKE 'new york city housing authority' or ownername not ILIKE 'nycha')
				    AND bldgclASs not ILIKE 'r%'	
			) AS a
			LEFT JOIN
			(	  
		  	SELECT * FROM dhcr_rs_w_bbls
		  	WHERE bbl IS NOT NULL
			) AS b 
			ON a.bbl = b.bbl
			WHERE b.bbl IS NULL
		) AS not_dhcr;

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
		(SELECT c.address, 
						c.unitsres, 
						c.borough, 
						c.ownername, 
						c.zipcode, 
						c.yearbuilt, 
						c.bbl,
						c.cd,
						c.council,
						c.geom
			FROM 
			map_pluto2014v2 c,
			(	  
		  	SELECT DISTINCT bbl FROM dhcr_rs_w_bbls
		  	WHERE bbl IS NOT NULL
			) d
			WHERE c.bbl = d.bbl		
		) AS dhcr;


-- I then added a column to identify properties that are registered or not registered with the DHCR:
ALTER TABLE map_pluto_not_dhcr add column registered boolean;
UPDATE map_pluto_not_dhcr set registered = false;

ALTER TABLE map_pluto_dhcr_rs add column registered boolean;
UPDATE map_pluto_dhcr_rs set registered = true;


-- now these two tables can be combined AND have a boolean value for whether or not 
-- they are in the DHCR's rent-stabilized buildings list. 
-- 59,679 rows total.
DROP TABLE map_pluto2014v2_likely_rs;
CREATE TABLE map_pluto_likely_rs AS
	SELECT * 
	FROM
		map_pluto_not_dhcr
	UNION
	SELECT * 
	FROM
		map_pluto_dhcr_rs;


-- check to make sure the data looks good:
SELECT Count(*) FROM map_pluto_likely_rs WHERE registered IS NULL;
	-- returns 0 rows
SELECT Count(DISTINCT bbl) FROM map_pluto_likely_rs;
  -- returns 59,679 rows
SELECT Count(*) FROM map_pluto_likely_rs WHERE geom IS NULL;
	-- returns 0 rows
SELECT Sum(unitsres) AS total_res_units FROM map_pluto_likely_rs;
	-- returns 1,962,469


--  In CartoDB....
--  remove all properties owned by the NYC Housing Authority that I missed.
--  Part of this involved doing a spatial intersect with the NYCHA shapefile 
--  available on NYC Open Data to determine all spellings of NYCHA:
SELECT DISTINCT a.ownername 
FROM map_pluto_likely_rs a, nycha_centroids b
where 
  ST_Intersects(
      a.the_geom, b.the_geom
  )
ORDER BY ownername

-- remove properties that are obviously owned by NYCHA
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'NYC HOUSING%';
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'new york city%';
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'NYC CITY HSG%';
DELETE FROM map_pluto_likely_rs WHERE ownername = 'CITY OF NEW YORK';
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'N Y C H A%';
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'N.Y.C. HOUSING AUTHOR%';
DELETE FROM map_pluto_likely_rs WHERE ownername ILIKE 'N Y C HOUSING AUTHORI%';
DELETE FROM map_pluto_likely_rs WHERE ownername = 'NY HOUSING AUTHORITY';
DELETE FROM map_pluto_likely_rs WHERE ownername = 'NEW YRK CTY HSG AUTHR';

-- pgsql2shp converted boolean value of the "registered" column to T / F, 
-- so I changed the valuse to 'yes' / 'no' for infowindows
UPDATE map_pluto_likely_rs set registered = 'no' WHERE registered = 'F';
UPDATE map_pluto_likely_rs set registered = 'yes' WHERE registered = 'T';

-- change boro codes to actual names for infowindows
UPDATE map_pluto_likely_rs set borough = 'Queens' WHERE borough = 'QN';
UPDATE map_pluto_likely_rs set borough = 'Brooklyn' WHERE borough = 'BK';
UPDATE map_pluto_likely_rs set borough = 'Staten Island' WHERE borough = 'SI';
UPDATE map_pluto_likely_rs set borough = 'Bronx' WHERE borough = 'BX';
UPDATE map_pluto_likely_rs set borough = 'Manhattan' WHERE borough = 'MN';



