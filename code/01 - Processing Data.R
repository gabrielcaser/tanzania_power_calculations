# This code process data

# Loading data ------------------------------------------------------------
data <- read.dta13(file = "data/raw/ag_sec_5a.dta",
                   generate.factors = TRUE # get variabels' labels
                   )

data <- data.table(data) # turns into data.frame format (increased performance)

# Processing data ---------------------------------------------------------

## Removing duplicates
data_p <- data[!duplicated(data), ]

## Selecting relevant variables
data_p <- data_p[, c("interview__key", "y5_hhid", "cropid", "ag5a_02", "ag5a_03")]

## Normalizing values names
data_p$cropid <- tools::toTitleCase(tolower(data$cropid))

## Setting variables labels
data_p <- set_variable_labels(data_p,
                              ag5a_02 = "What was the quantity sold? (KG)",
                              ag5a_03 = "What was the total value of the sales? (TSH)"
                              )


# Saving ------------------------------------------------------------------
#saveRDS(file = "data/intermediary/")
write_dta(data_p, "data/intermediary/TZA_PNS_CROPS.dta")
