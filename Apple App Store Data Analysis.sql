Select * from [Portfolio Project]..AppleStore

Select * from [Portfolio Project]..appleStore_description



-- Check the number of unique apps in both tables

Select COUNT(DISTINCT id) as UniqueAppIds 
from [Portfolio Project]..AppleStore

Select COUNT(DISTINCT id) as UniqueAppIds 
from [Portfolio Project]..appleStore_description



-- Check for missing values

Select COUNT(*) as MissingValues
from [Portfolio Project]..AppleStore
Where track_name is null or user_rating is null or prime_genre is null

Select COUNT(*) as MissingValues
from [Portfolio Project]..appleStore_description
Where app_desc is null 


-- Find out the number apps per genre

Select prime_genre, COUNT(*) as NumApps
from [Portfolio Project]..AppleStore
Group by prime_genre
Order by NumApps desc


-- Get an overview of the apps' rating 

Select MIN(user_rating) as MinRating, MAX(user_rating) as MaxRating, AVG(user_rating) as AvgRating
from [Portfolio Project]..AppleStore


-- Get distribution of app prices
Select (price/2)*2 as PriceBinStart, ((price/2)*2) + 2 as PriceBinEnd, COUNT(*) as NumApps
from [Portfolio Project]..AppleStore
Group by (price/2)*2
Order by PriceBinStart


-- Determine whether paid apps have higher rating than free apps

Select App_Type, avg(user_rating) as Avg_Rating from
(Select CASE
			When price > 0 Then 'Paid'
			Else 'Free'
       END as App_Type,
	   user_rating
	   from [Portfolio Project]..AppleStore) as typeOfApp
Group by App_Type;


-- Check if apps with multiple supported languages have higher ratings

WITH App_Languages   
AS(
	  Select 
			CASE 
				When lang#num<10 Then '<10 languages'
				When lang#num BETWEEN 10 and 30 Then '10-30 languages'
				Else '>30 languages'
		    END as language_bucket,
	      user_rating
	  from [Portfolio Project]..AppleStore
	)
Select language_bucket, avg(user_rating) as Avg_Rating from App_Languages
Group by language_bucket
Order by Avg_Rating desc



-- Check Genres with low ratings

Select TOP 10 prime_genre, avg(user_rating) as Avg_Rating
from [Portfolio Project]..AppleStore
Group by prime_genre
Order by Avg_Rating asc


-- Check if there is a correlation between the length of the app description and the user rating

With Desc_Length(description_length_bucket, rating) 
AS(
	Select 
	CASE
		When LEN(B.app_desc) < 500 Then 'Short'
		When LEN(B.app_desc) BETWEEN 500 AND 1000 Then 'Medium'
		Else 'Long'
	END as description_length_bucket, A.user_rating as rating
	from [Portfolio Project]..AppleStore as A JOIN [Portfolio Project]..appleStore_description as B
	ON A.id = B.id
)
Select description_length_bucket, Avg(rating) as Avg_Rating
from Desc_Length
Group by description_length_bucket
Order by Avg_Rating desc

-- Check the top rated apps for each genre
WITH Top_Rated_Apps 
AS(
Select prime_genre, track_name, user_rating,
RANK() OVER (PARTITION BY prime_genre Order by user_rating desc, rating_count_tot desc) as rank
from [Portfolio Project]..AppleStore
)
Select prime_genre, track_name, user_rating from Top_Rated_Apps
Where rank = 1
