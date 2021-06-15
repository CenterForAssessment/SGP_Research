################################################################################
###                                                                          ###
###       Script to create a single dataset for 2021 COMPLETE analysis       ###
###                                                                          ###
################################################################################

###   Set working directory to base Learning_Loss_Analysis directory
setwd("..")

if (exists("tmp.messages")) {
  tmp.messages <- c(tmp.messages, paste("\n\t#####  BEGIN Single File Data Modification", date(), "  #####\n\n"))
} else tmp.messages <- paste("\n\t#####  BEGIN Single File Data Modification", date(), "  #####\n\n")
started.data.mod <- proc.time()

###   Load packages
require(SGP)
require(data.table)
require(cfaTools)

###   Define data modification analyses to run if not already established
if (!exists("covid_impact")) covid_impact <- TRUE
if (!exists("low_participation")) low_participation <- TRUE

#####
###   Step 0 - Data Modification
#####

###   Add in a particular COVID Pandemic Academic Impact

if (covid_impact) {
  # started.impact <- proc.time()
  # tmp.messages <- c(tmp.messages, paste("\n\tAcademic Impact/Learning Loss data modification completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.impact))))
  if (covid.impact.directory == "DEFAULT_IMPACT") {
    tmp.messages <- c(tmp.messages, "\n\t\tDefault SGPdata COVID Impact Used\n")
  }
}


###   Scale Score Amputation and ("Observed" and "Complete" data) SGP Analyses

if (low_participation) {
  started.lowpart <- proc.time()
  if (!exists("Demonstration_COVID_Data")) {
    my.ss <- ifelse(covid_impact & covid.impact.directory == "DEFAULT_IMPACT", "SCALE_SCORE", "SCALE_SCORE_without_COVID_IMPACT")
    variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        my.ss, "ACHIEVEMENT_LEVEL", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
        "IEP_STATUS", "ETHNICITY", "GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")
    Demonstration_COVID_Data <- data.table(SGPdata::sgpData_LONG_COVID[,variables.to.get, with=FALSE])
    if (!covid_impact) setnames(Demonstration_COVID_Data, my.ss, "SCALE_SCORE")
  }

  ###   Read in STEP 0 SGP configuration scripts
  ###   Returns `growth_config_2021` and `status_config_2021`
  source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
  source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

  ###   Run 10 amputations with added priors
  Amputed_Data_LONG <-  amputeScaleScore(
      ampute.data = Demonstration_COVID_Data,
      growth.config = growth_config_2021,
      status.config = status_config_2021,
      compact.results = TRUE,
      default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", extra.default.vars),
      demographics = my.amp.demographics,
      institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
      ampute.vars  = my.amp.vars,
      ampute.var.weights = my.amp.weights,
      reverse.weight = my.rev.weight,
      ampute.args = my.ampute.args,
      complete.cases.only = my.complete.cases.only,
      partial.fill = TRUE,
      invalidate.repeater.dups = TRUE,
      seed = my.seed,
      M = 1 # my.amputation.n
  )

  Demonstration_COVID_Data_LONG_2021 <- Amputed_Data_LONG[YEAR=="2021"][AMP_1==TRUE, SCALE_SCORE := NA]
  Demonstration_COVID_Data_LONG_2021[, AMP_1 := NULL]
  tmp.messages <- c(tmp.messages, paste("\n\t\tLow Participation data modification completed in", SGP:::convertTime(SGP:::timetakenSGP(started.lowpart))))
}

tmp.messages <- c(tmp.messages, "\n\t#####  END Data Modification  #####\n")
