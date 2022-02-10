--Best Cities and Countries for Startups - Data Exploration 

--Skills used: Windows Functions, Aggregate Functions, String Functions, Joins, CTE's, Temp Tables, 
--             Stored Procedures w/ Parameters, Case Statements. 

--The following tables will be used to analyze the best Cities and Countries for Startups:
SELECT * FROM BestStartupCities
SELECT * FROM BestStartupCountries


------------------------------------------------------------------------------------------------------------ 
--1)Shows ranking list of best cities for startups, their total score 
--  and the average score of the country they belong to. 


SELECT CONCAT(city,' ,', country) AS Location, total_score,
ROUND(AVG(total_score) OVER (PARTITION BY country),2) AS CountryAvgScore
FROM BestStartupCities
ORDER BY position


------------------------------------------------------------------------------------------------------------
--2)Shows the list of countries and the number of cities they have in
--  the BEST CITIES FOR STARTUPS Ranking list. 


SELECT country, COUNT(DISTINCT City) AS #OfCitiesInList, ROUND(AVG(total_score),2) AS AvgScore 
FROM BestStartupCities
GROUP BY country
ORDER BY #OfCitiesInList DESC, country


------------------------------------------------------------------------------------------------------------
--3)List of cities, their ranking position , the country they belong to and the country's ranking position 


SELECT Countries.country, Cities.city, Countries.ranking  AS CountryRanking,  Cities.position AS CityRanking
FROM  BestStartupCountries AS Countries
JOIN BestStartupCities AS Cities
ON TRIM(Countries.country) = TRIM(Cities.country)
ORDER BY  Countries.country, Cities.position


------------------------------------------------------------------------------------------------------------
--4) List of all the cities that belong to a country in the TOP 10 Best countries for startups. 
--4.a) DONE WITH CTE


WITH Top10Countries AS(
SELECT TOP (10) country, total_score FROM BestStartupCountries)


SELECT Top10Countries.country ,BestStartupCities.city FROM BestStartupCities 
JOIN Top10Countries 
ON TRIM(BestStartupCities.country) = TRIM(Top10Countries.country)
ORDER BY Top10Countries.country,BestStartupCities.position


--4.b) DONE WITH TEMP TABLE


DROP TABLE IF EXISTS #Temp_Top10Countries
CREATE TABLE #Temp_Top10Countries
(country varchar(50), total_score int)


INSERT INTO #Temp_Top10Countries
SELECT TOP (10) country, total_score FROM BestStartupCountries


SELECT #Temp_Top10Countries.country ,BestStartupCities.city FROM BestStartupCities 
JOIN #Temp_Top10Countries 
ON TRIM(BestStartupCities.country) = TRIM(#Temp_Top10Countries.country)
ORDER BY #Temp_Top10Countries.country, BestStartupCities.position


--4.c) DONE WITH SUBQUERIES


SELECT Top10Countries.country ,BestStartupCities.city FROM BestStartupCities 
JOIN ( SELECT TOP (10) country, total_score FROM BestStartupCountries) AS Top10COuntries
ON TRIM(BestStartupCities.country) = TRIM(Top10Countries.country)
ORDER BY Top10Countries.country,BestStartupCities.position


------------------------------------------------------------------------------------------------------------
--5) List of all countries with a column that specifies if they belong to a Top 10, Top 50 ,
--   Top 100 country or non of the above.  
WITH CityAndCountryRankings AS(
SELECT Countries.country, Countries.ranking  AS CountryRanking, Cities.city, Cities.position AS CityRanking
FROM BestStartupCountries AS Countries
RIGHT JOIN BestStartupCities AS Cities
ON TRIM(Countries.country) = TRIM(Cities.country))


SELECT city, 
CASE
	WHEN CountryRanking<11 THEN 'Top 10 Country'
	WHEN CountryRanking<51 THEN 'Top 50 Country'
	WHEN CountryRanking<101 THEN 'Top 100 Country'
	ELSE 'Not in a top 100 Country'
END AS 'Belongs to a: '
FROM CityAndCountryRankings
ORDER BY CityRanking


------------------------------------------------------------------------------------------------------------
--6)Created STORED PROCEDURE (Function) that recieves a numeric integer parameter (n) and 
--  when executed shows a list of the Top (n) cities and countries


CREATE PROCEDURE ShowTopCountriesAndCities
AS
SELECT country, total_score FROM BestStartupCountries
SELECT city, total_score FROM BestStartupCities


EXEC ShowTopCountriesAndCities @Number = 10


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- THE STORED PROCEDURE ABOVE WAS MODIFIED TO BE ABLE TO RECIEVE A PARAMETER IN THE FOLLOWING SCRIPT:


--ALTER PROCEDURE [dbo].[ShowTopCountriesAndCities]
--@Number int
--AS
--SELECT country, total_score FROM BestStartupCountries
--WHERE [ranking ] <= @Number

--SELECT city, total_score FROM BestStartupCities
--WHERE position <= @Number
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------