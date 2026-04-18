# Nashville-Housing-Data-Cleaning-SQL
Professional data cleaning of Nashville housing sales dataset using SQL Server. Includes date standardization, address parsing, duplicate removal, and NULL handling.
# Nashville Housing Data Cleaning | SQL

![SQL](https://img.shields.io/badge/SQL-Server-CC2927?style=flat-square&logo=microsoft-sql-server&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/MIT-License-blue?style=flat-square)

## Project Overview

Raw data rarely arrives analysis-ready. This project takes a **56,000-row real estate dataset** from Nashville, Tennessee (2013–2019) and transforms it from a messy, inconsistent source file into a clean, structured table ready for reporting and business intelligence.

The dataset contained six distinct categories of quality issues, all resolved systematically using SQL Server without touching the source file.

---

## What Was Wrong and What Was Fixed

| Issue | Raw state | Clean state | Records affected |
|-------|-----------|-------------|-----------------|
| Missing property addresses | NULL in 29 rows | Populated via self-JOIN on Parcel ID | 29 rows recovered |
| Inconsistent date format | `April 9, 2013 00:00:00` | `2013-04-09` | All 56,000 rows standardised |
| Duplicate records | 104 exact duplicates | Removed, 0 remaining | Prevents inflated sale counts |
| Inconsistent boolean values | Mix of `'Y'`, `'N'`, `'Yes'`, `'No'` | Standardised to `'Yes'` / `'No'` | Clean grouping and filtering |
| Unparsed address field | Full address as single string | Split into Street, City, State columns | Geographic analysis unlocked |
| Redundant columns | 4 columns no longer needed post-cleaning | Dropped via `ALTER TABLE` | Leaner schema for downstream use |

---

## Why Each Fix Matters

**Missing addresses**, 29 properties shared a Parcel ID with another row that did have an address. A self-JOIN on Parcel ID recovered all 29 without any manual lookup or external data.

**Date format**, the original `datetime` field stored timestamps down to the second on data that only needed day-level precision. Converting to a clean `DATE` type removes noise and enables straightforward time-series grouping by month or quarter.

**Duplicates**, 104 duplicate rows would have inflated transaction counts by ~0.2% and skewed any per-property aggregation. Identified using `ROW_NUMBER() OVER (PARTITION BY ...)` on five business-key columns, then deleted.

**Boolean standardisation**, the `SoldAsVacant` field used four different values for what is a binary concept. A `CASE` statement collapsed them to two, making the column usable in `GROUP BY` and `WHERE` filters without workarounds.

**Address parsing**, splitting a single address string into Street, City, and State columns enables geographic filtering and grouping that was impossible on the raw field.

---

## SQL Techniques Demonstrated

| Technique | Purpose |
|-----------|---------|
| Self-JOIN | Populate NULLs using data already in the table |
| `SUBSTRING` + `CHARINDEX` | Parse comma-delimited address strings |
| `PARSENAME` | Extract components from period-delimited strings |
| CTE + `ROW_NUMBER()` | Identify and remove duplicate records |
| `CASE` statements | Standardise inconsistent categorical values |
| `ALTER TABLE` / `UPDATE` | Modify schema and apply bulk corrections |
| `ISNULL` | Handle NULL-safe comparisons during enrichment |

---

## Sample Query: Duplicate Detection and Removal

Partitions rows by five business-key columns. Any row receiving `row_num > 1` is a true duplicate, same property, same sale, same price, same legal reference.

```sql
With RowNumCTE as (
    Select *,
        Row_Number() Over (
            Partition by
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            Order by UniqueID
        ) as row_num
    From PortfolioProject..NashvilleHousing
)
Delete From RowNumCTE Where row_num > 1;
```

---

## Repository Structure

```
nashville-data-cleaning/
│
├── README.md
├── NashvilleHousing_Data_Cleaning.sql
└── data_dictionary.md
```

---

## What I Would Do Next

- **Exploratory analysis**: Now that the data is clean, the next step is analysing sale price trends by neighbourhood, year, and property type, questions that were blocked by the data quality issues this project resolved.
- **Power BI dashboard**: Connect the cleaned table to a dashboard tracking median sale prices over time with filters for city district and property category.
- **Automated validation**: Write a SQL script that checks for the same six quality issues on any new data load, turning this one-time cleaning into a repeatable data quality check.
