
*Author: Angela Jiang 

*This file plots housing and labor outcomes preservation age and access condition 


*Input Data: super.dta (with retirement and super variables)


//quart_a: this is super quartile at access==1


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

//do a bit of sample selection stuff, maybe only keep people who have labor supply observed in the period before and after reaching access age too, check if there is still the weird kink


//Simply looking at lfp vs age and not superannuation//


lgraph lfp hgage if hgage <=80 & hgage >=45, nomarker 

lgraph retired hgage if hgage <=80 & hgage >=45, nomarker ytitle(retirement rate) xtitle("Age") title("Retirement Rate by Age") 

 //general graph of decline in lfp look pretty smooth. Look somewhat like it gets most steep around 55 for a bit then flatter again for a couple of periods then become more steep as heading towards mid 60s. 


// mean lfp relative to p_age 

lgraph lfp time_p, xline(0, lcolor(green)) nomarker ytitle(labor force participation) xtitle("preservation age") title("lfp around preservation age")

graph export "/Users/bubbles/Desktop/Retirement_Income/writings/1.lfp.jpg", as(jpg) name("Graph") quality(90) replace

//mean participation rate probability relative to p_age,

lgraph lfp time_p hgsex, xline(0, lcolor(green)) nomarker //not much difference between the sexes

lgraph lfp time_p quart_p if inlist(quart_p,1,2,3,4), xline(0, lcolor(green)) nomarker ytitle(labor force participation) xtitle("preservation age") title("lfp around preservation age") //those with the highest quartile super at preservation age have the largest dip in lfp at quart_p 

lgraph lfp time_p oct_p if inlist(quart_p,1,2,3,4), xline(0, lcolor(green)) nomarker ytitle(labor force participation) xtitle("preservation age") title("lfp around preservation age") //check, seems okay 

bys quart_p: sum super_atp //the actual mean super value. 

graph export "/Users/bubbles/Desktop/Retirement_Income/writings/1.lfp_super.jpg", as(jpg) name("Graph") quality(90) replace

////mean retirement rate probability relative to p_age,
lgraph retired time_p hgsex, xline(0, lcolor(green)) nomarker //Noisy, probability of retirement reaches a slight local max at p_age but not obviously important. Age pension eligibility seems much more important. 

//quantile of super at retirement year 

lgraph retired time_p quart_p if inlist(quart_p,1,2,3,4)  , xline(0, lcolor(green)) nomarker //this one super bumpy, based on just 3500 people  //again the highest and the lowest quartile seem to be mostly greately affected by preservation age, but the lower one could just be an age thing 


//////////////////////////////
/////Gained access to super///
//////////////////////////////


lgraph lfp time_a, xline(0, lcolor(green)) nomarker //just as a check, also shows not all due to retirement


//housing

//basically all noise for extensive margine stuff, a little bit of downgrades but probably not as much as we would expect. 

lgraph own time_a, xline(0, lcolor(green)) nomarker //ownership, not sure why there is a weird dip in the middle. 
lgraph own time_a quart_a, xline(0, lcolor(green)) nomarker //none of the quartiles for access has a change in ownership status around when get access 


lgraph upgrade_financial time_a, xline(0, lcolor(green)) nomarker //probability each very small just noise
lgraph upgrade_financial time_a quart_a, xline(0, lcolor(green)) nomarker //just noise 

lgraph downgrade_financial time_a, xline(0, lcolor(green)) nomarker //p downgrade increases somewhat, probably because of retirement 
lgraph downgrade_financial time_a quart_a if inlist(quart_a,3,4), xline(0, lcolor(green)) nomarker //noise 

lgraph upgrade_physical time_a, xline(0, lcolor(green)) nomarker
lgraph  upgrade_physical time_a quart_a if inlist(quart_a,3,4), xline(0, lcolor(green)) nomarker //noise 


lgraph downgrade_physical time_a, xline(0, lcolor(green)) nomarker //again downgrade a bit more likely
lgraph downgrade_physical time_a quart_a if inlist(quart_a,3,4), xline(0, lcolor(green)) nomarker //noise 

lgraph rent_to_own time_a, xline(0, lcolor(green)) nomarker
lgraph rent_to_own time_a quart_a, xline(0, lcolor(green)) nomarker //noise //

lgraph own_to_rent time_a quart_a, xline(0, lcolor(green)) nomarker

lgraph own time_a if time_a <=15 & time_a >= -15, xline(0, lcolor(green)) nomarker ytitle(home ownership) xtitle("super access") 
graph export "/Users/bubbles/Desktop/Retirement_Income/writings/2.ownership.jpg", as(jpg) name("Graph") quality(90) replace

lgraph own time_a super_quart if time_a <=15 & time_a >= -15, xline(0, lcolor(green)) nomarker ytitle(home ownership) xtitle("super access") 
graph export "/Users/bubbles/Desktop/Retirement_Income/writings/2.ownership_super.jpg", as(jpg) name("Graph") quality(90) replace


//home equity and maintenance 

lgraph home_equity time_a, xline(0, lcolor(green)) nomarker

lgraph home_equity time_a quart_a, xline(0, lcolor(green)) nomarker ytitle(Home Equity 2012 AUD) xtitle("Super Access") title("Home Equity Around Access")

lgraph home_debt time_a, xline(0, lcolor(green)) nomarker

lgraph home_debt time_a quart_a, xline(0, lcolor(green)) nomarker ylabel(20000 "20k" 40000 "40k" 60000 "60k" 80000 "80k" 100000 "100k") ytitle(Home Debt (2012 AUD)) xtitle("Super Access") title("Home Debt Around Super Access") //but issue is not sure how much of this is due to retirement. //use this maybe 

lgraph home_maintenance time_a, xline(0, lcolor(green)) nomarker

lgraph home_maintenance time_a quart_a if own==1, xline(0, lcolor(green)) nomarker //the second quartile, those with small amounts of super (less than 50,000), see a maintenance local peak. 

////////////consumption/////////

//consider only keeping people who have exp_total for all waves from wave 6, these are houshold expenditure not individual 

lgraph exp_total time_a if wave>=6, xline(0, lcolor(green)) nomarker //annual household expenditure, no change to slope, just steady decline, wave>=6 because expenditure only becomes available then, can see the second group has a bit of a peak. 

lgraph exp_total time_a quart_a if wave>=6, xline(0, lcolor(green)) nomarker //different from below 

lgraph exp_t5 time_a quart_a if wave>=5, xline(0, lcolor(green)) nomarker //same 

lgraph exp_medical time_a quart_a if wave>=6, xline(0, lcolor(green)) nomarker //again the quart_a equals 2 group has slight increase, only 500 annual 

lgraph exp_maintain time_a quart_a if wave>=6, xline(0, lcolor(green)) nomarker //1000 dollar increase for the 2 group, note some of this is due to retirement 

lgraph exp_everyday time_a quart_a if wave>=6, xline(0, lcolor(green)) nomarker //everyday expenditure no change at all for any group. Old people seem to do more consumption smoothing. 

//consider doing something by liquidity constraints. 




















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



























