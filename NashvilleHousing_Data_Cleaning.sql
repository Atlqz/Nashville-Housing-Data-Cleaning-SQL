/*******************************************************************
 * Title: Nashville Housing Data Cleaning & Standardization
 * Description: Comprehensive data cleaning of Nashville housing sales 
 *              records including date standardization, address parsing,
 *              duplicate removal, and NULL handling.
 *******************************************************************/

-- ==============================================================
-- Section 1: Initial Data Preview
-- ==============================================================

-- Preview raw data structure
Select *
From PortfolioProject..NashvilleHousing

-- Check for missing values in critical columns
Select 
Count(*) as Total_Rows,
Sum(Case When PropertyAddress is null Then 1 Else 0 End) as Missing_PropertyAddress,
Sum(Case When OwnerAddress is null Then 1 Else 0 End) as Missing_OwnerAddress
From PortfolioProject..NashvilleHousing

-- ==============================================================
-- Section 2: Standardize Date Format
-- ==============================================================

-- View current datetime format vs desired date format
Select SaleDate, Convert(Date, SaleDate) as CleanDate
From PortfolioProject..NashvilleHousing

-- Add new standardized date column
Alter Table NashvilleHousing
Add SaleDateConverted Date

-- Populate with converted dates
Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

-- Verify the update
Select SaleDate, SaleDateConverted
From PortfolioProject..NashvilleHousing

-- ==============================================================
-- Section 3: Populate Missing Property Addresses
-- ==============================================================

-- Count rows with null PropertyAddress
Select Count(*) as Null_Address_Count
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

-- Identify matching ParcelIDs with known addresses
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
Isnull(a.PropertyAddress, b.PropertyAddress) as Filled_Address
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Fill null addresses using matching ParcelID references
Update a
Set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Confirm all addresses are now populated
Select Count(*) as Remaining_Nulls
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

-- ==============================================================
-- Section 4: Split Property Address into Street and City
-- ==============================================================

-- Preview address format (Street, City)
Select Distinct PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress is not null

-- Extract street (before comma) and city (after comma)
Select PropertyAddress,
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1) as Street,
Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

-- Create column for street address
Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) - 1)

-- Create column for city
Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1, Len(PropertyAddress))

-- Verify the split results
Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject..NashvilleHousing

-- ==============================================================
-- Section 5: Split Owner Address into Street, City, State
-- ==============================================================

-- Preview owner address format (Street, City, State)
Select Distinct OwnerAddress
From PortfolioProject..NashvilleHousing
Where OwnerAddress is not null

-- Use PARSENAME with comma-to-period replacement for parsing
Select OwnerAddress,
Parsename(Replace(OwnerAddress, ',', '.'), 3) as Street,
Parsename(Replace(OwnerAddress, ',', '.'), 2) as City,
Parsename(Replace(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..NashvilleHousing

-- Create columns for parsed components
Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-- Verify parsed components
Select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From PortfolioProject..NashvilleHousing

-- ==============================================================
-- Section 6: Standardize "Sold As Vacant" Values
-- ==============================================================

-- Check current values and distribution
Select Distinct SoldAsVacant, Count(*) as Frequency
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by Frequency Desc

-- Convert 'Y' to 'Yes' and 'N' to 'No'
Update NashvilleHousing
Set SoldAsVacant = Case 
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

-- Confirm only 'Yes' and 'No' remain
Select Distinct SoldAsVacant, Count(*) as Frequency
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

-- ==============================================================
-- Section 7: Remove Duplicate Records
-- ==============================================================

-- Identify duplicates using ROW_NUMBER partitioned by key fields
With RowNumCTE as (
Select *,
Row_Number() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID
) as row_num
From PortfolioProject..NashvilleHousing
)
Select * From RowNumCTE Where row_num > 1

-- Delete duplicate rows (keep first occurrence)
With RowNumCTE as (
Select *,
Row_Number() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID
) as row_num
From PortfolioProject..NashvilleHousing
)
Delete From RowNumCTE Where row_num > 1

-- Verify no duplicates remain
With RowNumCTE as (
Select *,
Row_Number() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order by UniqueID
) as row_num
From PortfolioProject..NashvilleHousing
)
Select Count(*) as Remaining_Duplicates From RowNumCTE Where row_num > 1

-- ==============================================================
-- Section 8: Drop Unused Columns
-- ==============================================================

-- Remove original address and date columns (now replaced by cleaned versions)
Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- ==============================================================
-- Section 9: Final Data Quality Check
-- ==============================================================

-- Summary statistics of cleaned dataset
Select 
Count(*) as Total_Records,
Count(Distinct ParcelID) as Unique_Properties,
Min(SalePrice) as Min_Price,
Max(SalePrice) as Max_Price,
Avg(SalePrice) as Avg_Price,
Min(SaleDateConverted) as Earliest_Sale,
Max(SaleDateConverted) as Latest_Sale
From PortfolioProject..NashvilleHousing

-- Preview cleaned dataset
Select Top 100 *
From PortfolioProject..NashvilleHousing
Order by SaleDateConverted Desc