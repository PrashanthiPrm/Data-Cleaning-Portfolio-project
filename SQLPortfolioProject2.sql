
/*
Data cleaning in SQL Queries
*/


Select *
From PortfolioProject2.dbo.housingdata

-- Standardize Date Format

Select SaleDateConverted, Convert(date,SaleDate) 
From PortfolioProject2.dbo.housingdata

Update housingdata
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE housingdata
Add SaleDateConverted Date;

Update housingdata
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select *
From PortfolioProject2.dbo.housingdata
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.housingdata a
Join PortfolioProject2.dbo.housingdata b
     On a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject2.dbo.housingdata a
Join PortfolioProject2.dbo.housingdata b
     On a.ParcelID = b.ParcelID
	 And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject2.dbo.housingdata


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProject2.dbo.housingdata


ALTER TABLE housingdata
Add PropertySplitAddress Nvarchar(255);


Update housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE housingdata
Add PropertySplitCity Nvarchar(255);


Update housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject2.dbo.housingdata


Select OwnerAddress
From PortfolioProject2.dbo.housingdata



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject2.dbo.housingdata


ALTER TABLE housingdata
Add OwnerSplitAddress Nvarchar(255);


Update housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE housingdata
Add OwnerSplitCity Nvarchar(255);


Update housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE housingdata
Add OwnerSplitState Nvarchar(255);


Update housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)


Select *
From PortfolioProject2.dbo.housingdata



 --Change Y and N to Yes and No in "Sold as Vacant" field

 Select Distinct(SoldAsVacant)
 From PortfolioProject2.dbo.housingdata

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.housingdata
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When cast(SoldAsVacant as varchar)= '1' THEN 'Yes'
	   When cast(SoldAsVacant as varchar)= '0' THEN 'No'
	   ELSE cast(SoldAsVacant as varchar)
	   END
From PortfolioProject2.dbo.housingdata

/*
Update housingdata
SET SoldAsVacant = CASE When cast(SoldAsVacant as varchar) = '1' THEN 'Yes'
	    When try_cast(SoldAsVacant as varchar )= '0' THEN 'No'
	    ELSE convert(varchar,SoldAsVacant )
	    END
*/


Update housingdata
SET SoldAsVacant = Replace(cast(SoldAsvacant as varchar),'Yes',1) 
where SoldAsVacant like 1


Update housingdata
SET SoldAsVacant = Replace(cast(SoldAsvacant as varchar),'No',0) 
where SoldAsVacant like 0


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.housingdata
Group by SoldAsVacant
order by 2


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject2.dbo.housingdata
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns


Select *
From PortfolioProject2.dbo.housingdata


ALTER TABLE PortfolioProject2.dbo.housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


