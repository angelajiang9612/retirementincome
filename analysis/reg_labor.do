//this file run regression 

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

//sample selection 

//keep those in the 55-60 age group 

keep if hgage <=60 & hgage >= 55


gen cohort= 0 if inrange(hgyob, 1955, 1959) //cohort 0 is the base cohort 
replace cohort =1 if p_age ==56 //construct hohort indicators based on p_age 
replace cohort =2 if p_age == 57 
replace cohort =3 if p_age == 58
replace cohort =4 if p_age == 59
replace cohort =5 if p_age == 60 

//average a little over 200 people in each cohort. 

/*
gen cohort_fuzzy =1 if inrange(cohort,1,5) //treated group 
replace cohort_fuzzy =0 if inrange(hgyob, 1955, 1959)
replace cohort_fuzzy =-1 if inrange(hgyob, 1950, 1954)
replace cohort_fuzzy =-2 if inrange(hgyob, 1945, 1949)

lgraph lfp hgage cohort_fuzzy 

*/

//try retirement 



//regression model

xtreg lfp mrcurr hhpers i.hhs3gcc i.hgage i.cohort#i.hgage i.year, fe cluster(id) 

//why is the oldest age grop omitted 


set showbaselevels all




/*

Tried doing the trend thing similar to M(2009), previous trends too unstable to see an obvious change in change, visualizing seem to show that compared to cohort zero  inrange(hgyob, 1955, 1959), there seem to be a bump up in the 55-60 region, mainly due to a bump up in the later cohorts. 

//kind of only have any precision if only use the treated cohorts and compare the later treated cohorts with the former. But there is a lot of covid in the background. 

//something big was going on with the cohort (hgyob, 1945, 1949). 
*/ 












