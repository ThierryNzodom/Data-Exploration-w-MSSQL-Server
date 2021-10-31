
-- Show data from both imported tables
Select * FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select * FROM PortfolioProject..CovidVaccinations
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Total cases vs total deaths in Germany
-- shows likelihood of dying if you contract COVID in Germany
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate 
FROM PortfolioProject..CovidDeaths
Where location = 'Germany'
order by DeathRate desc


-- Total cases vs population
-- shows what percentage of population actually got COVID
-- shows likelihood of dying if you contract COVID in Germany
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionRateOfPopulation 
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2


-- Looking at countries with their maximum infection Rate vs Population
Select location, population, MAX(total_cases) as PopInfectionCount, 
MAX((total_cases/population))*100 as PopInfectionRate_per_country 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PopInfectionRate_per_country desc


-- Show countries with highest Death Rate per Population
Select location, MAX(CAST(total_deaths as int)) as HighestTotalDeathCount
From PortfolioProject..CovidDeaths
Where continent not like ''
Group by location
order by HighestTotalDeathCount desc


-- Show total death count per continent using location
-- Assuming that the Where-conditions accurate the result
Select location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent like ''
And location not in ('European Union', 'World', 'International')
Group by location
order by TotalDeathCount desc
-- Same result using directly the field continent
Select continent, SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent not like ''
Group by continent
order by TotalDeathCount desc


-- Break result by Continent
-- showing continents with the highest death count
select continent, MAX(CAST(total_deaths as int)) as HighestTotalDeathCount
From PortfolioProject..CovidDeaths
Where continent not like ''
Group by continent
order by HighestTotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as t_cases,  SUM(CAST(new_deaths as int)) as t_deaths, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent not like ''
order by 1,2


-- Looking at Vaccinations rate vs population 
-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, SumOfPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(float, vac.new_vaccinations) as new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.location Order by dea.location, dea.date) as SumOfPeopleVaccinated
	--(MAX(SumOfPeopleVaccinated)/dea.population) as VaccinationRate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent not like ''
--order by 2,3
)
Select *, (SumOfPeopleVaccinated/Population)*100 as PopVaccinationsRate From PopvsVac


-- Looking at Vaccinations rate vs population 
-- Order by Vaccinationrate per continnt per country
With PopvsVacc (Continent, Location, Population, SumOfPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.population,
	SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.location Order by dea.location) as SumOfPeopleVaccinated
	--(MAX(SumOfPeopleVaccinated)/dea.population) as VaccinationRate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent not like ''
--Order by 2,3
)
Select *, (MAX(SumOfPeopleVaccinated)/Population)*100 as PopVaccinationsRate From PopvsVacc
Group by continent, location, population, SumOfPeopleVaccinated
Order by continent, VaccinationsRate desc


-- Use Temp Table
Drop table if exists #PopVaccinated
Create table #PopVaccinated (
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
sumOfPeopleVaccinated numeric
)
Insert into #PopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(float, vac.new_vaccinations) as new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.location Order by dea.location, dea.date) as SumOfPeopleVaccinated
	--(MAX(SumOfPeopleVaccinated)/dea.population) as VaccinationRate
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent not like ''
--order by 2,3

Select *, (SumOfPeopleVaccinated/Population)*100 as PopVaccinationsRate From #PopVaccinated


-- Create view to store data for late visualizations
Create View PopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, CONVERT(float, vac.new_vaccinations) as new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.location Order by dea.location, dea.date) as SumOfPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent not like ''
--order by 2,3

Select * From PortfolioProject..PopVaccinated