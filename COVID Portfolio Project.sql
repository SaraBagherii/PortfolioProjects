select * from PortfolioProject..CovidDeaths
order by 3,4


--select * from PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data that we are going to be useing

select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country


select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%Romania'
order by 1,2



--Looking at Total Cases vs Population
--Show what percentage of population got Covid

select Location, date, total_cases,Population, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
order by 1,2


--Looking at countries with Highest Infection Rate compare to Population

select Location,Population, max(total_cases) as HighestInfectionCount, max(total_cases/Population)*100 as
PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
Group by Location, Population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count per Population 


select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
where continent is not null
Group by Location

order by TotalDeathCount desc


--Let's Break Things Down by  Continent


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Showing continent whith the Hiest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
where continent is not null
--group by date  
order by 1,2


select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where Location like '%Romania'
where continent is not null
group by date
order by 1,2


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPeopleVaccinated


-- Creating view to store data for later visualizations

create view PercentPeopleVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location=vac.location
	  and dea.date=vac.date
where dea.continent is not null
-- order by 2,3

select * 
from PercentPeopleVaccinated