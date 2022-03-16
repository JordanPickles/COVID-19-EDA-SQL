-- Viewing the covid deaths data
SELECT * 
FROM `Porfolio Project 1`.covid_deaths
ORDER BY 3,4;

-- Viewing the covid vaccinations data
SELECT * 
FROM `Porfolio Project 1`.covid_vaccinations
ORDER BY 3,4;

-- I have noticed that the date format in the two tables is different, dd,mm,yyyy in the covid_deaths and yyyy,mm,dd in the covid_vaccinations table, this should be used for the covid vaccinations when using joins
SELECT date, cast(date as DATE) as date_edited
FROM `Porfolio Project 1`.covid_deaths;

SELECT str_to_date(date, "%d/%m/%Y") as date
FROM `Porfolio Project 1`.covid_deaths;

-- Selecting the interesting data
SELECT location, date, population, new_cases, total_cases, total_deaths, population
FROM `Porfolio Project 1`.covid_deaths
ORDER BY 1,2;

-- Investigating the rate of cases to the deaths and shows the percentage chance of dying if you contract covid 
SELECT location, date, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `Porfolio Project 1`.covid_deaths
ORDER BY 1,2;


-- Looking at the percentage rates within the UK and shows the percentage chance of dying if you contract covid in the UK
SELECT location, date, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `Porfolio Project 1`.covid_deaths
WHERE location = 'United Kingdom'
ORDER BY 1,2;

-- Percentage of population that has contracted covid 19 in the united kingdom
SELECT location, date, population, total_cases, (total_cases/population)*100 as COVIDInfectionPercentage
FROM `Porfolio Project 1`.covid_deaths
WHERE location = 'United Kingdom'
ORDER BY 1,2;

-- Highest Percentages of COVID Infection Percentage 
SELECT location, max(total_cases) as HighestCases, max(total_cases/population)*100 as COVIDInfectionPercentage
FROM `Porfolio Project 1`.covid_deaths
GROUP BY location
ORDER BY COVIDInfectionPercentage desc;

-- Highest percentage of COVID Infection in the UK
SELECT location, max(total_cases) as HighestCases, max(total_cases/population)*100 as COVIDInfectionPercentage
FROM `Porfolio Project 1`.covid_deaths
WHERE location = 'United Kingdom'
ORDER BY COVIDInfectionPercentage desc;

-- Countries with the highest death count per population 
SELECT location, max(cast(total_deaths as UNSIGNED)) as HighestDeaths
FROM `Porfolio Project 1`.covid_deaths
GROUP BY location
ORDER BY HighestDeaths desc;

-- Countries with the highest death count per population
SELECT location, max(cast(total_deaths as UNSIGNED)) as HighestDeaths
FROM `Porfolio Project 1`.covid_deaths
WHERE location = 'United Kingdom' 
ORDER BY HighestDeaths desc;

-- Rates by continent
SELECT continent, max(total_cases) as HighestCases, max(total_cases/population)*100 as COVIDInfectionPercentage
FROM `Porfolio Project 1`.covid_deaths
GROUP BY continent
ORDER BY COVIDInfectionPercentage desc;

SELECT continent, max(cast(total_deaths as UNSIGNED)) as HighestDeaths
FROM `Porfolio Project 1`.covid_deaths
GROUP BY continent 
ORDER BY HighestDeaths desc;

-- Number of cases by date
SELECT date, SUM(new_cases), SUM(cast(new_deaths as UNSIGNED)), SUM(cast(new_deaths as UNSIGNED))/sum(new_cases)*100 as death_percentage
FROM `Porfolio Project 1`.covid_deaths
GROUP BY date;

-- Joining the vaccination data to the deaths table, note the change to the format of the date in the deaths table to ensure the identical format across tables and allow the join
SELECT str_to_date(`Porfolio Project 1`.covid_deaths.date, "%d/%m/%Y") as date, `Porfolio Project 1`.covid_deaths.location, `Porfolio Project 1`.covid_deaths.population, `Porfolio Project 1`.covid_vaccinations.new_vaccinations 
FROM `Porfolio Project 1`.covid_deaths 
JOIN `Porfolio Project 1`.covid_vaccinations 
	ON `Porfolio Project 1`.covid_deaths.location = `Porfolio Project 1`.covid_vaccinations.location
    and str_to_date(`Porfolio Project 1`.covid_deaths.date, "%d/%m/%Y") = `Porfolio Project 1`.covid_vaccinations.date;


-- Running count per country with a partition included to reset the count as the country changes
SELECT str_to_date(`Porfolio Project 1`.covid_deaths.date, "%d/%m/%Y") as date, `Porfolio Project 1`.covid_deaths.location, 
	`Porfolio Project 1`.covid_deaths.population, `Porfolio Project 1`.covid_vaccinations.new_vaccinations, 
    SUM(cast(`Porfolio Project 1`.covid_vaccinations.new_vaccinations as UNSIGNED)) OVER (partition by `Porfolio Project 1`.covid_deaths.location ORDER BY `Porfolio Project 1`.covid_deaths.location, `Porfolio Project 1`.covid_deaths.date) as rolling_vaccine_count
FROM `Porfolio Project 1`.covid_deaths 
JOIN `Porfolio Project 1`.covid_vaccinations 
	ON `Porfolio Project 1`.covid_deaths.location = `Porfolio Project 1`.covid_vaccinations.location
    and str_to_date(`Porfolio Project 1`.covid_deaths.date, "%d/%m/%Y") = `Porfolio Project 1`.covid_vaccinations.date;

-- Percentage of population fully vaccinated
SELECT `Porfolio Project 1`.covid_deaths.location, `Porfolio Project 1`.covid_deaths.population, `Porfolio Project 1`.covid_vaccinations.people_fully_vaccinated, 
    SUM(cast(`Porfolio Project 1`.covid_vaccinations.people_fully_vaccinated as UNSIGNED)/cast(`Porfolio Project 1`.covid_deaths.population as UNSIGNED))*100 as percentage_vaccinated
FROM `Porfolio Project 1`.covid_deaths
JOIN `Porfolio Project 1`.covid_vaccinations 
	ON `Porfolio Project 1`.covid_deaths.location = `Porfolio Project 1`.covid_vaccinations.location
GROUP BY `Porfolio Project 1`.covid_deaths.location, `Porfolio Project 1`.covid_deaths.population, `Porfolio Project 1`.covid_vaccinations.people_fully_vaccinated
ORDER BY percentage_vaccinated desc;
