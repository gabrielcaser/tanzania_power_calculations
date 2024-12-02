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

## Aggregating data at farmer-crop level
data_cp_co <- data_cp_co[, .(
  total_output = sum(ag4a_27, na.rm = TRUE),
  total_input = sum(ag4a_21, na.rm = TRUE)
), by = .(y5_hhid, cropid)]

data_ft_co <- data_ft_co[, .(
  total_output = sum(ag6a_09, na.rm = TRUE),
  total_input = sum(ag6a_04, na.rm = TRUE)
), by = .(y5_hhid, cropid)]

## Creating Productivity variable (Output / Input)
data_cp_co <- data_cp_co[, total_productivity := total_output / total_input]
data_ft_co <- data_ft_co[, total_productivity := total_output / total_input]

# Merging datasets --------------------------------------------------------
data_final <- rbind(data_cp_co, data_ft_co, fill = TRUE)
data_final <- merge(data_final, data_hh_p, by = "y5_hhid")

## Creating Stats per Crop at Farmer level
table = data_final[, .(
  Mean_Output       = mean(total_output, na.rm = TRUE),
  SD_Output         = sd(total_output, na.rm = TRUE),
  Mean_Productivity = mean(total_productivity, na.rm = TRUE),
  SD_Productivity   = sd(total_productivity, na.rm = TRUE),
  N_Obs             = .N
), by = .(cropid)][order(-Mean_Output)]

## Creating Total_Share = Share of farmers that produce the output
table[, Total_Share := round(N_Obs / sum(N_Obs), 2)]

## Setting variable labels
table <- set_variable_labels(table,
                             Mean_Output       = "Average harvested value of CROP per household across the three regions",
                             SD_Output         = "Standard deviation of harvested value of CROP per household across the three regions",
                             N_Obs             = "Number of households producing CROP in the three regions",
                             Total_Share       = "Proportion of households producing CROP in the three regions",
                             Mean_Productivity = "Average value of output harvested per input (area or number of trees)",
                             SD_Productivity   = "Standard deviation value of output harvested per input (area or number of trees)"
)

## Filtering per crop
table <- table[cropid %in% c("Maize", "Groundnut", "Beans", "Avocado"), ]
