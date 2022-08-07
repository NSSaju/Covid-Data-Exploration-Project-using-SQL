Select *
from Portfolio .. CovidDeaths
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from Portfolio .. CovidDeaths
order by 1,2

--Percentage of people dying
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from Portfolio .. CovidDeaths
where location like '%en%'
order by 1,2

--Percentage of people having covid
Select  location, date, population, total_cases, (total_cases/population)*100 as popPercentage
from Portfolio .. CovidDeaths
where location like 'in%'
order by 1,2


--Highest Infection
Select location, population, MAX(total_cases) as HighestInfec, MAX((total_cases/population))*100 as HighestInfecPere
from Portfolio..CovidDeaths
group by location, population
order by HighestInfecPere desc

--Highest Death
Select location, Max(cast(total_deaths as int)) as Totaldeaths  
from Portfolio..CovidDeaths
where continent is not null
group by location
order by Totaldeaths desc

--Death in Continent
Select location, MAx(cast(total_deaths as int)) as Totaldeaths
from Portfolio.. CovidDeaths
where continent is null
group by location
order by Totaldeaths desc


--Deaths and cases a/c to date
select date, Sum(new_cases) as Cases, sum(cast(new_deaths as int)) as Deaths, sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage
from Portfolio..CovidDeaths
where continent is not null
group by date
order by 1

 
 --TOTAL POPULATION THAT GOT VACCINATED
 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
 from Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 --Percentage of people vaccinated
 With popVacc (Continent, Location, Date, population, New_vaccinations, PeopleVaccinated) as 
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
 from Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 
 )
 Select *, (PeopleVaccinated/population)*100
 from popVacc
 where Location like '%dia'


 --Temp Table (2nd way)
 drop table if exists #PercentPopVacc
 create table #PercentPopVacc 
 (continent nvarchar (255),
 location nvarchar (255),
 date datetime,
 population numeric,
 newVacc numeric,
 PeopleVaccinated numeric)

 insert into #PercentPopVacc
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
 from Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 
 
 Select *, (PeopleVaccinated/population)*100
 from #PercentPopVacc
 where Location like '%dia'

 --Creating View for visualization
CREATE VIEW PerPopVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
 from Portfolio..CovidDeaths dea
 join Portfolio..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 
 
 Select *
 from PerPopVacc
