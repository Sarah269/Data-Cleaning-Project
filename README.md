# Data-Cleaning-Project

This is a data cleaning project using an extract of Tennesse Housing data. The Excel file contains 541 records. The data file is cleaned using SAS Studio.

The following tasks were performed:
- Imported Excel file into SAS
- Checked for duplicates
- Missing Values - Character Variables
  - Populated missing Owner Address using Property Address. 100% of nonmissing Owner Address matched Property Address
  - Populated missing PropertyAddress fields using an existing record with same ParcelID
  - Populated missing TaxDistrict values based on the pattern presented in data
- Separated PropertyAddress into Address and City fields
- Standardized values in SoldAsVacant and LandUse fields
- Created LandUse_Grp field to assign categories to LandUse values
- Created SalePrice_Grp field to assign categories to SalePrice values
- Created SaleYear variable
- Missing Values - Numeric Variables
  - Decision: Drop BuildingValue, LandValue, TotalValue, Acreage, YearBuilt, Bedrooms, FullBath, HalfBath
    - 100% of the rows in the Condo LandUse did not have data for the above variables
    - 44% of the rows in Residential Land LandUse did not have data for the above variables
    - 19% of the rwos in Single Family LandUse did not have data for the above variables
- Checked Outlier.  Confirmed value is valid.

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/PropertyAddress.png)

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/OwnerAddress.png)

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/SoldAsVacant%20Standardization.png)

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/LandUse%20Standardization.png) 

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/LandUse_LandUseGrp.png)
