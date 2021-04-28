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

###   Utility functions from SGP package
`%w/o%` <- function(x,y) x[!x %in% y]

### Get input/output.directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/LOW_PARTICIPATION_AMPUTE"
if (!exists("input.directory")) input.directory <- "Data/BASIC_ANALYSIS"

###   Setup output.directory
if (!dir.exists(file.path(output.directory, missing.type)))
  dir.create(file.path(output.directory, missing.type), recursive = TRUE)

###   Load data from BASIC_ANALYSIS -- STEPs 2b & 3a
load(file.path(input.directory, "Demonstration_COVID_SGP_2019_STEP_2b.Rdata"))
load(file.path(input.directory, "Demonstration_COVID_SGP_LONG_Data_2021.Rdata"))


###   Assemble data required for 2021 SCALE_SCORE amputation

##    Select variables to keep/return after amputation
if (exists("custom.ampSS.arg.list")) {
  variables.to.get <- c("VALID_CASE", "ID", "YEAR", unique(c(
      custom.ampSS.arg.list$default.vars %w/o% c("SCALE_SCORE_ACTUAL", "ACH_LEV_ACTUAL"), # "ACTUAL" vars created below
      custom.ampSS.arg.list$demographics,
      custom.ampSS.arg.list$institutions)))
} else {
  variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
      "SCALE_SCORE", "ACHIEVEMENT_LEVEL","FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
      "IEP_STATUS", "ETHNICITY","GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")
}

##    Combine two data sources with subset of desired variables
setnames(Demonstration_COVID_SGP@Data, c("SGP", "SGP_BASELINE"), c("SGP_ACTUAL", "SGP_BASELINE_ACTUAL"))
setnames(Demonstration_COVID_SGP_LONG_Data_2021, c("SGP", "SGP_BASELINE"), c("SGP_ACTUAL", "SGP_BASELINE_ACTUAL"))

Pre_COVID_Data <- rbindlist(
    list(Demonstration_COVID_SGP@Data[YEAR %in% 2018:2019, variables.to.get, with=FALSE],
         Demonstration_COVID_SGP_LONG_Data_2021[, variables.to.get, with=FALSE]))[,
                SCALE_SCORE_ACTUAL := SCALE_SCORE][, # Create "ACTUAL" vars
                ACH_LEV_ACTUAL := ACHIEVEMENT_LEVEL]

priors_to_add <- Pre_COVID_Data[YEAR == "2019" & GRADE %in% c("7", "8")]

###   Read in STEP 0 SGP configuration scripts - returns `growth_config_2021` and `status_config_2021`
source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

###   Specify the data and config arguments of amputeScaleScore
default.ampSS.arg.list <- list(
  ampute.data=Pre_COVID_Data,
  additional.data = priors_to_add,
  growth.config = growth_config_2021,
  status.config = status_config_2021
)

###   Merge custom.ampSS.arg.list from mstep script if exists
if (exists("custom.ampSS.arg.list")) {
  default.ampSS.arg.list <- modifyList(default.ampSS.arg.list, custom.ampSS.arg.list)
}

###   Run 10 amputations with added priors
Amputed_Data_LONG <- do.call(amputeScaleScore, default.ampSS.arg.list)

###   Save amputed data object
save(list=c("Amputed_Data_LONG", "default.ampSS.arg.list"), file=file.path(output.directory, missing.type, "Amputed_Data_LONG_with_argument_list.Rdata"))
