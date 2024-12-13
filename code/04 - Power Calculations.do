* Description: This program calculates MDEs for different parameter values
use "${github}/data/final/dataset_power_calculations.dta", clear

* Create a dataset to store results
tempname results
postfile `results' str40 crop str40 outcome str40 num_farmers str40 num_clusters mean str40 icc_assumed sd detectable_difference attrition_percentage str40 results_unit str40 baseline_cor str40 winsorized using "${github}/output/power_calculations_results.dta", replace

* Loop through combinations of number of farmers, crops, and outcomes
forvalues num_farmers = 10(10)90 {  // number of clusters in each arm
    foreach crop in "Maize" "Avocado" "Groundnut" "Beans" {
        foreach outcome in "Production" "Production per hectare" {
			forvalues attrition_rate = 0.00(0.10)0.10 {
				foreach results_unit in "Kg or Kg per Hec" "Multiples of SD" "Percentage Increase" {
					forvalues num_clusters = 13(10)83 {
						forvalues icc_assumed = 0.0(0.1)0.3 {
							forvalues baseline_cor = 0.1(0.1)0.7 {
								foreach winsorized_option in "yes" "no" {	
									preserve
										// Keep relevant subset
										keep if cropid == "`crop'" & outcome == "`outcome'" & winsorized == "`winsorized_option'"
										display "`crop' and `outcome'"
										// Calculate descriptive statistics
										summarize mean, meanonly
										local _mean = r(mean)
										
										summarize sd, meanonly
										local sd = r(mean)
										
										//if "`icc_defined'" == "No" | ("`crop'" == "Avocado" & "`outcome'" == "Production per hectare") {
										//	local _icc = 0 // Defining it as 0 for Avocado since we don't have data on Yields for it
										//}
										//else if "`icc_defined'" == "Yes" {
										//	summarize icc, meanonly
										//	local _icc = r(mean)
										//}			                
										
										local num_farmers_real = `num_farmers' - `attrition_rate'*`num_farmers'
										
										// Perform power calculation
										clustersampsi, detectabledifference mu1(`_mean') sd1(`sd') m(`num_farmers_real') k(`num_clusters') rho(`icc_assumed') base_correl(`baseline_cor') // add correlation between base_correl()
										if "`results_unit'" == "Kg or Kg per Hec" {
											local dd = r(DD)
										}
										else if "`results_unit'" == "Multiples of SD" {
											local dd = real(r(DD)) / `sd'
										}
										else if "`results_unit'" == "Percentage Increase" {
											local dd = real(r(DD)) / `_mean'
										}
										
										local num_farmers_string = "`num_farmers' farmers"
										local num_clusters_string = "`num_clusters' clusters"
										
										// Save results
										post `results' ("`crop'") ("`outcome'") ("`num_farmers_string'") ("`num_clusters_string'") (`_mean') ("`icc_assumed'") (`sd') (`dd') (`attrition_rate' * 100) ("`results_unit'") ("`baseline_cor'") ("`winsorized_option'")
									restore
								}
							}
						
						}

					}
					
				}

			}

        }
    }
}

* Save and close results
postclose `results'

* Load the results dataset for review
use "${github}/output/power_calculations_results.dta", clear
//list
export excel using "${github}/output/power_calculations_results.xlsx", firstrow(variables) sheet("power_calculations_results") replace 