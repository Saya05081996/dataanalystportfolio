--first query
select * from [Portfolio Project]..CovidDeaths
where iso_code = 'ABW'
order by 1,3 desc;




--select * from [Portfolio Project]..[Covid-vaccinations]
--order by 3,4;

--select date that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths;




--percentage of total cases vs total deaths
-- this shows the percentage of covid deaths based on the location
select location, date, total_cases, total_deaths, 
round((try_convert(float,total_deaths)/try_convert(float,total_cases))*100,3) as percent_of_deaths
from [Portfolio Project]..CovidDeaths
where location like '%states%';




--percentage of total cases vs the popualtion
-- this shows the percentage of contracting covid based on the location
select location, date, total_cases, total_deaths, round((total_cases/population)*100,3) as percent_of_cases
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
order by 1,2;




--Countries with highest infection rate compared to population 
select location, population, Max(cast(total_cases as int)) as highest_cases,
Max((total_cases)/cast(population as float))*100 as case_percentage
from [Portfolio Project]..CovidDeaths
--where location = 'Andorra'
where continent is not null
group by location, population
order by highest_cases desc;




--breakdown by continent 
select continent, max(cast(total_cases as int)) as highest_cases
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by highest_cases desc;




--Global numbers 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0) * 100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2;


--Global numbers 
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0) * 100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2;


--Global numbers (total cases and total deaths)
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/nullif(sum(new_cases),0) * 100 as death_percentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1;




--total population and total vaccination 
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from [Portfolio Project]..CovidDeaths as d
join [Portfolio Project]..[Covid-vaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null and d.location = 'Canada'
order by 2,3;




--with window functions
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_vaccinations
from [Portfolio Project]..CovidDeaths as d
join [Portfolio Project]..[Covid-vaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null and d.location = 'Canada'
order by 2,3;




-- Using CTE

With popvsvac(Continent, location, date, Population, New_vaccinations, rolling_vaccinations)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as rolling_vaccinations
from [Portfolio Project]..CovidDeaths as d
join [Portfolio Project]..[Covid-vaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null and d.location = 'Canada'
--order by 2,3
)
select *, (rolling_vaccinations/Population)*100 as total_vaccine_percentage
from popvsvac



--Temp table

drop table if exists #percentpeoplevaccinated
create table #percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
rolling_vaccinations numeric
)
Insert into #percentpeoplevaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rolling_vaccinations
from [Portfolio Project]..CovidDeaths as d
join [Portfolio Project]..[Covid-vaccinations] as v 
on d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2,3
select *, (rolling_vaccinations/Population)*100
from #percentpeoplevaccinated



--create view
create view vaccination_and_percentage as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as rolling_vaccinations
from [Portfolio Project]..CovidDeaths as d
join [Portfolio Project]..[Covid-vaccinations] as v 
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3


--QUERY 2 
select location, sum(cast(new_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like %states%
where continent is null
and location not in ('World','European Union', 'International','Low income','High income','Upper middle income','Lower middle income')
group by location
order by TotalDeathCount desc;


--QUERY 3
select Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by location,Population 
order by PercentPopulationInfected desc;


--QUERY 4
select Location, Population, cast(date as DATE) as date_only, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
group by location,population,date
order by PercentPopulationInfected desc;


--QUERY 5
WITH cte AS (
    SELECT
        Location,
        Population,
        MAX(TRY_CONVERT(INT, total_cases)) AS HighestInfectionCount,
        MAX((TRY_CONVERT(INT, total_cases) * 100.0) / TRY_CONVERT(INT, Population)) AS PercentPopulationInfected
    FROM
        [Portfolio Project]..CovidDeaths
    GROUP BY
        Location,
        Population
)
SELECT
    Location,
    Population,
    HighestInfectionCount,
    PercentPopulationInfected
FROM
    cte
	order by PercentPopulationInfected desc;


--where location like '%states%'
--group by location,population,date
--order by PercentPopulationInfected desc;
