use "${github}/data/final/dataset_power_calculations.dta", clear

* Drop observations with missing ICC
//drop if icc == .

* Create a dataset to store results
tempname results
postfile `results' str40 crop str40 outcome num_farmers mean icc sd detectable_difference using "power_calculations_results.dta", replace

* Loop through combinations of number of farmers, crops, and outcomes
forvalues num_farmers = 20(10)120 {  // number of clusters in each arm
    foreach crop in "Maize" "Avocado" "Groundnut" "Beans" {
        foreach outcome in "Production" "Production per hectare" {
            preserve
                // Keep relevant subset
                keep if cropid == "`crop'" & outcome == "`outcome'"
                
                // Calculate descriptive statistics
                summarize mean, meanonly
                local _mean = r(mean)
                
                summarize sd, meanonly
                local sd = r(mean)
                
                summarize icc, meanonly
                local _icc = 0.05
                
                // Perform power calculation
                clustersampsi, detectabledifference mu1(`_mean') sd1(`sd') m(20) k(43) rho(`_icc') // for some reason ICC = 0 is not functioning
                local dd = r(DD)
                
                // Save results
                post `results' ("`crop'") ("`outcome'") (`num_farmers') (`_mean') (`_icc') (`sd') (`dd')
            restore
        }
    }
}

* Save and close results
postclose `results'

* Load the results dataset for review
use "power_calculations_results.dta", clear
list
