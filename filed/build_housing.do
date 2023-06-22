
*Author: Angela Jiang 
*Written on a mac 

*This dofile...


*Input Data: 
*Output files:


clear 

version 17.0

cap log close 

set more off 

set seed 0102

macro drop _all

/*
use "/Users/bubbles/Desktop/Hilda/original/CombinedFiles/Combined_a200c.dta", clear 
*/

global folder_path "/Users/bubbles/Desktop/Hilda" // <--- Input local path to the folder here

global data_original "$folder_path/original/CombinedFiles"

global data_interim "$folder_path/interim"
 
global data_output "$folder_path/output"
 
/*

//this part merge individuals with parents for each wave 

foreach w in a b c d e f g h i j k l m n o p q r s t u { 
	

	use "`origdatadir'/Combined_`w'200c.dta", clear 
	
	keep xwaveid `w'hhbfxid `w'hhbmxid `w'hhsgcc `w'fmhsib `w'fmnsib  `w'hgsex `w'hgage `w'ghgh `w'ghpf `w'mrcurr  `w'tchad `w'hhd0_4 `w'esempdt `w'esdtl `w'edhigh1  `w'hhsad10 `w'hsvalue `w'hsdebt `w'anatsi `w'ancob `w'fmpdiv `w'hifditn `w'hifditp hhd5_9
	
	
	save "`newdatadir'/`w'.mergedwithparents.dta", replace 
}

*/

clear 

local varstokeep hgsex hgage ghgh ghpf mrcurr tchad hhd0_4 esdtl esempdt edhigh1 hhsad10 /// 
hstenr hstenur mhli mhlyr hsyr hhadst lemvd rpsold hsvalue hsvalui hsprice losathl losatnl hsbedrm ///
hxyhmrn hxyhmri hsdebt hsdebti hsmg hsmgowe hwhmeip rtmfmv 

	 
local i = 0
foreach w in a b c d e f g h i j k l m n o p q r s t u {
	use "$data_original/Combined_`w'210c.dta", clear 
	
	renpfix `w'      // Strip off wave prefix
	local i = `i'+1  // Increase (wave) counter by 1
 	gen wave = `i'   // Create wave indicator (1, 2, ...)

	// select variables needed
	if ("`varstokeep'"!="") {
		local tokeep                                 // empty to keep list
		foreach var of local varstokeep {            // loop over all selected variables
			capture confirm variable `var'           // check whether variable exists in current wave
			if (!_rc) local tokeep `tokeep' `var'    // mark for inclusion if variable exists
			}
		keep xwaveid wave `tokeep' // keep selected variables
        }

	save "$data_interim/temp`w'", replace
}

// The following code appends the temporary data files for each wave to create
// an unbalanced panel.

foreach w in a b c d e f g h i j k l m n o p q r s t {
	append using "$data_interim/temp`w'"
	}


******missing data manipulation, convert variable with negative values to missing *****

mvdecode _all, mv(-1=.a \ -2=.b \ -3=.c \ -4=.d \ -5=.e \ -6=.f \ -7=.g \ -8=.h \ -9=.i \ -10=.j)

/*

label define lab .a "[.a] Not asked" .b "[.b] Not applicable" .c "[.c] Don't know"  .d "[.d] Refused or not answered" .e "[.e] Invalid multiple response (SCQ only)" .f "[.f] Value implausible" .g "[.g] Unable to determine value" .h "[.h] No Self-Completion Questionnaire returned and matched to individual record" .i "[.i] Non-responding household" .j "[.j] Non-responding person", add 

label values `varstokeep' lab 

*/

******

destring xwaveid, replace force 

order xwaveid wave 

sort xwaveid wave

rename xwaveid id 

by id: replace hstenr = hstenur if _n==1


// Save new data set

save "$data_output/housing_variables", replace 
