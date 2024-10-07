-- Creating indexes
create clustered index IX_COVIDDEATHS_DEPARTMENT
on CovidDeaths$ (location)

create NONclustered index IX_COVIDDEATHS_date
on CovidDeaths$ (date)

create NONclustered index IX_COVIDDEATHS_continent
on CovidDeaths$ (continent)

create clustered index IX_CovidVaccinations$_DEPARTMENT
on CovidVaccinations$ (location)

create NONclustered index IX_CovidVaccinations$_date
on CovidVaccinations$ (date)
-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country at a certain point in time
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location = 'Yemen'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- Shows the percentage of population that got infected with covid at a certain point in time
Select location, date,  population,total_cases, (total_cases/population)*100 as InfectionPercentage
from CovidDeaths$
where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to population in total
Select location, population,max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as InfectionPercentage
from CovidDeaths$
where continent is not null
group by location, population
order by InfectionPercentage desc

-- Showing countries with highest death count at the end
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Continents
-- queries cannot be done with continents because the data is not clean (if it was clean, we would replace location with continent and that's it)

-- Global
-- Shows likelihood of dying if you contract covid globally at a certain point in time
Select date, sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2

-- In Total
Select  sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
order by 1,2

--Using sum(new_(cases or deaths)) instead of total_(cases or deaths) because total already is cumulative so will mix up numbers
Select date,sum(total_cases), sum(cast(total_deaths as int)), (sum(cast(total_deaths as int))/sum(total_cases))*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccinations at a certain point in time
-- Use CTE because can't use aggregate function column in main query
WITH PopsvsVAC 
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as total_vaccinations
from CovidDeaths$ dea join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (total_vaccinations/population)*100
from PopsvsVAC

-- Use Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from CovidDeaths$ dea join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

--Create a view 
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from CovidDeaths$ dea join CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated