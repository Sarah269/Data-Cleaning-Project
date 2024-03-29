# Data-Cleaning-Project

This is a data cleaning project using an extract of Tennessee Housing data.  The original Excel file contains approximately 59,000 records.  Created an extract of the file due to challenges loading in SAS Studio.  The Google Sheets file contains 541 records. The data file is cleaned using SAS Studio.

Reference:  Alex the Analyst

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
  - Decision: Drop BuildingValue, LandValue, TotalValue, Acreage, YearBuilt, Bedrooms, FullBath, HalfBath, OwnerName
    - 100% of the rows in the Condo LandUse did not have data for the above variables
    - 44% of the rows in Residential Land LandUse did not have data for the above variables
    - 19% of the rwos in Single Family LandUse did not have data for the above variables
- Checked Outlier.  Confirmed value is valid.
- Generated basic statistics
- Visualized data

![SAS Code](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/TN_541_DataCleaningII.sas)

<b> Dataset before Cleaning</b>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/Dataset%20Before%20Cleaning.png)

<b> Missing Character Variables </b>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/Missing%20Character%20Variables.png)

<b> Numeric Variables - Basic Statistics </b>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/Numeric%20Variable%20Analysis.png)

<b> Property Address Split </b>
<p>Split Property Address into Address and City fields.  Populated missing Owner Address with Property Address since non-missing values were the same as Property Address.</p>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/PropertyAddressSplit.png)

<b> SoldAsVacant Standardizaton </b>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/SoldAsVacant%20Standardization.png)

<b> LandUse Standardization </b>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/LandUse%20Standardization.png) 

<b> LandUse_Grp </b>

<p>Created categorization field for the LandUse field.</p>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/LandUse_LandUseGrp.png)

<b>SalePrice_Grp </b>
<p>Created categorization field for the SalePrice field.</p>

![](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/SalePrice_Grp.png)

<b> Dataset after Cleaning </b>
<p>Dropped 9 fields due to missing values.  Added 5 fields.</p>

![Post-cleaned dataset stats & graphs PDF](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/TN_StatsGraphs.pdf)

<p>  Distribution of property sales</p>

![DistSales](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/TN_DistSalesPrice.png)

<p> Properties Sold By Year & Landuse</p>

![PropertiesSold](https://github.com/Sarah269/Data-Cleaning-Project/blob/main/TN_NumSoldByYr.png)

