# This code process data

# Loading data ------------------------------------------------------------
data_cp <- read.dta13(file = "data/raw/ag_sec_10.dta", # crops data
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
  "cropid",
  "ag10_02_1",
  "ag10_02_2",
  "ag10_04_1",
  "ag10_04_2"
)]

data_hh_p <- data_hh_p[, c(
  "y5_hhid",
  "hh_a01_1",
  "hh_a03_3a",
  "hh_a03_1",
  "hh_a02_1")]

data_ft_p <- data_ft_p[, c(
  "y5_hhid",
  "cropid",
  "ag6a_09")]

## Normalizing values names
data_cp_p$cropid       <- tools::toTitleCase(tolower(data_cp$cropid))
data_hh_p$hh_a03_3a    <- tools::toTitleCase(tolower(data_hh_p$hh_a03_3a))
data_hh_p$hh_a01_1     <- tools::toTitleCase(tolower(data_hh_p$hh_a01_1))
data_hh_p$hh_a02_1     <- tools::toTitleCase(tolower(data_hh_p$hh_a02_1))

## Setting variables labels
data_cp_p <- set_variable_labels(
  data_cp_p,
  ag10_02_1 = "Crop Name",
  ag10_02_2 = "Crop Code",
  ag10_04_1 = "What is the quantity produced in the last 12 months? AMOUNT",
  ag10_04_2 = "What is the quantity produced in the last 12 months? UNIT"
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
)

## Filtering for relevant crops and regions

data_hh_p <- data_hh_p[hh_a01_1 %in% c("Iringa", "Katavi", "Njombe"), ]
data_cp_p <- data_cp_p[ag10_02_2 %in% c(11, 12, 31), ] # Maize, Paddy, Beans
data_ft_p <- data_ft_p[cropid  == "avocado", ] 


# Saving ------------------------------------------------------------------
#saveRDS(file = "data/intermediary/")
write_dta(data_cp_p, "data/intermediary/TZA_PNS_CROPS.dta")
