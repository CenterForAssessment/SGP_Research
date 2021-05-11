################################################################################
###
###   Single script to run many steps consecutively
###   LOW PARTICIPATION - AMPUTE/IMPUTE
###
################################################################################

###  Variables to define before running:
##     - missing.type <- "MCAR" # Define missingness type
##     - cores -- the number of parallel processes to use
##     - run_prelim_steps <- FALSE # unless you want to run steps 1-2B again

###   Utility functions from SGP package
`%w/o%` <- function(x,y) x[!x %in% y]

###   Setup input/output.directory
input.directory <- output.directory <- base.directory <- file.path("Data", "LOW_PARTICIPATION_AMPUTE")


### Setup parallel.config
if (!exists("cores")) cores <- 4
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=cores, BASELINE_PERCENTILES=cores, PROJECTIONS=cores, LAGGED_PROJECTIONS=cores, SGP_SCALE_SCORE_TARGETS=cores))

###   Define missingness type (before sourcing mstep script!)
# missing.type <- "MCAR"
# missing.type <- "STATUS_w_GROWTH"
# missing.type <- "STATUS_w_DEMOG"

if (missing.type=="MCAR") {
  my.amp.vars <- my.amp.weights <- my.rev.weight <- extra.default.vars <- NULL
}

if (missing.type=="STATUS_w_GROWTH") {
  require(data.table)
  load(file.path(base.directory, "COMPLETE_ANALYSIS", "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"))
  variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "SGP", "SGP_BASELINE",
        "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS", "IEP_STATUS", "ETHNICITY", "GENDER",
        "SCHOOL_NUMBER", "DISTRICT_NUMBER")
  Demonstration_COVID_Data <- Demonstration_COVID_SGP@Data[,variables.to.get, with=FALSE]; rm(Demonstration_COVID_SGP); gc()
  # setnames(Demonstration_COVID_Data, c("SGP", "SGP_BASELINE"), c("SGP_COMPLETE", "SGP_BASELINE_COMPLETE"))
  Demonstration_COVID_Data[, SGP_COMPLETE := SGP]
  Demonstration_COVID_Data[, SGP_BASELINE_COMPLETE := SGP_BASELINE]
  Demonstration_COVID_Data[YEAR == "2021", SGP := NA]
  Demonstration_COVID_Data[YEAR == "2021", SGP_BASELINE := NA]

  extra.default.vars <- c("SGP_COMPLETE", "SGP_BASELINE_COMPLETE")
  my.amp.vars = c("SCHOOL_NUMBER", "SCALE_SCORE", "SGP_COMPLETE")
  my.amp.weights = list(SCALE_SCORE=2, SCHOOL_NUMBER=1) # Put institution last (if used) # , SCHOOL_NUMBER=1
  my.rev.weight = c("SCALE_SCORE", "SGP_COMPLETE")
}

if (missing.type=="STATUS_w_DEMOG") {
  extra.default.vars = NULL
  my.amp.vars = c("SCHOOL_NUMBER", "SCALE_SCORE", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS")
  my.amp.weights = list(SCALE_SCORE=2, FREE_REDUCED_LUNCH_STATUS=1, ELL_STATUS=0.5) # Put institution last (if used) # , SCHOOL_NUMBER=1
  my.rev.weight = "SCALE_SCORE"
}

###   Set amputeScaleScore arguments (Some need to be changed in Step_0_Data_Modification/sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R)
custom.ampSS.arg.list <- list(
  # ampute.data =     XXX, # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # additional.data = XXX, # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # growth.config =   XXX, # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  # status.config =   XXX, # (!) Set in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  compact.results = TRUE,
  default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", extra.default.vars),
                   # "SCALE_SCORE_COMPLETE", "ACH_LEV_COMPLETE"), # "ACTUAL" duplicate vars created in sgpData_LONG_COVID_LOW_PARTICIPATION_AMPUTE.R
  demographics = c("FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
                   "IEP_STATUS", "ETHNICITY", "GENDER"),
  institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
  ampute.vars  = my.amp.vars,
  ampute.var.weights = my.amp.weights,
  reverse.weight = my.rev.weight,
  ampute.args = list(prop=0.3, type="RIGHT"),
  complete.cases.only = TRUE,
  partial.fill = TRUE,
  invalidate.repeater.dups = TRUE,
  seed = 4224L,
  M = 10
)


#####
###   Conduct Analysis Steps in Sequence
#####

started.at.overall <- proc.time()

##    STEP 0
output.directory <- file.path(base.directory, paste0("MISSING_", custom.ampSS.arg.list$ampute.args$prop*100))
setwd("Step_0_Data_Modification")
print("BEGIN STEP 0")
source("Demonstration_COVID_LOW_PARTICIPATION_AMPUTE.R")
print("END STEP 0")


if (run_prelim_steps) {
  output.directory <- file.path(base.directory, "COMPLETE_ANALYSIS")

  Demonstration_COVID_Data_LONG <- rbindlist(list(
      priors_to_add_1617, priors_to_add_2018, priors_to_add_2019,
      Amputed_Data_LONG[YEAR <= 2019][, grep("^AMP_", names(Amputed_Data_LONG)) := NULL]),
    use.names=TRUE, fill=TRUE)

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
  file.remove(list.files(file.path(output.directory), full.names=TRUE) %w/o% c(step_1_file, step_2a_file, step_2b_file))


  # PART C
  setwd("Step_2_Baseline_Creation")
  print("BEGIN STEP 2, PART C")
  source("Demonstration_COVID_Baseline_PART_C_2019_Growth_Projections.R")
  print("END STEP 2, PART C")

  ## STEP 3 (2021) - "COMPLETE" data
  # PART A
  Demonstration_COVID_Data_LONG_2021 <- Amputed_Data_LONG[YEAR == "2021"][,
              grep("^AMP_", names(Amputed_Data_LONG)) := NULL]
  input.directory <- file.path(base.directory, "COMPLETE_ANALYSIS")

  setwd("Step_3_Skip_Year_Analyses")
  print("BEGIN STEP 3, PART A, COMPLETE dataset")
  source("Demonstration_COVID_SGP_2021_PART_A.R")
  print("END STEP 3, PART A, COMPLETE dataset")

  for(d in c("ELA.2021", "ELA.2021.BASELINE", "MATHEMATICS.2021", "MATHEMATICS.2021.BASELINE")) {
    if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
    file.copy(file.path("Goodness_of_Fit", d),
              file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
  }
  complete_sgps <- Demonstration_COVID_SGP@Data[YEAR=='2021' & !is.na(SGP), c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "SGP", "SGP_BASELINE"),]
  setnames(complete_sgps, c("SCALE_SCORE", "SGP", "SGP_BASELINE"), c("SCALE_SCORE_COMPLETE", "SGP_COMPLETE", "SGP_BASELINE_COMPLETE"))
  setkeyv(complete_sgps, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE_COMPLETE"))

  # PART D (Create summaries)
  setwd("Step_3d_Summary_Results")
  print("BEGIN STEP 3, PART D")
  source("Demonstration_COVID_Summary_Comparisons_2021_BASIC.R")
  print("END STEP 3, PART D")

} else {
  if (missing.type != "STATUS_w_GROWTH") {
    load(file.path(base.directory, "COMPLETE_ANALYSIS", "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"))
    complete_sgps <- Demonstration_COVID_SGP@Data[YEAR=='2021' & !is.na(SGP), c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "SGP", "SGP_BASELINE"),]
    setnames(complete_sgps, c("SCALE_SCORE", "SGP", "SGP_BASELINE"), c("SCALE_SCORE_COMPLETE", "SGP_COMPLETE", "SGP_BASELINE_COMPLETE"))
    setkeyv(complete_sgps, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE_COMPLETE"))
  }
}

## STEP 3 (2021)
# PART A
for (MM in seq(custom.ampSS.arg.list$M)) {
  Demonstration_COVID_Data_LONG_2021 <- copy(Amputed_Data_LONG[YEAR=="2021"])[,
                            SCALE_SCORE_COMPLETE := SCALE_SCORE][,  # Create "COMPLETE" vars
                            ACH_LEV_COMPLETE := ACHIEVEMENT_LEVEL][
                            get(paste0("AMP_", MM))==TRUE, SCALE_SCORE := NA][,
                            grep("^AMP_", names(Amputed_Data_LONG)) := NULL]
  if (missing.type != "STATUS_w_GROWTH") {
    setkeyv(Demonstration_COVID_Data_LONG_2021, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE_COMPLETE"))
    Demonstration_COVID_Data_LONG_2021 <- merge.data.table(Demonstration_COVID_Data_LONG_2021, complete_sgps, all.x=TRUE)
  }

  output.directory <- file.path(base.directory, paste0("MISSING_", custom.ampSS.arg.list$ampute.args$prop*100), missing.type, paste0("M_", MM))
  input.directory <- file.path(base.directory, "COMPLETE_ANALYSIS")

  if (!dir.exists(output.directory)) dir.create(output.directory, recursive = TRUE)
  setwd("Step_3_Skip_Year_Analyses")
  print(paste("BEGIN STEP 3, PART A, Amputed dataset", MM))
  source("Demonstration_COVID_SGP_2021_PART_A.R")

  outputSGP(Demonstration_COVID_SGP, output.type="LONG_Data", outputSGP.directory=output.directory)
  step_3a_file <- file.path(output.directory, "Demonstration_COVID_SGP_LONG_Data.Rdata")
  file.remove(list.files(file.path(output.directory), full.names=TRUE) %w/o% step_3a_file)

  for (d in c("ELA.2021", "ELA.2021.BASELINE", "MATHEMATICS.2021", "MATHEMATICS.2021.BASELINE")) {
    if(!dir.exists(file.path(output.directory, "Goodness_of_Fit", d))) dir.create(file.path(output.directory, "Goodness_of_Fit", d), recursive = TRUE)
    file.copy(file.path("Goodness_of_Fit", d),
              file.path(output.directory, "Goodness_of_Fit"), recursive = TRUE)
  }
  rm(Demonstration_COVID_SGP);gc()
  print(paste("END STEP 3, PART A, Amputed dataset", MM))
}
message("\n\tMstep with ", length(Amputed_Data_LONG), " datasets for STEP 3, PART A completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.at.overall)))

output.directory <- base.directory

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

# PART D (Create summaries)

output.directory <- file.path(base.directory, paste0("MISSING_", custom.ampSS.arg.list$ampute.args$prop*100))
input.directory <- file.path(base.directory, "COMPLETE_ANALYSIS")

if (missing.type=="MCAR") {
  setwd("Step_3d_Summary_Results")
  print("BEGIN STEP 3, PART D, MCAR")
  output.file.directories <- "MCAR"
  source("Demonstration_COVID_Summary_Comparisons_2021_AMPUTE.R")
  print("END STEP 3, PART D, MCAR")
}

if (missing.type=="STATUS_w_DEMOG") {
  setwd("Step_3d_Summary_Results")
  print("BEGIN STEP 3, PART D, STATUS_w_DEMOG")
  output.file.directories <- "STATUS_w_DEMOG"
  source("Demonstration_COVID_Summary_Comparisons_2021_AMPUTE.R")
  print("END STEP 3, PART D, STATUS_w_DEMOG")
}

if (missing.type=="STATUS_w_GROWTH") {
  setwd("Step_3d_Summary_Results")
  print("BEGIN STEP 3, PART D, STATUS_w_GROWTH")
  output.file.directories <- "STATUS_w_GROWTH"
  source("Demonstration_COVID_Summary_Comparisons_2021_AMPUTE.R")
  print("END STEP 3, PART D, STATUS_w_GROWTH")
}

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


## CLEANUP

unlink("Goodness_of_Fit", recursive=TRUE)
