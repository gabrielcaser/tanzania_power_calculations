# This code process data

# Observations
## Crop Names seems to repeat per household ID, I guess this is happening because the dataset is at the level crop|by-product level

# Loading data ------------------------------------------------------------
data_cp <- read.dta13(file = "data/raw/ag_sec_4a.dta", # crops data at cropID-PLOT_ID level
                      generate.factors = TRUE)
data_ft <- read.dta13(file = "data/raw/ag_sec_6a.dta", # fruit tree data
                      generate.factors = TRUE)
data_hh <- read.dta13(file = "data/raw/hh_sec_a.dta",  # household local variables
                      generate.factors = TRUE)


data_cp    <- data.table(data_cp) # turns into data.frame format (increased performance)
data_hh    <- data.table(data_hh)
data_ft    <- data.table(data_ft)
# Processing data ---------------------------------------------------------

## Removing duplicates
data_cp_p    <- data_cp[!duplicated(data_cp), ]
data_hh_p    <- data_hh[!duplicated(data_hh), ]
data_ft_p    <- data_ft[!duplicated(data_ft), ]

## Selecting relevant variables
data_cp_p <- data_cp_p[, c(
  "y5_hhid",
  "plot_id",
  "cropid",
  "ag4a_27",
  "ag4a_21"
)]

data_hh_p <- data_hh_p[, c(
  "y5_hhid",
  "hh_a01_1",
  "hh_a03_3a",
  "hh_a03_1",
  "hh_a02_1")]

data_ft_p <- data_ft_p[, c(
  "y5_hhid",
  "plot_id",
  "cropid",
  "ag6a_09",
  "ag6a_04")]

## Normalizing values names
data_cp_p$cropid       <- tools::toTitleCase(tolower(data_cp$cropid))
data_ft_p$cropid       <- tools::toTitleCase(tolower(data_ft_p$cropid))
data_hh_p$hh_a03_3a    <- tools::toTitleCase(tolower(data_hh_p$hh_a03_3a))
data_hh_p$hh_a01_1     <- tools::toTitleCase(tolower(data_hh_p$hh_a01_1))
data_hh_p$hh_a02_1     <- tools::toTitleCase(tolower(data_hh_p$hh_a02_1))

## Setting variables labels
data_cp_p <- set_variable_labels(
  data_cp_p,
  ag4a_27   = "What was the quantity harvested? (KG)",
  ag4a_21   = "What was the area harvested in the long rainy season 2020?"
)

data_hh_p <- set_variable_labels(
  data_hh_p,
  hh_a01_1  = "Region Code",
  hh_a03_3a = "Village Code",
  hh_a03_1  = "Ward Code",
  hh_a02_1  = "District Code"
)

data_ft_p <- set_variable_labels(
  data_ft_p,
  ag6a_09  = "What was the total amount of [FRUIT] harvested in the past 12 months? (KG)",
  ag6a_04  = "How many plants/trees were planted during the last 12 months?"
)

# Saving ------------------------------------------------------------------
saveRDS(data_cp_p, file = "data/intermediary/DATA_PROCESSED_CROPS.Rds")
saveRDS(data_ft_p, file = "data/intermediary/DATA_PROCESSED_FRUITS.Rds")
saveRDS(data_hh_p, file = "data/intermediary/DATA_PROCESSED_HOUSEHOLDS.Rds")




