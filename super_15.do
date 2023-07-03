
//look at super results for those the question was asked in 2015 and in 2019

//this calculates the lower bar of the total spendings, not all the spendings are necessarily reported this way



clear 

version 17.0

cap log close 

set more off 

set seed 0102

macro drop _all

global folder_path "/Users/bubbles/Desktop/Hilda" // <--- Input local path to the folder here

global data_original "$folder_path/original/CombinedFiles"

global data_interim "$folder_path/interim"
 
global data_output "$folder_path/output"
 
local varstokeep hgsex hgage hgyob ghgh ghpf mrcurr tchad hhd0_4 esdtl edhigh1 hhsad10 /// 
hstenr hstenur mhli mhlyr hsyr hhadst lemvd rpsold hsvalue hsvalui hsprice losathl losatnl hsbedrm ///
es esbrd esdtl esempdt esempst estjb rtage rt5yr lertr rtcomp rtcompn rtcrpr rtstat rtyr ///
hxyhmrn hxyhmri hsdebt hsdebti hsmg hsmgowe hwhmeip rtmfmv ///
hhtup ///
saest saval savaln savaln2 rtsup rtlump sacfnd2 sacfndr sacfnda sacfnd /// super
bnage bncap bncapa /// age pension
lejob pjsemp pjmsemp /// job change 
rt5yr rtsup rtlump rtconv rtcamt rtclgp rtcabp rtcos rtcrf rtcdk ///
rtrsls rtrsadf rtrsie rtrspd rtrslei rtrsafm rtrsos rtrsrf rtrsdk /// used for 
rtamtpd rtamtle rtamtfm rtcklsr rtlspa ///
rtlsp11 rtlsp12 rtlsp13 rtlsp14 rtlsp15 rtlsp16 ///

local i = 0 

foreach w in o s {
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

	save "$data_interim/tempretired`w'", replace
}

/*
rtrspd rtamtpd //debt 
rtrslei rtamtle //expenditure 
rtrsafm rtamtfm //family 
*/ 

use "$data_interim/tempretiredo" //this is just the 2015 one 

keep if rtsup ==1 & rtlump>0 //keep those who said they had super when retired and provided an estimate of amount

xtile qrt1 = rtlump, nq(4)

bysort hgsex: sum rtlump, detail //male and female superannuation differ a lot

//some people transferred everything to account based 

drop if inlist(rtamtpd, -3, -4) //refused or not stated 
drop if inlist(rtamtle, -3, -4)
drop if inlist(rtamtfm, -3, -4)

gen lump_sum = rtamtpd if rtrspd==1 & rtrslei !=1 & rtrsafm !=1 
replace lump_sum = rtamtle if rtamtle!=1 & rtrslei ==1 & rtrsafm !=1 
replace lump_sum = rtamtfm if rtrspd!=1 & rtrslei !=1 & rtrsafm ==1 

replace lump_sum = rtamtpd + rtamtle if rtrspd==1 & rtrslei ==1 & rtrsafm !=1 
replace lump_sum = rtamtpd + rtamtfm if rtrspd==1 & rtrslei !=1 & rtrsafm ==1 
replace lump_sum = rtamtle + rtamtfm if rtrspd!=1 & rtrslei ==1 & rtrsafm ==1 

replace lump_sum = rtamtpd + rtamtle + rtamtfm if rtrspd==1 & rtrslei ==1 & rtrsafm ==1 
replace lump_sum = 0 if rtrspd!=1 & rtrslei !=1 & rtrsafm !=1  //only 123 people have lump_sum > 0 by this definition 

gen percentage = lump_sum/rtlump

bysort qrt1: egen qrt1_mean = mean(percentage)

//this tabulation seem too small to be reliable
//the really wealthy does not dissave proportionally. 





















 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
