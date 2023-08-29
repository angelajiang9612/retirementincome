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

use "$data_output/all_variables", clear 

compress

xtset id wave //set as panel 

gen sup=1 if rtsup ==1 & rtlump>0 //

bysort id: egen sup_observed=min(sup) 

keep if sup_observed ==1 //keep those who reported their super at retirement (so in 2015 or 2019)



/* some people report multiple retirement years)

bysort id: egen age_r1 =  min(rtcage) //age for complete retirement, if multiple numbers are provided use the minimum one 

bysort id: egen age_r2 =  max(rtcage) 

*assert age_r1 == age_r2 // 340/1586 reported different age for complete retirement between two waves

keep if age_r1 

*/

drop if wave <=11 //this doesn't affect the number of observations 

bysort id: egen age_r1 =  min(rtcage) //age for complete retirement, if multiple numbers are provided use the minimum one 

bysort id: egen age_r2 =  max(rtcage)  //still 291 people report different retirement age across the two waves 

drop if age_r1 != age_r2 //drop those who reported different retirement age (i.e.  keep only those who had 1 retirement observation)

drop if missing(age_r1) //drop if never observed to be fully retired, now only 931 left 

bysort id: egen super_r = max(cond(!missing(rtcage), rtlump, .))  //this is the self reported super at retirement

drop if missing(super_r) //only 824 people left 

drop if age_r1 < p_age //drop those people who retired before preservation age 745 people 

bysort id: egen wave_r = max(cond(age_r1==hgage, wave, .)) //record the wave of retirement 

drop if wave_r >= 19 //drop the ones for which there are no wealth modules after their retirement, probably don't need to do this if can use the new super questions better later, only 566 people left 

gen wave_wealth = 14 if wave_r <=14
replace wave_wealth = 18 if wave_r > 14

replace sacfnda=0 if sacfnd==2 
bysort id: egen sup_after = max(cond(wave==wave_wealth,sacfnda, .))

drop if missing(sup_after) //450 people left

gen sup_c =sup_after-super_r 

bysort id: keep if _n==1

drop if sup_c > super_r //drop people whose change in sup value is larger than original retired super 

xtile quart = super_r, nq(4)

bysort hgsex: sum sup_c, detail //don't see any obvious gender differences 
bysort quart: sum sup_c, detail //


















































 





























