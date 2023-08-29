//this file look mortgage rates
//replicate table for table 18. 

clear 

version 17.0

cap log close 

set more off 

macro drop _all

set seed 0102

cd "/Users/bubbles/Desktop/Retirement_Income/dofile" 

local folder_path "/Users/bubbles/Desktop/Hilda" 

local data_output "`folder_path'/output"

use "`data_output'/all_variables.dta", clear 

xtset id wave //set as panel  

keep if inlist(wave,2,6,10,14,18) //wealth waves with super information 

gen mortgage_any =(hsdebti>0)

keep if hgage>24

//mortgage_any
 
table (age_bracket) (year) [pweight = hhwte] if own==1, nototals statistic(mean mortgage_any) nformat(%12.2f) style(Table-1)
collect title "Mortgage rate of homeowners"
collect notes `"Source: HILDA 2002-2018, enumerated persons weights are used"'

collect export "/Users/bubbles/Desktop/Retirement_Income/writings and graphs/mortgage.tex", as(tex) replace

//mortgage_amount 

table (age_bracket) (year) [pweight = hhwte], nototals statistic(mean hsdebti) nformat(%9.0fc) style(Table-1)
collect title "Average home debt (all respondents)"
collect notes `"All values in 2012 AUD"'
collect export "/Users/bubbles/Desktop/Retirement_Income/writings and graphs/mortgage_mean.tex", as(tex) replace


//mortgage_amount conditioning on being a home owner   

table (age_bracket) (year) [pweight = hhwte] if own==1, nototals statistic(mean hsdebti) nformat(%9.0fc) style(Table-1)
collect title "Average home debt (owners)"
collect notes `"All values in 2012 AUD"'
collect export "/Users/bubbles/Desktop/Retirement_Income/writings and graphs/mortgage_mean_owners.tex", as(tex) replace


//mortgage_amount conditioning on being having positive mortgage   

table (age_bracket) (year) [pweight = hhwte] if hsdebti>0, nototals statistic(mean hsdebti) nformat(%9.0fc) style(Table-1)
collect title "Average home debt (those with home debt)"
collect notes `"All values in 2012 AUD"'
collect notes `"Note small sample size for the older groups "'
collect export "/Users/bubbles/Desktop/Retirement_Income/writings and graphs/mortgage_mean_debters.tex", as(tex) replace






/* filed 


tabstat own if wave==2, by(age_bracket) statistics(mean n)  //the youngest group seems to not match with other document, older groups seem fine 
tabstat own if wave==6, by(age_bracket) statistics(mean n) 
tabstat own if wave==10, by(age_bracket) statistics(mean n) 
tabstat own if wave==14, by(age_bracket) statistics(mean n) 
tabstat own if wave==18, by(age_bracket) statistics(mean n) 


//not too much increase in ownership over the waves 

tabstat mortgage_any if wave==2 & own==1, by(age_bracket) statistics(mean n)  //the youngest group seems to not match with other document, older groups seem fine 
tabstat mortgage_any if wave==6 & own==1, by(age_bracket) statistics(mean n) 
tabstat mortgage_any if wave==10& own==1, by(age_bracket) statistics(mean n) 
tabstat mortgage_any if wave==14 & own==1, by(age_bracket) statistics(mean n) 
tabstat mortgage_any if wave==18& own==1, by(age_bracket) statistics(mean n) 

//the trend of having mortgage debt continues but increase been slower for the 65+ age group. In the most recent wave more the half (58%) of the 55-59 group still had mortgage 

tabstat hsdebti if wave==2 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==6 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==10 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==14 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==18 & hsdebti>0, by(age_bracket) statistics(mean n) 


tabstat hsdebti if wave==2 , by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==6, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==10 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==14 & hsdebti>0, by(age_bracket) statistics(mean n) 
tabstat hsdebti if wave==18 & hsdebti>0, by(age_bracket) statistics(mean n) 


//these debts are also getting much larger in magnitude 
//sample size gets really small 70+, may be a problem




//increase in home debt to older age persisted. 



//the difference is not due to a problem of weights




*/












