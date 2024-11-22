# Description: Master Script to Tanzania Subsidy Project

# R Version: 4.4.1

# PART 0: Clear memory =======================================================

rm(list = ls())
set.seed(123)

# PART 1: Load packages =======================================================

renv::restore() # Uses packages locally, without installing them on the computer

packages_select = c(
  "data.table",
  "ggplot2",
  "skimr"
  
)

for (package in packages_select) {
  library(package, character.only = TRUE)
}

# PART 2 - Execute codes --------------------------------------------------
#source("Code/01 - Construct dataset.R")