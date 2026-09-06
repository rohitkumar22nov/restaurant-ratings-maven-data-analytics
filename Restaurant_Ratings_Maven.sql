--=======================================
--Creating Database and Checking Tables
--=======================================

Create database restaurant_ratings_maven
use restaurant_ratings_maven

--consumer_preferences:
Select top 5 * from consumer_preferences

--consumers
Select top 5 * from consumers

--ratings
Select top 5 * from ratings

--restaurant_cuisines
Select top 5 * from restaurant_cuisines

--restaurant
Select top 5 * from restaurants


--=============================
-- Data Profiling & Cleaning
--=============================

-----------------------------
--Consumer_preferences:
-----------------------------
--Overview:
Select top 5 * from consumer_preferences


--Cleaning steps:
-- Null/Duplicate/Duplicate Deletion/Trim.

--Null Check: (No Null Found)
Select count(*) as  total_count,
count(consumer_id) as consumer_id_count,
count(preferred_cuisine) as cuisine_count
from consumer_preferences


--Duplicate record check: (2 duplicates found and removed)
;With dedupe as(
Select *,
ROW_NUMBER() Over(partition by consumer_id, preferred_cuisine order by consumer_id asc ) as Row_num
from consumer_preferences)

--Select * from dedupe where row_num >1

--(Below duplicates found and removed)
-- U1135	Asian	2
-- U1135	Pacific	2

-- (delete already executed & committed once; commented to prevent re-running)
--Delete from dedupe where row_num>1

--Final check after the deletion:
Select * from dedupe where row_num >1

--Removing any extra spaces:

Begin Transaction

Update consumer_preferences
set consumer_id = Trim(consumer_id)

--Verify changes:
Select top 5 * from consumer_preferences

--Commit the changes:

Commit Transaction

Begin Transaction
Update consumer_preferences
Set preferred_cuisine = Trim(Preferred_Cuisine)

--Verify the changes
Select top 5 * from consumer_preferences

--Commit the changes

Commit Transaction

-----------------
--Consumer:
-----------------

--Overview:
Select top 5 * from consumers

--Cleaning steps:
-- Null & Uniqueness/Duplicate/Duplicate Deletion/Trim.

--Null Check & Uniqueness:
Select count(*) total_count,
count(distinct consumer_id) as distinct_consumer_count,
count(city) as city_count,
count(state) as state_count,
count(country) as country,
count(latitude) as lat_count,
count(longitude) as lng_count,
count(smoker) as smoker_count,
count(drink_level) as drink_count,
count(transportation_method) as transport_count,
count(marital_status) as marital_count,
count(children) as child_count,
count(age) as age_count,
count(occupation) as occupation_count,
count(budget) as budget_count
from consumers

/*Output shows, 
consumer_id is non-null and unique
Fields containing null are:
smoker(3), transport(7), marital_count(4), children(11),
Occupation(7), budget(7)
*/

--Decided to fill all those missing values with 'Unknown'

-------------------------------
--Smoker Column (3 null count)
-------------------------------
Select smoker,  count(*) null_smoker_count from consumers
where smoker is null
group by smoker

Begin Transaction
Update consumers
set Smoker = 'Unknown'
where smoker is null

--Recheck if the null are not removed, then Commit:
Select smoker,  count(*) null_smoker_count from consumers
where smoker is null
group by smoker

Commit Transaction

--------------------------------------
--Transport_Method (7 null count):
--------------------------------------
Select Transportation_Method, count(*) as tranport_null_count
from consumers 
where Transportation_Method is null
group by Transportation_Method

Begin Transaction
Update consumers
set Transportation_Method = 'Unknown'
where Transportation_Method is null

--Recheck if the null are not removed, then Commit:
Select Transportation_Method, count(*) as tranport_null_count
from consumers 
where Transportation_Method is null
group by Transportation_Method

--commit after verifying
Commit Transaction

-----------------------------------
--Marital_Status (4 null count):
-----------------------------------
Select Marital_Status, count(*) as marital_status_count
from consumers where Marital_Status is null
group by Marital_Status

Begin Transaction
Update consumers
set Marital_Status = 'Unknown'
where Marital_Status is null

--Verify after updating
Select Marital_Status, count(*) as marital_status_count
from consumers where Marital_Status is null
group by Marital_Status

--Commit after verifying
Commit Transaction

-------------------------------
--Children (11 null count):
-------------------------------
Select Children, count(*) as children_column_null_count
from consumers where Children is null
group by Children

Begin Transaction
Update Consumers
Set Children = 'Unknown' 
where Children is null


--Verify before commit:
Select Children, count(*) as children_null_count
from consumers where Children is null
group by Children

--Commit after verified:
Commit Transaction

-------------------------------
--Occupation(7 null count)
-------------------------------
Select Occupation, count(*) as occupation_count_null
from consumers where Occupation is null
group by Occupation

Begin Transaction
Update Consumers
set Occupation = 'Unknown'
where Occupation is null

--Verify if the null got removed:
Select Occupation, count(*) as occupation_count_null
from consumers where Occupation is null
group by Occupation

--Commit changes after verifying:
Commit Transaction

-------------------------
--budget(7 null count)
-------------------------
Select Budget, count(*) as budget_count_null
from consumers where Budget is null
group by Budget

Begin Transaction
Update consumers
set Budget = 'Unknown'
where Budget is null

--Verfiying after update, before commit
Select Budget, count(*) as budget_count_null
from consumers where budget is null
group by budget

--Commit the changes:
Commit Transaction

----------------
--ratings:
-----------------

--Overview:
Select top 5 * from ratings

--Cleaning steps:
-- Null & Uniqueness/Duplicate/Duplicate Deletion/Trim.

--Null & Uniqueness check: (No null found)
Select count(*) as total_count, count(consumer_id) as consumer_id_count,
count(restaurant_id) restaurant_id_count,
count(overall_rating) as overall_rating_count,
count(food_rating) as food_rating_count,
count(service_rating) as service_rating_count
from ratings

--Duplication check: (no duplicates found)
;With dedupe_ratings as (
Select *,
ROW_NUMBER()
Over(partition by Lower(trim(consumer_id)), 
restaurant_id,
overall_rating,
food_rating,
service_rating order by consumer_id asc) as row_num
from ratings
)

Select * from dedupe_ratings where row_num>1

--Trim
Begin Transaction
Update ratings
set Consumer_ID = trim(consumer_id)

--Commit
Commit Transaction

--Check after commit:
Select consumer_id from ratings

----------------
--restaurant cuisines:
-----------------

--Overview:
Select top 5 * from restaurant_cuisines

--Cleaning steps:
-- Null & Uniqueness/Duplicate/Duplicate Deletion/Trim.

--Null & Uniqueness check: (No null found)
Select count(*) as total_count,
count(restaurant_id) as restaurant_id_null_count,
count(cuisine) as cuisine_null_count
from restaurant_cuisines

--Duplication check: (no duplicates found)
;With restaurant_cuisines_dedupe as(
Select *,
ROW_NUMBER() 
Over(partition by restaurant_id, lower(trim(cuisine)) 
order by restaurant_id) as row_num
from restaurant_cuisines)

Select * from restaurant_cuisines_dedupe where row_num >1

--Trim:
Begin Transaction
Update restaurant_cuisines
set Cuisine = trim(cuisine)

--Verify the update
Select * from restaurant_cuisines

--Commit after verify
Commit Transaction


----------------
--restaurants:
-----------------

--Overview:
Select top 5 * from restaurants

--Cleaning steps:
-- Null & Uniqueness/Duplicate/Duplicate Deletion/Trim.

--Null & Uniqueness check:(restaurant_id found as unique not null)
--Zip-codes are alone having null 74 count (Select 130-56)

Select count(*) as total_count, 
count(distinct restaurant_id) as distinct_restaurant_id_count,
count(name) as name_count, count(city)  as city_count, 
count(state) as state_count, count(country) as country_count,
count(zip_code) as zip_count, count(Latitude) as lat_count,
count(longitude) as lng_count, count(alcohol_service) as alcohol_count,
count(smoking_allowed) as smoking_count, count(price) as price_count,
count(franchise) as franchise_count, count(area) as area_count,
count(parking) as parking_count
from restaurants

--Check for possibility to get the zip from other available:
Select country, state, city, zip_code
from restaurants

Select distinct city from restaurants

--This proves, the zip code Can't be referenced from othe  cities:
Select distinct city, zip_code from restaurants
order by city

--Updating the null as Unknown for zip_codes:

--first step to  check the datatype of zip
Select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'restaurants'

--As the data_type is int, this needs to be updated to varchar:
Begin Transaction
Alter table restaurants
Alter column zip_code varchar(50)

--Verify the change:
Select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'restaurants'

--Commit the  changes after verifying:
Commit Transaction

--Update the null values as 'Unknown' in the zip_codes
Begin Transaction
Update restaurants
set Zip_Code = 'Unknown'
where zip_code is null

--Verify before commit:
Select * from restaurants where Zip_Code is null
or Zip_Code = 'unknown'

Select * from restaurants where
Zip_Code != 'unknown'

--Commit after verifying:
Commit Transaction

--Trim:
Begin Transaction
Update restaurants
set 
Name = trim(name),City = trim(city),State = trim(state),
country = trim(country), Alcohol_Service = TRIM(alcohol_service),
Smoking_Allowed = trim(Smoking_Allowed), price=trim(price),
Franchise = trim(franchise), area = trim(area),
Parking = trim(parking)

--Check before commit
Select * from restaurants

--Commit after verified:
Commit Transaction


--======================================================
--Setting Constraints and Building Schema Relationship
--======================================================

----------------------
--Consumer_Preferences
----------------------

--PK = Not Applicable
--FK = Consumer_id.Consumers

Select * from consumer_preferences

--Adding FK key constraint to consumer_preferences
Alter table consumer_preferences
Add constraint consumer_id_consumers_preferences_fk
Foreign Key (consumer_id)
References consumers(consumer_id)

------------------
--Consumers Table
------------------

--PK = consumer_id  (already defined while  creating/pulling table)
--FK = Not Applicable

-------------------
--ratings
-------------------

--PK = Not Applicable
--FK = Consumer_id.consumers / Restaurant_id.restaurants

--Adding FK key constraint to ratings

--FK with consumers:
Alter table ratings
Add Constraint ratings_consumers_consumer_id_fk
Foreign Key (consumer_id)
References consumers(consumer_id)

--FK with restaurants:
Alter table ratings
Add constraint ratings_consumers_restaurant_id_fk
Foreign Key (restaurant_id)
References restaurants(restaurant_id)

-------------------
--restaurant_cuisines
-------------------

--PK = Not applicable
--FK = restaurant_id.restaurants

--Adding FK constraint to restaurants_cuisines
Alter table restaurant_cuisines
Add constraint restaurant_cuisines_restaurants_restaurant_id_fk
Foreign Key (restaurant_id)
References restaurants(restaurant_id)



-------------------
--restaurants
-------------------
Select * from restaurants
--PK = Restaurant_id (already defined while  creating/pulling table)
--FK = Not Applicable


--===================================
--Exploratory Data Analysis
--===================================


-----------------------------------------------
--Highest Overall rating by various parameters
-----------------------------------------------

---Review Rating by Smoking Allowed: (Area restricted/dedicated smoking wins)
;With smoking_permission_count_by_rating as (
Select res.Smoking_Allowed,
Sum(case when rat.overall_rating = 0 then 1 end) as rating_0,
Sum(case when rat.overall_rating = 1 then 1 else 0 end) as rating_1,
Sum(case when rat.overall_rating = 2 then 1 else 0 end) as rating_2
from restaurants res join ratings rat
on res.restaurant_id = rat.restaurant_id
group by res.Smoking_Allowed),

smoking_by_percent as(
Select Smoking_Allowed,
Cast(Round((rating_0*100.0/nullif((rating_0+rating_1+rating_2),0)),2) as decimal(5,2)) as rating_0_percent,
Cast(Round((rating_1*100.0/nullif((rating_0+rating_1+rating_2),0)),2) as decimal(5,2)) as rating_1_percent,
Cast(Round((rating_2*100.0/nullif((rating_0+rating_1+rating_2),0)),2) as decimal(5,2)) as rating_2_percent
from smoking_permission_count_by_rating
)

Select * from smoking_by_percent
order by Smoking_Allowed


---Review Rating by Alcohol_service (Venue with Alcohol wins with highest rating)
With Alcohol_level_by_rating as(
Select Alcohol_Service,
Sum(case when rat.overall_rating = 0 then 1 else 0 end) as rating_0,
Sum(case when rat.overall_rating = 1 then 1 else 0 end) as rating_1,
Sum(case when rat.overall_rating = 2 then 1 else 0 end) as rating_2
from restaurants res join ratings rat
on res.restaurant_id = rat.restaurant_id
group by Alcohol_Service
),

alcohol_level_percentage as(
Select Alcohol_Service,
cast (rating_0*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_0_percent,
cast (rating_1*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_1_percent,
cast (rating_2*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_2_percent

from Alcohol_level_by_rating

)

Select * from alcohol_level_percentage
order by Alcohol_Service

---Review Rating by Price (Higher price venues with highest ratings)
With price_and_rating_count as(
Select Price,
Sum(Case when rat.overall_rating = 0 then 1 else 0 end) as rating_0,
Sum(Case when rat.overall_rating = 1 then 1 else 0 end) as rating_1,
Sum(Case when rat.overall_rating= 2 then 1 else 0 end) as rating_2
from restaurants res join ratings rat
on res.restaurant_id = rat.restaurant_id
group by price),

price_and_rating_percentage as(
Select Price,
Cast(rating_0*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_0_percent,
Cast(rating_1*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_1_percent,
Cast(rating_2*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal (5,2)) as rating_2_percent
from price_and_rating_count
)

Select * from price_and_rating_percentage
order by price

---Review Rating by Parking (Valet parking facility gets highest ratings)
With parking_and_rating_count as(
Select Parking,
Sum(Case when rat.overall_rating = 0 then 1 else 0 end) as rating_0,
Sum(Case when rat.overall_rating = 1 then 1 else 0 end) as rating_1,
Sum(Case when rat.overall_rating= 2 then 1 else 0 end) as rating_2
from restaurants res join ratings rat
on res.restaurant_id = rat.restaurant_id
group by parking),

parking_and_rating_percentage as(
Select parking,
Cast(rating_0*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_0_percent,
Cast(rating_1*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal(5,2)) as rating_1_percent,
Cast(rating_2*100.0/nullif((rating_0+rating_1+rating_2),0) as decimal (5,2)) as rating_2_percent

from parking_and_rating_count
)

Select *,
Ceiling((rating_0_percent + rating_1_percent + rating_2_percent)) as total
from parking_and_rating_percentage
order by parking


--Consumer Preferences:

--(Mexican is the most preferred cuisine, with highest number of preferences)
Select Top 10 Preferred_Cuisine, count(*) as Counts
from consumer_preferences
group by Preferred_Cuisine
order by counts desc 


--Consumer Preferences by food_rating 
--(Japanese cuisine is the highest rated cuisine)
With preference_food_rating_count as(
Select pre.Preferred_Cuisine,

Sum(Case when rat.food_rating =0 then 1 else 0 end) as food_rating_0,
Sum(case when rat.food_rating = 1 then 1 else 0 end) as food_rating_1,
Sum(case when rat.food_rating = 2 then 1 else 0 end) as food_rating_2
from consumer_preferences pre left join ratings rat
on pre.Consumer_ID = rat.Consumer_ID
group by pre.Preferred_Cuisine),

Preference_food_rating_percent as(
Select preferred_cuisine,

Cast(food_rating_0*100.0/(food_rating_0+food_rating_1+food_rating_2) as decimal(5,2))
as food_rating_0_percent,

Cast(food_rating_1*100.0/(food_rating_0+food_rating_1+food_rating_2) as decimal(5,2))
as food_rating_1_percent,

Cast(food_rating_2*100.0/(food_rating_0+food_rating_1+food_rating_2) as decimal(5,2))
as food_rating_2_percent
from preference_food_rating_count
)

Select Top 7 * from preference_food_rating_percent
order by food_rating_2_percent desc


------------------------------------------------------------------------
--Food Vs Service to get highest overall rating by Restaurant parameters
------------------------------------------------------------------------


--Restaurants by Ratings (Overall, Food & Service):
Select  rest.Name, rest.state, rest.city,rat.Overall_Rating,
rat.Food_Rating, rat.Service_Rating
from restaurants rest left join ratings rat
on rest.restaurant_id = rat.restaurant_id
order by rat.Overall_Rating desc

--(Food Vs Service to get the highest Overall Rating)

Select  
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from ratings



--Food Vs Service, where Alcohol is served
--Food is dominating to get overall best rating,
--until alcohol jumps in...

Select Alcohol_Service,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0  end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.Alcohol_Service




--Food Vs Service, venue  by smoking permission:
Select smoking_allowed,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.smoking_allowed

--Food Vs Service, venue  by Price Category:
--Food wins where price category is not High
--However, tie between food and service for other than high

Select Price,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0  end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.Price

--Food Vs Service, venue  by Parking:
--Food wins each parking category except Valet Parking (as there is tie)

Select Parking,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.Parking


--Food Vs Service, venue  by Area:
--Food wins both area categories (Oepn & Close)

Select rest.area,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.Area


--Food Vs Service, venue  by Franchise:
--Food has strong association with the overall rating for NON-Franchise.
--However, Franchise venue are almost equally competent in Service also to get highest rating

Select rest.Franchise,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0  end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from restaurants rest left join ratings rat
on rest.Restaurant_ID = rat.Restaurant_ID
group by rest.Franchise


------------------------------------------------------------------------
--Food Vs Service to get highest overall rating by Consumers parameters
------------------------------------------------------------------------

--Food Vs Service, by Consumer State:
--Food wins the race

Select con.State,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.state

--Food Vs Service, by Consumer's smoking habit:
--Food wins the race when consumer is NON-smoker and tie btwn food & service when a smoker
Select con.Smoker,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.Smoker


--Food Vs Service, by Consumer's Alcohol Drinking Level:
--Food wins each category and Abstemious more dominantly:
Select con.Drink_Level,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.Drink_Level


--Food Vs Service, by Consumer's Marital Status:
--Food wins for consumers thoe are Single rather than for Married:
Select con.Marital_Status,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.Marital_Status


--Food Vs Service, by Consumer's Budget:
--Food wins for consumers those having Midium or Low Budget.
--However, high budget consumers equally prefer the service also:

Select con.Budget,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.Budget


--Food Vs Service, by Consumer's Age Group:


--Adding a new column in the consumer table
Alter table consumers
Add Age_Group varchar(50)

--Update the new created column of age_group
Update consumers
Set age_group = Case
When age<=30 then 'Young Adult' 
when age<=45 then 'Adult'
When age<=60 then 'Senior Adult'
Else 'Senior Citizen'
End

--Food wins for consumers in Young_Adult (age below 31 yrs) age group.
--Young_Adults prefer food over service
Select con.age_group,
Sum(Case When overall_rating=2 and food_rating =2 then 1 else 0 end)
as overall_and_food_rating,
Sum(Case when overall_rating=2 and service_rating=2 then 1 else 0 end)
as overall_and_service_rating
from consumers con join ratings rat
on con.Consumer_ID = rat.Consumer_ID
group by con.age_group

--==========================================================================
--Project Completed and Moved to Power BI for visuals & Executive Summary
--==========================================================================