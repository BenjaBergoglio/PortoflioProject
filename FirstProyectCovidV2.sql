select*
from FirstPorfolioProject..CovidDeaths
where len(continent)>0 
order by 3,4


--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from FirstPorfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from FirstPorfolioProject..CovidDeaths
where location like 'argentina'
order by 1,2


--Looking at total cases vs population
-- show what percentage of population got Covid in Argentina

select location, date, population, total_cases,(total_cases/population)*100 as CasesPercentage
from FirstPorfolioProject..CovidDeaths
where location like 'argentina'
where len(continent)>0 
order by 1,2


--Looking at countries with Highest infecction rates compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as MaxCasesPercentage
from FirstPorfolioProject..CovidDeaths
where len(continent)>0 
group by location, population
order by MaxCasesPercentage DESC

--Showing countries with Highest Death Count Population

select location, MAX(cast(total_deaths as int)) as HighestDeathsCount,MAX((total_deaths/total_cases))*100 as MaxCasesPercentage
from FirstPorfolioProject..CovidDeaths
where len(continent)>0 
group by continent, population, location
order by HighestDeathsCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population


select continent, MAX(cast(total_deaths as bigint)) as DeathsCount
from FirstPorfolioProject..CovidDeaths
where len(continent)>0 
group by continent
order by DeathsCount DESC


--error

select location, MAX(cast(total_deaths as int)) as DeathsCount
from FirstPorfolioProject..CovidDeaths
where continent =''
group by location
order by DeathsCount DESC


--Global numbers

select sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from FirstPorfolioProject..CovidDeaths
where continent <>''
order by 1,2 


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From FirstPorfolioProject..CovidDeaths
where continent =''
and location not in ('World','European Union', 'Upper middle income','High income','Lower middle income', 'International','Low income')
Group by location
order by TotalDeathCount desc



Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From FirstPorfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc


select date, sum(new_cases) as total_cases,SUM(cast(new_deaths as bigint)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from FirstPorfolioProject..CovidDeaths
where continent <>''
group by date
order by 1,2


--Looking at total population 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) AS RollingpeopleVaccinated
from FirstPorfolioProject..CovidDeaths dea
join FirstPorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent <>''
order by 2,3


--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) AS RollingpeopleVaccinated
from FirstPorfolioProject..CovidDeaths dea
join FirstPorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent <>''
)

SELECT *, ((RollingpeopleVaccinated/population)*100) as Porcentage
FROM PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) AS RollingpeopleVaccinated
from FirstPorfolioProject..CovidDeaths dea
join FirstPorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent <>''

SELECT *, (RollingpeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS


drop view if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) AS RollingpeopleVaccinated
from FirstPorfolioProject..CovidDeaths dea
join FirstPorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''


select *
from PercentPopulationVaccinated
