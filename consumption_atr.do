//this file compares consumption changes for households at retirement based on superannuation


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

lgraph exp_total time_r if time_r<11, xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement")

lgraph exp_total time_r quart_r if time_r<11 & r_wave <12, xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement")

lgraph exp_total time_r quart_r if time_r<11 & r_wave>11, xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement") //now it looks like no one's consumption decreases following retirement 

lgraph exp_total time_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement") //single households. 
//looks like consumption does still decline, 

lgraph exp_total time_r quart_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement") //singles 

//seems to actually decline the most for the group with the highest super 


lgraph exp_total time_r quart_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_total) xtitle("retirement") //singles 


lgraph exp_medical time_r quart_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_medical) xtitle("retirement") //singles 

lgraph exp_maintain time_r quart_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_medical) xtitle("retirement") //singles 


lgraph exp_everyday time_r quart_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_medical) xtitle("retirement") //singles 

lgraph exp_everyday time_r if inlist(mrcurr,3,4,5,6), xline(0, lcolor(green)) nomarker ytitle(exp_medical) xtitle("retirement") //singles 
































