//this file look at super drawndown patterns for different cohorts 

clear 

version 17.0

cap log close 

set more off 

macro drop _all

set seed 0102

cd "/Users/bubbles/Desktop/Retirement_Income/dofile" 

global folder_path "/Users/bubbles/Desktop/Hilda" 

global data_output "$folder_path/output"

use "$data_output/all_variables.dta", clear 

compress

xtset id wave //set as panel  

keep if inlist(wave,2,6,10,14,18) //wealth waves with super information 

//drop non-responding (missing rtcomp)

drop if missing(rtcomp)

gen superi = pwsupri if pwsupri!=0 //retired (can't use rtcomp because a large proportion are non-responding so missing rtcomp, retirement status was somehow imputed)
replace superi = pwsupwi if pwsupwi!=0 //not retired
replace superi=0 if missing(superi) //all other cases zero 

egen age_02 = cut(hgage) if wave==2, at(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120) //cut into cohorts based on initial age 
bysort id: egen age_init = max(age_02) //people who joined in later waves, like the wave 11 top-up, will not be included here 
bysort id: gen rt_02 = 1 if wave==2 & rtcomp==1
bysort id: egen rt_init = max(rt_02) //initially retired 
bysort id: replace rt_init=0 if missing(rt_init)

bysort id: gen sup_02 = 1 if wave==2 & superi > 0 //initially have super
bysort id: egen sup_p = max(sup_02)
bysort id: replace sup_p = 0 if missing(sup_p)


lgraph superi wave age_init if age_init<=69 & age_init>=45, nomarker ylabel(50000 "50k" 100000 "100k" 150000 "150k" 200000 "200k" 250000 "250k") ytitle(superannuation amount (2012 AUD)) xtitle("Age") title("Superannuation Drawdown") // 4412 people 


lgraph superi wave age_init if age_init<=65 & age_init>=45 & sup_p > 0 //positive initial super, 2987 people, similar to above

lgraph superi wave age_init if age_init<=65 & age_init>=45 & rt_init==1  //mostly flat, again the youngest group just flat -looks a bit better now after adjusting for inflation, aside from the oldest group the other groups look flat or increasing

lgraph superi wave age_init if age_init<=65 & age_init>=45 & rt_init==1 & sup_p >0 //initial retirees with positive super value, only 600 people. The patterns look similar to above in shape but greater absolute value. 

lgraph superi wave age_init if age_init<=65 & age_init>=45 & rt_init==1 & sup_p ==0 //this part is weird. //this seems implausible. Many people initial report zero then suddenly report half a million. If they started working again maybe? 


lgraph superi wave hgsex if age_init<=65 & age_init>=45 


lgraph superi wave  if age_init<=65 & age_init>=45



//cut into finer quartiles 

local init 45 50 55 60 65 
local n : word count `init'

forval i=1/`n'{ //create binary 
	local y: word `i' of `init'
	xtile super_b`y' = superi if age_init==`y' & wave==2, nq(4)
	bysort id: egen b`y' = max(super_b`y')
}

lgraph superi wave b65 if age_init==65


//cutting into binary groups the lower group have very little (average less than 6436.551 ) supper, max is 25000, super hasn't really matured at the beginning of survey in 2002, only 10 years, and top has a mean of 130000. Should do this in 2002 real money or something. 

//try with three groups

//main conclusion here seem to be people are quite slow to run down their super assets, super only starts decreasing around 70 need to adjust for inflation though but would probably still be like this, has survival bias. 


//should divide into actually retired groups and not retired groups and people who has any superannuation income and do not have any super income etc. 




































