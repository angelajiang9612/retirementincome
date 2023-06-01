
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

use "$data_output/housing_variables", clear 

compress

xtset id wave //set as panel 

by id (wave), sort: keep if hgage[1] >= 50 & !missing(hgage[1]) 

by id (wave), sort: keep if hstenr[1] == 1 //keep initial owners



//simple version where just looks at the first outcome when the first ownership spell ends, and see what that outcome is 

sort id wave 

by id: gen change=1 if (hstenr[_n] != hstenr[_n-1]) & _n!=1 //takes care of missing too
by id: replace change = change[_n-1] if change[_n-1] ==1 //replace the periods after by 1 
replace change =0 if missing(change) 
by id: keep if change ==0 | (change ==1 & change[_n-1]==0) //delete periods after the first observation of the second spell

gen failure = hstenr if change==1
gen failtime = wave  if change==1
by id: replace failure = failure[_N] //fill all the earlier waves with the final result
by id: replace failtime = failtime[_N] 

by id: replace failure = 0 if hstenr[_N] ==1 | hstenr[_N] ==. // own or attrition 
by id: replace failtime = _N if hstenr[_N] ==1 | hstenr[_N] ==. //record last period


//describe 
tab failure if wave==1 //this shows what happens to those people whose ownership ends. 

//generate a binary variable for stop being an owner, this includes renters and no rent stay 

generate end_ownership = (failure== 2| failure== 4)

egen age_group = cut(hgage), at(50,55,65,75,150) //divide into 50 to 54, 55 to 64 etc

sort id wave 
quietly by id:  gen dup = cond(_N==1,0,_n)
drop if dup>1


/////declare to be survival data////

stset failtime, failure(end_ownership=1)

sts graph //graph 

sts graph, failure 

sts graph, by(age_group) 

sts graph, by(age_group) failure 

sts graph, hazard //no estimates for the first five waves? 

////Ignore rent/stay for free spells of less than three years, because the rent might just be an intermediate thing. 

//Need to calculate the length of the second spell, if less than 3 periods later returns back to own then ignore this spell and look for the next time the thing changes. --basically just ignore any spells less than three years then do the plot 








/*
//use change in residency, and divide into upgrade downgrade and similar 


sort id wave 

by id: gen change=1 if mhli==1 | (mhli==. & _n!=1) //changed address or missing (both serve as a reason for a wave to be last wave)

by id: replace change = change[_n-1] if change[_n-1] ==1 //replace the periods after by 1 
replace change =0 if missing(change) 
by id: keep if change ==0 | (change ==1 & change[_n-1]==0) //delete periods after the first observation of the second spell //this might have issues for the always missing because their waves after the first missing is not deleted as they never change. 

gen failure = hstenr if change==1
gen failtime = wave  if change==1
by id: replace failure = failure[_N] //fill all the earlier waves with the final result
by id: replace failtime = failtime[_N] 

by id: replace failure = 0 if mhli[_N] ==2 | mhli[_N] ==. // never moved or attrition 
by id: replace failtime = _N if  mhli[_N] ==2 | mhli[_N] ==. //record last period

//describe 
tab failure if wave==1 //this shows what happens to those people after they first changed address. 25 percent of those who owned in the first period changed address but continue to be owners when the first residentila spell ended. 

*/


/*

//physical downsize and upsize 

sort id wave 

by id: gen change=1 if mhli==1 | (mhli==. & _n!=1) //changed address or missing except for last wave (both serve as a reason for a wave to be last wave)

by id: gen size =1 if change ==1 & hsbedrm < hsbedrm[_n-1] & hsbedrm!= . //downsize
by id: replace size=2 if change ==1 & hsbedrm == hsbedrm[_n-1] & hsbedrm!= . 
by id: replace size=3 if change ==1 & hsbedrm > hsbedrm[_n-1] & hsbedrm!= . //upsize 

by id: replace change = change[_n-1] if change[_n-1] ==1 //replace the periods after by 1 
replace change =0 if missing(change) 
by id: keep if change ==0 | (change ==1 & change[_n-1]==0) //delete periods after the first observation of the second spell //this might have issues for the always missing because their waves after the first missing is not deleted as they never change. 

gen failure = hstenr if change==1 & hstenr != 1 //for non own cases this is just the final 

replace failure = 11 if size ==1 & hstenr == 1 //downsize 
replace failure = 12 if size ==2 & hstenr == 1 
replace failure = 13 if size ==3 & hstenr == 1 

gen failtime = wave  if change==1
by id: replace failure = failure[_N] //fill all the earlier waves with the final result
by id: replace failtime = failtime[_N] 

by id: replace failure = 0 if mhli[_N] ==2 | mhli[_N] ==. // never moved or attrition 
by id: replace failtime = _N if  mhli[_N] ==2 | mhli[_N] ==. //record last period

//describe 
tab failure if wave==1 & failure !=3 //this shows what happens to those people after they first changed address. 25 percent of those who owned in the first period changed address but continue to be owners when the first residentila spell ended. 

//physical upgrade is small, only 5% of initial homeowners experienced physical upgrade after initial ownership spell 





//Financial upgrade/downgrade 

//Binary definition 

sort id wave 

by id: gen change=1 if mhli==1 | (mhli==. & _n!=1) //changed address or missing except for last wave (both serve as a reason for a wave to be last wave)

by id: gen c_value =1 if change ==1 & hsvalui < hsvalui[_n-1] & hsvalui!= . //downsize
by id: replace c_value=3 if change ==1 & hsvalui > hsvalui[_n-1] & hsvalui!= . //upsize 

by id: replace change = change[_n-1] if change[_n-1] ==1 //replace the periods after by 1 
replace change =0 if missing(change) 
by id: keep if change ==0 | (change ==1 & change[_n-1]==0) //delete periods after the first observation of the second spell //this might have issues for the always missing because their waves after the first missing is not deleted as they never change. 

gen failure = hstenr if change==1 & hstenr != 1 //for non own cases this is just the final 

replace failure = 11 if c_value ==1 & hstenr == 1 //downsize 
replace failure = 13 if c_value ==3 & hstenr == 1 

gen failtime = wave  if change==1
by id: replace failure = failure[_N] //fill all the earlier waves with the final result
by id: replace failtime = failtime[_N] 

by id: replace failure = 0 if mhli[_N] ==2 | mhli[_N] ==. // never moved or attrition 
by id: replace failtime = _N if  mhli[_N] ==2 | mhli[_N] ==. //record last period

//describe 
tab failure if wave==1 & failure !=3 //this shows what happens to those people after they first changed address. 25 percent of those who owned in the first period changed address but continue to be owners when the first residentila spell ended. 

//physical upgrade is small, only 5% of initial homeowners experienced physical upgrade after initial ownership spell 

//check what happened to missing with this construction (some missing values persist)



//Financial upgrade/downgrade 

//Three levels (include similar)

sort id wave 

by id: gen change=1 if mhli==1 | (mhli==. & _n!=1) //changed address or missing except for last wave (both serve as a reason for a wave to be last wave)

by id: gen c_value =1 if change ==1 & (hsvalui - hsvalui[_n-1] <= -10000 ) & hsvalui!= . //downsize
by id: replace c_value =2 if change ==1 & hsvalui - hsvalui[_n-1] < 10000 & hsvalui - hsvalui[_n-1] > -10000  & hsvalui!= . 
by id: replace c_value=3 if change ==1 & (hsvalui - hsvalui[_n-1] >= 10000 ) & hsvalui!= . //upsize 

by id: replace change = change[_n-1] if change[_n-1] ==1 //replace the periods after by 1 
replace change =0 if missing(change) 
by id: keep if change ==0 | (change ==1 & change[_n-1]==0) //delete periods after the first observation of the second spell //this might have issues for the always missing because their waves after the first missing is not deleted as they never change. 

gen failure = hstenr if change==1 & hstenr != 1 //for non own cases this is just the final 

replace failure = 11 if c_value ==1 & hstenr == 1 //downsize 
replace failure = 12 if c_value ==2 & hstenr == 1 //downsize 
replace failure = 13 if c_value ==3 & hstenr == 1 

gen failtime = wave  if change==1
by id: replace failure = failure[_N] //fill all the earlier waves with the final result
by id: replace failtime = failtime[_N] 

by id: replace failure = 0 if mhli[_N] ==2 | mhli[_N] ==. // never moved or attrition 
by id: replace failtime = _N if  mhli[_N] ==2 | mhli[_N] ==. //record last period

//describe 
tab failure if wave==1 & failure !=3 //this shows what happens to those people after they first changed address. 25 percent of those who owned in the first period changed address but continue to be owners when the first residentila spell ended. 

//physical upgrade is small, only 5% of initial homeowners experienced physical upgrade after initial ownership spell 

//having a middle group doesn't do much, only 1% fall into this category. 
*/


//Look at when ownership status for first ownership spell ends. Basically the idea is get a sense of whether different cohorts end ownership at different age.

//Do a basic versiony then disregard other spells of less than three years












//

egen rent = max(hstenr == 2), by(id) 

by id (wave), sort: gen diff=hstenr - hstenr[_n-1] if hstenr[_n-1]==2

egen max_diff =max(diff == -1) , by(id) 

replace rent=0 if max_diff==1 //close to 300 people rent for some period then become owner again, this makes a lot of difference, halve the size of people who can be considered renters. Only doing this underestimae renters. //


egen rent_last =max(hstenr[_N]==2) , by(id) 

replace rent=1 if rent_last==1 //if last period renter then renter, slight increase. 

gen event =1 if hstenr == 2

egen first_wave = min(wave / (event == 1)), by(id)

replace first_wave=20 if missing(first_wave) | rent==0 //change to attrition

sort id 
quietly by id:  gen dup = cond(_N==1,0,_n)
drop if dup>1

egen age_group = cut(hgage), at(50,55,65,75,150)

//rent or live with someone rent free

egen sold = max(hstenr == 2 | hstenr == 4), by(id) 








//physical downsize as the final result 


//hysical upsize as the final result 



//financial downsize (moving into less expensive house) as the final result 


//physical upsize (moving into more expensive house) as the final result 


//rent to own 


/////declare to be survival data////

stset first_wave, failure(rent=1)

sts graph //graph 

sts graph, by(age_group) ylabel(0.6(.1)1)

//can contrast with if don't do the rent thing 

sts graph, by(age_group) failure ylabel(0(.1)0.4) //plot failure instead 



























