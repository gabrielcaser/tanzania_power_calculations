* This program runs power calculations *

* Creating Intracluster Correlation Coeficient (ICC) variable

** Oppening dataset
use  "${github}/data/final/household_crops.dta", clear

** Changing types
encode hh_a02_1, gen(district_code)
drop hh_a02_1

** Creating locals
levelsof cropid, local(all_crops)
display `all_crops'

** Using command to estimate icc at the Distric level
local first_loop 1
foreach outcome in "total_output" "total_productivity" {
	foreach crop in `all_crops' {
	 
	 loneway `outcome' district_code if cropid == "`crop'" //The loneway command calculates the one-way ANOVA by a group variable. 
							                               //It gives the within-group variation and the between group variation of a variable. 
							                               //It also produces the intra-cluster correlation coefficient (ICC) 
	 display "ICC for the `outcome' of `crop': `r(rho)'"
	 
	 // Storing ICC results
	 matrix input results = (`r(rho)') 

	 // Create a dataset from the matrix
	 preserve
		clear
		svmat results, names(col)
		ren c1 icc
		if "`outcome'" == "total_output" {
         gen outcome = "Production"
        }
        else if "`outcome'" == "total_productivity" {
         gen outcome = "Production per hectare"
	    }
	    gen cropid = "`crop'"
		
		if `first_loop' == 1 {
		 save "icc_data_temp.dta", replace
		}
		else if `first_loop' == 0 {
		 append using "icc_data_temp.dta"
		 save "icc_data_temp.dta", replace
		}
		local first_loop 0
	 restore
	 }
}

** Merging ICC with Sum stats
use "${github}/data/final/crops_stats.dta", clear
merge 1:1 outcome cropid using "icc_data_temp.dta"
drop _merge

** Saving and removing temp files
save "${github}/data/final/dataset_power_calculations.dta", replace
rm "icc_data_temp.dta"