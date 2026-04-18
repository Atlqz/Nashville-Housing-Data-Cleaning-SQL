
# Data Dictionary: Nashville Housing Sales

## Table: NashvilleHousing (Cleaned Version)

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| `UniqueID` | float | Unique row identifier |
| `ParcelID` | nvarchar(255) | Property tax parcel ID |
| `LandUse` | nvarchar(255) | Zoning/land use classification |
| `PropertyAddress` | nvarchar(255) | Full street address (temporary - dropped later) |
| `SaleDate` | datetime | Original sale date with time (temporary - dropped later) |
| `SalePrice` | float | Final sale price in USD |
| `LegalReference` | nvarchar(255) | Legal document reference number |
| `SoldAsVacant` | nvarchar(255) | Property vacant at sale (Yes/No only after cleaning) |
| `OwnerName` | nvarchar(255) | Name of property owner(s) |
| `OwnerAddress` | nvarchar(255) | Owner mailing address (temporary - dropped later) |
| `Acreage` | float | Lot size in acres |
| `TaxDistrict` | nvarchar(255) | Tax district (dropped) |
| `LandValue` | float | Assessed land value in USD |
| `BuildingValue` | float | Assessed building value in USD |
| `TotalValue` | float | Total assessed value in USD |
| `YearBuilt` | float | Year structure was built |
| `Bedrooms` | float | Number of bedrooms |
| `FullBath` | float | Number of full bathrooms |
| `HalfBath` | float | Number of half bathrooms |

## Added Cleaned Columns

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| `SaleDateConverted` | date | Standardized sale date (YYYY-MM-DD) |
| `PropertySplitAddress` | nvarchar(255) | Street portion of property address |
| `PropertySplitCity` | nvarchar(255) | City portion of property address |
| `OwnerSplitAddress` | nvarchar(255) | Street portion of owner address |
| `OwnerSplitCity` | nvarchar(255) | City portion of owner address |
| `OwnerSplitState` | nvarchar(255) | State portion of owner address |

## Dropped Columns

- `PropertyAddress` (replaced by PropertySplitAddress + PropertySplitCity)
- `OwnerAddress` (replaced by OwnerSplitAddress + OwnerSplitCity + OwnerSplitState)
- `TaxDistrict` (not needed for analysis)
- `SaleDate` (replaced by SaleDateConverted)

## Data Type Notes

- `float` used for numeric IDs due to source data format
- `nvarchar(255)` used for string fields to accommodate full addresses
- `date` used for SaleDateConverted to remove timestamp
