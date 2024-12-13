# Description: Master Script to Tanzania Subsidy Project

# R Version: 4.4.1

# PART 0: Clear memory =======================================================

rm(list = ls())
set.seed(123)

# PART 1: Load packages =======================================================

renv::restore()  # Uses packages locally, without installing them on the computer

packages_select = c(
  "data.table",  # data management
  "ggplot2",     # plots
  "skimr",       # quick sum stats
  "readstata13", # reading .dta files
  "haven",       # writing .dta files
  "dplyr",       # data management
  "labelled",     # variable labels
  "Hmisc"        # winsorizing
)

for (package in packages_select) {
  library(package, character.only = TRUE)
}

rm(package)
rm(packages_select)
# PART 2 - Execute codes --------------------------------------------------
source("code/01 - Processing Data.R")
source("code/02 - Constructing Data.R")