/*******************************************************************************
							Tanzania Smart Subsidies - Main do-file for Stata							   
*******************************************************************************/
* Set version
version 15.1

* Set project global(s)	
 if "`c(username)'" == "wb633398" {
  global github 	"C:/Users/wb633398/Documents/GitHub/World Bank/moz-promove/DataWork/promove_fup2/promove_fup2_hh/Dofiles/Analysis/FUP2 Report/Replication Package"
  }
  
* Ensuring all packages used in the code are installed and with the same version
sysdir set PLUS "ado" // changes location where Stata searches for packages and directs it to a subfolder created by the team with all packages required to run the code

//*Install packages 
//local user_commands	ietoolkit iefieldkit winsor sumstats estout keeporder grc1leg2 fre distinct reghdfe ftools //Add required user-written commands
//
//foreach command of local user_commands {
//   capture which `command'
//   if _rc == 111 { // only will run if not installed (it's already installed if someone clones the repository, so it won't change the version)
//	   ssc install `command'
//   }
//}