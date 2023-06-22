
*Author: Angela Jiang 

*This dofile...

*Input Data: 
*Output files:

//computes some simple summary statistics for housing 
//not survival analysis, just probabilities. 

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


//looking at change in residence 
lgraph move_address hgage if hgage >20  & hgage <=95, nomarker

//graphing change, these annual probabilities are all very small because they represent change, financial upgrade is more likely towards old age than physical upgrade. 

lgraph upgrade_financial hgage if hgage >45 & hgage <=95, nomarker
lgraph downgrade_financial hgage if hgage >45 & hgage <=95, nomarker
lgraph upgrade_physical hgage if hgage >45 & hgage <=95, nomarker
lgraph downgrade_physical hgage if hgage >45 & hgage <=95, nomarker
lgraph rent_to_own hgage if hgage >45 & hgage <=95, nomarker
lgraph own_to_rent hgage if hgage >45 & hgage <=95, nomarker

egen age_group = cut(hgage), at(20,25,30,35,40,45,50,55,65,75,80,85,90,95)

lgraph upgrade_financial age_group if hgage >45 & hgage <=95, nomarker
lgraph downgrade_financial age_group if hgage >45 & hgage <=95, nomarker
lgraph upgrade_physical age_group if hgage >45 & hgage <=95, nomarker
lgraph downgrade_physical age_group if hgage >45 & hgage <=95, nomarker
lgraph rent_to_own age_group if hgage >45 & hgage <=95, nomarker
lgraph own_to_rent age_group if hgage >45 & hgage <=95, nomarker

//graphically it seems that are more downgrades and own to rent happening at old age. 

//use stock definitions 

lgraph own hgage if hgage >50 & hgage <=95, nomarker

gen super_at_retirement= super_final if retired ==1
sort id 
by id: egen super=max(super_at_retirement)
xtile super_quart = super, nq(4)

lgraph own hgage super_quart if hgage >45 & hgage <=95, xline(0, lcolor(green)) nomarker




























