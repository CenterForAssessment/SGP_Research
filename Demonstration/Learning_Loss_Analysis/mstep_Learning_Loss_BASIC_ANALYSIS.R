################################################################################
###
### Single script to run many steps consecutively
### BASIC ANALYSIS SCRIPT
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)
require(data.table)


### Conduct Analysis Steps in Sequence

# STEP 1

print("BEGIN STEP 1")
setwd("Step_1_Pre_COVID")
source("Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R")
print("END STEP 1")


# STEP 2

setwd("Step_2_Baseline_Creation")
print("BEGIN STEP 2, PART A")
source("Demonstration_COVID_Baseline_PART_A_Matrix_Calculations.R")
print("END STEP 2, PART A")
setwd("Step_2_Baseline_Creation")
print("BEGIN STEP 2, PART B")
source("Demonstration_COVID_Baseline_PART_B_2019_Growth_Percentiles.R")
print("END STEP 2, PART B")
print("BEGIN STEP 2, PART C")
source("Demonstration_COVID_Baseline_PART_C_2019_Growth_Projections.R")
print("END STEP 2, PART C")

# STEP 3

setwd("Step_3_Skip_Year_Analyses")
source("Demonstration_COVID_SGP_2021_PART_A.R")
setwd("Step_3_Skip_Year_Analyses")
source("Demonstration_COVID_SGP_2021_PART_B.R")
setwd("Step_3_Skip_Year_Analyses")
source("Demonstration_COVID_SGP_2021_PART_C.R")


# STEP 4

setwd("Step_4_Recovery_Year_1")
source("Demonstration_COVID_SGP_2022.R")

# STEP 5

setwd("Step_5_Recovery_Year_2")
source("Demonstration_COVID_SGP_2023.R")
