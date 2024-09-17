select * from netflix;
--1. Count the number of Movies vs TV Shows
SELECT 
	type,
	count(*) 
from netflix
group by type;

---2. Find the most common rating for movies and TV shows

WITH cte1 AS(
SELECT
    type,
    rating,
    COUNT(*) as rank
FROM netflix
group by 1,2

),
cte2 as(
	select
	      type,rating,rank,
	      row_number() OVER(PARTITION by type order by rank desc ) rn
	from cte1
)

select
	type,
	rating
from cte2
where rn = 1 


---3. List all movies released in a specific year 

select 
	title,
	release_year
from netflix
where type = 'Movie'
group by 1,2
order by 2

---4. Find the top 5 countries with the most content on Netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;


---5. Identify the longest movie

SELECT 
    *
FROM netflix
WHERE type = 'Movie' AND duration is not  null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


---6. Find content added in the last 5 years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

---7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';


----8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--9. Count the number of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


--10.Find each year and the average numbers of content releases in India on netflix. 
--return top 5 year with highest avg content release!
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


---11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

---12. Find all content without a director
SELECT * 
FROM netflix
WHERE director IS NULL;

---13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

---14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;