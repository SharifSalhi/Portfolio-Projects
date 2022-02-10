-- Covid 19 - Data Exploration for Tableau Visualization 


--The following tables will be used to analyze the Covid 19 Pandemic:
SELECT * FROM CovidDeaths
SELECT * FROM CovidVaccinations


--Sections 1-4 are used in Tableau Covid 19 Dashboard

------------------------------------------------------------------------------------------------------------
--1)Shows Total Global Cases, Deaths and Death Rate 
--Used in Tableau Covid 19 Visualization

SELECT SUM(New_cases) AS TotalCases, SUM(CAST(New_deaths AS int)) AS TotalDeaths,
ROUND(SUM(CAST(New_deaths AS int))/SUM(New_cases),6)*100 AS DeathRate
FROM CovidDeaths
WHERE Continent IS NOT NULL


------------------------------------------------------------------------------------------------------------
--2)Shows Total Cases, Deaths and Death Rate Per Continent
--Used in Tableau Covid 19 Dashboard


SELECT Continent, SUM(New_cases) AS TotalCases, SUM(CAST(New_deaths AS int)) AS TotalDeaths,
ROUND(SUM(CAST(New_deaths AS int))/SUM(New_cases),6)*100 AS DeathRate
FROM CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY Continent


------------------------------------------------------------------------------------------------------------
--3)Shows Total Cases vs Population Per Country throughout the pandemic (timeline)
--Used in Tableau Covid 19 Dashboard


SELECT Location, Date, ROUND((Total_cases/Population)*100,4) AS PercentageInfected
FROM CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY Location, Date


------------------------------------------------------------------------------------------------------------
--4)Shows Current Total Deaths AND Cases vs Popultion
--Used in Tableau Covid 19 Visualization


SELECT Location, SUM(CAST(New_deaths as int)) AS TotalDeaths, 
ROUND(SUM(New_cases)*100/Population,8) AS PercentageInfected,
ROUND(SUM(CAST(New_deaths as int))*100/Population,8) AS PercentageDeseased
FROM CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY Location, Population 
ORDER BY PercentageInfected DESC


------------------------------------------------------------------------------------------------------------
--5)Mortality Rate compared to Percentage of Population Vaccinated
--Shows the vaccines's impact on Covid 19 Mortality Rate in the United States


SELECT CDeaths.Location, CDeaths.Date,
ROUND(Total_Deaths/Total_cases,4)*100 AS MortalityRate,
ROUND(people_fully_vaccinated/population *100,2) AS PercentageVaccinated 
FROM CovidDeaths AS CDeaths
JOIN CovidVaccinations AS CVacs
ON CDeaths.Location = CVacs.Location AND CDeaths.Date = CVacs.Date
WHERE CDeaths.Continent IS NOT NULL 
ORDER BY Location, CDeaths.Date


------------------------------------------------------------------------------------------------------------
--6)Shows list of countries, the continent they belong to
--  and the percentage of cases they represent in their respecitve continent. 


WITH ContinentCases (Continent, Totalcases)
AS
(SELECT Continent, SUM(New_cases)
FROM CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY Continent)
,CountryCases (Country, Continent, TotalCases)
AS
(SELECT Location, Continent, SUM(New_cases) FROM CovidDeaths
WHERE Continent IS NOT NULL 
GROUP BY location, Continent) 

SELECT CountryCases.Country, CountryCases.Continent, 
ROUND(CountryCases.TotalCases/ContinentCases.TotalCases,4)*100 
FROM CountryCases
JOIN ContinentCases 
ON CountryCases.Continent = ContinentCases.Continent
ORDER BY CountryCases.Continent, CountryCases.Country
--------------------------------------------------------------------------------------------------------------


