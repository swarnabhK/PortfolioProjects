Select location,date,total_cases,new_cases,total_deaths,population from 
PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 1,2;


-- Looking at total_deaths per total_cases
Select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage from 
PortfolioProject..CovidDeaths 
WHERE continent is not null
Order by 1,2;

-- Looking at the death percentage in United states.
Select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage from 
PortfolioProject..CovidDeaths 
WHERE location like 
'%states%'
Order by 1,2;

-- Looking at total cases vs population
-- shows percentage of population who got covid.
Select location,date,total_cases,new_cases,population, (total_cases/population)*100 as percentage_cases_population
from 
PortfolioProject..CovidDeaths 
WHERE continent is not null
Order by 1,2;

-- for united states
Select location,date,total_cases,new_cases,population, (total_cases/population)*100 as percentage_cases_population
from 
PortfolioProject..CovidDeaths
WHERE location like 
'%states%' Order by 1,2;

-- Looking at countries with the highest infection rates.

Select location,population,MAX(total_cases) as highest_infections,MAX((total_cases/population))*100 as highest_percentage_infected_population
from 
PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
Order by highest_percentage_infected_population DESC;

-- Showing the countries with highest death counts

Select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from 
PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount DESC;


-- LET's break things down by continent
-- showing the continents with the highest death count per population


Select continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
from 
PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount DESC;


-- GLOBAL NUMBERS


-- total cases and deaths per day
Select date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)) *100
as GlobalDeathPercentage
from 
PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY date
Order by 1,4 DESC;


-- Total cases and deaths as per 08-03-2022
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases)) *100
as GlobalDeathPercentage
from 
PortfolioProject..CovidDeaths 
WHERE continent is not null
Order by 1,2 DESC;

Select *
FROM PortfolioProject..CovidDeaths d;

-- Looking at total populations vs vaccinations 
-- new vaccinations per day

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent,d.location, d.date, d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100 As RollingPeopleVaccinatedPercentage
FROM PopVsVac;


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Populatin numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent,d.location, d.date, d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date;

SELECT *,(RollingPeopleVaccinated/Populatin)*100 As RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinatedYes as 
Select d.continent,d.location, d.date, d.population,v.new_vaccinations,
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null;


SELECT * from PercentPopulationVaccinatedYes;


SELECT * 
FROM INFORMATION_SCHEMA.tables;



