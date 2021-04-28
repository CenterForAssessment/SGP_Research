################################################################################
###
###   Single script to run many steps consecutively
###   LOW PARTICIPATION - AMPUTE/IMPUTE
###
################################################################################

###   Setup input/output.directory
input.directory <- "Data/BASIC_ANALYSIS"
output.directory <- "Data/LOW_PARTICIPATION_AMPUTE"

### Setup parallel.config
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4))

###   Define missingness type (before sourcing mstep script!)
# missing.type <- "MCAR"
# missing.type <- "STATUS_w_GROWTH"
# missing.type <- "STATUS_w_DEMOG"

if (missing.type=="MCAR") {
  my.amp.vars <- my.amp.weights <- my.rev.weight <- NULL
}

if (missing.type=="STATUS_w_GROWTH") {
  my.amp.vars = c("SCHOOL_NUMBER", "SCALE_SCORE", "SGP_ACTUAL")
  my.amp.weights = list(SCALE_SCORE=2, SCHOOL_NUMBER=1) # Put institution last (if used) # , SCHOOL_NUMBER=1
  my.rev.weight = c("SCALE_SCORE", "SGP_ACTUAL")
}

if (missing.type=="STATUS_w_DEMOG") {
  my.amp.vars = c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS")
  my.amp.weights = list(SCALE_SCORE=2, FREE_REDUCED_LUNCH_STATUS=1, ELL_STATUS=0.5) # Put institution last (if used) # , SCHOOL_NUMBER=1
  my.rev.weight = "SCALE_SCORE"
}

###   Set amputeScaleScore arguments (Some need to be changed in Step_0_Data_Modification/sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R)
custom.ampSS.arg.list <- list(
  # ampute.data = XXX,     # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # additional.data = XXX, # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # growth.config = XXX,   # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # status.config = XXX,   # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  default.vars = c("CONTENT_AREA", "GRADE",
                   "SCALE_SCORE", "ACHIEVEMENT_LEVEL",
                   "SCALE_SCORE_ACTUAL", "ACH_LEV_ACTUAL", # "ACTUAL" duplicate vars created in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
                   "SGP_ACTUAL", "SGP_BASELINE_ACTUAL"),  #  "ACTUAL" original vars renamed in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  demographics = c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
                   "IEP_STATUS", "ETHNICITY", "GENDER"),
  institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
  ampute.vars  = my.amp.vars,
  ampute.var.weights = my.amp.weights,
  reverse.weight = my.rev.weight,
  ampute.args = list(prop=0.3, type="RIGHT"),
  partial.fill = TRUE,
  invalidate.repeater.dups = TRUE,
  seed = 4224L,
  M = 10
)


#####
###   Conduct Analysis Steps in Sequence
#####

##    STEP 0

setwd("Step_0_Data_Modification")
print("BEGIN STEP 0")
source("Demonstration_COVID_LOW_PARTICIPATION_AMPUTE.R")
print("END STEP 0")

# ## STEP 1 (2018)
#setwd("Step_1_Pre_COVID")
#print("BEGIN STEP 1")
#source("Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R")
#print("END STEP 1")


# ## STEP 2 (2019)
# # PART A
#setwd("Step_2_Baseline_Creation")
#print("BEGIN STEP 2, PART A")
#source("Demonstration_COVID_Baseline_PART_A_Matrix_Calculations.R")
#print("END STEP 2, PART A")

# # PART B
#setwd("Step_2_Baseline_Creation")
#print("BEGIN STEP 2, PART B")
#source("Demonstration_COVID_Baseline_PART_B_2019_Growth_Percentiles.R")
#print("END STEP 2, PART B")

# # PART C
#setwd("Step_2_Baseline_Creation")
#print("BEGIN STEP 2, PART C")
#source("Demonstration_COVID_Baseline_PART_C_2019_Growth_Projections.R")
#print("END STEP 2, PART C")


## STEP 3 (2021)
# PART A
started.at.overall <- proc.time()
for (MM in 1:length(Amputed_Data_LONG)) {
  Demonstration_COVID_Data_LONG_2021 <- Amputed_Data_LONG[[MM]][YEAR == "2021"]
  output.directory <- file.path("Data", "LOW_PARTICIPATION_AMPUTE", missing.type, paste0("M_", MM))
  if (!dir.exists(output.directory)) dir.create(output.directory, recursive = TRUE)
  setwd("Step_3_Skip_Year_Analyses")
  print(paste("BEGIN STEP 3, PART A, Amputed dataset", MM))
  source("Demonstration_COVID_SGP_2021_PART_A.R")
  print(paste("END STEP 3, PART A, Amputed dataset", MM))

  for(d in c("ELA.2021", "ELA.2021.BASELINE", "MATHEMATICS.2021", "MATHEMATICS.2021.BASELINE")) {
    if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
    file.copy(file.path("Goodness_of_Fit", d),
              file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
  }
}
message("\n\tMstep with ", length(Amputed_Data_LONG), " datasets for STEP 3, PART A completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.at.overall)))
output.directory <- "Data/LOW_PARTICIPATION_AMPUTE"

# # PART B
# setwd("Step_3_Skip_Year_Analyses")
# print("BEGIN STEP 3, PART B")
# source("Demonstration_COVID_SGP_2021_PART_B.R")
# print("END STEP 3, PART A")
#
# # PART C
# setwd("Step_3_Skip_Year_Analyses")
# print("BEGIN STEP 3, PART C")
# source("Demonstration_COVID_SGP_2021_PART_C.R")
# print("END STEP 3, PART A")
#
#
# ## STEP 4
# setwd("Step_4_Recovery_Year_1")
# print("BEGIN STEP 4")
# source("Demonstration_COVID_SGP_2022.R")
# print("END STEP 4")
#
#
# ## STEP 5
# setwd("Step_5_Recovery_Year_2")
# print("BEGIN STEP 5")
# source("Demonstration_COVID_SGP_2023.R")
# print("END STEP 5")
