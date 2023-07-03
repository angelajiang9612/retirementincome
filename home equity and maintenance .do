//This filed computes super and retirement variables 


*Author: Angela Jiang 
*Written on a mac 

*This dofile computes trend descriptives for housing around when people gain access to superannuation funds 


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

use "$data_output/all_variables.dta", clear 

compress

xtset id wave //set as panel 
//using birth year and age at the June 30 to generate preservation age 

////////////////////////////

//generate cond_changed, variable that indicates the first time the person met condition of release for super
//probably still noisy 

////////////////////////////

gen changed_cpq =1 if pjsemp ==2  //this is only asked of last period employed people 
replace changed_cpq =0 if pjsemp ==1
replace changed_cpq =1 if pjmsemp ==2 //main job for multiple employers 
replace changed_cpq =0 if pjmsemp ==1 //result is 60% missing overall and 14 percent missing for employed people 

gen changed_scq =1 if lejob ==2
replace changed_scq =0 if lejob ==1

gen j_changed =1 if changed_scq==1 | changed_cpq ==1
replace j_changed =0 if (changed_scq ==0 & changed_cpq ==0) | (changed_scq ==0 & changed_cpq ==.) | (changed_scq ==. & changed_cpq ==0) //if reported zero in both or zero in one and missing in the other 

gen reached_page = (hgage >= p_age & !missing(hgage))
gen sixty_plus = (hgage >= 60 & !missing(hgage))

gen cond_release1 =1 if reached_page==1 & retirement_status==1
gen cond_release2 =1 if sixty_plus ==1 & j_changed==1 
gen cond_release3 =1 if hgage>= 65

forval i= 1/3 {
	bysort id (wave): replace cond_release`i'=1 if cond_release`i'[_n-1] ==1 
	replace cond_release`i' =0 if missing(cond_release`i')
	by id: gen cond_changed`i' =1 if cond_release`i' - cond_release`i'[_n-1] ==1 
	replace cond_changed`i' =0 if missing(cond_changed`i')
}

gen cond_release =1 if cond_release1 ==1 | cond_release2 ==1 | cond_release3 ==1
bysort id (wave): replace cond_release=1 if cond_release[_n-1] ==1 
replace cond_release =0 if missing(cond_release)
by id: gen cond_changed =1 if cond_release - cond_release[_n-1] ==1 
replace cond_changed =0 if missing(cond_changed)


gen p_observed =1 if hgage ==p_age

bysort id: egen keep = max(p_observed)

keep if keep==1 //keep those we see at preservation age 


/////////////////////////////////////////////////
//Generate event 
////////////////////////////////////////////////

gen event=(cond_changed == 1) 
by id: egen ewave = max(cond(event!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen timesince = wave - ewave //relative time to event 

//////////////////////////////////////////////////


/////////////////////////////////////////////////
//Generate Housing Related Variables  
////////////////////////////////////////////////

gen home_equity = hsvalui - hsdebti  //both of the imputed value already have no missing values and has hsvalui equal to 0 for the not asked cases 

//should deflate to 2001 dollars or something

gen flag =1 if hstenr==1 & cond_changed==1 //generate variable for being owner at when cond changed, 2182 people left
bysort id: egen own_at_change = max(flag)




////////////////////////////////////////////////////

//lfp around when a person gains access to superannuation 

lgraph lfp timesince, xline(0, lcolor(green)) nomarker

/////////////////////////////////////////////////////


//home equity around when a person gains access to superannuation 

lgraph home_equity timesince super_quart if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper. 

lgraph hsdebti timesince super_quart if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker //debt 


/////////////////////////////////////////////////////











lgraph own timesince_a if super_quart==3 | super_quart==4 , xline(0, lcolor(green)) nomarker //not sure why there is a weird dip in the middle. 
















/*

Some Notes 

Construction of variables 

pjsemp & pjmsemp: Do you still work for the same employer (or in the same business)?
lejob : SCQ:B23q Life events in past year: changed jobs (i.e. employers)

Using the pj variables get annual job turnover of 15.99 per cent using lejob get 13.19, difference could be the first one also counts self-employed people ending their business. 15% of people who reported no change in scq reported a change in cpq, 4.75  of those who reported no change in cpq reported a change in scq.  yearly rate of change is 14.78  because also consider the case of missing one of the reponses. 

The final indicator for changing jobs is if reported a change in either scq or cpq, 

In theory finishing not the main job but any other jobs could also lead to super access being met 

cond_changed indicator observed change in super eligibility condition for 4,341 people 

Break down to how the change happened, tab cond_changed`i' if cond_changed==1


(1) 2728 (2) 628 (3) 1308    ==sum 4664 , so 2 and 3 are variations not caused by retirement 

//most people meet the condition using 1 or 2 and not 3. 2 required the person to not ever has status as retired before 65 and never changed a job. So most of my change is from early retirement. There must be some people retired at 65 exactly? 353 

//drop people who we do not see at preservation age because we don't know if they had reached release condition before we observe them

now there is only 2671 people left, in theory these should be people who are working

1,737 -414 - 645 breakdown. 


//check if there is a reason why cond_changed rarely equals to 1 in wave 4

//use imputed values for housing value and debt 

*/



