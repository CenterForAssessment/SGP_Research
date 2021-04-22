################################################################################
###
### Single script to run many steps consecutively
### LOW PARTICIPATION MOD 1
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)
require(data.table)


### Setup output.directory

output.directory <- "Data/LOW_PARTICIPATION_MOD1"


### Conduct Analysis Steps in Sequence

## STEP 0

setwd("Step_0_Data_Modification")
print("BEGIN STEP 0")
source("sgpData_LONG_COVID_LOW_PARTICIPATION_MOD1.R")
print("END STEP 0")


## STEP 1
setwd("Step_1_Pre_COVID")
print("BEGIN STEP 1")
source("Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R")
print("END STEP 1")


## STEP 2
# PART A
setwd("Step_2_Baseline_Creation")
print("BEGIN STEP 2, PART A")
source("Demonstration_COVID_Baseline_PART_A_Matrix_Calculations.R")
print("END STEP 2, PART A")

# PART B
setwd("Step_2_Baseline_Creation")
print("BEGIN STEP 2, PART B")
source("Demonstration_COVID_Baseline_PART_B_2019_Growth_Percentiles.R")
print("END STEP 2, PART B")

# PART C
setwd("Step_2_Baseline_Creation")
print("BEGIN STEP 2, PART C")
source("Demonstration_COVID_Baseline_PART_C_2019_Growth_Projections.R")
print("END STEP 2, PART C")


## STEP 3
# PART A
setwd("Step_3_Skip_Year_Analyses")
print("BEGIN STEP 3, PART A")
source("Demonstration_COVID_SGP_2021_PART_A.R")
print("END STEP 3, PART A")

# PART B
setwd("Step_3_Skip_Year_Analyses")
print("BEGIN STEP 3, PART B")
source("Demonstration_COVID_SGP_2021_PART_B.R")
print("END STEP 3, PART A")

# PART C
setwd("Step_3_Skip_Year_Analyses")
print("BEGIN STEP 3, PART C")
source("Demonstration_COVID_SGP_2021_PART_C.R")
print("END STEP 3, PART A")


## STEP 4
setwd("Step_4_Recovery_Year_1")
print("BEGIN STEP 4")
source("Demonstration_COVID_SGP_2022.R")
print("END STEP 4")


## STEP 5
setwd("Step_5_Recovery_Year_2")
print("BEGIN STEP 5")
source("Demonstration_COVID_SGP_2023.R")
print("END STEP 5")
