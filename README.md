# Energy Consumption & Emission Analysis (SQL Project)

## 📌 Project Overview
This project focuses on analyzing global energy consumption, energy production, CO₂ emissions, GDP, and population trends using SQL.

The primary goal is to understand how economic growth, industrialization, and population influence carbon emissions and energy usage across countries.

The project uses MySQL 8+, advanced SQL concepts, and relational database design to generate meaningful analytical insights from multiple interconnected datasets.

---

# 🎯 Business Problem
With increasing global energy demand and rising carbon emissions, governments and organizations face challenges in balancing:

- Economic Growth
- Energy Demand
- Environmental Sustainability

Decision-makers often lack integrated analysis connecting:
- Energy Consumption
- Energy Production
- CO₂ Emissions
- GDP
- Population

This project provides a structured SQL-based analytical solution to identify:
- High-emission economies
- Energy dependency patterns
- Carbon intensity
- Per-capita energy trends
- Global sustainability insights

---

# 🗂️ Database Structure

The project contains 6 relational tables:

| Table Name | Description |
|------------|-------------|
| Country | Master table containing unique country identifiers |
| Emission_3 | CO₂ emissions by country, year, and energy type |
| Consumption | Energy consumption data by country and year |
| Production | Energy production data by country and year |
| GDP_3 | Yearly GDP data |
| Population | Yearly population statistics |

### 🔗 Relationships
- All tables are connected using the Country column.
- Time-based analysis is performed using the Year column.

---

# 🛠️ Tools & Technologies

- MySQL 8+
- SQL
- Relational Database Design
- CTEs (Common Table Expressions)
- Window Functions
- Aggregate Functions
- Joins & Subqueries

---

# 📊 Key Analytical Areas

## 1. General & Comparative Analysis
- Total emissions per country
- Top GDP countries
- Production vs Consumption comparison
- Highest emission-generating energy types

## 2. Trend Analysis
- Year-over-year global emission trends
- GDP growth trends
- Population vs emission trends
- Per-capita emission changes

## 3. Ratio & Per-Capita Analysis
- Emission-to-GDP ratio
- Energy consumption per capita
- Production per capita
- Energy intensity metrics

## 4. Global Comparisons
- Top countries by emissions and population
- Global emission share
- GDP vs energy production growth correlation
- Worldwide average trends

---

# 📈 SQL Concepts Used

## ✅ Joins

```sql
SELECT c.Country, g.year, g.gdp, p.population
FROM GDP_3 g
JOIN Population p
ON g.country = p.country
AND g.year = p.year;
