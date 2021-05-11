################################################################################
###                                                                          ###
###        Script to simulate low participation(missing data) in 2021        ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")

###   Load packages
require(SGP)
require(data.table)
source("Step_0_Data_Modification/amputeScaleScore.R") # Add to cfaTools?

### Get input/output.directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/LOW_PARTICIPATION_AMPUTE"
if (!exists("input.directory")) input.directory <- "Data/LOW_PARTICIPATION_AMPUTE"

###   Setup output.directory
if (!dir.exists(file.path(output.directory, missing.type)))
  dir.create(file.path(output.directory, missing.type), recursive = TRUE)

###   Load data from BASIC_ANALYSIS -- STEPs 2b & 3a

variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
      "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
      "IEP_STATUS", "ETHNICITY", "GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")

if (!exists("Demonstration_COVID_Data")) {
  Demonstration_COVID_Data <- data.table(SGPdata::sgpData_LONG_COVID[,variables.to.get, with=FALSE])#[,
  #               SCALE_SCORE_COMPLETE := SCALE_SCORE][,  # Create "COMPLETE" vars
  #               ACH_LEV_COMPLETE := ACHIEVEMENT_LEVEL]

  priors_to_add_2019 <- Demonstration_COVID_Data[YEAR == "2019" & GRADE %in% c("7", "8")]
  priors_to_add_2018 <- Demonstration_COVID_Data[YEAR == "2018" & GRADE %in% c("6", "7", "8")]
  priors_to_add_1617 <- Demonstration_COVID_Data[YEAR %in% c("2016", "2017")]
}

###   Read in STEP 0 SGP configuration scripts - returns `growth_config_2021` and `status_config_2021`
source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

###   Specify the data and config arguments of amputeScaleScore
default.ampSS.arg.list <- list(
  ampute.data=Demonstration_COVID_Data,
  growth.config = growth_config_2021,
  status.config = status_config_2021
)

###   Merge custom.ampSS.arg.list from mstep script if exists
if (exists("custom.ampSS.arg.list")) {
  ampSS_arg_list_used <- modifyList(default.ampSS.arg.list, custom.ampSS.arg.list)
} else ampSS_arg_list_used <- default.ampSS.arg.list

###   Run 10 amputations with added priors
Amputed_Data_LONG <- do.call(amputeScaleScore, ampSS_arg_list_used)

###   Save amputed data object
save(list=c("Amputed_Data_LONG", "ampSS_arg_list_used"), file=file.path(output.directory, missing.type, "Amputed_Data_LONG_with_argument_list.Rdata"))
