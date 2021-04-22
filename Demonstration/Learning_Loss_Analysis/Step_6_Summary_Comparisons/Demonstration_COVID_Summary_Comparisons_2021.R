################################################################################
###
### Script to investigate summary (e.g., mean SGP) comparisons using
### inferred values from functions such as bootstrapSRS
###
################################################################################

### Load packages

require(SGP)
require(Literasee)


setwd("..")

### Load Data

load("Data/BASIC_ANALYSIS/Demonstration_COVID_SGP_LONG_Data_2021.Rdata")
BASIC_ANALYSIS <- Demonstration_COVID_SGP_LONG_Data_2021
load("Data/LOW_PARTICIPATION_MOD1/Demonstration_COVID_SGP_LONG_Data_2021.Rdata")
LOW_PARTICIPATION_MOD1 <- Demonstration_COVID_SGP_LONG_Data_2021
