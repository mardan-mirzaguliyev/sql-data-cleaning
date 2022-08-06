--Test
SELECT *
FROM nashville_housing


--TASK-1: Standardize date format
SELECT SaleDate
FROM nashville_housing

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM nashville_housing

--MSSQL
UPDATE nashville_housing
SET SaleDate = CONVERT(Date, SaleDate)

--SQLite
UPDATE nashville_housing
SET SaleDate = date(SaleDate) AS date()

ALTER TABLE nashville_housing
ADD SalesDateConverted Date;
UPDATE nashville_housing
SET SaleDate = date(SaleDate);


--TASK-2: Populate property address data
SELECT PropertyAddress
FROM nashville_housing
WHERE PropertyAddress IS NULL

SELECT *
FROM nashville_housing
ORDER BY ParselID

--SQLITE
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL;

--MSSQL
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID] <> b.[UniqueID]);
WHERE a.PropertyAddress is NULL;


--TASK-3: Split address into individual columns (address, city, state)
SELECT PropertyAddress
FROM nashville_housing
--ORDER BY ParselID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(",", PropertyAddress)-1) AS Address
FROM nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(",", PropertyAddress)-1) AS Address
SUBSTRING(PropertyAddress, 1, CHARINDEX(",", PropertyAddress) + 1, LEN(PropertyAdress)) AS Address
FROM nashville_housing

----

ALTER TABLE nashville_housing
ADD PropertySplitAddress nvarchar(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(",", PropertyAddress)-1) AS Address;

ALTER TABLE nashville_housing
ADD PropertySplitCity nvarchar(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(",", PropertyAddress)-1)
------


SELECT OwnerAddress
FROM nashville_housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ",", "."), 3)
 ,PARSENAME(REPLACE(OwnerAddress, ",", "."), 2)
 ,PARSENAME(REPLACE(OwnerAddress, ",", "."), 1)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ",", "."), 3)

ALTER TABLE nashville_housing
ADD OwnerSplitCity nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ",", "."), 2)

ALTER TABLE nashville_housing
ADD OwnerSplitState nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ",", "."), 1)


--TASK-4: Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

------

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = "Y" THEN "Yes"
       WHEN SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
       END
FROM nashville_housing

------

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN "Yes"
       WHEN SoldAsVacant = "N" THEN "No"
       ELSE SoldAsVacant
       END
       
--TASK-5: Remove duplicates
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY
       UniqueID) row_num
FROM nashville_housing
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

----
--Delete duplicates
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY
       UniqueID) row_num
FROM nashville_housing
ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

--TASK-6: Delete unused columns
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM nashville_housing
