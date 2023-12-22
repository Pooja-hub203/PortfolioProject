Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- dataset
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%asia%'
order by 1,2

--looking at total cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%asia%'
order by 1,2

--looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things down by continent

--showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
order by 1,2

Select *
From PortfolioProject..CovidVaccinations

--Joining Both tables

Select *
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND
CD.date = CV.date

--Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND
CD.date = CV.date
Where CD.continent is not null
order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND
CD.date = CV.date
Where CD.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPeopleVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND
CD.date = CV.date
--Where CD.continent is not null
--order by 1,2

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPeopleVaccinated

--Creating View for later Data Visualization

CREATE View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CONVERT(int, CV.new_vaccinations)) OVER (Partition by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.location = CV.location
AND
CD.date = CV.date
Where CD.continent is not null
--order by 1,2


-- See the data using view
Select *
from PercentPopulationVaccinated