/*Excel file Housing_1.xslx Data Cleaning*/
/*SAS library: mylib*/
/*Dataset:  TN_541.  Records = 541.  19 Variables.*/


/*Setup library reference to point to location of sas dataset*/
libname mylib "/home/u63413844/DataAnalysis";

Data tn_wip;
   set mylib.TN_541;
   

proc contents data=tn_wip varnum ;run;

   
 /* Stats on Character Variables */
proc freq data=tn_wip order=FREQ;
tables _char_ / maxlevels =20 MISSING;


/* Duplicate Check */
  proc sort data=tn_wip dupout=dups noduprecs;
    by UniqueID;
  run;

  proc print data=dups;run;
   /*No dups records returned */

  /* Does UniqueID have any Duplicates */
  proc sql;
  select UniqueID, count(*)
  from tn_wip
  group by UniqueID
  having count(*) >1;
  quit;
   /* No rows selected*/

  /* Is a ParcelID listed twice with the same SaleDate */
  proc sql;
  select ParcelID, SaleDate, count(*)
  from tn_wip
  group by ParcelID, SaleDate
  having count(*) > 1;
  quit;
   /*No rows selected*/


/* Missing Values  - Character */
  /* format to be used with proc freq for missing values */
  proc format;
  value $missfmt ' '='Missing' other='Not Missing';
  value  missfmt  . ='Missing' other='Not Missing';
  run;

  /* Look at missing for character variables */
  proc freq data=tn_wip; 
  format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
  tables _CHAR_ / missing missprint nocum nopercent;
  *format _NUMERIC_ missfmt.;
  *tables _NUMERIC_ / missing missprint nocum nopercent;
  run;
  
  /* Missing Values: PropertyAddress, OwnerName, Owner Address, and TaxDistrict*/

  /* Missing PropertyAddress */ 
  proc sql;
  select * 
  from tn_wip
  where PropertyAddress is missing;
  quit;

  /*  There is a record with the missing Property Address */
  proc sql;
  select * 
  from tn_wip
  where ParcelID in (
  select ParcelID
  from tn_wip
  where PropertyAddress is missing)
  order by ParcelID;

  /* Create a dataset with the missing property address */
  proc sql;
  create table fix_propaddr as
  select UniqueID, ParcelID, PropertyAddress
  from tn_wip
  where ParcelID in (
  select ParcelID from tn_wip
  where PropertyAddress is missing
  )
  and PropertyAddress is not missing
  order by ParcelID;
  quit;

   /* Update PropertyAddress field */
  proc sql;
  update tn_wip
  set PropertyAddress = (
  select PropertyAddress from fix_propaddr
  where tn_wip.ParcelID = fix_propaddr.ParcelID
  and tn_wip.UniqueID <> fix_propaddr.UniqueID)
  where PropertyAddress is missing;
  quit;

  /* Check update*/
  proc sql;
  select * 
  from tn_wip
  where UniqueID in (43076, 39432, 45290, 53147);
  quit;

  proc sql;
  select * 
  from tn_wip
  where ParcelID in (select ParcelID from fix_propaddr)
  order by ParcelID;
  quit;

  proc freq data=tn_wip; 
  format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
  tables _CHAR_ / missing missprint nocum nopercent;
  *format _NUMERIC_ missfmt.;
  *tables _NUMERIC_ / missing missprint nocum nopercent;
  run;

  /*OwnerAddress */
  /* Does OwnerAddress = PropertyAddress for non-missing rows*/
  proc sql;
  select count(*)
  from tn_wip
  where OwnerAddress is not missing
  and scan(OwnerAddress,1,',') = scan(OwnerAddress,1,',')
  and scan(OwnerAddress,2,',') = scan(PropertyAddress,2,',');
  quit;
  /*404 rows returned: 541-137(missing) = 404 */

  /* Visual Inspection */
  proc sql;
  select PropertyAddress, OwnerAddress
  from tn_wip
  where OwnerAddress is not missing;
  quit;

  /*Tax District */

  /* Visual Inspection */
  proc sql;
  select OwnerAddress, TaxDistrict
  from tn_wip
  where OwnerAddress is not missing
  order by TaxDistrict;
  quit;


  /* Split Address Fields.  Standardize LandUse & SoldAsVacant. */
  /* Create categorization fields */

  Data tn_wip2 ;
  set tn_wip;
 
   /* Split Address Field */
   
   
   Owner_Address = scan(OwnerAddress,1,',');
   Owner_City = scan(OwnerAddress,2,',');
   Label Owner_Address = "Owner Address";
   Label Owner_City = "Owner Address City";
   attrib Owner_Address  format=$char30.; 
   attrib Owner_City format=$char20.;
   
   Property_Address = scan(PropertyAddress,1,',');
   Property_City = scan(PropertyAddress,2,',');

   Label Property_Address = "Property Address";
   Label Property_City = "Property Address City";
    attrib Property_Address format=$char30.;
    attrib Property_City format=$char20.;
   
   /* Standardize SoldAsVacant */
    select (SoldAsVacant);
    When ("N") SoldAsVacant = "No";
    when ("Y") SoldAsVacant = "Yes";
    Otherwise SoldAsVacant=SoldAsVacant;
    end;

   /*Standardize LandUse  & Create Group*/
    length LandUse_Grp $10;
    attrib LandUse_Grp format=$CHAR10.;
    Label LandUse_Grp = "LandUse Group";
    select (LandUse);
    when ("CHURCH") LandUse_Grp = "CHURCH";
    when ("DUPLEX") LandUse_Grp = "HOME";
    when ("RESIDENTIAL CONDO") LandUse_Grp = "HOME";
    when ("SINGLE FAMILY") LandUse_Grp = "HOME";
    when ("ZERO LOT LINE") LandUse_Grp = "HOME";
    when ("VACANT RES LAND") do;
        LandUse = "VACANT RESIDENTIAL LAND";
        LandUse_Grp = "LAND";
        end;
    when ("VACANT RESIDENTIAL LAND") LandUse_Grp = "LAND";
    when ("VACANT RURAL LAND") LandUse_Grp = "LAND";
    Otherwise  LandUse_Grp = "OTHER";
    end;

    /*  Show PropertyAddress Split */
    proc print data=tn_wip2;
    var PropertyAddress Property_Address Property_City Owner_Address Owner_City;  
    where Owner_Address is not missing;
  

  /* Resolve Missing Values for Character Variables */
  Data tn_wip3 (Drop = OwnerName PropertyAddress OwnerAddress) ;
  set tn_wip2;
   
   /* Drop OwnerName */
   
   /* Resolve missing Owner Address */
   if missing(Owner_Address)
     then Owner_Address = Property_Address;
  
   /* Resolve missing Owner City */
   if missing(Owner_City)
     then Owner_City = Property_City;
   
   /* Resolve missing TaxDistrict */
   if missing(TaxDistrict)
     then do;
        if Owner_City = 'GOODLETTSVILLE'
          then TaxDistrict = 'CITY OF GOODLETTSVILLE';
        else TaxDistrict = 'GENERAL SERVICES DISTRICT';
     end;
  
  /* Check missing values resolutions */    
   proc freq data=tn_wip3 order=FREQ;
   tables _char_ / maxlevels =10 MISSING;
 
  proc freq data=tn_wip3; 
  format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
  tables _CHAR_ / missing missprint nocum nopercent;
  *format _NUMERIC_ missfmt.;
  *tables _NUMERIC_ / missing missprint nocum nopercent;
  run;
 
/* Missing value - Numeric */

  /* Stats on Numeric Variables */
  ODS trace on;
  ODS select Moments MissingValues;
  proc univariate data=tn_wip3 (drop=SaleDate YearBuilt) outtable=tnwip3_stats noprint;
  run;

  title "Numeric Variable Analysis";
  proc print data=tnwip3_stats label noobs;
  var _VAR_ _NOBS_ _NMISS_ _MIN_ _MEAN_ _MEDIAN_ _MAX_ _SUM_ _Q1_ _Q3_;
  label _VAR_='Analysis';
  run;
  title; 

  proc tabulate data=tn_wip3;
  var SaleDate;
  tables SaleDate, n nmiss (min max median)*f=mmddyy10.;
  run;

  proc tabulate data=tn_wip3;
  var YearBuilt;
  tables YearBuilt, (n nmiss min max median)*f=yyyy4.;
  run;
  
  /*  Check missing data by LandUse */
  proc sort data=tn_wip3; by LandUse; run;
  
  proc freq data=tn_wip3;
  by LandUse;
  tables _numeric_ / maxlevels=10 missing;
  run;

   /*  Residential Land:  44% LandValue missing */
   /*  Condo:  100% missing for BuildingValue, LandValue, TotalValue, YearBuilt, Acreage, Bedrooms, FullBath, HalfBath */
   /*  Single Family:  19% missing for BuildingValue, LandValue, TotalValue, YearBuilt, Acreage, Bedroooms, FullBath, HalfBath*/
   /*  Decision:  Drop columns BuildingValue, LandValue, TotalValue, YearBuilt, Acreage, Bedrooms, HalfBath, FullBath*/


   Data tn_wip4;
   set tn_wip3 (drop=BuildingValue LandValue TotalValue YearBuilt Acreage Bedrooms FullBath HalfBath);

   /* Create Sale Price Group */
   attrib SalePrice_Grp format=$char15.;
   label SalePrice_Grp = "Sale Price Group";
   
   select;
     when (SalePrice > 0 and SalePrice <= 99999) SalePrice_Grp = "Below 100K";
     when (SalePrice >=100000 and SalePrice <= 199999) SalePrice_Grp = "100K-199K";
     when (SalePrice >=200000 and SalePrice <= 299999) SalePrice_Grp = "200K-299K";
     when (SalePrice >=300000 and SalePrice <= 399999) SalePrice_Grp = "300K-399K";
     when (SalePrice >=400000 and SalePrice <= 499999) SalePrice_Grp = "400K-499K";
     when (SalePrice >=500000 and SalePrice <= 599999) SalePrice_Grp = "500K-599K";
     when (SalePrice >=600000) SalePrice_Grp = "600K+";
     Otherwise SalePrice_Grp = "Unknown";
   end;
 
   
   /*Create SaleYear*/
   SaleYear = Year(SaleDate);
   *attrib SaleYear format yyyy4.;
   label SaleYear = "Sale Year";
 
   /* Check dataset and missing count */
   proc freq data=tn_wip4;
   tables _all_ /maxlevels = 10 missing;
   run;


   

/* Look at outliers */

ODS select ExtremeObs;
proc univariate data=tn_wip4;
ID UniqueID;
run;

proc print data=tn_wip;
where UniqueID = 16302;
run;

/* No remediation required.  Values are valid */


Data mylib.TN_541_CLEANED;
set tn_wip4;

/* Post-cleaning */

ODS PDF File= "/home/u63413844/DataAnalysis/TN_StatsGraphs.pdf";

/*  Descriptive information on cleaned dataset */

title "Contents of Cleaned Dataset";
proc contents data=mylib.TN_541_CLEANED varnum;run;
title;

/* Basic Statistics */
ODS select Moments BasicMeasures histogram;
proc univariate data=mylib.TN_541_CLEANED;
      var SalePrice;
      histogram / normal;
   run;
   
/*  Data Visualization */

title "Number of Properties Sold by Year";  
proc sgplot data = mylib.TN_541_CLEANED;
  vbar SaleYear / datalabel;
  xaxis label = "Year Sold";
  run;
title;


title "Number of Properties Sold by Land Use Group";  
proc sgplot data = mylib.TN_541_CLEANED;
  vbar LandUse_grp / datalabel;
  run;
title;
  
title "Value of Property Sold by Land Use Group" ; 
proc sgplot data = mylib.TN_541_CLEANED;
  vbar LandUse_grp / response = SalePrice datalabel;
  yaxis label = "Sale Price";
  xaxis label = "Land Use Group";
  run;
title;
 
title  " Number Sold by Sale Price Group";
proc sgplot data = mylib.TN_541_CLEANED;
  vbar SalePrice_grp / datalabel;
  yaxis label = "Number Sold";
  run;
title;


title "Property Sold As Vacant ";
proc sgplot data = mylib.TN_541_CLEANED;
  vbar SoldAsVacant / datalabel;
  yaxis label = "Number Sold";
  xaxis label = "Property Sold As Vacant";
  run;
title;


 title "Value of Property Sold by City" ; 
proc sgplot data = mylib.TN_541_CLEANED;
  vbar Property_City / response = SalePrice datalabel;
  yaxis label = "Sale Price";
  xaxis label = "City";
  run;
title;


 title "Value of Property Sold by Year Sold" ; 
format SaleYear yyyy4.;
proc sgplot data = mylib.TN_541_CLEANED;
  vbar SaleYear / response = SalePrice datalabel;
  yaxis label = "Sale Price";
  xaxis label = "Year Sold";
  run;
title;

   
title "Number of Properties Sold by Land Use";  
proc sgplot data = mylib.TN_541_CLEANED;
  vbar LandUse / datalabel;
  run;
title;
   
title "Properties by Year Sold";  
proc sgplot data = mylib.TN_541_CLEANED;
  vbar SaleYear / group = LandUse_Grp groupdisplay = cluster datalabel;
  keylegend / title="Land Use" ;
  run;
title;


title "Properties by Year Sold";  
proc sgplot data = mylib.TN_541_CLEANED;
where LandUse_Grp = "HOME";
  vbar SaleYear / group = LandUse groupdisplay = cluster datalabel;
  keylegend / title="Home" ;
  run;
title;


ODS PDF Close;








