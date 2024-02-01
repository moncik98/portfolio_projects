
/* Portfolio project - Covid */


SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data tha we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total_cases vs total_deaths
-- Shows likelihood of dying if you contract Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Poland'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at total_cases vs population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentageOfPopulationInfected
FROM CovidDeaths
WHERE location = 'Poland'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentageOfPopulationInfected
FROM CovidDeaths
--WHERE location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentageOfPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- ---------------------Data by continent----------------------------------------------------------


-- Showing continents with te highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- ----------------- Global data -------------------------------------------------------------------


-- total cases, deaths and percentage per day
SELECT date, SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageWorld
FROM CovidDeaths
--WHERE location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- total cases, deaths and percentage global
SELECT SUM(new_cases) TotalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentageWorld
FROM CovidDeaths
--WHERE location = 'Poland'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Population vs Total Vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
FROM CovidDeaths d
JOIN CovidVacc v
ON d.location=v.location
and d.date=v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3



-- Use CTE -----------------------------------------------------------------------------------------------------

WITH PopVsVac (Continent, Location, date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths d
JOIN CovidVacc v
ON d.location=v.location
and d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-----Temp Table--------------------------------------------------------------------------------------------------

--DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths d
JOIN CovidVacc v
ON d.location=v.location
and d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



------------ Create View to store data for later visualisation------------------------------------------------------

CREATE VIEW PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths d
JOIN CovidVacc v
ON d.location=v.location
and d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated