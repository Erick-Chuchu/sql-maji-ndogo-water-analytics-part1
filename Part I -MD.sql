-- MAJI NDOGO WATER PROJECT (Part I)

-- BEGINNING THE DATA-DRIVEN JOURNEY IN MAJI NDOGO

-- 1. Get to Know the Data

-- Retrieve the first few records from each table. How many tables are there in the database? What are the names of these tables? 
-- Take note of the columns and their respective data types in each table. What information does each table contain?
SELECT 	* 	FROM employee 	LIMIT 10;
SELECT 	* 	FROM location 	LIMIT 10;
SELECT 	* 	FROM visits 	LIMIT 10;
SELECT 	* 	FROM water_quality 	LIMIT 10;
SELECT 	* 	FROM water_source 	LIMIT 10;
SELECT 	* 	FROM well_pollution 	LIMIT 10;

-- 2. Dive into the Water Sources

-- What are the types of water sources?
SELECT 	DISTINCT type_of_water_source 	
FROM 	water_source;
-- NOTE: The surveyors combined the data of many households with taps in home together into a single record. 

-- 3. Unpack Visits to Water Sources

-- (a). How many records have people queueing for more than an hour?
SELECT 	* 	
FROM 	visits	
WHERE 	time_in_queue > 60;

-- (b). What are the top 10 longest time in queue?
SELECT 	*
FROM 	visits
ORDER BY time_in_queue DESC
LIMIT 10;

-- (c). What are the types of water sources for the records with longest time in queue?
SELECT 	*
FROM 	water_source
WHERE 	source_id IN ('AmRu14612224', 'AkRu05704224', 'HaRu19538224', 'SoRu35388224', 'HaRu20126224');

-- 4. Assess the Quality of Water Sources

-- Is it true that the surveyors only made multiple visits to shared taps and did not revisit other types of water sources?
SELECT 	*
FROM 	visits AS v
JOIN 	water_source AS ws
	ON 	v.source_id = ws.source_id
WHERE 	v.visit_count >1;

-- 5. Investigate Pollution Issues

-- Check if there be any case of contamination recorded as 'Clean'.
SELECT 	*
FROM 	well_pollution
WHERE 	results = 'Clean' AND biological > 0.01;

-- Identify records that mistakenly have the word 'Clean' in the description.
SELECT 	*
FROM 	well_pollution
WHERE 	description LIKE 'Clean_%'; -- _% gives additional letters after 'Clean'

-- Fixing the Mistakes

/*
	Case 1a: Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
	Case 1b: Update the descriptions that mistakenly mention
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
	Case 2: Update the `result` to `Contaminated: Biological` where
`biological` is greater than 0.01 plus current results is `Clean`
*/
-- To allow updates in the database
SET SQL_SAFE_UPDATES =0;

-- A safer way to UPDATE is by testing the changes on a copy of the table first.
CREATE TABLE well_pollution_copy
AS (SELECT * FROM well_pollution);

-- Case 1a
UPDATE 	well_pollution_copy
SET 	description = 'Bacteria:E. coli'
WHERE 	description = 'Clean Bacteria:E. coli';

-- Case 1b
UPDATE 	well_pollution_copy
SET 	description = 'Bacteria: Giardia Lamblia'
WHERE 	description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2
UPDATE 	well_pollution_copy
SET 	results = 'Contaminated: Biological'
WHERE 	biological > 0.01 AND results = 'Clean';

-- Check if the errors are fixed using a SELECT query on the well_pollution_copy table:
SELECT 	*
FROM 	well_pollution_copy
WHERE 	description LIKE "Clean_%" OR (results = "Clean" AND biological > 0.01);

-- Apply the changes to the `well_pollution` table.
-- Case 1a
UPDATE 	well_pollution
SET 	description = 'Bacteria:E. coli'
WHERE 	description = 'Clean Bacteria:E. coli';

-- Case 1b
UPDATE 	well_pollution
SET 	description = 'Bacteria: Giardia Lamblia'
WHERE 	description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2
UPDATE 	well_pollution
SET 	results = 'Contaminated: Biological'
WHERE 	biological > 0.01 AND results = 'Clean';

-- Drop the `well_pollution_copy` table.alter
DROP TABLE well_pollution_copy;