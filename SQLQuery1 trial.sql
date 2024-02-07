SELECT * 
FROM PortfolioProject..['Covid Deaths']
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['Covid Deaths']
ORDER BY 1, 2;

---Looking at total cases vs total deaths

SELECT location, 
	   date, 
	   total_cases, 
	   total_deaths, 
	   (cast(total_deaths as int)/cast(total_cases as int))*100 as rty
FROM PortfolioProject..['Covid Deaths']
GROUP BY 2
order by rty desc;

--Looking at total cases vs population 

SELECT location, 
	   date, 
	   population,
	   total_cases, 
	   (total_cases/population)*100 AS population_percentage
FROM PortfolioProject..['Covid Deaths']
WHERE location LIKE '%kenya%' AND total_cases IS NOT null
HAVING population_percentage > 0.5
ORDER BY 1, 2;

---Showing Countries with the highest death count 

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

---Break things now by continent

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['Covid Deaths']
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;

--Total world cases and deaths 

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['Covid Deaths']
WHERE continent is not null

--total population vs vaccination

SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   CONVERT(int,vac.new_vaccinations),
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..['Covid Deaths'] dea
 JOIN PortfolioProject..['Covid Vaccinations'] vac 
 ON dea.date = vac.date and dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2, 3
 
---with CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, 
	   dea.population, 
	   CONVERT(int,vac.new_vaccinations),
	   SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..['Covid Deaths'] dea
 JOIN PortfolioProject..['Covid Vaccinations'] vac 
 ON dea.date = vac.date and dea.location = vac.location
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac