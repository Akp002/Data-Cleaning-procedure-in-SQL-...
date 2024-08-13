SELECT *
FROM Portfolio_project.dbo.Nashvilehousing

-------------------------------------------------------------------------------------------

--Standardized Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_project.dbo.Nashvilehousing

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add SaleDateConverted  Date;

UPDATE Portfolio_project.dbo.Nashvilehousing
SET SaleDateconverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------

--Populate property Address data

Select *
FROM Portfolio_project.dbo.Nashvilehousing
--Where PropertyAddress is null
order by ParcelID


Select A.ParcelID,A.PropertyAddress,B.ParcelID,b.PropertyAddress,ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_project.dbo.Nashvilehousing a
JOIN Portfolio_project.dbo.Nashvilehousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]  <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_project.dbo.Nashvilehousing a
JOIN Portfolio_project.dbo.Nashvilehousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]  <> b.[UniqueID ]
Where a.PropertyAddress is null


-------------------------------------------------------------------------------------------

--Breaking out Address into Individual columns(Address,City,States)

Select PropertyAddress
FROM Portfolio_project.dbo.Nashvilehousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING (PropertyAddress, 1,CHARINDEX (',',PropertyAddress)-1) as Address
,SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress) +1, LEN (PropertyAddress)) as Address
FROM Portfolio_project.dbo.Nashvilehousing

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add  PropertySplitAddress nvarchar(255);

UPDATE Portfolio_project.dbo.Nashvilehousing
SET  PropertySplitAddress = SUBSTRING (PropertyAddress, 1,CHARINDEX (',',PropertyAddress)-1) 

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add  PropertySplitcity nvarchar(255);

UPDATE Portfolio_project.dbo.Nashvilehousing
SET  PropertySplitcity = SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress) +1, LEN (PropertyAddress)) 

Select *
FROM Portfolio_project.dbo.Nashvilehousing



Select OwnerAddress
FROM Portfolio_project.dbo.Nashvilehousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio_project.dbo.Nashvilehousing

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add  ownerSplitAddress nvarchar(255);

UPDATE Portfolio_project.dbo.Nashvilehousing
SET  ownerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add  ownerSplitcity nvarchar(255);

UPDATE Portfolio_project.dbo.Nashvilehousing
SET  ownerSplitcity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
Add  ownerSplitstate nvarchar(255);

UPDATE Portfolio_project.dbo.Nashvilehousing
SET  ownerSplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
FROM Portfolio_project.dbo.Nashvilehousing



--------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Portfolio_project.dbo.Nashvilehousing
Group By SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END
FROM Portfolio_project.dbo.Nashvilehousing

UPDATE Portfolio_project.dbo.Nashvilehousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END

----------------------------------------------------------------------------------------

--Remove Duplicates


WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             propertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				 )row_num

FROM Portfolio_project.dbo.Nashvilehousing
---ORDER BY parcelID
)
Select*
FROM RowNumCTE
where row_num> 1
ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--where row_num> 1

----------------------------------------------------------------------------------------------

--Delete unused columns(Not necesary)

SELECT *
FROM Portfolio_project.dbo.Nashvilehousing

ALTER TABLE Portfolio_project.dbo.Nashvilehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SalesDateConverted,SaleDate
