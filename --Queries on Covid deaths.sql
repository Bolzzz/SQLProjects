--Queries on Covid deaths

SELECT *
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
-- to eliminate continents that have been grouped as locations
WHERE continent is not null
ORDER BY 3, 4;

/*SELECT *
FROM `sql-portfolio-368609.covid_table.covid_vaccinations` 
ORDER BY 3, 4*/

--DATA EXPLORATION

--Select data that will be used
Select location, date, total_cases,new_cases,total_deaths,population
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
ORDER BY 1,2;

--Comparing total cases and total deaths in Nigeria
Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as percent_of_deaths
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
WHERE location = "Nigeria"
ORDER BY 1,2;

--Show what percentage of population in Nigeria got Covid
Select location, date, population,total_cases, (total_cases/population) *100 as percent_of_infectedpop
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
--WHERE location = "Nigeria"
ORDER BY 1,2;

--Looking at countries with highest infection rate
Select location, population,max(total_cases) as highest_inf, max((total_cases/population)) *100 as percent_of_infectedpop
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
--WHERE location = "Nigeria"
GROUP BY 2, 1 
ORDER BY percent_of_infectedpop desc;

--Looking at countries with highest death rate
Select location,max(total_deaths) as total_death_count
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
-- WHERE location = "Nigeria"
-- to eliminate continents that have been grouped as locations
WHERE continent is not null
GROUP BY 1
ORDER BY total_death_count desc;


-- CATEGORIZE THE DATA BY CONTINENT
Select continent, max(total_deaths) as total_death_count
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
-- WHERE location = "Nigeria"
WHERE continent is not null
GROUP BY 1
ORDER BY total_death_count desc;

--GLOBAL NUMBERS
--Daily count/percentage of new covid cases and deaths
Select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as percent_of_deaths--gives the daily aggregate of new cases
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Global sum of covid cases and deaths
Select SUM(new_cases) as Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as percent_of_deaths--gives the daily aggregate of new cases
FROM `sql-portfolio-368609.covid_table.covid_deaths` 
WHERE continent IS NOT NULL
ORDER BY 1,2;

SELECT *
FROM `sql-portfolio-368609.covid_table.covid_vaccinations` ;

--JOIN THE TABLES
--Looking at total population versus vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingVaccCount
        --do a rolling aggregation of the new vaccinations, but break it down by location
FROM `sql-portfolio-368609.covid_table.covid_deaths`  deaths
JOIN `sql-portfolio-368609.covid_table.covid_vaccinations`  vacc
ON deaths.location=vacc.location 
   AND deaths.date=vacc.date
WHERE deaths.continent is not null
ORDER BY 2,3;

--USING CTE to compare popualtion vs vaccination
With PopVacc --(continent, location, date, population, new_vaccinations, RollingVaccCount)
AS (
  SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingVaccCount
        --do a rolling aggregation of the new vaccinations, but break it down by location
FROM `sql-portfolio-368609.covid_table.covid_deaths`  deaths
JOIN `sql-portfolio-368609.covid_table.covid_vaccinations`  vacc
ON deaths.location=vacc.location 
   AND deaths.date=vacc.date
WHERE deaths.continent is not null
)
SELECT *, (RollingVaccCount/Population) 
FROM PopVacc;

--USING A TEMP TABLE
CREATE TEMPORARY TABLE IF NOT EXISTS PercPopVacc
--indicate the data type of the columns
(
  continent string, location string, date datetime, population int64, new_vaccinations int64, RollingVaccCount int64
  ); --end of string

INSERT INTO PercPopVacc
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingVaccCount
        --do a rolling aggregation of the new vaccinations, but break it down by location
FROM `sql-portfolio-368609.covid_table.covid_deaths`  deaths
JOIN `sql-portfolio-368609.covid_table.covid_vaccinations`  vacc
ON deaths.location=vacc.location 
   AND deaths.date=vacc.date
WHERE deaths.continent is not null; --end of string

SELECT *, (RollingVaccCount/Population)*100
FROM PercPopVacc
--come back to temp table query 

/*CREATE VIEW FOR VISUALIZATION
CREATE VIEW PercPopVacc
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER(Partition by deaths.location ORDER BY deaths.location, deaths.date) AS RollingVaccCount
        --do a rolling aggregation of the new vaccinations, but break it down by location
FROM `sql-portfolio-368609.covid_table.covid_deaths`  deaths
JOIN `sql-portfolio-368609.covid_table.covid_vaccinations`  vacc
ON deaths.location=vacc.location 
   AND deaths.date=vacc.date
WHERE deaths.continent is not null
--ORDER BY 2,3*/

