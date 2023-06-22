
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


log using housing_describe.log , text replace 


global folder_path "/Users/bubbles/Desktop/Hilda" 

global data_output "$folder_path/output"

use "$data_output/combined", clear 

compress

xtset id wave //set as panel 

by id (wave), sort: keep if hgage[1] >= 50 & !missing(hgage[1]) 

by id (wave), sort: keep if hstenr[1] == 2 | hstenr[1] == 4 //keep initial renters 

replace hstenr =2 if hstenr==4 //for now treat the two rental groups as the same. 

//first rental tenure results 

sort id wave 

by id: gen flag=1 if missing(hstenr)  //drop waves after a key variable becomes missing
by id : replace flag=flag[_n-1] if flag[_n-1]==1
drop if flag==1 
drop flag 

by id: gen change=1 if (hstenr[_n] != hstenr[_n-1]) & _n!=1 & !missing(hstenr) & !missing(hstenr[_n-1]) //change ownership status (in principal can live in the same place)
by id: egen failtime= min(cond(change == 1, wave, .)) //record the first time change turned 1 
by id: egen failure = min(cond(wave == failtime, hstenr, .))

by id: replace failure = 0 if missing(failure) // attrition 
by id: replace failtime = _N if missing(failtime) //record period attrition happened. 


label define outcomes 0 "0 attrition" 1 "1 ownership" 3 "3 rent-buy scheme" 
label values failure outcomes

tab failure if wave==1 
