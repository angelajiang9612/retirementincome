
*Author: Angela Jiang 

*This dofile...

*Input Data: 
*Output files:


clear 

version 17.0

cap log close 

set more off 

macro drop _all

set seed 0102

cd "/Users/bubbles/Desktop/Retirement_Income/dofile" 

log using describe_super.log , text replace 

global folder_path "/Users/bubbles/Desktop/Hilda" 

global data_output "$folder_path/output"

use "$data_output/housing_variables", clear 

compress

//using birth year and age at the June 30 to generate preservation age 


by id: gen p_age = 55 if hgyob <= 1959
by id: replace p_age = 55 if  hgyob == 1960 & hgage[1] == 41 
by id: replace p_age = 56 if  hgyob == 1960 & hgage[1] == 40
by id: replace p_age = 56 if  hgyob == 1961 & hgage[1] == 40
by id: replace p_age = 57 if  hgyob == 1961 & hgage[1] == 39
by id: replace p_age = 57 if  hgyob == 1962 & hgage[1] == 39
by id: replace p_age = 58 if  hgyob == 1962 & hgage[1] == 38
by id: replace p_age = 58 if  hgyob == 1963 & hgage[1] == 38
by id: replace p_age = 59 if  hgyob == 1963 & hgage[1] == 37
by id: replace p_age = 59 if  hgyob == 1964 & hgage[1] == 37
by id: replace p_age = 60 if  hgyob == 1964 & hgage[1] == 36
by id: replace p_age = 60 if  hgyob >= 1965 

//1.45% missing, probably related to top-up sample need to check 


//generate event reaching preservation age 

gen event=(p_age == hgage)
by id: egen eventwave = max(cond(event!=0, wave, .)) //max ignore missing values 
gen timesinceevent = wave - eventwave 


////////////////outcome variables///////////////////////////////// 

gen lfp =(esbrd==1 | esbrd==2) 

//clean up retirement variable and calculate probability of retirement by time to p_age 


sort timesinceevent
by timesinceevent: egen meanlfp_t = mean(lfp)
egen tag_t = tag(timesinceevent)


////qualifiers//// 

//Only people we see around p_age will be used in the graphs

sort id 
by id: egen working_45 = max(cond(lfp==1 & hgage==45, 1, 0))

sort id 

gen working_minus_5= cond(lfp==1 & timesinceevent== -5, 1, 0)

by id: egen working_5 = max(working_minus_5)


sort timesinceevent working_5
by timesinceevent working_5: egen meanlfp_tw = mean(lfp) //need to do by group means like this

////by superannuation amount///

//get the size of superannuation in the first available wealth wave before preservation age 




//Use labor force participation first 


sort hgage 

by hgage: egen meanlfp = mean(lfp) //calculate mean lfp by age 

egen tagage = tag(hgage) 

sort hgage
twoway connected meanlfp hgage if tagage ==1 & hgage <=70 & hgage >=45 & working_45==1 & rtcomp !=3 

sort timesinceevent

twoway connected meanlfp_t timesinceevent if tag_t ==1 & rtcomp !=3 & inrange(timesinceevent, -10,10),  xline(0, lcolor(green)) //this looks okay 


sort timesinceevent

twoway connected meanlfp_tw timesinceevent if tag_t ==1 & rtcomp !=3 & inrange(timesinceevent, -5,5) & working_5==1,  xline(0, lcolor(green)) //restrict to the group where can see working 10 periods before and working ==1 //



//something 












































