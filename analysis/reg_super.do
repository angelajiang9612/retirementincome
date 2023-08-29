//this file run regression for around superannuation accessibility 

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

drop if home_equity <  -83.1793 //drop the bottom percentile of home_equity values

local dep home_equity home_maintenance upgrade_financial upgrade_physical rent_to_own home_debt //add probability of becoming full owner (i.e. no debt)
local indep L.cond_release 
local interact L.cond_release##p_receives1
local controls L.hgage L.hhs_income L.hhfini L.ghpf L.retirement_stat L.partner L.hhpersons 


foreach y in  `dep' {
	foreach x in `indep' {
		xtreg `y' `x' `controls' i.year if hgage>=50, fe cluster(id)
	}	
}

xtreg home_debt L.cond_release##quart_a L.hgage L.hhs_income L.hhfini L.ghpf L.retirement_stat L.partner L.hhpersons i.year i.hhs3gcc, fe cluster(id)


xtreg home_debt L.cond_release##quart_a L.hhs_income L.hhfini L.ghpf L.partner L.hhpersons i.year i.hhs3gcc, fe cluster(id)



eststo: quietly xtreg home_debt L.cond_release##quart_a L.hgage L.hhs_income L.hhfini L.ghpf L.retirement_stat L.partner L.hhpersons i.year i.hhs3gcc, fe cluster(id)


esttab using regdebt.tex, se ar2 nolabel nostar stats(r2 N) drop(*year *hhs3gcc) noconstant replace 



//with interaction with age pension term 


foreach y in  `dep' {
	
	foreach x in `interact' {
		xtreg `y' `x' `controls' i.year if hgage>=50 & super_quart==1, fe cluster(id)
		}
}

	 
	 

forval v =1/4 { 
	
	xtreg home_equity L.cond_release##p_receives1 `controls' i.year if hgage>=50 & super_quart==`v', fe cluster(id)
			//nothing interesting from doing the quartill split, the first quartile seem to have a decrease in housing equity but imprecisely estimated 

}






//with interaction with age pension term 








