create TABLE appleStore_description_combined AS

SELECT * FROM appleStore_description1

union ALL

SELECT * FROM appleStore_description2

UNION ALL 

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

-- Check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) as UniqueAppIDs
from AppleStore

SELECT COUNT(DISTINCT id) as UniqueAppIDs
from appleStore_description_combined



-- Check for any missing values in the key fieldsAppleStore

SELECT COUNT(*) as MissingValues
FROM AppleStore
where track_name is NULL or user_rating is NULL or prime_genre is NULL

SELECT COUNT(*) as MissingValues
FROM appleStore_description_combined
where app_desc is NULL  

-- Finding out the number of apps per genre 

SELECT prime_genre, COUNT(*) as NumApps
from AppleStore
group by prime_genre
order by NumApps DESC

-- Get an overview of apps' ratings

SELECT min(user_rating) as MinRating,
	   max(user_rating) as MaxRating,
       round(avg(user_rating), 2) As AVGRating
FROM AppleStore
    
-- Get distribution of app prices 
 
SELECT 
	   price as PriceBinStart,
       round(price + 50, 2) as PriceBinEnd,
       COUNT (*) as NumApps,
       round(avg(user_rating), 2) as AVGRating
from AppleStore
group by PriceBinStart
order by AVGRating desc


**Data Analysis**
-- Determine whether paid apps have higer ratings than the free apps 

select CASE
			when price > 0 then 'Paid'
            ELSE 'Free'
       end as App_Type,
       round(avg(user_rating), 2) as Avg_Rating
FROM AppleStore
group BY App_Type
       
-- find out which price ranges have higer ratings

SELECT
    CASE
        WHEN price <= 5 THEN 'Under $5'
        WHEN price > 5 AND price <= 10 THEN '$5 - $10'
        WHEN price > 10 AND price <= 20 THEN '$11 - $20'
        WHEN price > 20 AND price <= 30 THEN '$21 - $30'
        WHEN price > 30 AND price <= 40 THEN '$31 - $40'
        WHEN price > 40 AND price <= 50 THEN '$41 - $50'
        WHEN price > 50 AND price <= 60 THEN '$51 - $60'
        ELSE 'Over $60'
    END AS price_range,
    round(AVG(user_rating), 2) AS avg_rating
FROM AppleStore
GROUP BY price_range
ORDER BY avg_rating DESC
       
-- Check if apps with more languages have higher ratings

SELECT CASE
			when lang_num < 10 THEN 'less than 10 languages'
            when lang_num BETWEEN 10 and 30 then 'between 10 and 30 languages'
            else 'more than 30 languages'
       END as Language_Bucket,
       round(avg(user_rating), 2) as Avg_Rating
FROM AppleStore
GROUP by Language_Bucket
order by Avg_Rating DESC

-- Check genres with low ratings

SELECT prime_genre, 
	   round(avg(user_rating), 2) as Avg_Rating
from AppleStore
GROUP by prime_genre
order by Avg_Rating ASC
LIMIT 10

-- Check if there is correlation between the length of description and ratings

SELECT CASE
			when length(B.app_desc) < 500 then 'Short'
            when length(B.app_desc) Between 500 and 1000 then 'Medium'
            else 'Long'
       End as Length_Description_Bucket,
       round(avg(A.user_rating), 2) as Avg_Rating
from 
	AppleStore as A
join 
	appleStore_description_combined as B
on 
	A.id = B.id
group by Length_Description_Bucket
ORDER by Avg_Rating DESC

-- Check the top-rated apps for each genre

SELECT 
      prime_genre, 
      track_name, 
      user_rating

FROM (
  	  SELECT
            prime_genre, 
            track_name, 
            user_rating,
            RANK () OVER(PARTITION By prime_genre ORDER by user_rating DESC, rating_count_tot DESC) as Rank
  	  from AppleStore) as A
WHERE A.rank = 1


