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


### Setup output.directory

output.directory <- "Data/BASIC_ANALYSIS"


### Setup parallel.config

parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4))


### Conduct Analysis Steps in Sequence

## STEP 1
setwd("Step_1_Pre_COVID")
print("BEGIN STEP 1")
source("Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R")

for(d in c("ELA.2017", "ELA.2018", "ELA.2019", "MATHEMATICS.2017", "MATHEMATICS.2018", "MATHEMATICS.2019")) {
  if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
  file.copy(file.path("Goodness_of_Fit", d),
            file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
}
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

for(d in c("ELA.2019.BASELINE", "MATHEMATICS.2019.BASELINE")) {
  if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
  file.copy(file.path("Goodness_of_Fit", d),
            file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
}
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

for(d in c("ELA.2021", "ELA.2021.BASELINE", "MATHEMATICS.2021", "MATHEMATICS.2021.BASELINE")) {
  if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
  file.copy(file.path("Goodness_of_Fit", d),
            file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
}
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

for(d in c("ELA.2022", "ELA.2022.BASELINE", "MATHEMATICS.2022", "MATHEMATICS.2022.BASELINE")) {
  if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
  file.copy(file.path("Goodness_of_Fit", d),
            file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
}
print("END STEP 4")


## STEP 5
setwd("Step_5_Recovery_Year_2")
print("BEGIN STEP 5")
source("Demonstration_COVID_SGP_2023.R")

for(d in c("ELA.2023", "ELA.2023.BASELINE", "MATHEMATICS.2023", "MATHEMATICS.2023.BASELINE")) {
  if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
  file.copy(file.path("Goodness_of_Fit", d),
            file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
}
print("END STEP 5")


## STEP 6
setwd("Step_6_Summary_Comparisons")
print("BEGIN STEP 6")
source("Demonstration_COVID_Summary_Comparisons_2021_BASIC.R")
print("END STEP 6")
