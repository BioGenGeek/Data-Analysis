#1
SELECT type, COUNT(*) AS total_content
FROM netflix
GROUP BY type
;

#2
SELECT type, rating, COUNT(*)
FROM netflix
GROUP BY 1,2
# ORDER BY 3 DESC
ORDER BY 1,3 DESC
;

SELECT type, rating
FROM ( SELECT type, rating, COUNT(*), RANK() OVER( PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
		FROM netflix
		GROUP BY 1,2
        ) AS temp
WHERE ranking = 1
# ORDER BY 3 DESC
# ORDER BY 1,3 DESC
;

#3
SELECT *
FROM netflix
WHERE type = 'Movie'
	AND release_year = 2020
;

#4

	

WITH RECURSIVE SplitCountries AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS new_country,
        SUBSTRING(country, LOCATE(',', country) + 1) AS remaining_countries
    FROM netflix
    WHERE country IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining_countries, ',', 1)) AS new_country,
        SUBSTRING(remaining_countries, LOCATE(',', remaining_countries) + 1) AS remaining_countries
    FROM SplitCountries
    WHERE remaining_countries LIKE '%,%'
)
SELECT 
    new_country,
    COUNT(show_id) AS total_content
FROM SplitCountries
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5
;

#5
SELECT *
FROM netflix
WHERE type = 'Movie'
	AND duration = (SELECT MAX(duration)
					FROM netflix)
;

#6
SELECT * 
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR
;

#8
SELECT *, 
       CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS Seasons
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
;

#9

WITH RECURSIVE Splitgenre AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LOCATE(',', country) + 1) AS remaining_genre
    FROM netflix
    WHERE listed_in IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining_genre, ',', 1)) AS genre,
        SUBSTRING(remaining_genre, LOCATE(',', remaining_genre) + 1) AS remaining_genre
    FROM Splitgenre
    WHERE remaining_genre LIKE '%,%'
)
SELECT 
    genre,
    COUNT(show_id) AS total_content
FROM Splitgenre
GROUP BY genre
ORDER BY total_content DESC
;	

#10
SELECT EXTRACT(Year 
				FROM STR_TO_DATE(date_added, '%M %d, %Y')) AS years,
		 COUNT(*) AS year_content,
         ROUND( CAST(COUNT(*) AS UNSIGNED)/CAST((SELECT * FROM netflix WHERE country = 'India') AS UNSIGNED)* 100,2) AS avg_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
;

#13
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
	 AND released_year >  EXTRACT(Year FROM CURRENT_DATE()) - 10
;

#14

WITH RECURSIVE Splitcast AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actors,
        SUBSTRING(casts, LOCATE(',', casts) + 1) AS remaining_actor
    FROM netflix
    WHERE casts IS NOT NULL
    
    UNION ALL
    
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining_actor, ',', 1)) AS actors,
        SUBSTRING(remaining_actor, LOCATE(',', remaining_actor) + 1) AS remaining_actor
    FROM Splitcast
    WHERE remaining_actor LIKE '%,%'
)
SELECT 
    actors,
    COUNT(show_id) AS total_content
FROM Splitcast
WHERE country LIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
;	

#15

WITH category_table AS
(
SELECT * ,
	CASE
    WHEN description LIKE '%kill%' OR
		description LIKE '%violence%' THEN 'BAD'
        ELSE 'GOOD'
	END category
FROM netflix
) 
SELECT category , COUNT(*) AS total_content
FROM category_table
GROUP BY 1