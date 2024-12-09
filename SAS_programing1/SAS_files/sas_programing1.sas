/*
SAS Code from course SAS programming 1
Author: Misael López Sánchez.

Codes of example of how interact with SAS 9 to leaarn how to create, modify and alterate 
code in SAS language
*/

*A proc sentence process and create a report with the indicated steps.;
proc print data=sashelp.cars;
	by make; *print a table by each value in the column make;
	var make model type MPG_city MPG_Highway;
run;

*In SAS we can run information from an specific route of information like;
%let path=C:/Users/mizlop/Documents/SAS_programming1/EPG1V2/EPG1V2/data;

*Here we are reding information from the path using a macro variable in SAS for a table;
*proc contents - print the description of the SAS table;
proc contents data="&path/storm_summary.sas7bdat";
run;


*Check the contents description of one of our tables;
proc contents data=pg1.class_birthdate;
run;

*When we want to finish the conection with a libname we use 'clear';
libname pg1 clear;


*There are additional SAS option when we works with libname;
options validvarname=v7; *Specify that the name of variables should be string with 32 length;


/*
We also can use libname to read information that use different types of information for this we have
to use a dbms engine that specify what kind of source format we are using and the name of the table
*/
proc import datafile="&path/storm_damage.csv" dbms=csv 
	out=work.storm_damage_import replace;
run;

*Example 1: How to import with CSV complete;
proc import datafile="&path/np_traffic.csv" dbms=csv	
	out=work.traffic replace;
	guessingrows=max; *Help us to get the full name and avoid truncate the information (can be a number);
	delimiter=","; *specify the delimiters of the document;
run;

proc contents data=work.traffic;
run;
*End of first example;

*Example 2: Exploring Data with procedures;
*List first 20 rows;
proc print data=pg1.np_summary(obs=20);
	var Reg Type ParkName DayVisits TentCampers RVCampers;
run;

*Calculate summary statistics;
proc means data=pg1.np_summary;
	var DayVisits TentCampers RVCampers;
run;

*Examine extreme values;
proc univariate data=pg1.np_summary;
	var DayVisits TentCampers RVCampers;
run;

*The difference is that this generate tables of information from columns;
*List unique values and frequency counts;
proc freq data=pg1.np_summary;
	tables Reg Type;
run;
*End Example 2;

/* Challenge Practice 
pg1.eu_occ has information of montly occupancy counts for Europe from 2004-2017
*/
ods select extremeobs; *The five lowest and highest extreme observations are listed;
proc univariate data=pg1.eu_occ nextrobs=10; *We specify how many extreme values we want;
	var camp;
run;



*In SAS we can create an generate libraries when we store our data and information localy in SAS enviroment;
%let path=C:/Users/mizlop/Documents/SAS_programming1/EPG1V2/EPG1V2/data;
libname pg1 base "&path"; 

*Filtering expressions with SAS;
proc print data=sashelp.cars;
	var Make Model Type MSRP MPG_City MPG_Highway;
	where Type="SUV" and MSRP<=30000;
run;

*We can combine and modify this sentences;
proc print data=sashelp.cars;
	var Make Model Type MSRP MPG_City MPG_Highway;
	where Type in ("SUV","Truck","Wagon");
run;

*For dates we have to add the 'd' at the end of the sentence;
proc print data=pg1.storm_summary;
	where StartDate>="01jan2010"d; *The filter must match with the format date;
run;

/*
LIKE sentences are helpul to find strings inside the rows
% - Any number of characters
_ - Single character
*/

proc print data=pg1.storm_summary(obs=50);
	where name like "Z%";
run;

*Obiously we also can use macro variables in the where sentenses;
%let CarType=Wagon;

proc print data=sashelp.cars;
	where Type="&CarType";
	var Type Make Model MSRP;
run;

proc means data=sashelp.cars;
	where Type="&CarType";
	var MSRP MPG_Highway;
run;

proc freq data=sashelp.cars;
	where Type="&CarType";
	tables Origin Make;
run;

%let WindSpeed=156;
%let BasinCode=NA;
%let Date=01JAN2000;

proc print data=pg1.storm_summary;
	where MaxWindMPH>=&WindSpeed and Basin="&BasinCode" and StartDate>="&Date"d;
	var Basin Name StartDate EndDate MaxWindMPH;
run;

*Example 3: Use of national parks and filter information;
proc print data=pg1.np_summary;
	var Type ParkName;
	where ParkName like '%Preserve%'; *Be careful with capital letters!;
run;


* Example 3.1: Creating a Listing Report for Missing Data;
proc print data=pg1.eu_occ;
	where Hotel is missing and ShortStay is missing and Camp is missing;
run;

* Example 3.2: Using Macros to Subset data in procedures;
%let ParkCode=ZION;
%let SpeciesCat=Bird;

proc freq data=pg1.np_species;
	tables Abundance Conservation_Status;
	where Species_ID like "&ParkCode%" and Category = "&SpeciesCat";
run;

proc print data=pg1.np_species;
	var Species_ID Category Scientific_Name Common_Names;
	where Species_ID like "&ParkCode%" and Category="&SpeciesCat";
run;

* Example 4 Eliminating case sensitivity in WHERE conditions
Character comparation in WHERE are case sensitive, we use comparation functions to this;

/*
UPCASE(column)-Can be used to eliminate case sensitivity in character WHERE expression.
*/

proc print data=pg1.np_traffic;
	var ParkName Location Count;
	where Count NE 0 and upcase(Location) like '%MAIN ENTRANCE%';
run;

*Now lets see how to sort data using SAS; 
proc sort data=pg1.class_test2 out=test_sort; *The information will be generated in another table;
	by Subject descending TestScore;
run;

*Which storm in Norh Atlantic had the strongest Wind??;
proc sort data=pg1.storm_summary out=storm_sort;
	where Basin in ("NA" "na");
	by descending MaxWindMPH;
run;

/*
NODUPKEY - Keeps only first occurrence of each unique value.
_ALL_ - removes entirely duplicated rows.
*/

proc sort data=pg1.class_test3 out=test_clean
	nodupkey dupout=test_dups; *Table where duplicated values will be remove;
	by _all_;
run;

* Exercise 5: Sorting Data and Creating an Ouput table;
proc sort data=pg1.np_summary out=np_sort;
	by Reg descending DayVisits;
	where Type="NP";
run;

* Exercise 6: Sorting Data to Remove Duplicate Rows;
proc sort data=pg1.np_largeparks out=park_clean
	dupout=park_dups nodupkey;
	by _all_; *Remove duplicated rows for all columns;
run;

*(KEEP=Varlist) - Specify form a list the columns that we want in the final repor, informtion just 
requireed;

* Excersise 7: Creating a Lookup Table from a Detailed Table;
proc sort data=pg1.eu_occ(keep=geo country) out=countryList nodupkey;
	by Geo Country;
run;

*Now lets see how to create a subset of information as new table;

data myclass;
	set sashelp.class;
	where Age>=15;
	*Keep Name Age Height;
	drop Sex Weight;
	format Height 4.1 Weight 3.; *We also can add format;
run;

* Lets see an example;
data storm_Cat5;
	set pg1.storm_summary;
	where StartDate>="01JAN2000"d and MaxWindMPH>=156;
	keep Season Basin Name Type MaxWindMPH;
run;

* Exercise 8 - Creating a SAS Table;
data eu_occ2016;
	set pg1.eu_occ;
	where YearMon like "2016%";
	format Hotel ShortStay Camp comma17.;
	drop geo;
run;

/* Important Tip: If we would like to create permanent tables, We must submit a LIBNAME 
statement and the reference for this information.
*/ 
%let path_out=C:/Users/mizlop/Documents/SAS_programming1/EPG1V2/EPG1V2/output;
libname out base "&path_out"; 

*With this reference we generate a permanent table fox in the folder ouput; 
data out.fox;
	set pg1.np_species;
	where Category='Mammal' and upcase(Common_Names) like '%FOX%' 
		and upcase(Common_Names) not like '%SQUIRREL%'; *We obmit the case sensitive;
	drop Category Record_Status Ocurrence Nativeness;
run;
		
proc sort data=out.fox;
	by Common_Names;
run;

*How we can generate new columns in SAS tables??
For this we have to put a new name for the columns an add the expression;

data cars_new;
	set sashelp.cars;
	where Origin NE "USA";
	*Here we put the new columns;
	profit = MSRP-Invoice;
	Source = "Non-US Cars";
	*Here we specify the format;
	format profit dollar10.;
	keep Make Model MSRP Invoice Profit Source;
run;

*Other example;

data tropical_storm;
	set pg1.storm_summary;
	drop Hem_EW Hem_NS Lat Lon;
	where Type="TS";
	*Add assignment and FORMAT statements;
	MaxWindKM=MaxWindMPH*1.60934;
	format MaxWindKM 3.;
	StormType="Tropical Storm";
run;

data storm_length;
	set pg1.storm_summary;
	drop Hem_EW Hem_NS lat lon;
	StormLength = EndDate-StartDate+1;
run;

/*
NUMERIC FUNCTION IN SAS.
We just add functions when we are declaring new columns in SAS is very helpful to add more 
functions or facilities in SAS. 
*/
data storm_windavg;
	set pg1.storm_range;
	WindAVG=mean(wind1,wind2,wind3,wind4);
	WindRange=range(of wind1-wind4);
run;

/* Me quede 43 de 86 */

* More excersices of functions;
data storm_new;
	set pg1.storm_summary;
	drop Type Hem_EW Hem_NS MinPressure Lat Lon;
	*Add assignment statements;
	Basin=upcase(basin);
	Name=propcase(Name);
	Hemisphere=cats(Hem_NS, Hem_EW);
	Ocean=substr(Basin,2,1);
run;

* Excercise 9: New columns with dates;
	
data pacific;
	set pg1.storm_summary;
	drop type Hem_EW Hem_NS MinPressure Lat Lon;
	where substr(Basin,2,1)="P"; *Pacific ocean;
run;

* Example of how to use Date functions in SAS;

data storm_new_date;
	set pg1.storm_damage;
	drop Summary;
	*Add assignment and FORMAT statements;
	YearsPassed=yrdif(Date,today(),"age");
	Anniversary=mdy(month(Date), day(Date), year(today())); *mdy()-Return a SAS date value from numeric month;
	format YearsPassed 4.1 Date Anniversary mmddyy10.;
run;

* Excercise 9: Creating new Date columns;

data np_summary_update;
	set pg1.np_summary;
	keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping;
	SqMiles=Acres*0.0015625;
	Camping=sum(OtherCamping, TentCampers, RVCampers, BackcountryCampers);
	format SqMiles comma6. Camping comma10.;
run;

data eu_occ_total;
	set pg1.eu_occ;
	Year=substr(YearMon,1,4);
	Month=substr(YearMon,6,2);
	ReportDate=MDY(Month,1,Year);
	Total=sum(Hotel,ShortStay,Camp);
	format Hotel ShortStay Camp Total comma17. ReportDate monyy7.;
	keep Country Hotel ShortStay Camp ReportDate Total;
run; 

* Exercise 10: Creating a New Column with the SCAN Function;
data np_summary2;
	set pg1.np_summary;
	ParkType=scan(parkname,-1); *Provides a simple and convenient way to parse out words from strings;
	keep Reg Type ParkName ParkType;
run;

/* Conditional sentences in SAS
In SAS we can use the typical conditional sentences to evaluate boolean conditions with IF-ELSE, 
IF-THEN sentences */

data cars2;
	set sashelp.cars;
	if MSRP<30000 then Cost_Group=1;
	if MSRP>=30000 then Cost_Group=2;
	keep Make Model Type MSRP Cost_Group;
run;

data cars3;
	set sashelp.cars;
	if MPG_city>26 and MPG_Highway>30 then Efficiency=1;
	else if MPG_City>20 and MPG_Highway>25 then Efficiency=2;
	else Efficiency=3;
	keep Make Model MPG_City MPG_Highway Efficiency;
run;

* Excercise 11: Filters;

data storm_cat;
	set pg1.storm_summary;
	keep Name Basin MinPressure StartDate PressureGroup;
	*Add ELSE keyword and remove final condition;
	if MinPressure=. then PressureGroup=.; *NULL values or white values;
	else if MinPressure<=920 then PressureGroup=1;
	else PressureGroup=0;
run;

*In SAS we can measure the longitud of the strings using 'length';

data cars2;
	set sashelp.cars;
	length CarType $ 6; *Elements of length 6;
	if MSRP<60000 then CarType="Basic";
	else CarType="Luxury";
	keep Make Model MSRP CarType;
run;

* Other example of length;
data storm_summary2;
	set pg1.storm_summary;
	length Ocean $ 8;
	keep Basin Seaason Name MaxWindMPH Ocean;
	Basin=upcase(Basin);
	OceanCode=substr(Basin,2,1);
	if OceanCode="I" then Ocean="Indian";
	else if OceanCode="A" then Ocean="Atlantic";
	else Ocean="Pacific";
run;

* IF-THEN/DO Sentences;

data under40 over40;
	set sashelp.cars;
	keep Make Model msrp cost_group;
	if MSRP<20000 then do;
		Cost_Group=1;
		output under40;
	end;
	else if MSRP<40000 then do;
		Cost_Group=2;
		output under40;
	end;
	else do;
		Cost_Group=3;
		ouput over40;
	end;
run;

data front rear;
	set sashelp.cars;
	if DriveTrain="Front" then do;
		DriveTrain="FWD";
		output front;
	end;
	else if DriveTrain='Rear' then do;
		DriveTrain="RWD";
		output rear;
	end;
run;

* We even can work with 3 tables at the same time;
data indian atlantic pacific;
	set pg1.storm_summary;
	length Ocean $ 8;
	keep Basin Season Name MaxWindMPH Ocean;
	Basin=upcase(Basin);
	OceanCode=substr(Basin,2,1);
	*Modify the program to use IF-THEN-DO Syntax;
	if OceanCode="I" then do;
		Ocean="Indian";
		output indian;
	end;
	else if OceanCode="A" then do;
		Ocean="Atlantic";
		output atlantic;
	end;
	else do;
		Ocean="Pacific";
		output pacific;
	end;
run;

/* Me quede 54 de 86 */ 


* Exercise 12: Processing Statements Conditionally with Do groups
  - In this exercise we should split np_summary into two tables: parks, monuments;
  
* Create two temporary tables park & monuments;
data parks monuments; *Both tables has the same information;
	set pg1.np_summary;
	where type in ('NM', 'NP'); 
	Campers=sum(OtherCamping, TentCampers, RVCampers,
				BackcountryCampers);
	format Campers comma17.;	
run;

* We don't want exactly the same information in the same table, what could we do to
  separate the information? - Use conditional sentences;
  
data parks monuments;
	set pg1.np_summary;
	where type in ('NM','NP');
	Campers=sum(OtherCamping,TentCampers,RVCampers,
				BackcountryCampers);
	format Campers comma17.;
	* Here we start to separate the tables;
	length ParkType $ 8;
	if type='NP' then do;
		ParkType='Park';
		output parks; *Put information in table parks;
	end;
	else do;
		ParkType='Monument';
		output monuments;
	end;
	keep Reg ParkName DayVisits OtherLodging Campers ParkType;
run;

* Exercise 13: Processing Stetements conditionally with SELECT-WHEN Groups;
data parks monuments;
	set pg1.np_summary;
	where type in ('NM','NP');
	Campers=sum(OtherCamping,TentCampers,RVCampers,
				BackcountryCampers);
	format Campers comma17.;
	length ParkType $ 8;
	* We repeate the previous excercise, but now we use SELECT-WHEN sentences; 
	select (type);
		when ('NP') do;
			ParkType='Park';
			output parks;
				end;
				otherwise do;
			ParkType='Monument';
			output monuments;
				end; 
	end;
	keep Reg ParkNeme DayVisists OtherLodging Campers ParkType;
run;
		
	
/* New section: Titles, footnotes in SAS reports */

* This code generate a report or class birdthdate with add elements as two 
  titles and a footnote.;
title1 "Class Report";
title2 "All Students";
footnote1 "Report Generated on 01SEP2018";

proc print data=pg1.class_birthdate;
run;

* To clean the Values of title or fott note we just have to use the sentences without
  numbers:
  - TITLE -FOOTNOTE;

title; footnote; * Here the titble and footnote are disabled; 
proc means data=sashelp.heart;
	var height weight; run;
	
* Other example when both reports has same title but different subtitbles, same components
 can be shared between different reports;
title "Storm Analysis";
title2 "Summary Statistics for MaxWind and MinPressure";
proc means data=pg1.storm_final;
	var MaxWindMPH MinPressure; run;
title2 "Frequency Report for Basin";
proc freq data=pg1.storm_final;
	tables BasinName; run;

	
* Besides we can use macro-variables in reports;
%let age=13;

title1 "Class Report";
title2 "Age=&age"; *Here the macrovaraible;
footnote1 "Schol Use Only";

proc print data=pg1.class_birthdate;
	where age=&age; run;
 *Disabilitate the titles;
 title; footnote;
 
 /* LABEL col-name="label-Text" 
    The label just exists for the actual table and we have to declare it in the specific 
    row of information */

proc means data=sashelp.cars;
	where type="Sedan";
	var MSRP MPG_Highway;
	label MSRP="Manufacturer Suggested Retail Price"
		  MPG_Highway="Highway Miles per Gallon";
	run;
	
/* The exception is the PROC PRINT in the beggining of the sentence. In this case we
	just have to specify the label */
	
proc print data=sashelp.cars label; *Here the first label;
	where type="Sedan";
	var Make Model MSRP MPG_Highway MPG_City;
	label MSRP="Manufacturer Suggested Retail Price" /*Second label - Just rename the column*/
	      MPG_Highway="Highway Miles per Gallon"; run;
	      

	
/* Me quede 61 de 86*/

*Continue with the cars examples
 In this first step we create the data set to use;
data cars_update;
	set sashelp.cars;
	keep Make Model MSRP Invoice AvgMPG;
	AvgMPG=mean(MPG_Highway, MPG_City);
	label MSRP="Manufacturer Suggested Retail Price"
		  AvgMPG="Average Miles per Gallon"
		  Invoice="Invoice Price";
run;

* Here we use the data set previously created to generate a report;
proc means data=cars_update min mean max;
	var MSRP Invoice;
run;

proc print data=cars_update label;
	var Make Model MSRP Invoice AvgMPG;
run;

* Now lets see an example with the full graphics;
ads graphics on;
ads noproctitle;
title "Frequency Report for Basin and Storm Month";
proc freq data=pg1.storm_final order=freq nlevels;
	tables BasinName StartDate / nocum plots=freqplot(orient=horizontal scale=percent);
	format StartDate monname.;
	label BasinName="Basin"
	startDate="Storm Month";
run;
title;
ods proctitle;

* Just another single report;
title "Frequency Report for Basin and Storm Month";
proc freq data=pg1.storm_final order=freq noprint;
	tables StartDate / out=storm_count;
	format StartDate monname.;
run;

/* Now lets see an important point when we are working with tables and their columns, 
 the operator ´*´ help us to create a cartesian product with the columns of multiples tables like
 in the next example: (The final result is similar to 'Pivot Table' in Python) */

proc freq data=sashelp.heart;
	tables BP_Status*Chol_Status;
run;

proc freq data=pg1.storm_final;
	tables BasinName*StartDate;
	format StartDate monname.;
	label BasinName="Basin"
		  StartDate="Storm Month";
run;

*Excercise: Creating One-Way Frequency reportss;
title1 "Categories of Reported Species"; *Subreport;
proc freq data=pg1.np_species order=freq;
	tables Category / nocum;
run;

* What is the difference with this new code?
  The big difference si that here we add more funtionalities. 
  We add in the tables oparation the function of plots that plots a histogram according with each value
  and this is a full example of how to use graphics with filters and where sentences.
;

ods graphics on;
ods noproctitle;
title1 "Categories of Reported Species";
title2 "In the Everglades";
proc freq data=pg1.np_species order=freq;
	tables Category / nocum plots=freqplot;
	where Species_ID like "EVER%" and Category NE "Vascular Plant";
run;
title;

* Excercise: Creating Two-Way Frequency Reports (Similar-advance example) ;
*The problem with this table is that it has so much information! Is not normal for small reports.;
title 'Park Types by Region';
proc freq data=pg1.np_codelookup order=freq;
	tables Type*Region / nocol;
	where Type not like '%Other%';
run;

*Adding changes
critial commands:
	croslist: Allows filter the columns and add special sentences like grouyp by, scale and orient
	orient = specify how the data will be oriented according to  the first table or the second
	scale = stablish tha scale of data information to use.
	;


title1 'Selected Park Types by Region';
ods graphics on;
proc freq data=pg1.np_codelookup order=freq;
	tables Type*Region / nocol crosslist
		plots=freqplot(groupby=row scale=grouppercent orient=horizontal);
	where Type in ('National Historic Site', 'Noational Monument', 'National Park');
run;
title;

*In SAS we can create an generate libraries when we store our data and information localy in SAS enviroment;
%let path=C:/Users/mizlop/Documents/SAS_programming1/EPG1V2/EPG1V2/data;
libname pg1 base "&path"; 

/* Me quede 68 de 86 */

*Excercise challenge: Creating and customized graph
sgplot - create multiple graphs that overlay in the same graph
;

proc sgplot data=pg1.np_codelookup;
	where Type in ('National Historic Site', 'National Monumnet',
	 			   'National Park');
	hbar region / group=type seglabel; *Put labels to the bar;
	 		      fillattrs=(transparency=0.5) dataskin=crisp;
	keylegent / opaque across=1 position=bottomright
	            location=inside;
	xaxis grid;  *Put grid in the graph;
	yaxis grid;
run;
title;

/* Other method to generate small summaries is use the CLASS sentence that allows generate
reports using class to group information */

proc means data=pg1.storm_final mean median min max maxdec=0;
	var MaxWindMPH; *This is the analysis variable for all tables;
	class BasinName StormType; *Generate a table for each one and a pivot table with both;
	ways 0 1 2; *Group by var, class1 class2;
run;


*If we obmit the way sentence create a single pivot table with the information;
proc means data=pg1.storm_final maxdec=0 n mean min;
	var MinPressure;
	where Season >= 2010;
	class Season Ocean; run;

*We can play with the ways option to add or rest tables of visualization;
proc means data=pg1.storm_final maxdec=0 n mean min;
	var MinPressure;
	where Season>=2010;
	class Season Ocean;
	ways 1; run;

*As the same way we can generate output result for our tables and results;

/* Other example creating a table of output */

proc means data=pg1.storm_final noprint; *Supress the statical report;
	var MaxWindMPH;
	class BasinName;
	ways 1; output out=wind_stats mean=AvgWind max=MaxWind; 
run;

/* Practice 1: Producing a descriptive statistic report 
The advantage of using clases is that this generate a report like a pivot table.*/
title1 'Weather Statistics by Year and Park';
proc means data=pg1.np_westweather mean min max maxdec=2;
	var Precip Snow TempMin TempMax;
	class Year Name; run;
	
/* Practice 2: Creating an ouput table with custom columns */
proc means data=pg1.np_westweather noprint;
	where Precip NE 0;
	var Precip;
	class Name Year;
		ways 2;
		output out=rainstats n=RainDays sum=TotalRain; run;

/* What is the difference with the previous excrcise?
	- The code generate a ouput table in work enviroment.
	- No generate a pivot table report becase use the parameter ways 2
	- We modified the ouput columns with specific methods.*/
	
*Other example;
title1 'Rain Statistics by Year and Park';
proc print data=rainstats label noobs; *Suprim the observation label in the ouput;
	var Name Year RainDays TotalRain;
	label Name='Park Name' /*Here we use a label to generate information and data*/
		RainDays='Number of Days Raining'
		TotalRain='Total Rain Amount (inches)';
run;
title;

/*  HOW TO EXPORT OUR WORK from SAS to Local Server */

proc export data=sashelp.cars
	outfile="C:\Users\mizlop\Documents\SAS_programming1\EPG1V2\EPG1V2\output\cars.txt"
	dbms=tab replace; *Tab is the motor for .txt files;
run;

/* Lets see how to create macro variables to store our outputs
   syntax: %let outpath= filepath-to-output-folder;
*/

%let outpath=C:\Users\mizlop\Documents\SAS_programming1\EPG1V2\EPG1V2\output;
proc export data=pg1.storm_final
	outfile="&outpath/storm_final.csv" /* Here we save the data with the outpath */
	dbms=csv replace; run;

*Example of how to use ods outputs;

ods csvall file="&outpath/cars.csv";
proc print data=sashelp.cars noobs;
	var Make Model Type MSRP MPG_City MPG_Highway;
	format MSRP dollar8.;
run;
ods csvall close;

/* Example of how to use ods of excel */

title "Minimum pressure Statistics by Basin";
ods noproctitle;
proc means data=pg1.storm_final mean median min maxdec=0;
	class BasinName;
	var MinPressure;
run;

title "Correlation of Minimum Pressure and Maximum Wind";
proc sgscatter data=pg1.storm_final;
		plot minpressure*maxwindmph;
run;
title;

ods proctitle;
ods excel close;

/* Can we export our information ot PDF? */

ods pdf file="outpath/wind.pdf" startpage=no style=journal pdftoc=1;
ods noproctitle;

ods proclabel "Wind Statistics";
title "Wind Statiwstics by Basin";
proc means data=pg1.storm_final min mean median max maxdec=0;
	class BasinName;
	var MaxWindMPH; run;
	
ods proclabel "Wind Distribution";
title "Distribution of Maximum Wind";
proc sgplot data=pg1.storm_final;
	histogram MaxWindMPH;
	density MaxWindMPH;
run;
title;


* Examples with ODS EXCEL;

ods excel file="&outpath/StormStats.xlsx"
	style=snow
	options(sheet_name='South Pacific Summary');
ods noproctitle;

proc means data=pg1.storm_detail maxdec=0 median max;
	class Season;
	var Wind;
	where Basin='SP' and Season in (2014,2015,2016);
run;

ods excel options(sheet_name='Detail');

proc print data=pg1.storm_detail noobs;
	where Basin='SP' and Season in (2014,2015,2016);
	by Season; run;
	
ods excel close;
ods proctitle;

/* Creating a Document with ODS RTF */

ods rtf file="&outpath/ParkReport.rtf" style=Journal startpage=no;

ods noproctitle;
options nodate;

title "US National Park Regional Usage Summary";

proc freq data=pg1.np_final;
	tables Region / nocum; run;
	
proc means data=pg1.np_final mean median max nonobs maxdec=0;
	class Region;
	var DayVisits Campers; run;
	
ods rtf style=SASDocPrinter;

title2 'Day Vists vs. Camping';
proc sgplot data=pg1.np_final;
	vbar Region / response=DayVisits;
	vline Region / response=Campers;
run;
title;

ods proctitle;
ods rtf close;
options date;


/* Practice: Creating a Landscape Report with ODS PDF */

options orientation=landscape;
ods pdf file="&outpath/StormSummary.pdf" style=Journal nobookmarkgen;

title1 "2016 Northern Atlantic Storms";

ods layout gridded columns=2 rows=1;
ods region;

proc sgmap plotdata=pg1.storm_final;
	*Open street map;
	esrimap url='http://services.arcgisonline.com/arcgis/rest/services/World_Physical_Map';
	bubble x=lon y=lat size=maxwindmph / datalabel=name datalabelattrs=(color=red size=8);
	where Basin='NA' and Season=2016;
	keylegend 'wind'; run;
	
ods region;
proc print data=pg1.storm_final noobs;
	var name StartDate MaxWindMPH StormLength;
	where Basin="NA" and Season=2016;
	format StartDate monyy7.; run;
	
ods layout end;
ods pdf close;
options orientation=portrait;


/* USING SQL IN SAS!!!! */

proc sql;
select Name, Age, Height, Birthdate format=date9.
	from pg1.class_birthdate;
quit;

proc sql;
select Name, Age, Height*2.54 as HeightCM format=5.1,
		Birthdate format=date9.
		from pg1.class_birthdate;
quit;

/* Creating tables in SAS SQL */

proc sql;
create table work.myclass as 
	select Name, Age, Height
	from pg1.class_birthdate
	where age>14
	order by Height desc; quit;

* Droping or deleate table;
proc sql;
	drop table work.myclass;
quit;

* Using of JOINS;
proc sql;
select Grade, Age, Teacher
	from pg1.class_update inner join pg1.class_teachers *both tables should be previously sorted;
	on class_update.Name = class_teachers.Name;
quit;


*Renaiming variables;
proc sql;
select u.Name, Grade, Age, Teacher
	from pg1.class_update as u 
	inner join pg1.class_teachers as t 
	on u.Name=t.Name;
quit;


