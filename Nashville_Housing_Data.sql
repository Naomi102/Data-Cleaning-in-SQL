/*Data Cleaning in SQL*/

SELECT *
FROM [Portfolio_Project(latest)]..['Nashville Housing Data$']

-----------------------------------------------------------------------------------------
--Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS New_SalesDate
FROM ['Nashville Housing Data$']


ALTER TABLE ['Nashville Housing Data$']
ALTER COLUMN SaleDate DATE;


/*ALTERNATIVE:

ALTER TABLE ['Nashville Housing Data$']
ADD SaleDateConverted Date; --Empty column for now

UPDATE ['Nashville Housing Data$']
SET SaleDateConverted = CONVERT(Date, SaleDate) --populate empty column with converted data

ALTER TABLE ['Nashville Housing Data$']
DROP COLUMN SaleDate*/


-----------------------------------------------------------------------------------------

--Populate PropertyAddress
SELECT  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ['Nashville Housing Data$'] a
JOIN ['Nashville Housing Data$'] b
	ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


/* AND a.[UniqueID ] <> b.[UniqueID ]

This ensures that you're comparing different records that 
share the same ParcelID (it checks if it does not check against itself), 
effectively avoiding self-matching (to avoid redundancy) and 
focusing on different entries with the same property 
identification (ParcelID).*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ['Nashville Housing Data$'] a
JOIN ['Nashville Housing Data$'] b
	ON a.[ParcelID] = b.[ParcelID]
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/*When using JOINS and UPDATE if you used aliases, 
SQL only takes alias in UPDATE not full table name*/







-----------------------------------------------------------------------------------------
--Breaking down Address into Individual Colums (Address, City, State)


--Check to see the formating of the PropertyAddress
--Check how many comma seperations are there

SELECT PropertyAddress
From [Portfolio_Project(latest)]..['Nashville Housing Data$']
WHERE LEN(PropertyAddress) - LEN(REPLACE(PropertyAddress,',','')) <1 


SELECT PropertyAddress
From [Portfolio_Project(latest)]..['Nashville Housing Data$']
WHERE LEN(PropertyAddress) - LEN(REPLACE(PropertyAddress,',','')) >1 

SELECT PropertyAddress
From [Portfolio_Project(latest)]..['Nashville Housing Data$']
WHERE LEN(PropertyAddress) - LEN(REPLACE(PropertyAddress,',','')) =1 


--Seperate by delimeter now
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM ['Nashville Housing Data$']


SELECT
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM ['Nashville Housing Data$']


ALTER TABLE ['Nashville Housing Data$']
ADD Property_Address_Splitted NVARCHAR(255)

ALTER TABLE ['Nashville Housing Data$']
ADD Property_City_Splitted NVARCHAR(198)


UPDATE ['Nashville Housing Data$']
SET Property_Address_Splitted = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


UPDATE ['Nashville Housing Data$']
SET Property_City_Splitted = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



--Seperate OwnerAdress as well
--Instead of SUBSTRING we'll use PARSENAME because it is much simpler

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS State
FROM ['Nashville Housing Data$']


ALTER TABLE ['Nashville Housing Data$']
ADD Owner_Address_Splitted NVARCHAR(255)

ALTER TABLE ['Nashville Housing Data$']
ADD Owner_City_Splitted NVARCHAR(255)

ALTER TABLE ['Nashville Housing Data$']
ADD Owner_State_Splitted NVARCHAR(255)


UPDATE ['Nashville Housing Data$']
SET Owner_Address_Splitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	Owner_City_Splitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	Owner_State_Splitted = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


SELECT *
FROM ['Nashville Housing Data$']


--------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM ['Nashville Housing Data$']



SELECT SoldAsVacant
FROM ['Nashville Housing Data$']
WHERE SoldAsVacant = 'N' OR SoldAsVacant = 'Y'


/*--Alternative : ensures all possible outcomes are taken care of
SELECT SoldAsVacant
FROM ['Nashville Housing Data$']
WHERE SoldAsVacantIS NOT NULL 
	AND SoldAsVacant <> 'No' 
	AND SoldAsVacant <> 'Yes'
	AND (SoldAsVacant LIKE 'N%' OR SoldAsVacant LIKE 'Y%')*/

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No' 
	ELSE SoldAsVacant
END AS New_SoldVacant
FROM ['Nashville Housing Data$']
WHERE SoldAsVacant = 'N' OR SoldAsVacant = 'Y'



UPDATE ['Nashville Housing Data$']
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No' 
	ELSE SoldAsVacant
END

















