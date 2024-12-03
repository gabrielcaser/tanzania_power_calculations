# This code constructs data

# Loading data into datatable format ------------------------------------------------------------
data_cp_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_CROPS.Rds" # crops data at cropID-PLOT_ID level
                      ))
data_ft_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_FRUITS.Rds" # fruit tree data
                      ))
data_hh_p <- data.table(readRDS(file = "data/intermediary/DATA_PROCESSED_HOUSEHOLDS.Rds"  # household local variables
                      ))

## Filtering for relevant regions
data_hh_p <- data_hh_p[hh_a01_1 %in% c("Iringa", "Katavi", "Njombe"), ]

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
#  total_input = sum(ag6a_04, na.rm = TRUE)
), by = .(y5_hhid, cropid)]

## Creating Productivity variable (Output / Input)
data_cp_co <- data_cp_co[, total_productivity := total_output / total_input]
#data_ft_co <- data_ft_co[, total_productivity := total_output / total_input]

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
                             Output_Mean       = "Average production of CROP/FRUIT harvested per household across the three regions",
                             Output_SD         = "Standard deviation of the harvested production of CROP/FRUIT per household across the three regions",
                             N_Obs             = "Number of households harvesting CROP/FRUIT in the three regions",
                             Total_Share       = "Proportion of households harvesting CROP/FRUIT in the three regions",
                             Productivity_Mean = "Average production of CROP harvested per hectare",
                             Productivity_SD   = "Standard deviation in the production of CROP harvested per hectare"
)


## Filtering per crop
table <- table[cropid %in% c("Maize", "Groundnut", "Beans", "Avocado"), ]

# Saving data_final and table

write_dta(table, "data/final/crops_stats.dta")
write_dta(data_final, "data/final/household_crops.dta")



