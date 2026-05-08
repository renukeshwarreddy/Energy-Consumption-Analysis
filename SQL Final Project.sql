CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;


-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;

ALTER TABLE population
CHANGE countries country VARCHAR(100);

-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

# Validation Of Tables

select distinct country
from emission_3
where country not in (select Country from country);

select distinct country
from population
where country not in (select Country from country);

select distinct country
from production 
where country not in (select Country from country);

select distinct country
from gdp_3
where country not in (select Country from country);

select distinct country
from consumption
where country not in (select Country from country);



#  General & Comparative Analysis

# 1) What is the total emission per country for the most recent year available?

select country,sum(emission) as Total_emission 
from emission_3 
where year = (select max(year) from emission_3)
group by country
order by Total_emission  desc;


# 2) What are the top 5 countries by GDP in the most recent year?

select country,year,value as GDP 
from gdp_3
where year = (select max(year) from gdp_3)
order by GDP desc
limit 5;


# 3) Compare energy production and consumption by country and year. 

select p.country,p.year,
sum(p.production) as total_production,sum(c.consumption) as total_consumption
from production p
join consumption c
on p.country=c.country
and p.year=c.year
group by p.country,p.year
order by p.country,p.year;


# 4) Which energy types contribute most to emissions across all countries?

select energy_type,sum(emission) as total_emission, 
sum(emission)*100/(select sum(emission) from emission_3) as contribution_percent
from emission_3
group by energy_type
order by total_emission desc;


# Trend Analysis Over Time

# 5) How have global emissions changed year over year?

select year,sum(emission) as total_emission,
sum(emission)-lag(sum(emission)) over (order by year) as yearly_change
from emission_3
group by year
order by year;


# 6) What is the trend in GDP for each country over the given years?

select country,year,value as gdp,
 value -lag(value) OVER (PARTITION BY country ORDER BY year) AS gdp_change
from gdp_3;


# 7) How has population growth affected total emissions in each country?

select p.country,p.year,p.value as population,
sum(e.emission) as total_emission
from population p
inner join emission_3 e
on p.country = e.country
and p.year = e.year
group by p.country, p.year, p.value
order by p.country, p.year;

# 8) Has energy consumption increased or decreased over the years for major economies?

with top_gdp as (
select country from gdp_3
where year = (select max(year) from gdp_3)
order by value desc
limit 5)
select c.country,c.year,sum(c.consumption)as total_consumption
from consumption c
 join top_gdp t
on c.country=t.country
group by c.country,c.year
order by c.country,c.year;


# 9) What is the average yearly change in emissions per capita for each country?

WITH total_emission AS (
    SELECT
        country,
        year,
        SUM(emission) AS total_emission
    FROM emission_3
    GROUP BY country, year
),

per_capita AS (
    SELECT
        e.country,
        e.year,
        e.total_emission / p.value AS pc_emission
    FROM total_emission e
    JOIN population p
        ON e.country = p.country
       AND e.year = p.year
),

changes AS (
    SELECT
        country,
        year,
        pc_emission -
        LAG(pc_emission) OVER (PARTITION BY country ORDER BY year) AS yearly_change
    FROM per_capita
)

SELECT
    country,
    ROUND(AVG(yearly_change),4) AS avg_yearly_change_per_capita
FROM changes
WHERE yearly_change IS NOT NULL
GROUP BY country
ORDER BY avg_yearly_change_per_capita DESC;



# Ratio & Per Capita Analysis

# 10) What is the emission-to-GDP ratio for each country by year?

select e.country,e.year,
sum(e.emission)/g.value as  emission_gdp_ratio
from emission_3 e 
join gdp_3 g
on e.country=g.country
and e.year=g.year
group by e.country,e.year,g.value
order by e.country,e.year;


# 11) What is the energy consumption per capita for each country over the last decade?

select c.country,c.year,sum(c.consumption) as total_consumption,p.value as population,
sum(c.consumption)/p.value as energy_consumption_per_capita
from consumption c 
join population p
on c.country=p.country 
and c.year=p.year
WHERE c.year >= (select max(year) - 9 from consumption)
group by c.country,c.year,p.value
order by c.country,c.year;


# 12) How does energy production per capita vary across countries?

select p.country,p.year,sum(p.production) as total_production,po.value as population,
sum(p.production)/po.value as energy_production_per_capita
from production p
join population po
on p.country=po.country
and p.year=po.year
group by p.country,p.year,po.value
order by p.country,p.year;


# 13) Which countries have the highest energy consumption relative to GDP?

select c.country,c.year,
sum(c.consumption)/sum(g.value) as energy_consumption_gdp_ratio
from consumption c
join gdp_3 g 
on c.country=g.country
and c.year=g.year
group by c.country,c.year
order by energy_consumption_gdp_ratio desc;


# 14) What is the correlation between GDP growth and energy production growth?

WITH gdp_growth AS (
    SELECT country,year,
        value - LAG(value) OVER (PARTITION BY country ORDER BY year) AS gdp_growth
    FROM gdp_3
),

production_yearly AS (
    SELECT country,year,
        SUM(production) AS total_production
    FROM production
    GROUP BY country, year
),

production_growth AS (
    SELECT country,year,
        total_production -LAG(total_production) OVER (PARTITION BY country ORDER BY year) AS prod_growth
    FROM production_yearly
),

combined AS (
    SELECT g.country,g.year,g.gdp_growth,p.prod_growth,
        AVG(g.gdp_growth) OVER (PARTITION BY g.country) AS avg_gdp_growth,
        AVG(p.prod_growth) OVER (PARTITION BY p.country) AS avg_prod_growth
    FROM gdp_growth g
    JOIN production_growth p
         ON g.country = p.country
        AND g.year = p.year
    WHERE g.gdp_growth IS NOT NULL
      AND p.prod_growth IS NOT NULL
)

SELECT
    country,
    ROUND(
        SUM((gdp_growth - avg_gdp_growth) * (prod_growth - avg_prod_growth)) /
        SQRT(
        SUM(POW(gdp_growth - avg_gdp_growth, 2)) *
            SUM(POW(prod_growth - avg_prod_growth, 2))),4) AS gdp_production_correlation
FROM combined
GROUP BY country
HAVING gdp_production_correlation IS NOT NULL
ORDER BY gdp_production_correlation DESC;


#  Global Comparisons

 
# 15) What are the top 10 countries by population and how do their emissions compare?

select p.country,p.value as population, sum(e.emission) as total_emission
from population p 
left join emission_3 e
on p.country=e.country
and p.year=e.year
where p.year = (select max(year)-1 from population)
group by p.country,p.value
order by population desc
limit 10;



# 16) Which countries have improved (reduced) their per capita emissions the most over the last decade?


WITH yearly_pc AS (
    SELECT e.country,e.year,
	SUM(e.emission) / p.value AS per_capita_calc
    FROM emission_3 e
    JOIN population p
	ON e.country = p.country
	AND e.year = p.year
    GROUP BY e.country, e.year, p.value
),
changes AS (
    SELECT country,year,
	per_capita_calc -LAG(per_capita_calc) OVER (PARTITION BY country ORDER BY year) AS yearly_change
    FROM yearly_pc
)

SELECT country,
SUM(yearly_change) AS total_emission_change
FROM changes
WHERE yearly_change IS NOT NULL
GROUP BY country
ORDER BY total_emission_change;


# 17) What is the global share (%) of emissions by country?

select country,sum(emission) as total_emissions,
round(sum(emission) *100/(select sum(emission) from emission_3),2) as global_share
from emission_3 
group by country
order by global_share desc;

# 18) What is the global average GDP, emission, and population by year?

with global_data as (
select g.country,g.year,g.value AS gdp,e.emission,p.value AS population
from gdp_3 g
join emission_3 e 
on g.country=e.country
and g.year=e.year
join population p 
on g.country=p.country
and g.year=p.year)

select year,round(avg(gdp),3) as avg_gdp,round(avg(emission),3) as avg_emission, round(avg(population),3) as avg_population
from global_data
group by year;