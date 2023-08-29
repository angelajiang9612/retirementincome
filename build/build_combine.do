
*Author: Angela Jiang 
*Written on a mac 

*This dofile pick useful variables from HILDA and merges waves of HILDA into one long form file


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
 


clear 

local varstokeep hhid hgsex hgage hgyob ghgh ghpf mrcurr tchad hhd0_4 esdtl edhigh1 hhsad10 hhs3gcc /// 
hstenr hstenur mhli mhlyr hsyr hhadst lemvd rpsold hsvalue hsdebt hsvalui hsvaluf hsdebti hsdebtf hsprice losathl losatnl hsbedrm ///
es esbrd esdtl esempdt esempst estjb rtage rt5yr lertr rtcomp rtcompn rtcrpr rtstat rtyr ///
hxyhmrn hxyhmri hsdebt hsdebti hsmg hsmgowe hwhmeip rtmfmv ///
hhtup ///
saest saval savaln savaln2 rtsup rtlump sacfnd2 sacfndr sacfnda sacfnd /// super
pwsuprt pwsupri pwsuprf pwsupwi pwsupwk pwsupwf hwsupei hwsupri hwsupwi hwsuprt hwsupwk hwsuprf hwsupwf /// super cleaned up
hxygrci hxyalci hxycigi hxypbti hxymli hxymvfi hxymcfi hxywcfi hxyccfi hxytlii hxyphii hxyoii hxyhlpi hxyphmi hxyutil hxyhmrn hxymvr hxyeduc /// expenditure 
bnage bnage1 bncap bncapa /// age pension
lejob pjsemp pjmsemp /// job change 
rt5yr rtsup rtlump rtconv rtcamt rtclgp rtcabp rtcos rtcrf rtcdk /// retirement module variables 
rtrsls rtrsadf rtrsie rtrspd rtrslei rtrsafm rtrsos rtrsrf rtrsdk ///
rtamtpd rtamtle rtamtfm rtcklsr rtlspa ///
rtlsp11 rtlsp12 rtlsp13 rtlsp14 rtlsp15 rtlsp16 ///
rtcage rtpage rtstat rtcklsa ///
hifditn hifditp hwfini ghpf mrcurr hhpers ///demographic controls 
jbmmply jbmemsz jbmi61 jbmi62 jbmo61 jbmo62/// job features 

	 
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

label dir //put all the labels in macro called r(names)


foreach lab in `r(names)' {
	
	forval i = 1/10{
		label define `lab' -`i' "", modify
	}
 
   label define `lab' .a "[.a] Not asked", modify
   label define `lab' .b "[.b] Not applicable", modify
   label define `lab' .c "[.c] Don't know", modify
   label define `lab' .d "[.d] Refused or not answered", modify
   label define `lab' .e "[.e] Invalid multiple response (SCQ only)" , modify
   label define `lab' .f "[.f] Value implausible" , modify
   label define `lab' .g "[.g] Unable to determine value", modify
   label define `lab' .h "[.h] No Self-Completion Questionnaire returned and matched to individual record", modify
   label define `lab' .i "[.i] Non-responding household", modify
   label define `lab' .j "[.j] Non-responding person", modify
}


******

destring xwaveid, replace force 

order xwaveid wave 

sort xwaveid wave

rename xwaveid id 

by id: replace hstenr = hstenur if _n==1


// Save new data set

save "$data_output/combined", replace 
