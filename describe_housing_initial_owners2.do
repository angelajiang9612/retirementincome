
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

by id (wave), sort: keep if hstenr[1] == 1 //keep initial owners



//1.simple version where just looks at the first outcome when the first ownership spell ends (end if move address), and see what that outcome is 

//the main point is to generate a dataset that has id, failure (the final outcome when change happened) and failtime (when this change happened) 
//something who dropped after 3 waves and someone who dropped out after 20 waves both count as attrition but at different times. 

sort id wave 

by id: gen flag=1 if missing(hstenr) | (missing(mhli) & _n!=1)  //drop waves after a key variable becomes missing
by id : replace flag=flag[_n-1] if flag[_n-1]==1
drop if flag==1 
drop flag 

by id: gen change=1 if (hstenr[_n] != hstenr[_n-1]) & _n!=1 & !missing(hstenr) & !missing(hstenr[_n-1]) //change ownership status (in principal can live in the same place)
replace change =1 if mhli==1 //change address 
by id: egen failtime= min(cond(change == 1, wave, .)) //record the first time change turned 1 
by id: egen failure = min(cond(wave == failtime, hstenr, .))

by id: replace failure = 0 if missing(failure) // attrition 
by id: replace failtime = _N if missing(failtime) //record period attrition happened. 

//describe 
label define outcomes 0 "0 attrition" 1 "1 ownership" 2 "2 rent" 3 "3 rent-buy scheme" 4 "4 rent free"
label values failure outcomes
tab failure if wave==1 //this shows what happens to those initial owners (after the end of the first ownership spell)

/*

//1.b As above but divide move into another ownership phase into physical upgrade and downgrade 

by id: gen size =1 if  hsbedrm < hsbedrm[_n-1] & _n!=1 & !missing(hsbedrm) & !missing(hsbedrm[_n-1]) 
by id: replace size=2 if hsbedrm == hsbedrm[_n-1] & _n!=1 & !missing(hsbedrm) & !missing(hsbedrm[_n-1]) 
by id: replace size=3 if hsbedrm > hsbedrm[_n-1] & _n!=1 & !missing(hsbedrm) & !missing(hsbedrm[_n-1]) 

by id: egen sizechange =  min(cond(wave == failtime, size, .))

replace failure = 11 if sizechange ==1 & failure ==1
replace failure = 12 if sizechange ==2 & failure ==1
replace failure = 13 if sizechange ==3 & failure ==1


label define outcomes_phys 0 "0 attrition" 1 "1 ownership" 2 "2 rent" 3 "3 rent-buy scheme" 4 "4 rent free" 11 "1.1 physical downgrade" 12 "1.2 size unchanged" 13 "1.3 physical upgrade"
label values failure outcomes_phys
tab failure if wave==1 & failure != 1 & failure != 3 //divide ownership change by size of new home
*/

//1.c As above but divide move into another ownership phase into financial upgrade and downgrade 

by id: gen c_value =1 if hsvalui - hsvalui[_n-1] <= -10000  & _n!=1 & !missing(hsvalui) & !missing(hsvalui[_n-1]) 

by id: replace c_value =2 if  hsvalui - hsvalui[_n-1] < 10000 & hsvalui - hsvalui[_n-1] > -10000 & _n!=1 & !missing(hsvalui) & !missing(hsvalui[_n-1]) 
by id: replace c_value=3 if hsvalui - hsvalui[_n-1] >= 10000  & _n!=1 & !missing(hsvalui) & !missing(hsvalui[_n-1]) 

by id: egen financialchange =  min(cond(wave == failtime, c_value, .))

replace failure = 11 if financialchange ==1 & failure == 1 //downsize 
replace failure = 12 if financialchange ==2 & failure == 1 //downsize 
replace failure = 13 if financialchange ==3 & failure == 1 

label define outcomes_phys 0 "0 attrition" 1 "1 ownership" 2 "2 rent" 3 "3 rent-buy scheme" 4 "4 rent free" 11 "1.1 financial downgrade" 12 "1.2 +/- 10,000" 13 "1.3 financial upgrade"
label values failure outcomes_phys
tab failure if wave==1 & failure != 1 & failure != 3 //divide ownership change by value of new home

//financial upgrade is more likely than physical upgrade


/*
//2.Rental tenure after the first ownership spell ends /graph 
//Need to start again rather than just use the above because mhli is no longer a key variable and we might not want to delete all observations after mhli is missing
//Also the definition of change is different now. 

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

tab failure if wave==1 
generate end_ownership = (failure== 2 | failure== 4)

egen age_group = cut(hgage), at(55,65,75,150) 

sort id wave 
quietly by id:  gen dup = cond(_N==1,0,_n) //drop the other waves
drop if dup>1

/////declare to be survival data////

stset failtime, failure(end_ownership=1) //survival graph that estimates probability of survival with analysis time
sts graph //graph  

sts graph, by(age_group) //my shape looks similar to the whelan et al ones in terms of the younger two groups being very similar and the oldest group very different, but the estimates are bigger. 

*/












