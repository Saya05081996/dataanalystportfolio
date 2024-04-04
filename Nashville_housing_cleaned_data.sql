-- selecting data from nashville housing
select * from dbo.Nashville;

--converting the sale date
select saledate from Nashville;

alter table Nashville
add SaleDateConverted date;

update Nashville
set saledateconverted = convert(date, saledate);

select saledateconverted from nashville;

--property address update

select count(*) from nashville
where nashville.PropertyAddress is null

--there are a few properties which have null values in their property address
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress 
from Nashville a
join nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from Nashville a
join nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

--checking address and seperating it into columns (address, state)
select propertyaddress from Nashville;

select 
substring(propertyaddress, 1, charindex(',',propertyaddress)-1) as address,
substring(propertyaddress, charindex(',',propertyaddress)+1, len(propertyaddress)) as state
from nashville;

--adding the columns to the existing table
alter table nashville
add Propertysplitaddress nvarchar(255);

alter table nashville
add Propertysplitcity nvarchar(255);

update Nashville
set Propertysplitaddress = substring(propertyaddress, 1, charindex(',',propertyaddress)-1);

update Nashville
set Propertysplitcity = substring(propertyaddress, charindex(',',propertyaddress)+1, len(propertyaddress));

select propertysplitaddress, propertysplitcity from Nashville;


--parsing the owner address from nashville
select * from nashville
where owneraddress is not null;

select 
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from Nashville;

alter table nashville
add Ownersplitaddress nvarchar(255);

alter table nashville
add Ownersplitcity nvarchar(255);

alter table nashville
add Ownersplitstate nvarchar(255);

update Nashville
set Ownersplitaddress = parsename(replace(owneraddress,',','.'),3);

update Nashville
set Ownersplitcity = parsename(replace(owneraddress,',','.'),2);

update Nashville
set Ownersplitstate = parsename(replace(owneraddress,',','.'),1);

select * from Nashville;


--changing Y and N to Yes and No respectively

select distinct(soldasvacant),count(*) from Nashville
group by SoldAsVacant;

select Soldasvacant, 
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from Nashville;

update Nashville
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end;

--finding duplicates and removing them

WITH dup_cte as
(
select *,
		ROW_NUMBER()
		over(partition by 
		parcelID,
		propertyaddress,
		saleprice,
		saledate,
		legalreference
		order by uniqueID)
		row_num
from nashville
)
			
DELETE
from dup_cte
where row_num > 1;
--order by PropertyAddress;


--deleting unused columns from nashville
select * from Nashville;

alter table nashville
drop column propertyaddress,owneraddress,taxdistrict,saledate;