# This code constructs data

# Loading data into datatable format ------------------------------------------------------------
data_cp_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_CROPS.Rds" # crops data at cropID-PLOT_ID level
                      ))
data_ft_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_FRUITS.Rds" # fruit tree data
                      ))
data_hh_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_HOUSEHOLDS.Rds"  # household local variables
                      ))

## Dropping observations with harvested value = missing
data_cp_co <- data_cp_p[!is.na(ag4a_27), ]
data_ft_co <- data_ft_p[!is.na(ag6a_09), ]

## Dropping observations where area harvested = 0
data_cp_co <- data_cp_p[ag4a_21 != 0, ]

## Aggregating data at farmer-crop level
data_cp_co <- data_cp_co[, .(
  total_output = sum(ag4a_27, na.rm = TRUE),
  total_input = sum(ag4a_21, na.rm = TRUE)
), by = .(y5_hhid, cropid)]

data_ft_co <- data_ft_co[, .(
  total_output = sum(ag6a_09, na.rm = TRUE)
), by = .(y5_hhid, cropid)]

## Creating Productivity variable (Output / Input)
data_cp_co <- data_cp_co[, total_productivity := total_output / total_input]

# Merging datasets --------------------------------------------------------
data_final <- rbind(data_cp_co, data_ft_co, fill = TRUE)
data_final <- merge(data_final, data_hh_p, by = "y5_hhid")

## Creating Stats per Crop at Farmer level
table = data_final[, .(
  Output_Mean       = mean(total_output, na.rm = TRUE),
  Output_SD         = sd(total_output, na.rm = TRUE),
  Productivity_Mean = mean(total_productivity, na.rm = TRUE),
  Productivity_SD   = sd(total_productivity, na.rm = TRUE),
  N_Obs             = .N
), by = .(cropid)][order(-Output_Mean)]

## Creating Total_Share = Share of farmers that produce the output
table[, Total_Share := round(N_Obs / sum(N_Obs), 2)]

## Setting variable labels
table <- set_variable_labels(table,
                             Output_Mean       = "Average production of CROP/FRUIT harvested",
                             Output_SD         = "Standard deviation of the harvested production of CROP/FRUIT per household",
                             N_Obs             = "Number of households harvesting CROP/FRUIT",
                             Total_Share       = "Proportion of households harvesting CROP/FRUIT",
                             Productivity_Mean = "Average production of CROP harvested per hectare",
                             Productivity_SD   = "Standard deviation in the production of CROP harvested per hectare"
)

## Filtering per crop
table      <- table[cropid %in% c("Maize", "Groundnut", "Beans", "Avocado"), ]
data_final <- data_final[cropid %in% c("Maize", "Groundnut", "Beans", "Avocado"), ]

## Reshaping for power calculations

### Reshape the data
table_long <- melt(
  table,
  id.vars = "cropid",
  measure.vars = list(
    c("Output_Mean", "Productivity_Mean"), # Means
    c("Output_SD", "Productivity_SD")      # SDs
  ),
  variable.name = "outcome",
  value.name = c("mean", "sd")
)


### Renaming for clarity
table_long[, outcome := fifelse(outcome == 1, "Production", "Production per hectare")]

table_long <- set_variable_labels(table_long,
                             sd                = "Standard deviation of the OUTCOME of CROP/FRUIT per household",
                             mean              = "Average OUTCOME of CROP",
)

## Dropping variables we won't use
data_final[, hh_a01_1 := NULL]
data_final[, hh_a03_3a := NULL]
data_final[, hh_a03_1 := NULL]

# Saving data_final and table
write_dta(table_long, "data/final/crops_stats.dta")
write_dta(data_final, "data/final/household_crops.dta")



