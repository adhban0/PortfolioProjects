-- Standardize date format

/*update NashvilleHousing
set SaleDate = CONVERT(date, saledate) doesn't work*/
alter table NashvilleHousing
alter column saledate date
/* or
alter table NashvilleHousing
add saledateconverted date

update NashvilleHousing
set SaleDateconverted = CONVERT(date, saledate)
*/


-- Populate property address

select n1.PropertyAddress, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress) as updatedpropertyaddress
from NashvilleHousing n1 join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID and n1.[UniqueID ] != n2.[UniqueID ]
where n1.PropertyAddress is null

update n1
set PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
from NashvilleHousing n1 join NashvilleHousing n2
on n1.ParcelID = n2.ParcelID and n1.[UniqueID ] != n2.[UniqueID ]
where n1.PropertyAddress is null


-- Breaking out address into individual columns (Address, City, State)
-- You can alter the original column directly if you prefer
-- You can use PARSENAME method for property address (start with 2) but you can't use CHARINDEX method for owneraddress
select PropertyAddress, 
SUBSTRING ( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
LEN(PropertyAddress))
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING ( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING ( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, 
LEN(PropertyAddress))


select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select * from NashvilleHousing


--Change Y and N to Yes and No or vice versa (depending on which is more)

select SoldAsVacant, COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant

update NashvilleHousing
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

update NashvilleHousing
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'

/* or 
update NashvilleHousing
set SoldAsVacant = case
when soldasVacant = 'Y' then 'Yes'
when soldasVacant = 'N' then 'No'
else soldasvacant
end */

-- Remove duplicates

with RownumCTE as
(
select ROW_NUMBER() over ( partition by
parcelid,
propertyaddress,
legalreference,
saleprice,
saledate
order by
uniqueid) as row_num
from NashvilleHousing
)
delete
from RownumCTE
where row_num > 1

--Delete Unused Columns (Basically useless columns not null columns)

alter table NashvilleHousing
drop column propertyaddress, owneraddress, saledate, taxdistrict

-- Replace Null Values

Update NashvilleHousing
set OwnerName =  coalesce(OwnerName, 'City of Nashville')

-- Convert all text to uppercase

Update NashvilleHousing
set LandUse = UPPER(landuse)

Update NashvilleHousing
set SoldAsVacant = UPPER(soldasvacant) 

Update NashvilleHousing
set OwnerName = UPPER(OwnerName)

Update NashvilleHousing
set PropertySplitAddress = UPPER(PropertySplitAddress)

Update NashvilleHousing
set PropertySplitCity = UPPER(PropertySplitCity)

Update NashvilleHousing
set OwnerSplitAddress = UPPER(OwnerSplitAddress)

Update NashvilleHousing
set OwnerSplitCity = UPPER(OwnerSplitCity)

Update NashvilleHousing
set OwnerSplitState = UPPER(OwnerSplitState)

-- Finding outliers
/* delete from table_name 
 where (column_name) > upper_limit or (column_name) < lower_limit */

 -- Remove Spaces
 Update NashvilleHousing
set LandUse = trim(landuse)

Update NashvilleHousing
set SoldAsVacant = trim(soldasvacant) 

Update NashvilleHousing
set OwnerName = trim(OwnerName)

Update NashvilleHousing
set PropertySplitAddress = trim(PropertySplitAddress)

Update NashvilleHousing
set PropertySplitCity = trim(PropertySplitCity)

Update NashvilleHousing
set OwnerSplitAddress = trim(OwnerSplitAddress)

Update NashvilleHousing
set OwnerSplitCity = trim(OwnerSplitCity)

Update NashvilleHousing
set OwnerSplitState = trim(OwnerSplitState)

-- Delete Null rows

delete from NashvilleHousing
where [UniqueID ] is null
