/*

Cleaning Data in SQL Queries

*/ 

SELECT * 
FROM dbo.NashvilleHousing

-- Standardize Date Format 

Select SaleDate, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = Convert (Date, SaleDate)

-- Populate Property Address data

Select *
FROM NashvilleHousing
ORDER BY ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NAshvilleHousing AS BA
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is null


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NAshvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is null

-- Breaking out Address Into Individual Columns (Adress, City, State)

--Property Address


Select PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) As Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) As City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD Address nvarchar(250),
City nvarchar(250)


UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET City =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select * 
FROM NashvilleHousing


-- Owner Address

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD AddressOwn nvarchar(250),
CityOwn nvarchar(250),
StateOwn nvarchar(250)

UPDATE NashvilleHousing
SET AddressOwn = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing
SET CityOwn = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
SET StateOwn = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
	,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant = 'N' THEN 'No'
		  ELSE SoldAsVacant
		  END
FROM NashvilleHousing

UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		  WHEN SoldAsVacant = 'N' THEN 'No'
		  ELSE SoldAsVacant
		  END

-- Remove Duplicates
WITH RowNumCTE AS (	
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY ParcelID, 
			 PropertyAddress, 
			 SalePrice, 
			 SaleDate, 
			 LegalReference
			 ORDER BY UniqueID 
			 ) row_num
FROM NashvilleHousing )

DELETE 
FROM RowNumCTE
Where row_num>1


-- Delete Unused Columns 

Select * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing 
DROP COLUMN SaleDate
