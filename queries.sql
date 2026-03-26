--View

CREATE OR REPLACE VIEW forestation AS(
SELECT f.country_code, f.country_name, f.year, r.region, r.income_group, f.forest_area_sqkm, (l.total_area_sq_mi*2.59) AS total_area_sqkm, (f.forest_area_sqkm/(l.total_area_sq_mi*2.59)) *100 AS forest_area_perc
FROM land_area l
JOIN forest_area f
ON f.country_code = l.country_code
AND f.year = l.year
JOIN regions r
ON r.country_code = f.country_code);

--total forest area (in sq km) of the world in 1990

SELECT SUM(forest_area_sqkm) 
FROM forestation 
WHERE region = 'World' 
AND year = 1990;

--total forest area (in sq km) of the world in 2016
 
SELECT SUM(forest_area_sqkm) 
FROM forestation 
WHERE region = 'World' 
AND year = 2016;

--change (in sq km) in the forest area of the world from 1990 to 2016

WITH f_2016 AS
(SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 2016
GROUP BY 1,2),
f_1990 AS (SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 1990
GROUP BY 1,2);

SELECT (f_1990.forest_area_sqkm - f_2016.forest_area_sqkm) AS diff
FROM f_1990
JOIN f_2016
USING(country_name);

--percent change in forest area of the world between 1990 and 2016

WITH f_2016 AS
(SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 2016
GROUP BY 1,2),
f_1990 AS (SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 1990
GROUP BY 1,2);

SELECT ((f_1990.forest_area_sqkm - f_2016.forest_area_sqkm)/f_1990.forest_area_sqkm)*100 AS perc_loss
FROM f_1990
JOIN f_2016
USING(country_name);

--compares the amount of forest area lost between 1990 and 2016 to country's total area in 2016
WITH f_2016 AS
(SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 2016
GROUP BY 1,2),
f_1990 AS (SELECT country_name, year, SUM(forest_area_sqkm) forest_area_sqkm
FROM forestation
WHERE region = 'World'
AND year = 1990
GROUP BY 1,2);

SELECT country_name, total_area_sqkm
FROM forestation
WHERE year = 2016
AND total_area_sqkm <
    (SELECT (f_1990.forest_area_sqkm - f_2016.forest_area_sqkm) AS diff
    FROM f_1990
    JOIN f_2016
    USING(country_name))
ORDER BY 2 DESC
LIMIT 1;

--forestarea of the entire world in 2016

SELECT forest_area_perc
FROM forestation
WHERE region = 'World'
AND year = 2016;

--region with the highes forest percent in 2016

SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 2016
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--lowest forest percent to 2 decimal places

SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 2016
GROUP BY 1
ORDER BY 2
LIMIT 1;

--forestarea of the entire world in 1990

SELECT forest_area_perc
FROM forestation
WHERE region = 'World'
AND year = 1990;

--region with the highes forest percent in 1990

SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 1990
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--lowest forest percent to 2 decimal places

SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 1990
GROUP BY 1
ORDER BY 2
LIMIT 1;

--regions of the world which decreased in forest area from 1990 to 2016?

WITH cte_1990 AS
(SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 1990
GROUP BY 1
ORDER BY 2), cte_2016 AS
(SELECT region, ROUND(CAST(SUM(forest_area_sqkm)/SUM(total_area_sqkm)*100 as numeric), 2) AS perc
FROM forestation
WHERE year = 2016
GROUP BY 1
ORDER BY 2);

SELECT cte_1990.region, cte_1990.perc AS perc_1990, cte_2016.perc AS perc_2016, (cte_2016.perc - cte_1990.perc) AS diff
FROM cte_1990
JOIN cte_2016
USING(region)
ORDER BY 4;

--SUCCESS STORIES

WITH cte_2016 AS
(SELECT country_name, forest_area_sqkm
FROM forestation
WHERE year = 2016
AND forest_area_sqkm IS NOT NULL
ORDER BY 2), cte_1990 AS
(SELECT country_name, forest_area_sqkm
FROM forestation
WHERE year = 1990
AND forest_area_sqkm IS NOT NULL
ORDER BY 2);

SELECT cte_2016.country_name, cte_1990.forest_area_sqkm AS forest_1990, cte_2016.forest_area_sqkm AS forest_2016, 
(cte_2016.forest_area_sqkm-cte_1990.forest_area_sqkm) AS diff 
FROM cte_2016
JOIN cte_1990
USING(country_name)
ORDER BY diff DESC
LIMIT 2;

WITH cte_2016 AS
(SELECT country_name, forest_area_sqkm
FROM forestation
WHERE year = 2016
AND forest_area_sqkm IS NOT NULL
ORDER BY 2), cte_1990 AS
(SELECT country_name, forest_area_sqkm
FROM forestation
WHERE year = 1990
AND forest_area_sqkm IS NOT NULL
ORDER BY 2);

SELECT cte_2016.country_name, cte_1990.forest_area_sqkm AS forest_1990, cte_2016.forest_area_sqkm AS forest_2016, 
((cte_2016.forest_area_sqkm/cte_1990.forest_area_sqkm)*100)-100 AS perc
FROM cte_2016
JOIN cte_1990
USING(country_name)
ORDER BY 4 DESC
LIMIT 1;

--5 countries with the largest amount decrease in forest area from 1990 to 2016

WITH cte_2016 AS
(SELECT country_name, forest_area_sqkm, region
FROM forestation
WHERE year = 2016
AND forest_area_sqkm IS NOT NULL
ORDER BY 2), cte_1990 AS
(SELECT country_name, forest_area_sqkm, region
FROM forestation
WHERE year = 1990
AND forest_area_sqkm IS NOT NULL
ORDER BY 2);

SELECT cte_2016.region, cte_2016.country_name, cte_1990.forest_area_sqkm AS forest_1990, cte_2016.forest_area_sqkm AS forest_2016, 
(cte_2016.forest_area_sqkm-cte_1990.forest_area_sqkm) AS diff 
FROM cte_2016
JOIN cte_1990
USING(country_name)
WHERE country_name <> 'World'
ORDER BY diff
LIMIT 5;

--5 countries with the largest percent decrease in forest area from 1990 to 2016

WITH cte_2016 AS
(SELECT region, country_name, forest_area_sqkm
FROM forestation
WHERE year = 2016
AND forest_area_sqkm IS NOT NULL
ORDER BY 2), cte_1990 AS
(SELECT region, country_name, forest_area_sqkm
FROM forestation
WHERE year = 1990
AND forest_area_sqkm IS NOT NULL
ORDER BY 2);

SELECT cte_2016.region, cte_2016.country_name, cte_1990.forest_area_sqkm AS forest_1990, cte_2016.forest_area_sqkm AS forest_2016, 
ROUND(CAST(((cte_2016.forest_area_sqkm/cte_1990.forest_area_sqkm)*100)-100 AS numeric), 2) AS perc
FROM cte_2016
JOIN cte_1990
USING(country_name)
ORDER BY 5
LIMIT 5;

--countries grouped by percent forestation in quartiles, group with the most countries in 2016

WITH cte_2016 AS(SELECT country_name,
	   CASE WHEN forest_area_perc >= 75 THEN '4'
       WHEN forest_area_perc >= 50 THEN '3'
       WHEN forest_area_perc >= 25 THEN '2'
       ELSE '1' END AS quartiles,
       forest_area_perc
FROM forestation
WHERE year = 2016
AND forest_area_perc IS NOT NULL);

SELECT quartiles, COUNT(quartiles)
FROM cte_2016;

--4th quartile in 2016

WITH cte_2016 AS(SELECT country_name,
	   CASE WHEN forest_area_perc >= 75 THEN '4'
       WHEN forest_area_perc >= 50 THEN '3'
       WHEN forest_area_perc >= 25 THEN '2'
       ELSE '1' END AS quartiles,
       forest_area_perc,
       region
FROM forestation
WHERE year = 2016
AND forest_area_perc IS NOT NULL);

SELECT country_name, region,  forest_area_perc
FROM cte_2016
WHERE quartiles = '4'
ORDER BY 3 DESC;

--countries with a percent forestation higher than the United States in 2016

SELECT COUNT(*)
FROM forestation
WHERE forest_area_perc > (SELECT forest_area_perc 
                          FROM forestation
                          WHERE year = 2016
                          AND country_name = 'United States')
AND year = 2016;
