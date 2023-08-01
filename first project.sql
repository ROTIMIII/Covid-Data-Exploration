select *
from PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--select data that we are using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as death_percentage
from PortfolioProject.dbo.CovidDeaths
where location = 'United States'
AND continent is not NULL
order by 1,2


--total cases vs population
--% of population that got covid
select location, date, total_cases, population, (total_cases/population)* 100 as population_percentage
from PortfolioProject.dbo.CovidDeaths
where location = 'United States'
AND continent is not NULL
order by 1,2


--countries with highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infectrion_count, MAX((total_cases/population))* 100 as population_infected_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY location, population
order by 4 desc


--continent with highest infection rate compared to population
select continent, population, MAX(total_cases) as highest_infectrion_count, MAX((total_cases/population))* 100 as population_infected_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
GROUP BY continent, population
order by 4 desc

--contries with highest death count per population
select location, MAX(cast(total_deaths as int)) as highest_death_count, population, MAX((total_deaths/population))* 100 as population_infected_percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
GROUP BY location, population
order by 2 desc

--continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as highest_death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
GROUP BY continent
order by 2 desc


--global numbers
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentages
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
order by 1,2

--global number by date
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentages
from PortfolioProject.dbo.CovidDeaths
where continent is not NULL
GROUP BY date
order by 1,2

--total population vs vaccinations

With PopvsVac 
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_vaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select continent, location, date, population, new_vaccinations, running_total_vaccinations, (running_total_vaccinations/population)*100
from PopvsVac



--temp_table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
running_total_vaccinations numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_vaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date

select continent, location, date, population, new_vaccinations, running_total_vaccinations, (running_total_vaccinations/population)*100
from #percentpopulationvaccinated


--creating view for later visualizations
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as running_total_vaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from percentpopulationvaccinated