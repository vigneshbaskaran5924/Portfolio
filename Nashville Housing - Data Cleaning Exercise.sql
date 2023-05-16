
--Imported 56477 rows

--Started with data cleaning

Select * from dbo.NashvilleHousing


--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) as SaleDateNew From NashvilleHousing

--UPDATING THE HOUSING TABLE WITH THE NEW DATE FORMAT

Alter Table NashvilleHousing
Add SaleDateNew Date

Update NashvilleHousing
Set SaleDateNew = Convert(Date, SaleDate)

--DELETING THE SaleDate Column

Alter Table NashvilleHousing
Drop Column SaleDate

--PROPERTY ADDRESS DATA

Select * from NashvilleHousing
Where PropertyAddress is Null 
Order By ParcelID

/* 29rows without a property address */

/* for ParcelID without propertyAddress, we check for ParcelID that have the same ID with it 
and has address, use the address of the second ParceID to replace the null values */
--Using Self Join

SELECT a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
--, ISNULL(a.PropertyAddress, b.PropertyAddress) 
--When a.propertyaddress isnull, input b.propertyaddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update the table by populating the PropertyAddress Column

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID =b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
--29 Rows Affected

--Using Substring to seperate the PropertyAddress column into House address and city

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1) AS HouseAddress
, SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

--Updating the NashvilleHousing Table

Alter Table NashvilleHousing
Add HouseAddress Varchar(255)

Update NashvilleHousing
Set HouseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1)

--(56477 rows affected)

Alter Table NashvilleHousing
Add City Varchar(255)

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress))

--(56477 rows affected)

--DELETING THE PropertyAddress Column

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress

--Seperate Owner Address to display as Street Address, City and State

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3) AS OwnersAddress,
PARSENAME(REPLACE(OwnerAddress,',', '.') , 2) AS OwnersCity,
PARSENAME(REPLACE(OwnerAddress,',', '.') , 1) AS OwnersState
From NashvilleHousing

--Updating the table with the columns OwnersAddress, OwnersCity and OwnersState & the values

Alter Table NashvilleHousing
Add	OwnersAddress Varchar(255), OwnersCity VarChar(255), OwnersState VarChar(255)

Update NashvilleHousing
Set OwnersAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3),
OwnersCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2),
OwnersState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress

--Dropped the newly added column in the previous query "OwnersAddress" was dropped instead of "OwnerAddress" hence, had to add the column and update values again
Alter Table NashvilleHousing
Add	OwnersAddress Varchar(255)

Update NashvilleHousing
Set OwnersAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3)

-- CHANGING Y and N to Yes and No in SoldASVacant Column using the case statement

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VarChar(10) as 

SELECT SoldAsVacant
, CASE when SoldAsVacant = '1' THEN 'YES'
		WHEN SoldAsVacant = '0' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add SoldAsVacant1 VarChar(10)

Update NashvilleHousing
Set SoldAsVacant1 = CASE when SoldAsVacant = '1' THEN 'YES'
		WHEN SoldAsVacant = '0' THEN 'NO'
		ELSE SoldAsVacant
		END

ALTER TABLE NashvilleHousing
Drop Column SoldAsVacant

--REMOVE DUPLICATES

with RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			HouseAddress,
			SalePrice,
			SaleDateNew,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

/* 104 Duplicate rows removed */

-- CHECKING IF THERE ARE STILL DUPLICATES

with RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			HouseAddress,
			SalePrice,
			SaleDateNew,
			LegalReference
			ORDER BY
				UniqueID
				) row_num
FROM NashvilleHousing
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1

/* There are no duplicates */

--TOTAL NUMBER OF COLUMNS
SELECT count(*) AS NUMBEROFCOLUMNS FROM information_schema.columns
    WHERE table_name ='NashvilleHousing'



