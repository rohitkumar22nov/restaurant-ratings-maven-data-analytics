# Restaurant Ratings by Maven — Data Analytics Project

An end-to-end analysis of what drives top guest ratings at restaurants in Mexico, built across three layers — **Excel, SQL, and Power BI** — using the Restaurant Ratings dataset from Maven Analytics.

---

## 📊 Project Overview

This project investigates what actually drives a restaurant's overall guest rating — food quality, service, price, parking, smoking policy, alcohol service, and consumer demographics — and turns those findings into concrete business recommendations.

The project was planned and built as a deliberate 3-layer pipeline:
1. **Excel** — first-pass exploratory analysis using Power Query and Power Pivot
2. **SQL (T-SQL)** — full data cleaning, relational schema design, and rigorous EDA
3. **Power BI** — an interactive report and DAX-driven data model


Technical Layer	Primary Tool	Core Components & Functions
Layer 1	Excel	Power Query, Power Pivot data modeling, and first-pass exploratory PivotTables.
Layer 2	SQL Server (T-SQL)	Data cleaning, window functions for deduplication, relational schema setup, and CTE analytics.
Layer 3	Power BI	DAX measures, bidirectional filter modeling, and 4-page interactive reporting.


An early Excel-only version of this project was shared on LinkedIn, where Maven Analytics engaged with the post and asked whether the complete project would be published to a Maven portfolio. This repository is that complete, end-to-end version — spanning all three layers, with every number independently cross-validated against the raw source data.

---

## 🗂️ Repository Structure

```
restaurant-ratings-maven-data-analytics/
├── README.md
├── data/                     # Raw CSVs + data dictionary
├── excel/                    # Excel workbook (Power Query, Power Pivot, initial EDA)
├── sql/                      # Full SQL script (cleaning, schema, EDA)
├── power bi/                 # Interactive Power BI report (.pbix)
├── reports/                  # Final PDF report: hypothesis testing, findings & recommendations
├── schema-diagrams/          # Database schema/relationship diagrams (Excel, SQL, Power BI)
└── screenshots/              # Sample Power BI report page preview
```

---

## 📁 Dataset

Raw data lives in [`data/`](./data), covering five tables: `consumers`, `consumer_preferences`, `ratings`, `restaurants`, and `restaurant_cuisines`. Column-level definitions for every field are documented in [`data/data_dictionary.csv`](./data/data_dictionary.csv).

---

## 🗄️ Database Schema & Relationships

The same relational structure — `restaurants` ↔ `ratings` ↔ `consumers`, `restaurants` → `restaurant_cuisines`, `consumers` → `consumer_preferences` — was independently modeled in all three layers, shown below:

**Excel (Power Pivot Diagram View)**
![Excel Schema](./schema-diagrams/DB_Schema_Relationship_Restaurant_Ratings_Excel.PNG)

**SQL Server (ER Diagram)**
![SQL Schema](./schema-diagrams/DB_Schema_Relationship_Restaurant_Ratings_SQL.PNG)

**Power BI (Model View)**
![Power BI Schema](./schema-diagrams/DB_Schema_Relationship_Restaurant_Ratings_Power_BI.PNG)

> Note: in Power BI, the `consumers`–`ratings` and `consumers`–`consumer_preferences` relationships were deliberately set to **bidirectional** filtering (rather than using `CROSSFILTER()` in DAX) as a hands-on exploration of model-level vs. measure-level filter propagation.

---

## 1️⃣ Layer 1 — Excel

**File:** [`excel/Restaurant_Project.xlsx`](./excel)

- Imported all five source tables via **Power Query**
- Built the data model and table relationships in **Power Pivot**
- Produced first-pass PivotTables for rating distribution by smoking policy, alcohol service, price, parking, and cuisine preference
- Served as the initial exploratory pass, later validated (and in one case, corrected — see Hypothesis #6 below) against the more rigorous SQL/Power BI layers

---

## 2️⃣ Layer 2 — SQL

**File:** [`sql/Restaurant_Ratings_Maven.sql`](./sql)

### Data Cleaning & Profiling
- Null and duplicate checks across every table
- Duplicate removal using window functions:
```sql
;With dedupe as(
Select *,
ROW_NUMBER() Over(partition by consumer_id, preferred_cuisine order by consumer_id asc ) as Row_num
from consumer_preferences)

Select * from dedupe where row_num >1
```
- Transaction-safe updates (verify before commit) for trimming text fields and filling nulls with `'Unknown'`
- Data type correction (`zip_code` from `int` to `varchar`) using `INFORMATION_SCHEMA.COLUMNS`

### Schema & Relational Integrity
Explicit primary/foreign key design across all five tables, e.g.:
```sql
Alter table ratings
Add Constraint ratings_consumers_consumer_id_fk
Foreign Key (consumer_id)
References consumers(consumer_id)
```

### Exploratory Data Analysis
Business questions answered using CTEs and conditional aggregation, e.g. rating distribution by category:
```sql
;With smoking_permission_count_by_rating as (
Select res.Smoking_Allowed,
Sum(case when rat.overall_rating = 0 then 1 end) as rating_0,
Sum(case when rat.overall_rating = 1 then 1 else 0 end) as rating_1,
Sum(case when rat.overall_rating = 2 then 1 else 0 end) as rating_2
from restaurants res join ratings rat
on res.restaurant_id = rat.restaurant_id
group by res.Smoking_Allowed)

Select Smoking_Allowed,
Cast(Round((rating_2*100.0/nullif((rating_0+rating_1+rating_2),0)),2) as decimal(5,2)) as rating_2_percent
from smoking_permission_count_by_rating
```
A derived `Age_Group` column was also added via `ALTER TABLE` + `CASE`, used later for consumer-level analysis.

---

## 3️⃣ Layer 3 — Power BI

**File:** [`power bi/Restaurant_Ratings_Maven_1.1.pbix`](./power%20bi)

### Report Pages
1. Overall Rating by Restaurant's Parameters
2. Consumer's Preference
3. Food Rating vs Service Rating — by Restaurant Parameters
4. Food Rating vs Service Rating — by Consumer Parameters

### Key DAX Measures
| Measure | DAX |
|---|---|
| Count of Food Rating | `CALCULATE(COUNT(ratings[Food_Rating]))` |
| Food Rating Percent | `DIVIDE([Count of Food Rating], CALCULATE([Count of Food Rating], REMOVEFILTERS(ratings[Food_Rating])))` |
| Food & Overall Rating Count | Consumers where `Food_Rating = 2` **and** `Overall_Rating = 2` |
| Service & Overall Rating Count | Consumers where `Service_Rating = 2` **and** `Overall_Rating = 2` |
| Overall Rating Percent | Overall rating distribution as % of total |
| Count of Consumer Preferences | Count of cuisine preference records |

### Sample Report Page
![Sample Power BI Page](./screenshots/sample_powerbi_page.png)
*Overall Ratings by Restaurant Parameters — one of four pages in the full interactive report.*

---

## 🧪 Hypothesis Testing Summary

19 hypotheses were tested across restaurant and consumer parameters. A condensed sample:

| # | Hypothesis | Status | Recommendation |
|---|---|---|---|
| 2 | Smoking allowed within a restricted area has a positive association with top Overall Rating | Accepted | Implement restricted smoking areas (bar-only or a dedicated section) rather than a blanket policy |
| 4 | Valet parking has a positive association with top Overall Rating | Accepted | Expand valet parking at flagship/high-traffic locations |
| 6 | Mexican cuisine is the best-rated cuisine | Rejected | Despite being the most *preferred* cuisine, Mexican is not the top-*rated* — focus quality investment on Japanese, Regional, Breakfast, and Contemporary |
| 9 | Food wins over Service for lower price categories | Accepted | Emphasize food heavily at low/medium price venues; invest equally in service at high-price venues |
| 19 | Food rating is a stronger driver of Overall Rating than Service rating | Accepted (marginal) | Treat food and service as near-equal priorities |

📄 Full 19-hypothesis breakdown with findings and recommendations: [`reports/Restaurant_Ratings_Maven_Final.pdf`](./reports)

---

## 💡 Key Insights & Recommendations

- **Smoking policy**: restricted smoking areas (Bar Only, Smoking Section) outperform blanket no-smoking or blanket smoking-allowed policies
- **Parking**: valet parking is associated with the highest top-rating share and the most balanced food/service experience
- **Price**: at low/medium price points, food quality is the dominant driver of satisfaction; at high price points, service matters equally
- **Cuisine**: Mexican is the most *preferred* cuisine by volume, but not the top *rated* — Japanese, Regional, Breakfast, and Contemporary cuisines earn higher ratings
- **Food vs. Service**: food is the stronger overall driver of guest satisfaction, but the gap narrows significantly wherever alcohol is served or price/budget is high

---

## ✅ Validation

Every headline number in this project — rating distributions, cuisine ratings, and all food-vs-service comparisons — was independently recalculated directly from the raw CSVs in [`data/`](./data) and cross-checked against the Excel, SQL, and Power BI outputs. All three layers, plus an independent recheck, produced matching results.

---

## 🔍 How to Explore This Project

- **Interactive report**: open [`power bi/Restaurant_Ratings_Maven_1.1.pbix`](./power%20bi) in Power BI Desktop
- **Full write-up**: read the PDF in [`reports/`](./reports) for the complete hypothesis testing table and recommendations
- **Reproduce the analysis**: run [`sql/Restaurant_Ratings_Maven.sql`](./sql) against the raw tables in [`data/`](./data)
