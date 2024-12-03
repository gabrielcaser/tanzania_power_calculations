/*******************************************************************************
							Tanzania Smart Subsidies - Main do-file for Stata							   
*******************************************************************************/
* Set version
version 15.1

* Set project global(s)	
 if "`c(username)'" == "wb633398" {
  global github "C:/Users/wb633398/Documents/GitHub/World Bank/tanzania_power_calculations"
  }
  
* Ensuring all packages used in the code are installed and with the same version
sysdir set PLUS "ado" // changes location where Stata searches for packages and directs it to a subfolder created by the team with all packages required to run the code

* Run do files 
* Switch to 0/1 to not-run/run do-files 
if (0) do "03 - Power Calculations.do"

* End of do-file!