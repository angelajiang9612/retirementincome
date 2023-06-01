
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
by id: egen eventwave = max(cond(event!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen timesinceevent = wave - eventwave //relative time to event 


////////////////outcome variables///////////////////////////////// 

gen lfp =(esbrd==1 | esbrd==2) 

//clean up retirement variable and calculate probability of retirement by time to p_age 


/*
// The basic version where just look at mean lfp relative to p_age 

sort timesinceevent
by timesinceevent: egen meanlfp_t = mean(lfp) //generate average lfp by relative time. 
egen tag_t = tag(timesinceevent) //tag distinct values so graph has one observation each, should do it by if not missing average group value if add group qualifier 

sort timesinceevent
twoway connected meanlfp_t timesinceevent if tag_t ==1 & rtcomp !=3,  xline(0, lcolor(green)) //this looks okay, something is obviously up at t=0 


*/

//look at subsamples 

/*
//working (lfp==1) at -10 periods before p_age

sort id 

by id: egen working_minus_10 = max(cond(lfp==1 & timesinceevent==-10, 1, 0))
by id: egen working_10 = max(working_minus_10)
sort timesinceevent working_10

by timesinceevent working_10: egen meanlfp_w10 = mean(lfp) 

egen tag_w10 = tag(timesinceevent) if working_10 ==1

sort timesinceevent
twoway connected meanlfp_w10 timesinceevent if tag_w10 ==1 & rtcomp !=3  & inrange(timesinceevent, -10,10) ,  xline(0, lcolor(green)) //this looks okay, something is obviously up at t=0, similar trend as before 

*/ 


////by superannuation amount///




//get the size of superannuation in the first available wealth wave before preservation age 
























//Use labor force participation first 



sort timesinceevent

twoway connected meanlfp_tw timesinceevent if tag_t ==1 & rtcomp !=3 & inrange(timesinceevent, -5,5) & working_5==1,  xline(0, lcolor(green)) //restrict to the group where can see working 10 periods before and working ==1 //



//something about the generate group mean is not working, many groups do not have mean








//Simply looking at lfp vs age and not superannuation//

sort hgage 

by hgage: egen meanlfp = mean(lfp) //calculate mean lfp by age 

egen tagage = tag(hgage) 

sort hgage
twoway connected meanlfp hgage if tagage ==1 & hgage <=70 & hgage >=45 & rtcomp !=3 //general graph of decline in lfp look pretty smooth. Look somewhat like it gets most steep around 55 for a bit then flatter again for a couple of periods then become more steep as heading towards mid 60s. 




































