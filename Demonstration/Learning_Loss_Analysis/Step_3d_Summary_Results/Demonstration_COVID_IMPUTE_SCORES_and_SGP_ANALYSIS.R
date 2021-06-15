####################################################################################
###                                                                              ###
###  1) IMPUTE, 2) ANALYZE and 3) SUMMARIZE missing 2021 data for FULL analysis  ###
###                                                                              ###
####################################################################################

###   Set working directory to base Learning_Loss_Analysis directory
setwd("..")

###   Load packages
require(SGP)
require(data.table)
require(cfaTools)

###   Set up objects from mstep_Learning_Loss_FULL_ANALYSIS.R if missing
if (exists("tmp.messages")) {
  tmp.messages <- c(tmp.messages, paste("\n\t#####  BEGIN Scale Score Imputation", date(), "  #####\n\n"))
} else tmp.messages <- paste("\n\t#####  BEGIN Scale Score Imputation", date(), "  #####\n\n")
started.impute.analysis <- proc.time()

if (!exists("data_imputation")) data_imputation <- TRUE
if (!exists("imputated_sgp_analysis")) imputated_sgp_analysis <- TRUE
if (!exists("imputation_summaries")) imputation_summaries <- TRUE
if (!exists("output.directory")) output.directory <- file.path("Data", "FULL_ANALYSIS")
if (!exists("input.directory")) input.directory <- output.directory
if (!exists("imp.cores")) imp.cores <- parallel::detectCores(logical = FALSE)

#####
###   Scale Score Imputation
#####

if (data_imputation) {
  load(file.path(input.directory, "Demonstration_COVID_SGP_LONG_Data.Rdata"))

  ###   Read in STEP 0 SGP configuration scripts - returns `growth_config_2021` and `status_config_2021`
  source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
  source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

  if (!dir.exists(my.diagnostics.dir)) dir.create(my.diagnostics.dir, recursive = TRUE)

  Demonstration_COVID_Imputed <- imputeScaleScore(
      impute.data = Demonstration_COVID_SGP_LONG_Data,
      diagnostics.dir = my.diagnostics.dir,
      growth.config = growth_config_2021,
      status.config = status_config_2021,
      default.vars = c("CONTENT_AREA", "GRADE",
                       "SCALE_SCORE", "ACHIEVEMENT_LEVEL"),
      demographics = imp.demographics,
      institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
      impute.factors = my.impute.factors,
      impute.long = my.impute.long,
      partial.fill = FALSE, # Already done in amputeScaleScore
      impute.method = my.impute.method,
      parallel.config = my.parallel.config, # define cores, packages, cluster.type
      cluster.institution = my.cluster.institution, # set to TRUE for multilevel (cross-sectional) methods
      M = imputation.m,
      maxit = my.maxit,
      # tsf = "mcjI", symm = TRUE, dbounded = TRUE, # Only used for RQ
      allow.na=TRUE # Allow some priors (2018) to still be NA.
  )

  ###   Subset out 2021
  Demonstration_COVID_Imputed <- Demonstration_COVID_Imputed[YEAR == "2021"]
}

  tmp.messages <- c(tmp.messages, paste("\n\t\tRaw Scale Score", my.impute.method, "LONG"[my.impute.long], "Imputation completed in", SGP:::convertTime(SGP:::timetakenSGP(started.impute.analysis))))

#####
###   SGP Analysis of Imputed Scale Scores
#####

if (imputated_sgp_analysis) {
  ###   Load Data from Step 2c
  load(file.path(input.directory, "Demonstration_COVID_SGP_2019_STEP_2c.Rdata"))

  ###   Add Baseline matrices calculated in STEP 2A to SGPstateData
  load(file.path(baseline.matrices.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata"))
  SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

  ###   Read in STEP 3 SGP Configuration Scripts and Combine
  source("SGP_CONFIG/STEP_3/PART_A/ELA.R")
  source("SGP_CONFIG/STEP_3/PART_A/MATHEMATICS.R")

  DEMO_COVID_CONFIG_STEP_3 <- c(ELA_2021.config, MATHEMATICS_2021.config)

  M.IMP <- length(grep("SCORE_IMP_", names(Demonstration_COVID_Imputed)))

  priors.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")

  variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
                        "SCALE_SCORE", "ACHIEVEMENT_LEVEL")

  variables.to.keep <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
                         "SCALE_SCORE", "SGP", "SGP_BASELINE")

  started.sgp <- proc.time()
  Imputed_SGP_Data <- data.table()
  for (IMP in seq(M.IMP)) {
    Demonstration_COVID_Data_LONG_2021 <- copy(Demonstration_COVID_Imputed[, c(variables.to.get, paste0("SCORE_IMP_", IMP)), with=FALSE])
    setnames(Demonstration_COVID_Data_LONG_2021, c("SCALE_SCORE", paste0("SCORE_IMP_", IMP)), c("SCALE_SCORE_OBSERVED", "SCALE_SCORE"))

    ##  Force scores outside LOSS/HOSS back into range
    for (CA in c("ELA", "MATHEMATICS")) {
      for (G in 3:8) {
        tmp.loss <- SGPstateData[["DEMO_COVID"]][["Achievement"]][["Knots_Boundaries"]][[CA]][[paste0("loss.hoss_", G)]][1]
        tmp.hoss <- SGPstateData[["DEMO_COVID"]][["Achievement"]][["Knots_Boundaries"]][[CA]][[paste0("loss.hoss_", G)]][2]
        Demonstration_COVID_Data_LONG_2021[CONTENT_AREA == CA & GRADE == G & SCALE_SCORE < tmp.loss, SCALE_SCORE := tmp.loss]
        Demonstration_COVID_Data_LONG_2021[CONTENT_AREA == CA & GRADE == G & SCALE_SCORE > tmp.hoss, SCALE_SCORE := tmp.hoss]
      }
    }

    TEMP_SGP <- updateSGP(
            what_sgp_object = Demonstration_COVID_SGP,
            with_sgp_data_LONG = Demonstration_COVID_Data_LONG_2021,
            steps = c("prepareSGP", "analyzeSGP", "combineSGP"),
            sgp.config = DEMO_COVID_CONFIG_STEP_3,
            sgp.percentiles = TRUE,
            sgp.projections = FALSE,
            sgp.projections.lagged = FALSE,
            sgp.percentiles.baseline = TRUE,
            sgp.projections.baseline = FALSE,
            sgp.projections.lagged.baseline = FALSE,
            goodness.of.fit.print = FALSE,
            save.intermediate.results = FALSE,
            parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
    )

    Imputed_SGP_Data <- rbindlist(list(Imputed_SGP_Data, TEMP_SGP@Data[YEAR == "2021", variables.to.keep, with = FALSE][, IMP_N := IMP]))
    message(paste("\n\tSGP", my.impute.method, "LONG"[my.impute.long], "Imputation analysis -- IMP:", IMP, "-- completed", date()))
  }  #  END IMP

  Imputed_SGP_Data_Wide <- dcast(Imputed_SGP_Data, VALID_CASE + ID + YEAR + CONTENT_AREA + GRADE ~ IMP_N,
    sep = "_IMPUTED_", drop = FALSE, value.var = c("SCALE_SCORE", "SGP", "SGP_BASELINE"))
  Imputed_SGP_Data_Wide <- Imputed_SGP_Data_Wide[!is.na(SCALE_SCORE_IMPUTED_1)]
  tmp.messages <- c(tmp.messages, paste("\n\t\tSGP Analysis with", IMP, "imputations", "completed in", SGP:::convertTime(SGP:::timetakenSGP(started.sgp))))

  if (is.null(imputed.file.name)) imputed.file.name <- "Demonstration_COVID_SGP_Data_Imputed"

  assign(imputed.file.name, Imputed_SGP_Data_Wide)
  save(list=imputed.file.name, file=file.path(output.directory, paste0(imputed.file.name, ".rda")))
} else {
  if (data_imputation) save(Demonstration_COVID_Imputed, file=file.path(output.directory, "Demonstration_COVID_Imputed_2021.rda"))
}


#####
###   Summaries/Imputation Statistics
#####

if (imputation_summaries) {
  setkeyv(Imputed_SGP_Data_Wide, SGP:::getKey(Imputed_SGP_Data_Wide))

  ##  Merge (2021 only):
  Summary_Data <- Demonstration_COVID_SGP_LONG_Data[Imputed_SGP_Data_Wide]
  setnames(Summary_Data, c("SCALE_SCORE", "SGP", "SGP_BASELINE"), c("SCALE_SCORE_OBSERVED", "SGP_OBSERVED", "SGP_BASELINE_OBSERVED"))

  institution.level = "SCHOOL_NUMBER"
  summary.level = c("GRADE", "CONTENT_AREA")

  if (imputation_summaries) {
    setDTthreads(threads = min(imp.cores, parallel::detectCores(logical = FALSE)), throttle = 1024)
    if (!dir.exists(file.path(output.directory, "Summary_Tables"))) dir.create(file.path(output.directory, "Summary_Tables"), recursive = TRUE)

    started.smry <- proc.time()
    Tmp_Summaries <- list()
    Tmp_Summaries[["STATE"]][["GRADE"]] <- imputationSummary(Summary_Data, summary.level = "GRADE")
    Tmp_Summaries[["STATE"]][["CONTENT"]] <- imputationSummary(Summary_Data, summary.level = "CONTENT_AREA")
    Tmp_Summaries[["STATE"]][["GRADE_CONTENT"]] <- imputationSummary(Summary_Data, summary.level = c("GRADE", "CONTENT_AREA"))
    Tmp_Summaries[["DISTRICT"]][["GLOBAL"]] <- imputationSummary(Summary_Data, summary.level = NULL, institution.level = "DISTRICT_NUMBER")
    Tmp_Summaries[["DISTRICT"]][["GRADE"]] <- imputationSummary(Summary_Data, summary.level = "GRADE", institution.level = "DISTRICT_NUMBER")
    Tmp_Summaries[["DISTRICT"]][["CONTENT"]] <- imputationSummary(Summary_Data, summary.level = "CONTENT_AREA", institution.level = "DISTRICT_NUMBER")
    Tmp_Summaries[["DISTRICT"]][["GRADE_CONTENT"]] <- imputationSummary(Summary_Data, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "DISTRICT_NUMBER")
    Tmp_Summaries[["SCHOOL"]][["GLOBAL"]] <- imputationSummary(Summary_Data, summary.level = NULL, institution.level = "SCHOOL_NUMBER")
    Tmp_Summaries[["SCHOOL"]][["GRADE"]] <- imputationSummary(Summary_Data, summary.level = "GRADE", institution.level = "SCHOOL_NUMBER")
    Tmp_Summaries[["SCHOOL"]][["CONTENT"]] <- imputationSummary(Summary_Data, summary.level = "CONTENT_AREA", institution.level = "SCHOOL_NUMBER")
    Tmp_Summaries[["SCHOOL"]][["GRADE_CONTENT"]] <- imputationSummary(Summary_Data, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "SCHOOL_NUMBER")
    tmp.messages <- c(tmp.messages, paste("\n\t\tSGP Imputation summaries with", M.IMP, "imputations completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.smry))))

    assign(summary.file.name, Tmp_Summaries)
    save(list=summary.file.name, file=file.path(output.directory, "Summary_Tables", paste0(summary.file.name, ".rda")))
  }
}

tmp.messages <- c(tmp.messages, "\n\t#####  END  Score Imputation and/or Analysis  #####\n")
