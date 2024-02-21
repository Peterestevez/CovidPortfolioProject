SELECT *
FROM [dbo].[coviddeaths$]
ORDER BY 3,4

--SELECT *
--FROM [dbo].[covidvaccination]
--ORDER BY 3,4

select location,date,total_cases,new_cases,total_deaths,population
from[dbo].[coviddeaths$]
order by 1,2

--Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths (total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[coviddeaths$]
where location like '%states%'
order by 1,2

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE
        WHEN TRY_CAST(total_cases AS DECIMAL(18, 2)) > 0 THEN 
            (TRY_CAST(total_deaths AS DECIMAL(18, 2)) / TRY_CAST(total_cases AS DECIMAL(18, 2))) * 100
        ELSE 
            NULL
    END AS DeathPercentage
FROM 
    [dbo].[coviddeaths$]
WHERE 
    location LIKE '%states%'
ORDER BY 
    1, 2;

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths * 100.0 / NULLIF(total_cases, 0)) AS DeathPercentage
FROM 
    [dbo].[coviddeaths$]
WHERE 
    location LIKE '%states%'
ORDER BY 
    1, 2;

	--what percentage of the population got covid

	SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
  population,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) <> 0 THEN 
            (TRY_CAST(total_cases AS FLOAT) / TRY_CAST(population AS FLOAT)) * 100
        ELSE 
            NULL
    END AS PercentageOfPopulationWithCovid
FROM 
    [dbo].[coviddeaths$]
WHERE 
    location LIKE '%states%'
ORDER BY 
    1, 2;

	--Daily Death Rate Trend?
	
	SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    LAG(total_deaths) OVER (PARTITION BY location ORDER BY date) AS PreviousDayDeaths,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) <> 0 THEN 
            (TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(population AS FLOAT)) * 100
        ELSE 
            NULL
    END AS DeathPercentage,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) IS NOT NULL AND TRY_CAST(population AS FLOAT) <> 0 THEN 
            ((TRY_CAST(total_deaths AS FLOAT) - LAG(total_deaths) OVER (PARTITION BY location ORDER BY date)) / TRY_CAST(population AS FLOAT)) * 100
        ELSE 
            NULL
    END AS DailyDeathRateChange
FROM 
    [dbo].[coviddeaths$]
WHERE 
    location LIKE '%states%'
ORDER BY 
    location, date;

	 --Locations with Highest Total Deaths
SELECT 
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM 
    [dbo].[coviddeaths$]
WHERE 
    continent IS NOT NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathsCount DESC;
	
	
	--highest total deaths by continent

SELECT 
    continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM 
    [dbo].[coviddeaths$]
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
order by TotalDeathsCount DESC;
    
--global death and cases
SELECT 
    'Global' AS location,
    MAX(CAST(total_cases AS INT)) AS GlobalTotalCases,
    MAX(CAST(total_deaths AS INT)) AS GlobalTotalDeaths
FROM 
    [dbo].[coviddeaths$];

	---and percentage
	SELECT 
    'Global' AS location,
    MAX(CAST(total_cases AS INT)) AS GlobalTotalCases,
    MAX(CAST(total_deaths AS INT)) AS GlobalTotalDeaths,
    MAX((CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100) AS GlobalDeathPercentage
FROM 
    [dbo].[coviddeaths$];


SELECT 
    SUM(CAST(new_cases AS BIGINT)) AS TotalCases,
    SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths,
    (SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0)) * 100 AS DeathPercentage
FROM 
    [dbo].[coviddeaths$]
WHERE 
    continent IS NOT NULL
ORDER BY 
    TotalCases, TotalDeaths;

	--view vaccination
	SELECT 
    dea.continent,
    dea.location,
    dea.population,
    vac.new_vaccinations
FROM 
    [dbo].[coviddeaths$] dea
JOIN 
    [dbo].[covidvaccination] vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
    AND vac.new_vaccinations is not null
ORDER BY 
    vac.new_vaccinations desc

	--Total Cases and Deaths by Location
SELECT 
    location,
    SUM(ISNULL(TRY_CAST(total_cases AS BIGINT), 0)) AS TotalCases,
    SUM(ISNULL(TRY_CAST(total_deaths AS BIGINT), 0)) AS TotalDeaths
FROM 
    [dbo].[coviddeaths$]
GROUP BY 
    location
ORDER BY 
    TotalCases DESC;


	SELECT 
    location,
    SUM(ISNULL(TRY_CAST(total_cases AS BIGINT), 0)) AS TotalCases,
    SUM(ISNULL(TRY_CAST(total_deaths AS BIGINT), 0)) AS TotalDeaths
FROM 
    [dbo].[coviddeaths$]
WHERE
    location IN ('united states')
GROUP BY 
    location
ORDER BY 
    TotalCases DESC;