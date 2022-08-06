
----------------------------------------------------------------------------------------------------------------------------------------------------
--Cleaning Housing Data in SQL

Select *
From PortfolioProject..Housing

----------------------------------------------------------------------------------------------------------------------------------------------------

--Making sure the date formats are right

Select SalesDate, CONVERT(Date,SaleDate) AS Sale_Date
From PortfolioProject..Housing

ALTER TABLE Housing
ADD SalesDate Date;

UPDATE Housing
SET SalesDate = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Populating the Property Address Column where address is Null

Select *
From PortfolioProject..Housing 
Where PropertyAddress is null


--Making a Self Join

Select ab.ParcelID, ab.PropertyAddress, cd.ParcelID, cd.PropertyAddress
From PortfolioProject..Housing ab
Join PortfolioProject..Housing cd
	On ab.ParcelID = cd.ParcelID
	AND ab.[UniqueID ] <> cd.[UniqueID ]
Where ab.PropertyAddress is null

--Now to populate the Property Address

Select ab.ParcelID, ab.PropertyAddress, cd.ParcelID, cd.PropertyAddress, ISNULL(ab.PropertyAddress, cd.PropertyAddress)
From PortfolioProject..Housing ab
Join PortfolioProject..Housing cd
	On ab.ParcelID = cd.ParcelID
	AND ab.[UniqueID ] <> cd.[UniqueID ]
Where ab.PropertyAddress is null

UPDATE ab
SET PropertyAddress = ISNULL(ab.PropertyAddress, cd.PropertyAddress)
From PortfolioProject..Housing ab
Join PortfolioProject..Housing cd
	On ab.ParcelID = cd.ParcelID
	AND ab.[UniqueID ] <> cd.[UniqueID ]
Where ab.PropertyAddress is null



----------------------------------------------------------------------------------------------------------------------------------------------------

--Seperating Address into Individual Columns (Address, City, States)

Select PropertyAddress
From PortfolioProject..Housing 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

From PortfolioProject..Housing 

ALTER TABLE Housing
ADD Property_Address NVARCHAR(255);

UPDATE Housing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Housing
ADD PropertyCity NVARCHAR(255);

UPDATE Housing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--To Confirm the changes

SELECT *
From PortfolioProject..Housing

--Setting Owner's Address

SELECT OwnerAddress
From PortfolioProject..Housing

SELECT 
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)

From PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
ADD Owner_Address NVARCHAR(255);

UPDATE PortfolioProject..Housing
SET Owner_Address = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..Housing
ADD OwnerCity NVARCHAR(255);

UPDATE PortfolioProject..Housing
SET OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..Housing
ADD OwnerState NVARCHAR(255);

UPDATE PortfolioProject..Housing
SET OwnerState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

--To Confirm the Changes

SELECT *
From PortfolioProject..Housing


--Setting the Y and N to Yes and No

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		End
From PortfolioProject..Housing



UPDATE PortfolioProject..Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' Then 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		End

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num

FROM PortfolioProject..Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY Property_Address


-- Delecting Unwanted Columns

Select *
From PortfolioProject..Housing

ALTER TABLE PortfolioProject..Housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
