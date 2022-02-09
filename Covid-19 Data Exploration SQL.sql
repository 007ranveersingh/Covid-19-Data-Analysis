SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location='India'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at the Total Cases vs the Population
-- Shows what percentage of population has gotten Covid infected

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location='India'
ORDER BY 1,2

-- Looking at countries with highest Infection Rate(Percentage of Population Infected) compared to Population

SELECT location, population, MAX(total_cases) AS Highest_infection_count,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with Highest Death Count per Country

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death counts per population
-- This NOT the right Query

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC

--The RIGHT Query

SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = "India"
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Low income', 'Lower middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS of covid cases per day

SELECT date, SUM(new_cases) AS cases_per_day, SUM(CAST(new_deaths AS bigint)) AS deaths_per_day,  SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS bigint)) AS total_deaths,  SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS Death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE location = "India"
WHERE continent IS NOT NULL   
--GROUP BY date
ORDER BY 1,2

SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--Joining both tables
SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date

--Looking at Total Population vs Vaccinations
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.Date) AS People_Vaccinated_till_date
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, People_Vaccinated_till_date)
as 
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.Location, dea.Date) AS People_Vaccinated_till_date
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (People_Vaccinated_till_date/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
People_Vaccinated_till_date numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS People_Vaccinated_till_date
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--Order by 1,2,3
SELECT *, (People_Vaccinated_till_date/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visulizations

CREATE VIEW PerctPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS People_Vaccinated_till_date
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--Order by 1,2,3

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = "India"
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC