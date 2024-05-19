select *
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
where continent is not null
order by 3,4

select *
from [PORTFOLIO PROJECT SQL]..CovidVaccinations$
order by 3,4
--select data that we want
select location,date,total_cases, new_cases, total_deaths, population
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
order by 1,2

--total cases vs total deaths
--show likelihood of people contract to covid in your country
 select location,date,total_cases, total_deaths, (total_cases/total_deaths)*100 as deathpercentage
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
where location like '%india%'
order by 1,2

--total cases vs population
--show what percentage of population got covid
select location,date,population, total_cases, (total_cases/population)*100 as deathpercentage
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
--where location like '%india%'
order by 1,2

--looking for country of highest infection compared to population
select location,population, max(total_cases) as highestinfectioncount,  max((total_cases/population))*100 as deathpercentage
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
--where location like '%india%'
group by location , population
order by deathpercentage desc

--countries with highest deathcount per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by totaldeathcount desc

--breaking it by continent
select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
select date,SUM(new_cases) as totalcases, sum(cast(total_deaths as int)) as totaldeaths, sum(cast(total_deaths as int))/sum(new_cases)*100 as deathpercentage
from [PORTFOLIO PROJECT SQL]..CovidDeaths$
where continent is not null
group by date
order by 1,2

--total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations )) 
over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinate
from [PORTFOLIO PROJECT SQL]..CovidDeaths$ dea
join [PORTFOLIO PROJECT SQL]..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order by 1,2

--using ctes
with popvsvac ( continent,location,date,population,new_vaccination, rollingpeoplevaccinate)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinate
from [PORTFOLIO PROJECT SQL]..CovidDeaths$ dea
join [PORTFOLIO PROJECT SQL]..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
)
select *
from popvsvac


--temp table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinate numeric
)
insert into #percentagepopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinate
from [PORTFOLIO PROJECT SQL]..CovidDeaths$ dea
join [PORTFOLIO PROJECT SQL]..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
select *
from #percentagepopulationvaccinated


--create view to store data

create view percentagepopulatevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinate
from [PORTFOLIO PROJECT SQL]..CovidDeaths$ dea
join [PORTFOLIO PROJECT SQL]..CovidVaccinations$ vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null

