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
//this do file generate some key variables///

/////////////////////////////////////////////////////////////////////////////////////////////
//Generate variable retired for changing from labor force to retired in that period/ 
////////////////////////////////////////////////////////////////////////////////////////////

//variables used rtcomp rtcompn rtstat lertr
//should try with rtcage (At what age did you completely retire) to see how many matches. 
//retirement means completely retired. 
//currently uses retirement status questions first and then replace with self reported retirement change if missing, because the status questions are in more salient retirement sections and the life event questions are mixed with other types of questions and are in SCQs, can try the other way around too. 

gen lfp =(esbrd==1 | esbrd==2) //labor force participation 

//recode rtcomp rtcompn rtstat .a(not asked) to 0, all to 1/0, 1 being completely retired


mvencode rtcomp rtcompn rtstat, mv(.a = 0) //people who are still working are not asked. 
recode rtcomp rtcompn (2 = 0) (3 = 0) //never in labor force is coded as not retired
recode rtstat (2 = 0) (3 = 0) (4 = 0) //partially retired is considered not retired. 

//
gen retirement_status = rtcomp 
replace retirement_status = rtcompn if missing(retirement_status)
replace retirement_status = rtstat if missing(retirement_status)

sort id 
by id: gen retired_change = retirement_status -  retirement_status[_n-1]   
gen retired = retired_change if retired_change ==0 | retired_change ==1 //this is whether went from non-retired to retired in that period, ignoring re-entered workforce for now. 

//if still missing, use lertr 
recode lertr (1 = 0) (2 = 1) //make retired 1 and not retired 0 
replace retired = lertr if missing(retired)


//superannuation 


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

//gen job change indicator 

gen changed_cpq =1 if pjsemp ==2  //this is only asked of last period employed people 
replace changed_cpq =0 if pjsemp ==1
replace changed_cpq =1 if pjmsemp ==2 
replace changed_cpq =0 if pjmsemp ==1 //result is 60% missing overall and 14 percent missing for employed people 

gen changed_scq =1 if lejob ==2
replace changed_scq =0 if lejob ==1

gen j_changed =1 if changed_scq==1 | changed_cpq ==1
replace j_changed =0 if missing(j_changed) & !missing(changed_cpq) & !missing(changed_scq) //try to keep the rest as missing, this doesn't to result in too many changes 

gen reached_page = (hgage >= p_age & !missing(hgage))
gen sixty_plus = (hgage >= 60 & !missing(hgage))

gen cond_release =1 if reached_page==1 & retirement_status==1
replace cond_release =1 if sixty_plus ==1 & j_changed==1
replace cond_release=1 if hgage>= 65
sort id wave 
by id: replace cond_release=1 if cond_release[_n-1] ==1
replace cond_release =0 if missing(cond_release)
by id: gen cond_changed =1 if cond_release - cond_release[_n-1] ==1
replace cond_changed =0 if missing(cond_changed)


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

gen super_c = super_estimate if retirement_status == 0
replace super_c = super_estimater if retirement_status == 1

replace super_c = super_estimate if missing(super_estimater) & !missing(super_estimate)
replace super_c = super_estimater if !missing(super_estimater) & missing(super_estimate)

//final interpolation (should check again to see if int for transitions from employed to retired make sense), shouldn't extrapolate yet

by id: ipolate super_c wave, generate(super_final) //generate int super_estimate, do not extrapolate because people will retire and super will then decline

//come up with some permanent superannuation component or something that would allow more super annuation information to be used. 


//construct housing variables 


gen move_address = mhli

recode move_address  (2=0)


//generate upgrade/downgrade indicators//

gen own = hstenr
recode own (2=0) (3=0) (4=0)

by id: gen upgrade_financial = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsvalui > hsvalui[_n-1])

by id: gen downgrade_financial = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsvalui < hsvalui[_n-1])

by id: gen upgrade_physical = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsbedrm > hsbedrm[_n-1] )

by id: gen downgrade_physical = (hstenr[_n-1] == 1 & hstenr ==1 & mhli==1 &  hsbedrm < hsbedrm[_n-1])

by id: gen rent_to_own =((hstenr[_n-1] == 2 |  hstenr[_n-1] == 4) & hstenr ==1)

by id: gen own_to_rent = (hstenr[_n-1] == 1 & (hstenr == 2 |  hstenr == 4))


// Save new data set

save "$data_output/all_variables", replace 


















