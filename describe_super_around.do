
*Author: Angela Jiang 

*This dofile computes some lfp and retirement probability means around superannuation preservation age and superannuation access time. 

*Input Data: super.dta (with retirement and super variables)

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

use "$data_output/all_variables.dta", clear 

compress

xtset id wave //set as panel 
//using birth year and age at the June 30 to generate preservation age 

//generate event reaching preservation age 

gen event=(p_age == hgage)
by id: egen eventwave = max(cond(event!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen timesinceevent = wave - eventwave //relative time to event 



//generate event  change in access condition 
gen event_a=(cond_changed == 1) 
by id: egen eventwave_a = max(cond(event_a!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen timesince_a = wave - eventwave_a //relative time to event 


////////////////construct some more variables///////////////////////////////// 

gen super_at_retirement= super_final if retired ==1
sort id 
by id: egen super=max(super_at_retirement)
xtile super_quart = super, nq(4)

//Simply looking at lfp vs age and not superannuation//

sort hgage 

by hgage: egen meanlfp = mean(lfp) //calculate mean lfp by age 

egen tagage = tag(hgage) //tag unique values  

//
//twoway line meanlfp hgage if tagage ==1 & hgage <=80 & hgage >=20
//

lgraph lfp hgage if hgage <=80 & hgage >=45, nomarker 
lgraph retired hgage if hgage <=80 & hgage >=45, nomarker 

 //general graph of decline in lfp look pretty smooth. Look somewhat like it gets most steep around 55 for a bit then flatter again for a couple of periods then become more steep as heading towards mid 60s. 


// mean lfp relative to p_age 

lgraph lfp timesinceevent, xline(0, lcolor(green)) nomarker ytitle(labor force participation) xlabel(-20 "" -10 "" 0 "preservation age" 10 "" 20 "") xtitle("")

//mean retirement probability relative to p_age 

lgraph lfp timesinceevent hgsex, xline(0, lcolor(green)) nomarker //not much difference between the sexes

lgraph lfp timesinceevent super_quart, xline(0, lcolor(green)) nomarker //people with lowest quartile superannuation tend to have initially much lower level of labor force participation but eventually higher rates than those with higher superannuation, probably because they tend to include largely the self-employed group. 

lgraph retired timesinceevent hgsex, xline(0, lcolor(green)) nomarker //probability of retirement reaches a slight local max at p_age but not obviously important. Age pension eligibility seems much more important. 

//quantile of super at retirement year 

lgraph retired timesinceevent super_quart, xline(0, lcolor(green)) nomarker  //this one super bumpy, based on just 3500 people 

//probability of retirement

//change this

sort timesinceevent
by timesinceevent: egen meanlfp_t = mean(lfp) //generate average lfp by relative time. 
egen tag_t = tag(timesinceevent) //tag distinct values so graph has one observation each, should do it by if not missing average group value if add group qualifier 

sort timesinceevent
twoway connected meanlfp_t timesinceevent if tag_t ==1 & rtcomp !=3,  xline(0, lcolor(green)) //this looks okay, something is obviously up at t=0 

//housing around when a person gains access to superannuation 

lgraph lfp timesince_a, xline(0, lcolor(green)) nomarker
lgraph own timesince_a if super_at_retirement>700000, xline(0, lcolor(green)) nomarker //not sure why there is a weird dip in the middle. 


lgraph own timesince_a, xline(0, lcolor(green)) nomarker
lgraph own timesince_a super_quart, xline(0, lcolor(green)) nomarker
lgraph upgrade_financial timesince_a, xline(0, lcolor(green)) nomarker
lgraph downgrade_financial timesince_a, xline(0, lcolor(green)) nomarker
lgraph upgrade_physical timesince_a, xline(0, lcolor(green)) nomarker
lgraph downgrade_physical timesince_a, xline(0, lcolor(green)) nomarker
lgraph rent_to_own timesince_a, xline(0, lcolor(green)) nomarker
lgraph own_to_rent timesince_a, xline(0, lcolor(green)) nomarker

//is the variable I constructed for access super too noisy or the superannuation I interpolated too noisy try with only the waves with the actual super information? Or use only the past 10 years where we know retirement date and superannuation amount?























/*




Old stuff using two way connected 

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


//Use labor force participation first 


sort timesinceevent

twoway connected meanlfp_tw timesinceevent if tag_t ==1 & rtcomp !=3 & inrange(timesinceevent, -5,5) & working_5==1,  xline(0, lcolor(green)) //restrict to the group where can see working 10 periods before and working ==1 //



//something about the generate group mean is not working, many groups do not have mean









/*filed twoway methods



sort timesinceevent
by timesinceevent: egen meanlfp_t = mean(lfp) //generate average lfp by relative time. 
egen tag_t = tag(timesinceevent) //tag distinct values so graph has one observation each, should do it by if not missing average group value if add group qualifier 

twoway connected meanlfp_t timesinceevent if tag_t ==1,  xline(0, lcolor(green)) //this looks 

or twoway line




*/   



























