/*Excel file Housing_1.xslx Data Cleaning*/
/*SAS library: mylib*/
/*Dataset:  TN_541.  Records = 541.  19 Variables.*/


/*Setup library reference to point to location of sas dataset*/
libname mylib "/home/u63413844/DataAnalysis";

/*View datasets in library*/
proc contents data=mylib._all_ nobs; run;

/*Add informat and/or format information*/

Data mylib.TN_541;
   set mylib.TN_541;
   attrib Acreage informat=8.2 format=8.2;
   attrib Bedrooms FullBath HalfBath informat=8. format=8.;
   attrib LandValue  BuildingValue TotalValue informat=15. format=comma15.;
   attrib SalePrice UniqueID informat=15.;
   attrib YearBuilt informat=4.;

/*View attributes for TN_541*/
proc contents data=mylib.TN_541; run;

/*Create SaleYear*/
Data mylib.TN_541_Cleaned;
  set mylib.TN_541;
  SaleYear = Year(SaleDate);
  attrib SaleYear informat=4.;
  label SaleYear = "Sale Year";

/*View attributes for TN_541_Cleaned */
proc contents data=mylib.TN_541_CLEANED;run;
  
   
/*Separate PropertyAddress into multiple fields*/
Data mylib.TN_541_Cleaned;
   set mylib.TN_541_Cleaned;
   /*Property Address*/
   Length Property_Address $42;
   Length Property_Address_City $30;
   Property_Address = scan(PropertyAddress,1,',');
   Property_Address_City = scan(PropertyAddress,2,',');
   attrib Property_Address format=$char42.; 
   Label Property_Address = "Property Address";
   attrib Property_Address_City format= $char30.; 
   Label Property_Address_City = "Property Address City";
run; 
 
proc print data = mylib.TN_541_Cleaned;
  var PropertyAddress Property_Address Property_Address_City;
run;
 
/*Separate OwnerAddress into multiple fields*/
Data mylib.TN_541_Cleaned;
   set mylib.TN_541_Cleaned;
   /*Owner Address*/
   Length Owner_Address $42;
   Length Owner_Address_City $30;
   Length Owner_Address_State $3;
   Owner_Address = scan(OwnerAddress,1,',');
   Owner_Address_City = scan(OwnerAddress,2,',');
   Owner_Address_State = scan(OwnerAddress,3,',');
   attrib Owner_Address  format=$char42.; 
   Label Owner_Address = "Owner Address";
   attrib Owner_Address_City format= $30.;
   Label Owner_Address_City = "Owner Address City";
   attrib Owner_Address_State format = $char3.;
   Label Owner_Address_State = "Owner Address State";
run;  

proc print data = mylib.TN_541_Cleaned;
  var OwnerAddress Owner_Address Owner_Address_City Owner_Address_State;
run;

   
/*Look at the data values for SoldAsVacant*/
proc sql;
select SoldAsVacant, count(*)
from mylib.TN_541_Cleaned
group by SoldAsVacant;
quit;

/*Standardize the values for SoldAsVacant*/
Data mylib.TN_541_Cleaned;
  set mylib.TN_541_Cleaned;
  select (SoldAsVacant);
     When ("N") SoldAsVacant = "No";
     when ("Y") SoldAsVacant = "Yes";
     Otherwise SoldAsVacant=SoldAsVacant;
  end;
run;

/*Check values for SoldAsVacant*/
proc sql;
select SoldAsVacant, count(*)
from mylib.TN_541_Cleaned
group by SoldAsVacant;
quit;


/*Check for duplicates*/
proc sql;
select uniqueid, count(*)
from mylib.TN_541_cleaned
group by uniqueid
having count(*)>1;


/*Browse properties with multiple entries*/
proc sql;
select *
from mylib.TN_541_cleaned
where parcelid in (
select parcelid
from mylib.TN_541_Cleaned
group by parcelid
having count(*) > 1
)
order by parcelid;
quit;

/*Look at values for Fullbath halfbath bedrooms landuse*/
proc freq data = mylib.TN_541_Cleaned;
tables Bedrooms Fullbath Halfbath landuse;
run;

/*Standardize LandUse value Vacant Residential Land*/
proc sql;
select *
from mylib.TN_541_cleaned
where landuse = 'VACANT RES LAND';

Data mylib.TN_541_Cleaned;
  set mylib.TN_541_Cleaned;
  select (LandUse);
    when ("VACANT RES LAND") Landuse = "VACANT RESIDENTIAL LAND";
    Otherwise LandUse = LandUse;
  end;
run; 

/*Group LandUse into Groups*/
Data mylib.TN_541_Cleaned;
  set mylib.TN_541_Cleaned;
  length LandUse_Grp $10;
  attrib LandUse_Grp format=$CHAR10.;
  Label LandUse_Grp = "LandUse Group";
  select (LandUse);
    when ("CHURCH") LandUse_Grp = "CHURCH";
    when ("DUPLEX") LandUse_Grp = "HOME";
    when ("RESIDENTIAL CONDO") LandUse_Grp = "HOME";
    when ("SINGLE FAMILY") LandUse_Grp = "HOME";
    when ("ZERO LOT LINE") LandUse_Grp = "HOME";
    when ("VACANT RESIDENTIAL LAND") LandUse_Grp = "LAND";
    when ("VACANT RURAL LAND") LandUse_Grp = "LAND";
    Otherwise LandUse_Grp = "OTHER";
    end;
run;

proc sql;
select LandUse, LandUse_Grp, count(*)
from mylib.TN_541_Cleaned
group by LandUse, LandUse_Grp;
quit;