-- select needed columns

select location, date,continent , total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent is not null
order by 1, 2;

--change column datatype

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Precentage
from Portfolio..CovidDeaths
where continent is not null
order by 1, 2;

-- use filtering
-- show likelihood of death if you get infected with covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Precentage
from Portfolio..CovidDeaths
where location like '%states%'
order by 1, 2;

-- looking at total cases vs population
-- with 2 floating points

select location, date, population, total_cases, round((total_cases/population)*100, 2) as Cases_Precentage
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1, 2;

--without floating points

select location, date, population, total_cases, (total_cases/population)*100 as Cases_Precentage
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1, 2;

--countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionNumber, max((total_cases/population))*100 as HighestCasesPrecentage
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by HighestCasesPrecentage DESC

-- countries with highest death count compared to population

select location, population, Max(total_deaths) as HighestDeathNumber, max((total_deaths/population))*100 as HighestDeathPrecentage
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by HighestDeathPrecentage DESC

select location, population, Max(total_deaths) as HighestDeathNumber
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by population DESC

--continent with highest death count 

select continent, Max(total_deaths) as HighestDeathNumber
from Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by HighestDeathNumber DESC

--global numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 as Death_Precentage
from Portfolio..CovidDeaths
where continent is not null
group by date
order by 1, 2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/SUM(new_cases))*100 as DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 as Death_Precentage
from Portfolio..CovidDeaths
where continent is not null
--group by date
order by 1, 2;

--looking at total Population vs Vaccinations


select cd.location,cd.date, cd.continent, cd.population, cv.new_vaccinations
,SUM(cv.new_vaccinations) over	(partition by cd.location order by cd.location, cd.date)
as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd 
join Portfolio..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
order by 2, 3

-- use CTE

with PopvsVac (location, date, continent, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.location,cd.date, cd.continent, cd.population, cv.new_vaccinations
,SUM(cv.new_vaccinations) over	(partition by cd.location order by cd.location, cd.date)
as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd 
join Portfolio..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
--order by 2, 3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date nvarchar(50),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.location,cd.date, cd.continent, cd.population, cv.new_vaccinations
,SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date)
as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd 
join Portfolio..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
-- cd.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- create view to store data for later vizualizations

create view PercentPopulationVaccinated as
select cd.location,cd.date, cd.continent, cd.population, cv.new_vaccinations
,SUM(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date)
as RollingPeopleVaccinated
from Portfolio..CovidDeaths cd 
join Portfolio..CovidVaccinations cv
	on cd.location = cv.location 
	and cd.date = cv.date
where cd.continent is not null
--order by 2, 3

select* 
from PercentPopulationVaccinated
