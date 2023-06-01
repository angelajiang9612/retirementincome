
*Author: Angela Jiang 

*This dofile...

*Input Data: 
*Output files:


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

use "$data_output/housing_variables", clear 

compress

xtset id wave //set as panel 

by id (wave), sort: keep if hgage[1] >= 50 & !missing(hgage[1]) 

by id (wave), sort: keep if hstenr[1] == 1 //keep initial owners


//rent as the final result

egen rent = max(hstenr == 2), by(id) 

by id (wave), sort: gen diff=hstenr - hstenr[_n-1] if hstenr[_n-1]==2

egen max_diff =max(diff == -1) , by(id) 

replace rent=0 if max_diff==1 //close to 300 people rent for some period then become owner again, this makes a lot of difference, halve the size of people who can be considered renters. Only doing this underestimae renters. //


egen rent_last =max(hstenr[_N]==2) , by(id) 

replace rent=1 if rent_last==1 //if last period renter then renter, slight increase. 

gen event =1 if hstenr == 2

egen first_wave = min(wave / (event == 1)), by(id)

replace first_wave=20 if missing(first_wave) | rent==0 //change to attrition

sort id 
quietly by id:  gen dup = cond(_N==1,0,_n)
drop if dup>1

egen age_group = cut(hgage), at(50,55,65,75,150)

//rent or live someone rent free

egen sold = max(hstenr == 2 | hstenr == 4), by(id) 








//physical downsize as the final result 


//hysical upsize as the final result 



//financial downsize (moving into less expensive house) as the final result 


//physical upsize (moving into more expensive house) as the final result 


//rent to own 


/////declare to be survival data////

stset first_wave, failure(rent=1)

sts graph //graph 

sts graph, by(age_group) ylabel(0.6(.1)1)

//can contrast with if don't do the rent thing 

sts graph, by(age_group) failure ylabel(0(.1)0.4) //plot failure instead 



























