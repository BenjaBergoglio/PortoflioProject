/*

Cleaning Data en SQL

*/

select *
from SQLDataCleaningProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

--Standardize Data Format


select SaleDateConverted, CONVERT(date,SaleDate)
from SQLDataCleaningProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


---------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from SQLDataCleaningProject.dbo.NashvilleHousing
Order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from SQLDataCleaningProject.dbo.NashvilleHousing a
JOIN SQLDataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select ParcelID, PropertAddress
from SQLDataCleaningProject.dbo.NashvilleHousing


update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from SQLDataCleaningProject.dbo.NashvilleHousing a
JOIN SQLDataCleaningProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

---------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns from Property (Address, City, State)


select PropertyAddress
from SQLDataCleaningProject.dbo.NashvilleHousing
Order by ParcelID



select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address

from SQLDataCleaningProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


--Breaking out Address into Individual Columns from owners (Address, City, State)

Select OwnerAddress
from SQLDataCleaningProject.dbo.NashvilleHousing


Select  
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from SQLDataCleaningProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from SQLDataCleaningProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" column	

Select Distinct(SoldAsVacant), COUNT(soldasvacant)
from SQLDataCleaningProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End
from SQLDataCleaningProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	End


---------------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
) row_num
from SQLDataCleaningProject.dbo.NashvilleHousing
)

DELETE  
From RowNumCTE
where row_num >1


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
) row_num
from SQLDataCleaningProject.dbo.NashvilleHousing
)

Select *
From RowNumCTE
where row_num >1


---------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
from SQLDataCleaningProject.dbo.NashvilleHousing

ALTER TABLE SQLDataCleaningProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE SQLDataCleaningProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
