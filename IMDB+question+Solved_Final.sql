USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT "movie"  AS "Table_Name",-- Count Total rows from movie table
       Count(*) AS "Total_rows"
FROM   movie
UNION
SELECT "genre"  AS "Table_Name",-- Count Total rows from genre table
       Count(*) AS "Total_rows"
FROM   genre
UNION
SELECT "director_mapping" AS "Table_Name", -- Count Total rows from director_mapping table
       Count(*)           AS "Total_rows"
FROM   director_mapping
UNION
SELECT "names"  AS "Table_Name",-- Count Total rows from names table
       Count(*) AS "Total_rows"
FROM   names
UNION
SELECT "ratings" AS "Table_Name",-- Count Total rows from ratings table
       Count(*)  AS "Total_rows"
FROM   ratings
UNION
SELECT "role_mapping" AS "Table_Name", -- Count Total rows from role_mapping table
       Count(*)       AS "Total_rows"
FROM   role_mapping;

-- -------------------------------------------------------------------------------------------------------------------
-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT Sum(CASE
             WHEN id IS NULL THEN 1
             ELSE 0
           end) AS id_null,
       Sum(CASE
             WHEN title IS NULL THEN 1
             ELSE 0
           end) AS title_null,
       Sum(CASE
             WHEN year IS NULL THEN 1
             ELSE 0
           end) AS year_null,
       Sum(CASE
             WHEN date_published IS NULL THEN 1
             ELSE 0
           end) AS date_published_null,
       Sum(CASE
             WHEN duration IS NULL THEN 1
             ELSE 0
           end) AS duration_null,
       Sum(CASE
             WHEN country IS NULL THEN 1
             ELSE 0
           end) AS country_null,
       Sum(CASE
             WHEN worlwide_gross_income IS NULL THEN 1
             ELSE 0
           end) AS worlwide_gross_income_null,
       Sum(CASE
             WHEN languages IS NULL THEN 1
             ELSE 0
           end) AS languages_null,
       Sum(CASE
             WHEN production_company IS NULL THEN 1
             ELSE 0
           end) AS production_company_null
FROM   movie;
-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 

-- ----------------------------------------------------------------------------------------------------------------------
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Number of movies released each year
SELECT year,
       Count(title) AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY year;

-- Number of movies released each month 
SELECT Month(date_published) AS MONTH_NUM,
       Count(*)              AS NUMBER_OF_MOVIES
FROM   movie
GROUP  BY month_num
ORDER  BY month_num; 

-- Highest number of movies were released in 2017
/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- ------------------------------------------------------------------------------------------------------------------  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT year,
       Count(id) AS total_movies
FROM   movie
WHERE  ( country LIKE '%USA%'
          or country LIKE '%India%' )
       AND year = 2019;
-- India and USA produced 1059 movies in 2019

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- -------------------------------------------------------------------------------------------------------------------
-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT genre 
FROM genre
GROUP BY genre;
/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- ----------------------------------------------------------------------------------------------------------------
-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
WITH genre_rank_summary as 
(
SELECT     genre,
           COUNT(m.id) AS number_of_movies,
           DENSE_RANK() OVER (ORDER BY COUNT(m.id) DESC) AS Rank_Genre
FROM       movie AS m
INNER JOIN genre AS g ON g.movie_id = m.id
GROUP BY   genre
)
SELECT * 
from genre_rank_summary
WHERE rank_genre <=1;

-- 4285 Drama movies were produced in total and are the highest among all genres.


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- -----------------------------------------------------------------------------------------------------------------
-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH genre_summary -- Creating CTE for genre count by each movie
     AS (SELECT movie_id,
                Count(genre) AS no_of_genres
         FROM   genre
         GROUP  BY movie_id)
SELECT Count(movie_id) -- Checking movies with only one genre - 3289
FROM   genre_summary
WHERE  no_of_genres = 1 ;


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- -------------------------------------------------------------------------------------------------------------------
-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT genre,
       Round(Avg(duration), 2) AS Avg_duration
FROM   movie as m
       INNER JOIN genre as g
               ON m.id = g.movie_id
GROUP  BY genre
ORDER  BY Avg_duration DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- -----------------------------------------------------------------------------------------------------------------
-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH genre_summary AS
(
           SELECT     genre,
                      Count(movie_id)                            AS movie_count ,
                      Rank() OVER(ORDER BY Count(movie_id) DESC) AS genre_rank
           FROM       genre                                 
           GROUP BY   genre )
SELECT *
FROM   genre_summary
WHERE  genre = "THRILLER" ;

-- Thriller has rank=3 and movie count of 1484

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- ----Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT Min(avg_rating)    AS min_avg_rating, -- minimum of avg_rating: 1.0
       Max(avg_rating)    AS max_avg_rating, -- maximum of avg_rating: 10.0
       Min(total_votes)   AS min_total_votes, -- minimum of total_votes: 100
       Max(total_votes)   AS max_total_votes, -- maximum of total_votes: 725138
       Min(median_rating) AS min_median_rating,  -- minimum of median_rating: 1
       Max(median_rating) AS max_median_rating   -- maximum of median_rating: 10
FROM   ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- -----------------------------------------------------------------------------------------------------------------

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH MOVIE_RANK AS
(
SELECT     title,
           avg_rating,
           ROW_NUMBER() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM       ratings                               AS r
INNER JOIN movie                                 AS m
ON         m.id = r.movie_id
)
SELECT * FROM MOVIE_RANK
WHERE movie_rank<=10;

-- Top 3 movies have average rating >= 9.8

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- ------------------------------------------------------------------------------------------------------------------
-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT median_rating,
       Count(movie_id) AS movie_count
       
FROM   ratings
GROUP  BY median_rating
ORDER BY Count(movie_id) DESC;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- -------------------------------------------------------------------------------------------------------------------
-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH high_rated_production_houses -- Summarising production houses based on hit movies
     AS (SELECT production_company,
                Count(id) AS movie_count,
                Dense_rank()
					OVER (
						ORDER BY Count(id) DESC) AS prod_company_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *                         -- Ranking movies based on number of hits : Dream Warrior Pictures and National Theatre Live are the top movies
       
FROM   high_rated_production_houses
WHERE prod_company_rank=1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- ----------------------------------------------------------------------------------------------------------------
-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre,
       Count(M.id) AS movie_count
FROM   movie AS M
       INNER JOIN genre AS G
               ON G.movie_id = M.id
       INNER JOIN ratings AS R
               ON R.movie_id = M.id
WHERE  year = 2017
       AND Month(date_published) = 3
       AND country LIKE '%USA%'
       AND total_votes > 1000
GROUP  BY genre
ORDER  BY movie_count DESC; 

-- 24 Drama movies were released during March 2017 in the USA and had more than 1,000 votes
-- Top 3 genres are drama, comedy and action during March 2017 in the USA and had more than 1,000 votes


-- Lets try to analyse with a unique problem statement.

-- ------------------------------------------------------------------------------------------------------------------
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT  title,
       avg_rating,
       genre
FROM   movie AS M
       INNER JOIN genre AS G
               ON G.movie_id = M.id
       INNER JOIN ratings AS R
               ON R.movie_id = M.id
WHERE  avg_rating > 8
       AND title LIKE 'THE%'
ORDER BY avg_rating DESC;


-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- -------------------------------------------------------------------------------------------------------------------

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT Count(m.id) AS number_of_movies
FROM   movie m
       INNER JOIN ratings r
               ON m.id = r.movie_id
WHERE  m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
       AND median_rating = 8 ;


-- Once again, try to solve the problem given below.

-- ------------------------------------------------------------------------------------------------------------------
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
WITH compare
     AS (SELECT country,
                Sum(total_votes) AS total_votes
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE  country = 'Germany'
                 OR country = 'Italy'
         GROUP  BY country)
SELECT country,
       total_votes,
       CASE
         WHEN country = 'Germany'
              AND total_votes > (SELECT total_votes
                                 FROM   compare
                                 WHERE  country = 'Italy') THEN 'Yes'
         WHEN country = 'Italy'
              AND total_votes > (SELECT total_votes
                                 FROM   compare
                                 WHERE  country = 'Germany') THEN 'Yes'
         ELSE 'No'
       END AS comparison_result
FROM   compare
WHERE  country IN ( 'Germany', 'Italy' );

-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- -----Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT Sum(CASE
             WHEN name IS NULL THEN 1
             ELSE 0
           end) AS name_nulls,
       Sum(CASE
             WHEN height IS NULL THEN 1
             ELSE 0
           end) AS height_nulls,
       Sum(CASE
             WHEN date_of_birth IS NULL THEN 1
             ELSE 0
           end) AS date_of_bith_nulls,
       Sum(CASE
             WHEN known_for_movies IS NULL THEN 1
             ELSE 0
           end) AS known_for_movies_nulls
FROM names;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- ----------------------------------------------------------------------------------------------------------------
-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH top_genre_summary  -- Selecting top genres
     AS (SELECT g.genre,
                Count(m.id) AS movie_count,
                Row_number()
                  OVER(
                    ORDER BY Count(m.id) DESC) AS genre_rank
         FROM   genre g
                INNER JOIN movie m
                        ON g.movie_id = m.id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
         GROUP  BY genre),
     top_director_summary -- Selecting top directors
     AS (SELECT n.name AS director_name,
                Count(m.id) AS movie_count,
                Row_number()
                  OVER(
                    ORDER BY Count(m.id) DESC) AS director_rank
         FROM   names n
                INNER JOIN director_mapping d
                        ON n.id = d.name_id
                INNER JOIN movie m
                        ON d.movie_id = m.id
                INNER JOIN genre g
                        ON m.id = g.movie_id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
                AND genre IN (SELECT genre
                              FROM   top_genre_summary
                              WHERE  genre_rank <= 3)
         GROUP  BY 1)
SELECT director_name,
       movie_count
FROM   top_director_summary
WHERE  director_rank <= 3 ;
-- Top 3 directors are James Mangold followed by Anthony Russo and Joe Russo


/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- ---------------------------------------------------------------------------------------------------------------
-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH actor_rank_summary as 
(
SELECT
  actor_name,
  movie_count,
  DENSE_RANK() OVER (ORDER BY movie_count DESC) AS Actor_rank
FROM (
  SELECT
    n.name AS actor_name,
    COUNT(rm.movie_id) AS movie_count
  FROM role_mapping AS rm
  INNER JOIN names AS n ON n.id = rm.name_id
  INNER JOIN ratings AS r ON r.movie_id = rm.movie_id
  WHERE category = "actor"
    AND r.median_rating >= 8
  GROUP BY n.name
) AS subquery
ORDER BY movie_count DESC
)
SELECT * 
FROM actor_rank_summary 
	where Actor_rank<=2;
    
/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- -----------------------------------------------------------------------------------------------------------------
-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH ranking AS(
SELECT production_company, sum(total_votes) AS vote_count,
	RANK() OVER(ORDER BY SUM(total_votes) DESC) AS prod_comp_rank
FROM movie AS m
	INNER JOIN ratings AS r ON r.movie_id=m.id
GROUP BY production_company)
SELECT production_company, vote_count, prod_comp_rank
FROM ranking
WHERE prod_comp_rank<4;

-- Top three production houses based on the number of votes received by their movies are Marvel Studios, Twentieth Century Fox and Warner Bros.



/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- -------------------------------------------------------------------------------------------------------------------
-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actor_summary
     AS (SELECT n.NAME AS actor_name,
                Sum(total_votes) AS total_votes,
                Count(m.id) AS movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating
         FROM   names n
                INNER JOIN role_mapping rm
                        ON n.id = rm.name_id
                INNER JOIN movie m
                        ON rm.movie_id = m.id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  ( rm.category = 'actor'
                  AND m.country LIKE '%India%' )
         GROUP  BY n.NAME
         HAVING movie_count >= 5)
SELECT *,
       Dense_rank()
         OVER (
           ORDER BY actor_avg_rating DESC, total_votes DESC) AS actor_rank
FROM top_actor_summary;

-- Top actor is Vijay Sethupathi

-- -----------------------------------------------------------------------------------------------------------------
-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
WITH top_actress_summary
     AS (SELECT n.NAME AS actress_name,
                Sum(total_votes) AS total_votes,
                Count(m.id) AS movie_count,
                Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actress_avg_rating
         FROM   names n
                INNER JOIN role_mapping rm
                        ON n.id = rm.name_id
                INNER JOIN movie m
                        ON rm.movie_id = m.id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  ( rm.category = 'actress'
                  AND m.country LIKE '%India%' AND languages like '%Hindi%')
         GROUP  BY n.NAME
         HAVING movie_count >= 3)
SELECT *,
       Dense_rank()
         OVER (
           ORDER BY actress_avg_rating DESC, total_votes DESC) AS actress_rank
FROM top_actress_summary
limit 5;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/

-- -----------------------------------------------------------------------------------------------------------------
/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

WITH thriller_movies
     AS (SELECT DISTINCT title,
                         avg_rating
         FROM   movie AS M
                INNER JOIN ratings AS R
                        ON R.movie_id = M.id
                INNER JOIN genre AS G using(movie_id)
         WHERE  genre LIKE 'THRILLER')
SELECT *,
       CASE
         WHEN avg_rating > 8 THEN 'Superhit movies'
         WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         ELSE 'Flop movies'
       END AS avg_rating_category
FROM   thriller_movies;


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- ------------------------------------------------------------------------------------------------------------------
-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
WITH duration_genre_summary
AS
  (
	 SELECT     genre,
				round(avg(duration),2) AS avg_duration
	 FROM       movie m
	 INNER JOIN genre g
	 ON         m.id=g.movie_id
	 GROUP BY   genre )
  SELECT   *,
           sum(avg_duration) over w AS running_total_duration,
           avg(avg_duration) over w AS moving_avg_duration
  FROM     duration_genre_summary 
  window w AS (ORDER BY genre rows unbounded preceding)
  ORDER BY genre;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- ----------------------------------------------------------------------------------------------------------------
-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH genre_summary -- Selecting top genres
     AS (SELECT g.genre,
                Count(m.id)  AS movie_count,
                Row_number()
                  over(
                    ORDER BY Count(m.id) DESC) AS genre_rank
         FROM   genre g
                inner join movie m
                        ON g.movie_id = m.id
         GROUP  BY genre),
     income_summary
     AS (SELECT id,
                CASE
                  WHEN Position('$' IN worlwide_gross_income) > 0 THEN
                  Cast(Replace(worlwide_gross_income, "$", '') AS DECIMAL)
                  WHEN Position('INR' IN worlwide_gross_income) > 0 THEN
                  Cast(Replace(worlwide_gross_income, "inr", '') AS DECIMAL) /75 
															-- assuming 1 USD=75 INR as average exchange rate
                  ELSE 0
                END AS worldwide_gross_income
         FROM   movie),
     topmovies_by_year_summary
     AS (SELECT g.genre,
                m.year,
                m.title   AS movie_name,
                round(i_s.worldwide_gross_income,0) as worldwide_gross_income,
                Row_number()
                  over(
                    PARTITION BY m.year
                    ORDER BY i_s.worldwide_gross_income DESC ) AS movie_rank
         FROM   movie m
                inner join income_summary i_s
                        ON m.id = i_s.id
                inner join genre g
                        ON m.id = g.movie_id
         WHERE  genre IN (SELECT genre
                          FROM   genre_summary
                          WHERE  genre_rank < 4))
SELECT *
FROM   topmovies_by_year_summary
WHERE  movie_rank <= 5;  


-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.

-- -----------------------------------------------------------------------------------------------------------------
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH prod_company_ranking_summary
     AS (SELECT production_company,
                Count(m.id)                    AS movie_count,
                Row_number()
                  over(
                    ORDER BY Count(m.id) DESC) AS prod_comp_rank
         FROM   movie m
                inner join ratings r
                        ON m.id = r.movie_id
         WHERE  median_rating >= 8
                AND Position(',' IN languages) > 0
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   prod_company_ranking_summary
WHERE  prod_comp_rank <= 2 ;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- -----------------------------------------------------------------------------------------------------------------
-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_summary
     AS (SELECT n.NAME AS actress_name,
                Sum(total_votes) AS total_votes,
                Count(m.id) AS movie_count,
                Avg(avg_rating) AS actress_avg_rating,
                Row_number()
                  OVER(
                    ORDER BY Count(m.id) DESC) AS actress_rank
         FROM   movie m
                INNER JOIN role_mapping rm
                        ON m.id = rm.movie_id
                INNER JOIN names n
                        ON rm.name_id = n.id
                INNER JOIN ratings r
                        ON m.id = r.movie_id
                INNER JOIN genre g
                        ON m.id = g.movie_id
         WHERE  genre LIKE '%drama%'
                AND avg_rating > 8
                AND rm.category = "actress"
         GROUP  BY n.NAME)
SELECT *
FROM   actress_summary
WHERE  actress_rank <= 3; 

-- ------------------------------------------------------------------------------------------------------------------
/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


WITH director_summary
AS
  (
             SELECT     dm.name_id AS director_id,
                        n.name     AS director_name,
                        m.id       AS movie_id,
                        total_votes,
                        avg_rating,
                        duration,
                        datediff(date_published,lag(date_published,1,0) over(partition BY n.name ORDER BY date_published)) AS inter_movie_days
             FROM       movie m
             INNER JOIN director_mapping dm
             ON         m.id=dm.movie_id
             INNER JOIN names n
             ON         n.id=dm.name_id
             INNER JOIN ratings r
             ON         m.id=r.movie_id )
  SELECT   director_id,
           director_name,
           count(movie_id)                AS number_of_movies,
           round(avg(inter_movie_days),0) AS avg_inter_movie_days,
           round(avg(avg_rating),2)       AS avg_rating,
           sum(total_votes)               AS total_votes,
           min(avg_rating)                AS min_rating,
           max(avg_rating)                AS max_rating,
           sum(duration)                  AS total_duration
  FROM     director_summary
  GROUP BY director_id,
           director_name
  ORDER BY number_of_movies DESC
  LIMIT    9;
  
