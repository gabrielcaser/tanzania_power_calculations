* This program runs power calculations *

* Creating Intracluster Correlation Coeficient (ICC) variable

** Oppening dataset
use  "${github}/data/final/household_crops.dta", clear

** Creating locals
levelsof cropid, local(all_crops)
display `all_crops'

** Using command
foreach outcome in "total_output" "total_productivity" {
	foreach crop in `all_crops' {
	 loneway `outcome' hh_a02_1 if cropid == `crop' //The loneway command calculates the one-way ANOVA by a group variable. 
							  //It gives the within-group variation and the between group variation of a variable. 
							  //It also produces the intra-cluster correlation coefficient (ICC)
	

	 local rho = `r(rho)' // ICC	 
	 display `rho'			
	}
}
		