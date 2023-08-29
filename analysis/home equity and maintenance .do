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


gen flag =1 if hstenr==1 & cond_changed==1 //generate variable for being owner at when cond changed, 2182 people left
bysort id: egen own_at_change = max(flag)

////////////////////////////////////////////////////

//lfp around when a person gains access to superannuation 

lgraph lfp timesince, xline(0, lcolor(green)) nomarker

/////////////////////////////////////////////////////

//home equity around when a person gains access to superannuation 

//owners 

lgraph home_equity timesince if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home equity (thousands)") xtitle("super access"), //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper ---this artificially restricts to be owner at change, so make it seem more steep 

lgraph home_equity timesince super_quart if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home equity (thousands)"  xtitle("super access")) //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper. 

lgraph home_debt timesince if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home debt (thousands)" xtitle("super access")) //debt 

lgraph home_maintenance timesince if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home maintenance (thousands)"  xtitle("super access")) //owners, 

lgraph home_value timesince if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home value (thousands)"  xtitle("super access")) //owners, home value for some reason peak around super access 

/////////////////////////////////////////////////////

//all people 


lgraph home_equity timesince if timesince <=15 & timesince >= -15, xline(0, lcolor(green)) nomarker ytitle("home equity (thousands)") xtitle("super access") //

lgraph home_equity timesince super_quart if timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home equity (thousands)"  xtitle("super access")) //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper. 

lgraph home_debt timesince if timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home debt (thousands)") xtitle("super access") //debt 

lgraph home_maintenance timesince if & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home maintenance (thousands)")  xtitle("super access") //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper

lgraph home_value timesince if timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker ytitle("home value (thousands)") xtitle("super access") //owners, there appear to be some movement around super access (could be just due to retirement), the highest super quartile one change is steeper


//financial and physical upgrade for owners 


lgraph upgrade_financial timesince if timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker  //owners, home value for some reason peak around super access  //financial upgrade peaks around super access/retirement, then declines. 


lgraph upgrade_physical timesince if own_at_change==1 & timesince <=10 & timesince >= -10, xline(0, lcolor(green)) nomarker  //owners, home value for some reason peak around super access 













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



