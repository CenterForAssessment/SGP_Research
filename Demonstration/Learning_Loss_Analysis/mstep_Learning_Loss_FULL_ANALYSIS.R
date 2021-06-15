################################################################################
###
###   Single script to run many steps consecutively
###   Complete Analysis (COVID Impact, Amputation, Imputation, Summaries)
###
################################################################################

###   There are SIX sections that can be modified:
###
##     - Hardware and Local Environment Variables
##       * How much CPU horsepower do you have / want to use?
##       * What directories to use?
##       * What BASELINE matrices do you want to use?
##     - COVID Impact
##       * Are you using data that has "Learning Loss" modeled
##       * Are you creating your own impacted data or using SGPdata default
##     - Low Participation / Missing Data
##       * Are you creating your own amputated data or using pre-calculated data with missing values?
##       * Define missingness type and patterns for low_participation
##       * Define missingness extent/proportion for low_participation
##     - Steps 1,2 & 3 (BASIC analysis for 2017-19, Baseline construction, and OBSERVED 2021 data analysis)
##       * If `run_prelim_steps = TRUE`, then the BASIC_ANALYSIS scripts for these
##         steps are run "as-is"
##       * if `observed_2021_analysis = TRUE`, then run steps 3a-3c on provided/produced
##         amputed data with data using provided/produced prior data (e.g.,
##         BASIC_ANALYSIS or `run_prelim_steps`)
##       * Alternatively, the appropriate `input.directory` can be provided for
##         the necessary Rdata objects produced in those steps as needed.
##     - Missing Data Imputation
##       * Include imputation of amputed data?
##       * Define imputation methods and variables/factors to use.
##     - Imputated Data SGP Analysis
##       * Include SGP (cohort and baseline) analyses using imputed data?
##       * Define data directories and baseline coefficient matrices to use.
##       * Imputated Data SGP analysis summary tables are created by default

###   NOTE:  Parallel processing is tricky!
###     The parallel processes in the SGP analyses don't play well with the ones
###     used in the imputation analyses.  It is advised to run Steps 0 through
###     `observed_2021_analysis` first (and only needs to be done once unless
###     changes to the amputation, etc. have been made), quit R, then reopen and
###     run the imputation steps.  It does not seem to be a problem going from
###     imputation to SGP analysis, however.  Very strange...

###   Define steps to be run:
covid_impact <- TRUE # If TRUE use sgpData_LONG_COVID default or define below
low_participation <- FALSE
run_prelim_steps <- FALSE
observed_2021_analysis <- FALSE
data_imputation <- TRUE
imputated_sgp_analysis <- TRUE
imputation_summaries <- imputated_sgp_analysis

###   Utility functions from SGP package
`%w/o%` <- function(x,y) x[!x %in% y]

#####
###   Hardware and Local Environment Variables
#####

##  Parallel processing for SGP analyses
sgp.cores <- 8
parallel.config <- list(
  BACKEND="PARALLEL",
  WORKERS=list(PERCENTILES = sgp.cores, BASELINE_PERCENTILES = sgp.cores,
               PROJECTIONS = sgp.cores, LAGGED_PROJECTIONS = sgp.cores,
               SGP_SCALE_SCORE_TARGETS = sgp.cores))

##  Parallel processing for imputeScaleScore
imp.cores <- 15

##  Main/base directory for saving/locating data
base.directory <- file.path("Data", "FULL_ANALYSIS")
output.directory <- base.directory
if (!dir.exists(base.directory)) dir.create(base.directory)

#####
###   COVID Academic Impact
#####

if (covid_impact) {
  ##  SGPdata default or user defined:
  covid.impact.directory <- "DEFAULT_IMPACT"
} else {
  covid.impact.directory <- "NO_IMPACT"
}


#####
###   Low Participation / Missing Data
#####

if (!low_participation) {
  ##  If not creating amputed data, which already amputed dataset to use
  # load(file.path(base.directory, "Demonstration_COVID_SGP_LONG_Data.Rdata"))
  ##  The following dataset could be used to skip 'low_participation', 'observed_2021_analysis' & 'run_prelim_steps'
  # load(file.path(base.directory, covid.impact.directory, "MISSING_30", "STATUS_w_DEMOG", "M_3", "Demonstration_COVID_SGP_LONG_Data.Rdata"))
  # Demonstration_COVID_SGP <- SGP::prepareSGP(Demonstration_COVID_SGP_LONG_Data, create.additional.variables = FALSE)
  # rm(Demonstration_COVID_SGP_LONG_Data)
} else {
  ###  Exemplar/Default for amputing data in "STATUS_w_DEMOG" style use in IMPUTATION simulations:
  missing.type <- "STATUS_w_DEMOG"

  ###   Customized arguments for amputeScaleScore
  extra.default.vars <- NULL # added to default default.vars argument ("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")
  my.amp.demographics <- c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER", "ETHN_HISP", "ETHN_AFAM")
  my.amp.vars <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ETHN_HISP", "ETHN_AFAM", "ELL_STATUS")
  my.amp.weights <- list(SCALE_SCORE=0.75, FREE_REDUCED_LUNCH_STATUS=0.5, ETHN_HISP=0.25, ETHN_AFAM=0.25, ELL_STATUS=0.25, SCHOOL_NUMBER=0.5) # Put institution last (if used) #
  my.rev.weight <- "SCALE_SCORE"
  my.ampute.args <- list(prop=0.3, type="RIGHT")
  my.complete.cases.only <- FALSE
  my.seed <- 303L
  # my.amputation.n <- 1 # Only 1 amputed dataset for FULL_ANALYSIS

  ###   Create custom data for `ampute.data` argument
  # Make ETHNICITY a series of dummy vars and include in ampute and impute.
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
}


#####
###   Steps 1,2 & 3 (BASIC analysis for 2017-19, Baseline construction, and OBSERVED 2021 data analysis)
#####

if (!run_prelim_steps) {
  ##  File path for the necessary Rdata objects produced in those steps.
  input.directory <- file.path("Data", "BASIC_ANALYSIS")
}

if (!observed_2021_analysis) {
  ##  An SGP object is needed for subsequent steps.  If not produced above in
  ##  "if (!low_participation)", then use something like this (assumes
  ##  `observed_2021_analysis` has already been run before):

  # observed_2021_data <- file.path("Data", "FULL_ANALYSIS", "Demonstration_COVID_SGP_2021_STEP_3c.Rdata")
}

#####
###   Imputation of missing data
#####

if (data_imputation) {
  ##  Customizable arguments for call to imputeScaleScore
  my.diagnostics.dir <- file.path(base.directory, "Imputation_Plots")
  my.impute.factors <- c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS",
                         "ELL_STATUS", "IEP_STATUS", "GENDER") # , "ETHN_WHITE" #
  imp.demographics <- c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "GENDER") # , "ETHN_WHITE" #
  my.impute.long <- FALSE
  my.impute.method <- "2l.pan"
  my.parallel.config <- list(packages = "mice", cores = imp.cores) # c("mice", "Qtools"), cores=20) # ,  # define cores, packages, cluster.type
  my.cluster.institution <- TRUE # set to TRUE for multilevel methods (cross-sectional required, LONG to avoid unnecesary message)
  imputation.m <- 30
  my.maxit <- 10
}

if (imputated_sgp_analysis) {
  imputed.file.name <- NULL ##  Final filename to be saved - if NULL, then Demonstration_COVID_SGP_Data_Imputed

  ##  Directory in which to look for 2021 OBSERVED data results (Demonstration_COVID_SGP_LONG_Data.Rdata)
  data.with.missing.directory <- base.directory
  baseline.matrices.directory <- base.directory
}

if (imputation_summaries) {
  ##  Summary filename to be saved
  summary.file.name <- "Demonstration_COVID_Imputation_Summaries"
}

###   Info for log files
log.imp.meth <- ifelse(exists("my.impute.method"), paste0(toupper(gsub("[.]", "", my.impute.method)), "LONG"[my.impute.long]), "NO_IMP")
if (low_participation) {
  my.logfile <- paste0("impute_", gsub(" ", "", SGP::capwords(covid.impact.directory)), "_",
                       paste0(missing.type, "_", my.ampute.args$prop*100), "_", log.imp.meth)
} else {
  my.logfile <- paste0("impute_", gsub(" ", "", SGP::capwords(covid.impact.directory)), "_", log.imp.meth)
}
my.log.directory <- file.path(base.directory, "Logs")

### Conduct Analysis Steps in Sequence
tmp.messages <- paste("\n\t#####  BEGIN FULL ANALYSES", date(), "  #####\n\n")
started.at.overall <- proc.time()

##    STEP 0
if (covid_impact) {
  ##  Currently no alternative COVID impact simulation.
}

if (low_participation) {
  setwd("Step_0_Data_Modification")
  print("BEGIN STEP 0")
  source("Demonstration_COVID_SINGLE_AMPUTE_ANALYSIS.R")
  print("END STEP 0")
}

### STEP 1-2
if (run_prelim_steps | observed_2021_analysis) started.prelim.obs <- proc.time()

if (run_prelim_steps) {
  ## STEP 1 (2018)
  setwd("Step_1_Pre_COVID")
  print("BEGIN STEP 1")
  source("Demonstration_COVID_SGP_2017_to_2019_PreCOVID.R")
  print("END STEP 1")

  step_1_file <- file.path(output.directory, "Demonstration_COVID_SGP_STEP_1.Rdata")
  file.remove(list.files(file.path(output.directory), full.names=TRUE) %w/o% step_1_file)

  ## STEP 2 (2019)
  # PART A
  tmp.par.config <- parallel.config
  if (!is.null(parallel.config)) {
    parallel.config$WORKERS <- list(TAUS = max(unlist(parallel.config$WORKERS)))
  }
  setwd("Step_2_Baseline_Creation")
  print("BEGIN STEP 2, PART A")
  source("Demonstration_COVID_Baseline_PART_A_Matrix_Calculations.R")
  print("END STEP 2, PART A")

  tmp.par.config -> parallel.config
  step_2a_file <- file.path(output.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata")

  # PART B
  setwd("Step_2_Baseline_Creation")
  print("BEGIN STEP 2, PART B")
  source("Demonstration_COVID_Baseline_PART_B_2019_Growth_Percentiles.R")
  print("END STEP 2, PART B")
  step_2b_file <- file.path(output.directory, "Demonstration_COVID_SGP_2019_STEP_2b.Rdata")

  # PART C
  setwd("Step_2_Baseline_Creation")
  print("BEGIN STEP 2, PART C")
  source("Demonstration_COVID_Baseline_PART_C_2019_Growth_Projections.R")
  print("END STEP 2, PART C")
  step_2c_file <- file.path(output.directory, "Demonstration_COVID_SGP_2019_STEP_2c.Rdata")

  prelim_files <- c(step_1_file, step_2a_file, step_2b_file, step_2c_file)
  file.remove(list.files(file.path(output.directory), full.names=TRUE) %w/o% prelim_files)

  for(d in c("ELA.2017", "ELA.2018", "ELA.2019", "MATHEMATICS.2017", "MATHEMATICS.2018", "MATHEMATICS.2019")) {
    if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
    file.copy(file.path("Goodness_of_Fit", d), file.path(output.directory, "Goodness_of_Fit"), recursive=TRUE)
  }
} else prelim_files <- NULL


## STEP 3 (2021)
# PART A
if (observed_2021_analysis) {
  if (run_prelim_steps) input.directory <- base.directory
  setwd("Step_3_Skip_Year_Analyses")
  print("BEGIN STEP 3, PART A (OBSERVED)")
  source("Demonstration_COVID_SGP_2021_PART_A.R")

  step_3a_file <- file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3a.Rdata")

  for (d in c("ELA.2021", "ELA.2021.BASELINE", "MATHEMATICS.2021", "MATHEMATICS.2021.BASELINE")) {
    if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
    file.copy(file.path("Goodness_of_Fit", d),
              file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
  }
  print("END STEP 3, PART A (OBSERVED)")

  # PART B
  setwd("Step_3_Skip_Year_Analyses")
  print("BEGIN STEP 3, PART B (OBSERVED)")
  source("Demonstration_COVID_SGP_2021_PART_B.R")
  print("END STEP 3, PART B (OBSERVED)")
  step_3b_file <- file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3b.Rdata")

  # PART C
  setwd("Step_3_Skip_Year_Analyses")
  print("BEGIN STEP 3, PART C")
  source("Demonstration_COVID_SGP_2021_PART_C.R")
  print("END STEP 3, PART C (OBSERVED)")
  step_3c_file1 <- file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3c.Rdata")
  step_3c_file2 <- file.path(output.directory, "Demonstration_COVID_SGP_LONG_Data.Rdata")

  observed_files <- c(step_3a_file, step_3b_file, step_3c_file1, step_3c_file2, file.path(output.directory, "Goodness_of_Fit"), file.path(output.directory, "Logs"))
  file.remove(list.files(file.path(output.directory), full.names=TRUE) %w/o% c(prelim_files, observed_files))
}

if (run_prelim_steps | observed_2021_analysis)
  tmp.messages <- c(tmp.messages,
    "\n\t\t", paste(c("Prelim Analyses (Steps 1 & 2)", "Observed SGP Analyses (Steps 3a-3c)")[c(run_prelim_steps, observed_2021_analysis)], collapse = " and "), " completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.prelim.obs)))


if (data_imputation | imputated_sgp_analysis | imputation_summaries) {
  input.directory <- data.with.missing.directory
  setwd("Step_3d_Summary_Results")
  print("BEGIN STEP 3d - Imputation")
  source("Demonstration_COVID_IMPUTE_SCORES_and_SGP_ANALYSIS.R")
  print("END STEP 3d")
}


steps.completed <-
  c("Data Amputation", "Prelim Analyses (Steps 1 & 2)", "Observed SGP Analyses (Steps 3a-3c)", "Data Imputation", "Imputed Data SGP Analysis", "Imputation Summaries")[
    c(low_participation, run_prelim_steps, observed_2021_analysis, data_imputation, imputated_sgp_analysis, imputation_summaries)]

tmp.messages <- c(tmp.messages, "\n\n\tFULL ANALYSIS", " with DEFAULT COVID impact "[covid_impact], " -- Steps: ", paste(paste(head(steps.completed, -1), collapse=", "), tail(steps.completed, 1), sep=" and "), " completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.at.overall)))
tmp.messages <- c(tmp.messages, paste("\n\t#####  END FULL ANALYSES", date(), "  #####\n\n"))
messageLog(log.message = tmp.messages, logfile = my.logfile, log.directory = my.log.directory)
