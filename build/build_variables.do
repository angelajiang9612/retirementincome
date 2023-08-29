//This filed computes super and retirement variables 


*Author: Angela Jiang 
*Written on a mac 

*This dofile computes key variables like retirement year and estimate superannuation for years missing. 


*Input Data: the results of build all. "$data_output/all_variables", 
*Output files:  "$data_output/super_retirement_added", 


clear 

version 17.0

cap log close 

set more off 

set seed 0102

macro drop _all

cd "/Users/bubbles/Desktop/Retirement_Income/dofile" 

log using describe_super.log , text replace 

global folder_path "/Users/bubbles/Desktop/Hilda" 

global data_output "$folder_path/output"

use "$data_output/combined", clear 

compress

xtset id wave 

//infile the result of build_combine, output a data file with key constructed variables. 
//this do file generate some key variables//


/////////////////////////////////////////////////////////////////////////////////////////////
//Generate variable retired for changing from labor force to retired in that period/ 
////////////////////////////////////////////////////////////////////////////////////////////

//variables used rtcomp rtcompn rtstat lertr
//generated variables retirement_stat and retire (whether retired in that period or noy)
//should try with rtcage (At what age did you completely retire) to see how many matches. 
//retirement means completely retired. 
//currently uses retirement status questions first and then replace with self reported retirement change if missing, because the status questions are in more salient retirement sections and the life event questions are mixed with other types of questions and are in SCQs, can try the other way around too. 

gen lfp =(esbrd==1 | esbrd==2) //labor force participation 
replace lfp =. if missing(esbrd)

//recode rtcomp rtcompn rtstat .a(not asked) to 0, all to 1/0, 1 being completely retired

mvencode rtcomp rtcompn rtstat, mv(.a = 0) //people who are still working are not asked. 
recode rtcomp rtcompn (2 = 0) (3 = 0) //never in labor force is coded as not retired
recode rtstat (2 = 0) (3 = 0) (4 = 0) //partially retired is considered not retired. 

//
gen retirement_stat = rtcomp 
replace retirement_stat = rtcompn if missing(retirement_stat)
replace retirement_stat = rtstat if missing(retirement_stat)

sort id 
by id: gen retired_change = retirement_stat -  retirement_stat[_n-1]   
gen retire = retired_change if retired_change ==0 | retired_change ==1 //this is whether went from non-retired to retired in that period, ignoring re-entered workforce for now. 

//if still missing, use lertr 
recode lertr (1 = 0) (2 = 1) //make retired 1 and not retired 0 
replace retire = lertr if missing(retired)







/////////////////////////////////////////////
///////////////SUPER VARIABLES//////////////
//////////////////////////////////////////////


//generate superannuation preservation age using birth year and current age. 

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

//generate indicator for reaching condition of release 
//outcome variable cond_changed =1 in the period when condition of release is reached, 0 in other periods. 

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

gen cond_release1 =1 if reached_page==1 & retirement_stat==1
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

//deflation of super value to 2012 real dollars 

gen year = wave + 2000 

local years 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 
local cpi 73.9 76.1 78.6 80.2 82.1 84.5 86.6 90.3 92.5 95.2 98.3 99.9 102.4 105.4 106.8 108.2 110.5 112.6 114.1 116.6 117.9 

local n: word count `years'

forval i = 1/`n' {
	local y: word `i' of `years'
	local ind: word `i' of `cpi' 
	replace pwsupri = pwsupri/`ind'*100 if year == `y' 
	replace pwsupwi = pwsupwi/`ind'*100 if year == `y' 
	replace pwsuprt = pwsuprt/`ind'*100 if year == `y' 
	replace pwsupwk = pwsupwk/`ind'*100 if year == `y' 
}  


/////////////////////////////////////////////
//Reach Preservation Age & Gain Access Events/
//////////////////////////////////////////////


//generate event reaching preservation age 

gen event=(p_age == hgage)
by id: egen p_wave = max(cond(event!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen time_p = wave - p_wave //relative time to event 


//generate event change in access condition 
gen event_a=(cond_changed == 1) 
by id: egen a_wave = max(cond(event_a!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen time_a = wave - a_wave //relative time to event 

//generate event retired (need to adjust for household size etc later)

gen event_r=(retire == 1) 
by id: egen r_wave = max(cond(event_r!=0, wave, .)) //record wave event took place, max ignore missing values automatically 
gen time_r = wave - r_wave //relative time to event 


/*
small numbers 
//dropping some inconsistencies 
drop if rtcomp ==1 & pwsupwi!=0 & inlist(wave,2,6,10,14,18) //retired but has non retired super, 1 case
drop if rtcomp ==0 & pwsupri!=0 & inlist(wave,2,6,10,14,18) // not retired but has retired super, 140 cases 
drop if pwsupri!=0 & pwsupwi!=0 & inlist(wave,2,6,10,14,18) //cases where they are both not 0, 165 cases, rtcomp status not responding

//note that pwsupwi and pwsupri are never missing, they are set to zero when non applicable. 
//when both pwsupwi and pwsupri are zero and rtcomp is missing it is not clear whether this person should count as retired or not. Check if there is a derived variable for retirement. Can email HILDA
*/ 

//combining retired and non-retired super 

gen super_c = pwsupwi + pwsupri //total super, still super noisy
bys id: ipolate super_c wave, generate(super_i)
bys id: egen super_atr = max(cond(retire==1, super_i, .)) //super at retirement 
bys id: egen super_atp = max(cond(p_age == hgage, super_i, .)) //super at p_age 
bys id: egen super_ata = max(cond(cond_changed == 1, super_i, .)) //super at access 

xtile quart_r = super_atr, nq(4) //note that the first 25 percent doesnt't have any super, this is probably misleading, many people already ran down their super 
xtile quart_p = super_atp, nq(4)
xtile oct_p = super_atp, nq(8)
xtile quart_a = super_ata, nq(4)

/////////////////////////////////////////////
///////////////HOUSING VARIABLES//////////////
//////////////////////////////////////////////


gen move_address = mhli

recode move_address  (2=0)

//housing related monetary values, adjust to 2012 dollars and in thousands. 

//home maintenance costs (note this is household total, imputed values, some missing values exist)

gen home_maintenance =hxyhmri

//home equity and home maintenance(resident home)

//adjust to 2012 real dollars 

gen home_equity = hsvalui - hsdebti 
gen home_debt = hsdebti 
gen home_value = hsvalui

forval i = 1/`n' {
	local y: word `i' of `years'
	local ind: word `i' of `cpi' 
	replace home_equity = home_equity/`ind'*100 if year == `y' //adjust for inflation and convert to thousands 
	replace home_maintenance = home_maintenance/`ind'*100 if year == `y'
	replace home_debt = home_debt/`ind'*100 if year == `y'
	replace home_value = home_value/`ind'*100 if year == `y'
}  


//other home loan variables 

rename hsmgpd homeloan_any
recode homeloan_any (1=0) (2=1) 


//generate upgrade/downgrade indicators//

gen own = hstenr
recode own (2=0) (3=0) (4=0)

by id: gen upgrade_financial = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsvalui > hsvalui[_n-1]) //owners in both period, moved between periods, value of home increased. 
by id: gen downgrade_financial = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsvalui < hsvalui[_n-1])
by id: gen upgrade_physical = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsbedrm > hsbedrm[_n-1] )
by id: gen downgrade_physical = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsbedrm < hsbedrm[_n-1])
by id: gen rent_to_own =((hstenr[_n-1] == 2 |  hstenr[_n-1] == 4) & hstenr ==1)
by id: gen own_to_rent = (hstenr[_n-1] == 1 & (hstenr == 2 |  hstenr == 4))


/////////////////////////////////////////////
///////////////Expenditure Variables/////////
//////////////////////////////////////////////

gen exp_total = hxygrci + hxyalci + hxycigi + hxypbti + hxymli + hxymvfi + hxymcfi + hxywcfi + hxyccfi + hxytlii + hxyphii + hxyoii + hxyhlpi + hxyphmi + hxyutil + hxyhmrn + hxymvr + hxyeduc //sum is missing if any of them are missing, therefore used only from wave 6 onwards 

gen exp_t5 = hxygrci + hxyalci + hxycigi + hxypbti + hxymli + hxymvfi  + hxyphii + hxyhmrn + hxymvr + hxyeduc //those available from wave onwards 

gen exp_medical = hxyphii + hxyoii + hxyhlpi + hxyphmi  

gen exp_maintain = hxyhmrn + hxymvr //home and vehical maintenance

gen exp_everyday =  hxygrci + hxyalci + hxycigi + hxypbti + hxymli + hxymvfi + hxymcfi + hxywcfi + hxyccfi + hxytlii + hxyutil //non medical, non maintenance and educational 

//adjust for inflation 

forval i = 1/`n' {
	local y: word `i' of `years'
	local ind: word `i' of `cpi' 
	replace exp_total= exp_total/`ind'*100 if year == `y' //adjust for inflation
	replace exp_t5= exp_t5/`ind'*100 if year == `y'
	replace exp_medical = exp_medical/`ind'*100 if year == `y'
    replace exp_maintain = exp_maintain/`ind'*100 if year == `y'
	replace exp_everyday = exp_everyday/`ind'*100 if year == `y'
}  

//adjust for household size 



/////////////////////////////////////////////
///////////////AGE PENSION VARIABLES/////////
//////////////////////////////////////////////

//whether or not age eligible 
gen pension_age=1 if bnage==1 | bnage==2 | bnage1==1 //age above threshold.
bysort id: replace pension_age=1 if pension_age[_n-1] ==1 //fill in waves where someone is non-responding bnage is recorded as zero
replace pension_age=0 if missing(pension_age) //might want to check this for missing. 
bysort id: gen pension_changed =1 if pension_age - pension_age[_n-1] ==1 
replace pension_changed =0 if missing(pension_changed)
bysort id: egen pwave = max(cond(pension_changed==1, wave, .)) //the wave at which reached pension age 


//whether or not receives age pension 
//p_receives1 and p_receives5 are whether ever receives age pension in the 1st period and 5 periods after they become age eligible. 

gen flag1=1 if wave <= pwave+1 & wave>=pwave //period or period after turning to age_pension age, inrange does something funny with missing values 

gen p1=1 if bncap==1 & flag1==1 
replace p1=0 if bncap==2 & flag1==1 //does not receive age pension the first or the second period after age eligible
bysort id: egen p_receives1 = max(p1)

gen flag5=1 if wave <= pwave+5 & wave>=pwave 
gen p5=1 if bncap==1 & flag5==1
replace p5=0 if bncap==2 & flag5==1
bysort id: egen p_receives5 = max(p5) //someone who receives age pension in some periods and not in other periods is considered to receive age pension. 


//other regression controls  

gen hhs_income = hifditp/1000 //income in thousands 
replace hhs_income = hifditn/1000 if hifditn>0 //income in thousands 
gen partner=1 if mrcurr <= 2
replace partner=0 if mrcurr >= 3
gen hhpersons = hhpers 
bysort id: ipolate hwfini wave, generate(hhfini) epolate //interpolate financial wealth for middle waves 
replace hhfini=hhfini/1000
// Save new data set

egen age_bracket = cut(hgage), at(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,105,110,115,120)

replace age_bracket= 80 if age_bracket>80 //80+ group


//job related variables 

rename jbmmply jcompany_sector
rename jbmemsz jcompany_size 
rename jbmi61  jindustry_1digit
rename jbmi62  jindustry_2digit
rename jbmo61  joccup_1digit
rename jbmo62  joccup_2digit 



compress

save "$data_output/all_variables", replace 







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




/* filed super impute /



///////superannuation amount/////

//need to check how reasonable the interpolations are in a more rigorous way later
//should check the topcode thing, HILDA provides the actual top code cutoff
//the current problem with the interpolations is they intepolate outside their section (retired vs not retired)
//need to figure out why 6000 observations have non missing value for both super_int and super_intr
//1.45% missing, probably related to top-up sample need to check 
//think about doing within group (retirement, in labor force) extapolation as well



//////generate yearly estimates for the value of superannuation/////////


//for those who are not completely retired 

//modify the brackets saval savaln savaln2 

recode saval (1 = 2500) (2 = 12500)  (3 = 35000)  (4 = 75000)  (5 = 150000)  (6 = 350000)  (7 = 500000) (10 = 0) //replace bracket by bracket midvalue or value in the case of max bracket

recode savaln (1 = 2500) (2 = 12500)  (3 = 35000)  (4 = 75000)  (5 = 150000)  (6 = 350000)  (7 = 750000) (8 = 1000000) (10 = 0) //replace bracket by bracket midvalue or value in the case of max bracket

recode savaln2 (1 = 2500) (2 = 12500)  (3 = 35000)  (4 = 75000)  (5 = 150000)  (6 = 350000)  (7 = 750000) (8 = 1500000) (9 = 3500000) (10 = 5000000) (97 = 0) //replace bracket by bracket midvalue or value in the case of max bracket

gen super_bracket = saval
replace super_bracket = savaln if missing(super_bracket)
replace super_bracket = savaln2 if missing(super_bracket)

gen super_value =saest //estimation of actual value 
replace super_value = super_bracket if missing(super_value) & !missing(super_bracket)

by id: ipolate super_value wave, generate(super_estimate) //generate int super_estimate, do not extrapolate because people will retire and super will then decline
//replace super_estimate = 0 if super_estimate <0 //no negative values for super //no need no extrapolate 

egen max_1 = max(saest)  
replace super_estimate = max_1 if super_estimate > max_1 & super_estimate != . //can't exceed the max of reported value
drop max_1
replace super_estimate=0 if hgage <15 //children below legal working age has no super

///those who are completely retired

recode sacfndr (1 = 2500) (2 = 12500)  (3 = 35000)  (4 = 75000)  (5 = 150000)  (6 = 350000)  (7 = 750000) (8 = 1000000) (10 = 0) //replace bracket by bracket midvalue or value in the case of max bracket

recode sacfnd2 (1 = 2500) (2 = 12500)  (3 = 35000)  (4 = 75000)  (5 = 150000)  (6 = 350000)  (7 = 750000) (8 = 1500000) (9 = 3500000) (10 = 5000000) (97 = 0) //replace bracket by bracket 

gen super_bracketr = sacfnd2 //this is combination of super, allocated pension and annuity assets
replace super_bracketr = sacfndr if missing(super_bracketr)


gen super_valuer = sacfnda
replace super_valuer = super_bracketr if missing(super_valuer) & !missing(super_bracketr) 

by id: ipolate super_valuer wave, generate(super_estimater) //generate int super_estimate
egen max_2 = max(sacfnda) 
replace super_estimater = max_2 if super_estimater > max_2 & super_estimater != . //can't exceed the max of reported value
drop max_2


//overall superannuation estimate that combines retired and not retired groups

//need to figure out why 6000 observations have non missing value for both super_int and super_intr

gen super_c = super_estimate if retirement_stat == 0
replace super_c = super_estimater if retirement_stat == 1

replace super_c = super_estimate if missing(super_estimater) & !missing(super_estimate)
replace super_c = super_estimater if !missing(super_estimater) & missing(super_estimate)

//final interpolation (should check again to see if int for transitions from employed to retired make sense), shouldn't extrapolate yet

by id: ipolate super_c wave, generate(super_final) //generate int super_estimate, do not extrapolate because people will retire and super will then decline


gen super_at_retirement= super_final if retired ==1
bysort id: egen super=max(super_at_retirement)
xtile super_quart = super, nq(4)
xtile super_binary = super, nq(2)















