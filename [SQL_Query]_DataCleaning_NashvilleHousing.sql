/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProjectTutorial..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------


--Standardize Date Format

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProjectTutorial..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)


Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)


----------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address Date

Select *
From PortfolioProjectTutorial..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectTutorial..NashvilleHousing a
Join PortfolioProjectTutorial..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProjectTutorial..NashvilleHousing a
Join PortfolioProjectTutorial..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProjectTutorial..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , Len(PropertyAddress)) as Address
From PortfolioProjectTutorial..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , Len(PropertyAddress))




Select *
From PortfolioProjectTutorial..NashvilleHousing




Select OwnerAddress
From PortfolioProjectTutorial..NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProjectTutorial..NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From PortfolioProjectTutorial..NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjectTutorial..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProjectTutorial..NashvilleHousing


Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End





----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From PortfolioProjectTutorial..NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProjectTutorial..NashvilleHousing

Alter Table PortfolioProjectTutorial..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate