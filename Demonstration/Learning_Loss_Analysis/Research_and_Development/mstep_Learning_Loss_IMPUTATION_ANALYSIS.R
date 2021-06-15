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

cores <- 8
covid_impact <- FALSE
low_participation <- FALSE
missing.type <- "MCAR" # "STATUS_w_GROWTH" # "STATUS_w_DEMOG" #
complete_analysis <- FALSE # only needs to be run once!
imputation_analysis <- TRUE
imputation_summaries <- TRUE

###   Setup input/output.directory
###   Or just base and some others - define (at least) output in script

base.directory <- file.path("Data", "IMPUTATION_SIMULATION")
if (covid_impact) {
  covid.impact.directory <- "DEFAULT_IMPACT"
} else {
  covid.impact.directory <- "NO_IMPACT"
}
complete.directory <- file.path(base.directory, covid.impact.directory, "COMPLETE_ANALYSIS")
baseline.matrices.directory <- file.path("Data", "LOW_PARTICIPATION_AMPUTE", "COMPLETE_ANALYSIS")

### Setup parallel.config
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=cores, BASELINE_PERCENTILES=cores, PROJECTIONS=cores, LAGGED_PROJECTIONS=cores, SGP_SCALE_SCORE_TARGETS=cores))

base.demographics <- c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER") # , "ETHN_WHITE")
my.ampute.args <- list(prop=0.5, type="RIGHT")
my.seed <- 719L
my.amputation.n <- 50

if (low_participation) {
  if (missing.type=="MCAR") {
    my.amp.vars <- my.amp.weights <- my.rev.weight <- extra.default.vars <- NULL
    amp.demographics <- base.demographics
  }

  if (missing.type=="STATUS_w_DEMOG") {
    # Make ETHNICITY a series of dummy vars and start including in ampute and impute. - modify and send in `Demonstration_COVID_Data` from mstep
    require(data.table)
    my.ss <- ifelse(covid_impact & covid.impact.directory == "DEFAULT_IMPACT", "SCALE_SCORE", "SCALE_SCORE_without_COVID_IMPACT")
    variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        my.ss, "ACHIEVEMENT_LEVEL", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
        "IEP_STATUS", "ETHNICITY", "GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")
    Demonstration_COVID_Data <- data.table(SGPdata::sgpData_LONG_COVID[,variables.to.get, with=FALSE])
    if (!covid_impact) setnames(Demonstration_COVID_Data, my.ss, "SCALE_SCORE")

    Demonstration_COVID_Data[, ETHN_HISP := as.integer(NA)]
    Demonstration_COVID_Data[, ETHN_AFAM := as.integer(NA)]
    Demonstration_COVID_Data[ETHNICITY == "Hispanic", ETHN_HISP := 1L]
    Demonstration_COVID_Data[ETHNICITY != "Hispanic", ETHN_HISP := 0L]
    Demonstration_COVID_Data[ETHNICITY == "African American", ETHN_AFAM := 1L]
    Demonstration_COVID_Data[ETHNICITY != "African American", ETHN_AFAM := 0L]

    extra.default.vars <- NULL
    amp.demographics <- c(base.demographics, "ETHN_HISP", "ETHN_AFAM")
    my.amp.vars <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ETHN_HISP", "ETHN_AFAM", "ELL_STATUS")
    my.amp.weights <- list(SCALE_SCORE=0.75, FREE_REDUCED_LUNCH_STATUS=0.5, ETHN_HISP=0.25, ETHN_AFAM=0.25, ELL_STATUS=0.25, SCHOOL_NUMBER=0.5) # Put institution last (if used) #
    my.rev.weight <- "SCALE_SCORE"
  }

  if (missing.type=="STATUS_w_GROWTH") {
    require(data.table)
    load(file.path(complete.directory, "Demonstration_COVID_SGP_Complete.rda"))
    assign("Demonstration_COVID_Data", Demonstration_COVID_SGP_Complete)
    Demonstration_COVID_Data[YEAR == "2021", SGP_COMPLETE := NA]
    Demonstration_COVID_Data[YEAR == "2021", SGP_BASELINE_COMPLETE := NA]

    extra.default.vars <- c("SGP_COMPLETE", "SGP_BASELINE_COMPLETE")
    amp.demographics <- base.demographics
    my.amp.vars <- c("SCHOOL_NUMBER", "SCALE_SCORE", "SGP_COMPLETE")
    my.amp.weights <- list(SCALE_SCORE=2, SGP_COMPLETE=1, SCHOOL_NUMBER=1) # Put institution last (if used) # , SCHOOL_NUMBER=1
    my.rev.weight <- c("SCALE_SCORE", "SGP_COMPLETE")
  }
}

ampute.directory <- file.path(base.directory, covid.impact.directory, paste0("MISSING_", my.ampute.args$prop*100), missing.type)


if (imputation_analysis) {
  ##  Arguments passed to imputeScaleScore
  my.impute.factors <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "GENDER") # , "ETHN_WHITE" #
  imp.demographics <- c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "GENDER") # , "ETHN_WHITE" #
  # my.impute.factors <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS")
  # imp.demographics <- "FREE_REDUCED_LUNCH_STATUS"
  my.impute.long <- FALSE
  # my.impute.method <- "pmm"
  # my.impute.method <- "rf"
  # my.impute.method <- "2l.pan"
  my.impute.method <- "2l.pmm"
  # my.impute.method <- "2l.lmer"
  my.parallel.config <- list(packages = c("mice", "miceadds"), cores=20) # c("mice", "Qtools"), cores=20) # ,  # define cores, packages, cluster.type
  my.cluster.institution <- TRUE # set to TRUE for multilevel methods (cross-sectional required, LONG to avoid unnecesary message)
  imputation.m <- 20

  ##  Final filename to be saved
  imputed.file.name <- "Imputed_SGP_Data_L2PMM"
}

if (imputation_summaries) {
  summary.file.name <- "L2PMM_Summaries"
}

###   Info for log files
log.imp.meth <- ifelse(exists("my.impute.method"), paste0(toupper(gsub("[.]", "", my.impute.method)), "LONG"[my.impute.long]), "NO_IMP")
my.logfile <- paste0("impute_", gsub(" ", "", SGP::capwords(covid.impact.directory)), "_",
                     paste0(missing.type, "_", my.ampute.args$prop*100), "_", log.imp.meth)
my.log.directory <- file.path(ampute.directory, "Logs")

###   Run requested analyses
source("Step_0_Data_Modification/Demonstration_COVID_Imputation_and_Analysis.R")
