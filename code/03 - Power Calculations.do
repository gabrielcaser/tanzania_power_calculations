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
foreach outcome in "total_output" "total_productivity" {
	foreach crop in `all_crops' {
	 
	 loneway `outcome' district_code if cropid == "`crop'" //The loneway command calculates the one-way ANOVA by a group variable. 
							                               //It gives the within-group variation and the between group variation of a variable. 
							                               //It also produces the intra-cluster correlation coefficient (ICC)
	 local rho = `r(rho)' // ICC	 
	 display "ICC for the `outcome' of `crop': `rho'"
	 
	// preserve
	  clear
	  if `outcome' == "total_output" {
	  	gen outcome = "production" 
	  }
	  else if `outcome' == "total_productivity" {
	  	gen outcome = "production per hectare"
	  }
	  gen cropid = "`crop'"
      gen icc = `rho'
	}
}

