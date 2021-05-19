################################################################################
###
###   Single script to run many steps consecutively
###   Full Simulation (COVID Impact, Amputation, Imputation, Analysis, Summaries)
###
################################################################################

###  Variables to define before running:
##     - cores -- the number of parallel processes to use
##     - covid_impact <- FALSE  #  still To-Be-Done
##     - low_participation <- TRUE  #  Include data amputation
##     - missing.type <- "MCAR" # Define missingness type for low_participation
##     - complete_analysis <- FALSE  #  Include complete data analysis - only needs to be done ONCE
##     - imputation_analysis <- TRUE  #  Include imputation of amputed data and subsequent SGP analyses
##     - imputation_summaries <- TRUE  #  Include summary table creation
##       (of imputed SGP/SS data via summarizeImputation function)

cores <- 15
covid_impact <- FALSE
low_participation <- TRUE
missing.type <- "STATUS_w_DEMOG" # "MCAR"
complete_analysis <- FALSE
imputation_analysis <- TRUE
imputation_summaries <- TRUE


###   Setup input/output.directory
###   Or just base and some others - define (at least) output in script
base.directory <- file.path("Data", "FULL_SIMULATION")
complete.directory <- file.path(base.directory, "COMPLETE_ANALYSIS")
baseline.matrices.directory <- file.path("Data", "LOW_PARTICIPATION_AMPUTE", "COMPLETE_ANALYSIS")

### Setup parallel.config
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=cores, BASELINE_PERCENTILES=cores, PROJECTIONS=cores, LAGGED_PROJECTIONS=cores, SGP_SCALE_SCORE_TARGETS=cores))

if (covid_impact) {
  message("TBD")
  covid.impact.directory <- "IMPACT_TBD"
} else {
  covid.impact.directory <- "NO_IMPACT"
}

base.demographics <- c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER")
my.ampute.args <- list(prop=0.3, type="RIGHT")
my.seed <- 719L
my.amputation.n <- 50

if (low_participation) {
  if (missing.type=="MCAR") {
    my.amp.vars <- my.amp.weights <- my.rev.weight <- extra.default.vars <- NULL
  }

  if (missing.type=="STATUS_w_DEMOG") {
    # Make ETHNICITY a series of dummy vars and start including in ampute and impute. - modify and send in `Demonstration_COVID_Data` from mstep
    require(data.table)
    variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
        "IEP_STATUS", "ETHNICITY", "GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")
    Demonstration_COVID_Data <- data.table(SGPdata::sgpData_LONG_COVID[,variables.to.get, with=FALSE])
    Demonstration_COVID_Data[, NON_WHITE := as.integer(NA)]
    Demonstration_COVID_Data[ETHNICITY == "White", NON_WHITE := 0L]
    Demonstration_COVID_Data[ETHNICITY != "White", NON_WHITE := 1L]

    extra.default.vars <- NULL
    amp.demographics <- c(base.demographics, "NON_WHITE")
    my.amp.vars <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "NON_WHITE", "ELL_STATUS")
    my.amp.weights <- list(SCALE_SCORE=1, FREE_REDUCED_LUNCH_STATUS=0.75, NON_WHITE=0.5, ELL_STATUS=0.5, SCHOOL_NUMBER=1) # Put institution last (if used) #
    my.rev.weight <- "SCALE_SCORE"
  }

  if (missing.type=="STATUS_w_GROWTH") {
    require(data.table)
    load(file.path(complete.directory, "Demonstration_COVID_SGP_Complete.rda"))
    variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
          "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "SGP", "SGP_BASELINE",
          "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER",
          "SCHOOL_NUMBER", "DISTRICT_NUMBER")
    Demonstration_COVID_Data <- Demonstration_COVID_SGP_Complete[,variables.to.get, with=FALSE]; rm(Demonstration_COVID_SGP); gc()
    Demonstration_COVID_Data[, SGP_COMPLETE := SGP]
    Demonstration_COVID_Data[, SGP_BASELINE_COMPLETE := SGP_BASELINE]
    Demonstration_COVID_Data[YEAR == "2021", SGP := NA]
    Demonstration_COVID_Data[YEAR == "2021", SGP_BASELINE := NA]

    extra.default.vars <- c("SGP_COMPLETE", "SGP_BASELINE_COMPLETE")
    my.amp.vars = c("SCHOOL_NUMBER", "SCALE_SCORE", "SGP_COMPLETE")
    my.amp.weights = list(SCALE_SCORE=2, SCHOOL_NUMBER=1) # Put institution last (if used) # , SCHOOL_NUMBER=1
    my.rev.weight = c("SCALE_SCORE", "SGP_COMPLETE")
  }
}

ampute.directory <- file.path(base.directory, covid.impact.directory, paste0("MISSING_", my.ampute.args$prop*100), missing.type)

# if (complete_analysis) {
#
# }

if (imputation_analysis) {
  ##  Arguments passed to imputeScaleScore
  my.impute.factors <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "GENDER")
  imp.demographics <- c('FREE_REDUCED_LUNCH_STATUS', 'ELL_STATUS', 'IEP_STATUS', 'GENDER')
  my.impute.long <- FALSE # TRUE
  my.impute.method <- "pmm"
  # my.impute.method <- "rq"
  # my.impute.method <- "2l.lmer"
  my.parallel.config <- list(packages = "mice", cores=10) # c("mice", "Qtools")) # define cores, packages, cluster.type
  my.cluster.institution <- FALSE # set to TRUE for multilevel (cross-sectional) methods
  imputation.m <- 20

  ##  Final filename to be saved
  imputed.file.name <- "Imputed_SGP_Data_PMM"
}

if (imputation_summaries) {
  summary.file.name <- "PMM_Summaries"
}

source("Step_0_Data_Modification/Demonstration_COVID_Imputation_and_Analysis.R")
