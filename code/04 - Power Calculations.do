* Description: This program calculates MDEs for different parameter values
use "${github}/data/final/dataset_power_calculations.dta", clear

* Create a dataset to store results
tempname results
postfile `results' str40 crop str40 outcome num_farmers mean icc sd detectable_difference attrition_percentage str40 multiples_sd using "${github}/output/power_calculations_results.dta", replace

* Loop through combinations of number of farmers, crops, and outcomes
forvalues num_farmers = 20(10)120 {  // number of clusters in each arm
    foreach crop in "Maize" "Avocado" "Groundnut" "Beans" {
        foreach outcome in "Production" "Production per hectare" {
			forvalues attrition_rate = 0.00(0.10)0.40 {
				foreach multiples_sd in "yes" "no" {
					
				preserve
                // Keep relevant subset
                keep if cropid == "`crop'" & outcome == "`outcome'"
                display "`crop' and `outcome'"
                // Calculate descriptive statistics
                summarize mean, meanonly
                local _mean = r(mean)
                
                summarize sd, meanonly
                local sd = r(mean)
                
				if "`crop'" == "Avocado" & "`outcome'" == "Production per hectare" {
					local _icc = 0
				}
				else {
					summarize icc, meanonly
					local _icc = r(mean)
				}			                
                
				local num_farmers_real = `num_farmers' - `attrition_rate'*`num_farmers'
				
                // Perform power calculation
                clustersampsi, detectabledifference mu1(`_mean') sd1(`sd') m(`num_farmers_real') k(43) rho(`_icc') // for some reason ICC = 0 is not functioning
                if "`multiples_sd'" == "no" {
					local dd = r(DD)
				}
				else if "`multiples_sd'" == "yes" {
					local dd = real(r(DD)) / `sd'
				}
				
                
                // Save results
                post `results' ("`crop'") ("`outcome'") (`num_farmers') (`_mean') (`_icc') (`sd') (`dd') (`attrition_rate' * 100) ("`multiples_sd'")
            restore
					
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
export delimited using "${github}/output/power_calculations_results.csv", replace
