cap log close 

set trace off 
set more off 
clear 
set seed 10103 

drop _all 


/*
/* classic ES data structure */
set obs 9 ;									/* number of units */
gen i = _n ;
gen E_i = 5 + i ;
gen treated = 1 ;							/* all units treated */
expand 20 ;									/* number of time periods */
*/

set obs 10 									/* number of units */
gen i = _n 

/* NxT DiD data structure */
gen treated = i > 5 						/* half of units treated */
gen E_i = 11 if treated == 1

/*
/* 2 treatment dates data structure */
gen treated = 1 ;							/* half of units treated */
gen E_i = 10 if i <= 5 ;
replace E_i = 11 if i > 5 ;
*/

expand 20 							/* number of time periods */

sort i 
qui by i: gen t = _n 

xtset i t 

/* make variables that determine the DGP */
gen D = (t == E_i) 					/* the event "pulse" */
gen etime = (t - E_i) 					/* event time */

gen TE = 1 * (etime >= 0) 			/* step function treatment effect */
*gen TE = (etime >= 0) * (etime+1) ;				/* endless ramp function for treatment effect */
replace TE = 0 if E_i == .  //check what role this TE plays in the regressions --this just defines the artificial treatment effects and is used to create the fake data. 

gen treated_post = etime >= 0 

gen Y0_pure = 0 + 1 * treated 							/* offset counterfactual */
*gen Y0_pure = 4 * treated +  0.3 * treated * t ;		/* treated have a pre-trend ... */
*gen Y0_pure = 4 * treated +  0.01 * treated * (t-10) * (E_i - 9);	/* pre-trend based on E_i ... */

gen eps = sqrt(0.3) * rnormal() 
gen actual = Y0_pure + TE * treated 		
gen y = actual + eps 					/* observed Y */


forvalues i = 0/20 { 
	gen D_p`i' = (etime == `i') 
	gen D_m`i' = (etime == -1 * `i') 
	summ D_p`i' 
	local dropme = (r(mean) == 0) 
	if `dropme' == 1 { 
		drop D_p`i'  
	} 
	summ D_m`i' 
	local dropme = (r(mean) == 0) 
	if `dropme' == 1 { 
		drop D_m`i'  
	} 
} 

drop D_m0  ;

gen byte group2 = E_i == 11 ;
gen trend_group2 = t * group2 ;

summ ; 


forvalues i = 0/10 { 
	constraint define 2 1.i + 2.i + 3.i + 4.i + 5.i + 
	6.i + 7.i + 8.i + 9.i + 10.i = 0 
} 


















