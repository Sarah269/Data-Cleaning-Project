
/*Upload Housing_1 Excel to SAS Server
/*Reference uploaded Housing_1 Excel file

libname Housing xlsx "/home/u63413844/DataAnalysis/Housing_1.xlsx";

/*View datasets in Housing library reference
proc contents data=housing._all_;
run;


/*Create a new library
libname mylib "/home/u63413844/DataAnalysis";

/*Create Housing sas dataset
Data mylib.TN_541;
  set housing.sheet1;
run;

