/*******************************************************************************
Purpose: 
General/Frequently used commands in stata to describe data and run basic OLS regressions

Created on: 2/24/2022
By: Hersheena Rajaram

Last modified on: 2/24/2022
By: Hersheena Rajaram
    
*******************************************************************************/

clear all
set more off
macro drop _all
cap log close
program drop _all
matrix drop _all
set trace on
set tracedepth 1

global date = c(current_date)
global username = c(username)

** Step 1: Set your file paths - This is relevant for large projects 
global base "Y:\projects\MCAN"
global mcan_data "$base\data_final"
global temp_data "$base\data_temp"
global mcan_raw "$base\data_raw"
global mcan_log "$base\code_logs"
global results "$base\results"

* Step 2: Open log file
log using "${mcan_log}\summary_stats_${username}.log", replace 

*Step 3: Open your data
use "$mcan_data\pre_analysis_student_level.dta", clear


*Here are some general commands to describe the data

*Count - outputs the number of observations in the data
count

* Describe - describes variables in data
desc

*Summarize - outputs mean, std dev, min, max 
sum
sum varx vary
sum varx vary, d 	\\adding d as an option outputs detailed summary stats (quartile etc.)

* Tabulate - Breaks down the data by value. Especially useful for dummy and categorical variables
tab varx vary
tab varx vary,m 	\\includes missing observations

*Generate  - create new variable
gen var_new==.

*Replace - replace values in existing variables
replace var_new = 0 if var_new==.

* Help - look up commands
help replace

*OLS regression
reg varx vary \\vary is your outcome, varx is your independent variable

/* Other frequently used commands are
1. egen			\\more options to create new variables
2. graph export
3. esttab/estout 			\\outputs regression results in a nice table
4. forv/foreach			\\these are loops
*/

I added some code I used for a project for reference. And always close your log file

log close

/* Unused code

***CREATE SOME ADDITIONAL VARIABLES
* Urbanicity: create dummy variables to indicate city, suburb, town, and rural
gen urb_city= (urbanicity==1) if !missing(urbanicity)
gen urb_suburb= (urbanicity==2) if !missing(urbanicity)
gen urb_town= (urbanicity==3) if !missing(urbanicity)
gen urb_rural= (urbanicity==4) if !missing(urbanicity)
 
/* School type
gen type_oth = (school_type!=1) if !missing(school_type)
* type_other includes special education, vocational, other/alternaticve and program(new since 2008).
*/

* High grade, Low grade
egen highm=mode(highgrade), by(bcode)
egen lowm=mode(lowgrade), by(bcode)
tab lowm highm, m
gen highschool=(lowm>=9) if !missing(lowm)
drop highgrade lowgrade

* There is a meang8_score variable but it was only created for the g8score quartiles subgroup. Create a new average of standardized g8 math and reading scores, g8std.
egen g8std=rmean(mathg8 readingg8)

* ACT/New SAT Standardized Scores
gen act_sat_std=actstd if year<2017
replace act_sat_std=satstd if year>=2017

* Number of schools in district
egen nsch_in_dcode=count(bcode), by(dcode year)
replace nsch_in_dcode= 0 if dcode==.
replace nsch_in_dcode=. if charter==1
replace nsch_in_dcode =. if year ==.

* Generate dummy vars if there's 1, 2, 3-9 and >10 schools in a district
gen nsch_in_dcode1=nsch_in_dcode==1 if !missing(nsch_in_dcode)
gen nsch_in_dcode2=nsch_in_dcode==2 if !missing(nsch_in_dcode)
gen nsch_in_dcode3_9=nsch_in_dcode>2 & nsch_in_dcode<10 if !missing(nsch_in_dcode)
gen nsch_in_dcode10=nsch_in_dcode>=10 if !missing(nsch_in_dcode)

