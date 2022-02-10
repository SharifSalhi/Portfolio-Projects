--Nasville Housing - Data Cleaning


--The following table will be used to demonstrate  SQL Data Cleaning skills:
SELECT * FROM NashvilleHousing

------------------------------------------------------------------------------------------------------------
--1)Creating a shorter date format. 
--Current format: "YYYY-MM-DD hh: mm: ss". 
--Desired format:"YYYY-MM-DD"


ALTER TABLE NashvilleHousing
ADD ShortSaleDate Date
UPDATE NashvilleHousing
SET ShortSaleDate =  CONVERT(date,SaleDate)


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate 


------------------------------------------------------------------------------------------------------------
--2) Populating address section:
--Some rows of the table have no values for the PropertyAddress column, we can obtatin
--that information from other rows that have the same Parcel ID. 


SELECT TableA.ParcelID, TableA.PropertyAddress, TableB.ParcelID, TableB.PropertyAddress,
ISNULL(TableA.PropertyAddress, TableB.PropertyAddress)
FROM NashvilleHousing AS TableA 
JOIN NashvilleHousing AS TableB
ON TableA.ParcelID = TableB.ParcelID
AND TableA.[UniqueID ] <> TableB.[UniqueID ]
WHERE TableA.PropertyAddress IS NULL 


UPDATE TableA 
SET TableA.PropertyAddress = ISNULL(TableA.PropertyAddress, TableB.PropertyAddress)
FROM NashvilleHousing AS TableA 
JOIN NashvilleHousing AS TableB
ON TableA.ParcelID = TableB.ParcelID
AND TableA.[UniqueID ] <> TableB.[UniqueID ]
WHERE TableA.PropertyAddress IS NULL 


------------------------------------------------------------------------------------------------------------
--3)Separatring address into individual columns:

--a)The current PropertyAddress column follows the following format: "Street Address , City".
SELECT PARSENAME(REPLACE(PropertyAddress,',','.'),2) AS StreetAddress,
PARSENAME(REPLACE(PropertyAddress,',','.'),1) AS City
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyStreetAdress Nvarchar(255)
UPDATE NashvilleHousing
SET PropertyStreetAdress = PARSENAME(REPLACE(PropertyAddress,',','.'),2) 


ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255)
UPDATE NashvilleHousing
SET PropertyCity = PARSENAME(REPLACE(PropertyAddress,',','.'),1)


ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress


--b)The current OwnerAddress column follows the following format: "Street Address , City, State".
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS StreetAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerStreetAdress Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerStreetAdress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 


ALTER TABLE NashvilleHousing
ADD OwnerCity Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 


ALTER TABLE NashvilleHousing
ADD OwnerState Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress


------------------------------------------------------------------------------------------------------------
--4)Standardizing the SoldAsVacant column
--Current values: Yes, No, Y and N.  
--Desired values: Yes and No


SELECT
CASE
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' Then 'Yes'
	WHEN SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
END


------------------------------------------------------------------------------------------------------------
--5)Deleting Duplicates


WITH CTE_Duplicates AS(
SELECT * ,  
ROW_NUMBER()
OVER(PARTITION BY 
		ParcelID,SalePrice,ShortSaleDate,
		PropertyStreetAdress,
		PropertyCity,OwnerState,OwnerState 
		ORDER BY ParcelID) AS DuplicateIndicator
FROM NashvilleHousing)


DELETE FROM CTE_Duplicates
WHERE DuplicateIndicator>1


