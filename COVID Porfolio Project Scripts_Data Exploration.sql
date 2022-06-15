SELECT *
FROM PortfolioProject..COVID_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..COVID_Vacinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVID_deaths
ORDER BY 1,2

--Total cases versus total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..COVID_deaths
WHERE location like '%canada%'
AND continent IS NOT NULL
ORDER BY 1,2

--total cases versus the population
SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
FROM PortfolioProject..COVID_deaths
WHERE location like '%canada%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to the population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM PortfolioProject..COVID_deaths
--WHERE location like '%canada%'
GROUP BY location, population
ORDER BY PercentofPopulationInfected DESC

--Showing the highest Death Count per Population
SELECT location, MAX(cast(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..COVID_deaths
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


--Breaking down by continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..COVID_deaths
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


--showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS INT)) AS Total_Death_Count
FROM PortfolioProject..COVID_deaths
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC

--Global numbers
                                                          
--total new cases is 520921996 and new cases is 6225343

--Queries used for Tableau Project

--global numbers 2

--1
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_cases) *100 AS DeathPercentage
FROM PortfolioProject..COVID_Deaths
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--2
SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'high income','Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--3
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))* 100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_Deaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

--5
SELECT dea.continent, dea.location, dea.date, dea.population,
MAX(vac.total_vaccinations) AS RollingPeopleVaccinated
--, (RollingPeopleVacinnated/population) *100
FROM PortfolioProject..Covid_Deaths dea
JOIN PortfolioProject..Covid_Vacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3

--6
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS
DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--7


--Looking at total population versus vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated)/population)*100
 FROM PortfolioProject..COVID_deaths dea
JOIN PortfolioProject..COVID_Vacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated)/population)*100
 FROM PortfolioProject..COVID_deaths dea
JOIN PortfolioProject..COVID_Vacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated)/population)*100
 FROM PortfolioProject..COVID_deaths dea
JOIN PortfolioProject..COVID_Vacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM #PercentPopulationVaccinated

--Creating view to store data for visualizations later

--view 1
DROP VIEW IF exists PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated)/population)*100
 FROM PortfolioProject..COVID_deaths dea
JOIN PortfolioProject..COVID_Vacinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

--view 2 - highest infection rate
CREATE VIEW PercentofPopulationInfected AS
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected
FROM PortfolioProject..COVID_deaths
--WHERE location like '%canada%'
GROUP BY location, population
--ORDER BY PercentofPopulationInfected DESC


