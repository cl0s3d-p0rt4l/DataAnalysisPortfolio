/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Choosing Data for further inspections

Select *
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
order by 3,4

-- Selecting more specicifed group of Data 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProjectTutorial..CovidDeaths
Where location like '%Turkey%'
and continent is not null
order by 1,2

-- Total Cases vs Population

Select Location, date, Population, total_cases, (total_cases/population)*100 as Infected_Population_Percentage
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
and location like '%Turkey%'
order by 1,2

-- Highest Infection Rate compared to population for all countries

Select Location, population, max(total_cases) as HighestInfactionCount, max((total_cases/population))*100 as Infected_Population_Percentage
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
Group by Location, population
order by Infected_Population_Percentage desc

-- Countries with Highest Death Count per Population

Select Location, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
Group by location
order by Total_Death_Count desc

-- Similar operations for continents this time

Select continent, max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
Group by continent
order by Total_Death_Count desc

-- Data of Global Numbers

Select continent, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProjectTutorial..CovidDeaths
Where continent is not null
Group by continent
order by Death_Percentage desc

-- Total Population vs Vaccinations (for Turkey)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProjectTutorial..CovidDeaths dea
Join PortfolioProjectTutorial..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
and vac.location like '%Turkey%'
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProjectTutorial..CovidDeaths dea
Join PortfolioProjectTutorial..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #Vaccinated_Population_Percantage
Create Table #Vaccinated_Population_Percantage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

Insert into #Vaccinated_Population_Percantage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProjectTutorial..CovidDeaths dea
Join PortfolioProjectTutorial..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date

Select *, (Rolling_People_Vaccinated/Population)*100
From #Vaccinated_Population_Percantage

-- Creating View to store data for later visualizations

Create View Vaccinated_Population_Percentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProjectTutorial..CovidDeaths dea
Join PortfolioProjectTutorial..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null



