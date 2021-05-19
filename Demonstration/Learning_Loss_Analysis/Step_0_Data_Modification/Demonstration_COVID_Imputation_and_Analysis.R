tmp.messages <- paste("\n\t#####  BEGIN Full Amputation/Imputation Simulation ", date(), "  #####\n\n")
started.at.overall <- proc.time()

###   Load packages
require(SGP)
require(data.table)
require(mice)
source("Step_0_Data_Modification/amputeScaleScore.R")
source("Step_0_Data_Modification/imputeScaleScore.R")
source("Step_0_Data_Modification/parMICE.R")
source("Step_3d_Summary_Results/summarizeImputation.R")

#####
###   Step 0 - Data Modification
#####

###   Add in a particular COVID Pandemic Academic Impact

if (covid_impact) {
  started.impact <- proc.time()
  tmp.messages <- c(tmp.messages, paste("\n\tAcademic Impact/Learning Loss data modification completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.impact))))
  tmp.messages <- c(tmp.messages, "\n\tCOVID Impact Simulation TBD\n")
}


###   Scale Score Amputation and ("Observed" and "Complete" data) SGP Analyses

if (low_participation) {
  started.lowpart <- proc.time()
  if (!exists("Demonstration_COVID_Data")) {
    variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "FREE_REDUCED_LUNCH_STATUS", "ELL_STATUS",
        "IEP_STATUS", "ETHNICITY", "GENDER", "SCHOOL_NUMBER", "DISTRICT_NUMBER")
    Demonstration_COVID_Data <- data.table(SGPdata::sgpData_LONG_COVID[,variables.to.get, with=FALSE])
  }

  ###   Read in STEP 0 SGP configuration scripts - returns `growth_config_2021` and `status_config_2021`
  source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
  source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

  ###   Run 10 amputations with added priors
  Amputed_Data_LONG <-  amputeScaleScore(
      ampute.data=Demonstration_COVID_Data,
      growth.config = growth_config_2021,
      status.config = status_config_2021,
      compact.results = TRUE,
      default.vars = c("CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", extra.default.vars),
      demographics = amp.demographics,
      institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
      ampute.vars  = my.amp.vars,
      ampute.var.weights = my.amp.weights,
      reverse.weight = my.rev.weight,
      ampute.args = my.ampute.args,
      complete.cases.only = TRUE,
      partial.fill = TRUE,
      invalidate.repeater.dups = TRUE,
      seed = my.seed,
      M = my.amputation.n
  )

  ###   Setup ampute.directory
  if (!dir.exists(ampute.directory)) dir.create(ampute.directory, recursive = TRUE)

  Demonstration_COVID_SGP_Observed <- data.table()

  ###   Add Baseline matrices calculated in STEP 2A to SGPstateData
  load(file.path(baseline.matrices.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata"))
  SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

  ###   Read in STEP 3 SGP Configuration Scripts and Combine
  source("SGP_CONFIG/STEP_3/PART_A/ELA.R")
  source("SGP_CONFIG/STEP_3/PART_A/MATHEMATICS.R")

  DEMO_COVID_CONFIG_STEP_3 <- c(ELA_2021.config, MATHEMATICS_2021.config)

  for (MM in seq(my.amputation.n)) {
    Demonstration_COVID_Data_LONG <- copy(Amputed_Data_LONG)[
        get(paste0("AMP_", MM))==TRUE, SCALE_SCORE := NA][,
        c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")]

    Demonstration_COVID_SGP <- abcSGP(
            sgp_object = Demonstration_COVID_Data_LONG,
            steps = c("prepareSGP", "analyzeSGP", "combineSGP"),
            sgp.config = DEMO_COVID_CONFIG_STEP_3,
            sgp.percentiles = TRUE,
            sgp.projections = FALSE,
            sgp.projections.lagged = FALSE,
            sgp.percentiles.baseline = TRUE,
            sgp.projections.baseline = FALSE,
            sgp.projections.lagged.baseline = FALSE,
            save.intermediate.results = FALSE,
            goodness.of.fit.print = FALSE,
            parallel.config=parallel.config
    )

    # Need to keep all records!  Esp grade 3/4
    tmp_observed_sgps <- Demonstration_COVID_SGP@Data[YEAR=='2021', # & !is.na(SGP),
        c("VALID_CASE", "YEAR", "ID", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "SGP", "SGP_BASELINE"),] # "",
    setnames(tmp_observed_sgps,
      c("SGP", "SGP_BASELINE"), # "SCALE_SCORE",
      c("SGP_OBSERVED", "SGP_BASELINE_OBSERVED")) # "SCALE_SCORE_OBSERVED",
    setkeyv(tmp_observed_sgps, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE"))
    tmp_observed_sgps[, AMP_N := MM]

    Demonstration_COVID_SGP_Observed <- rbindlist(list(Demonstration_COVID_SGP_Observed, tmp_observed_sgps))
  }
  setkeyv(Demonstration_COVID_SGP_Observed, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE"))
  # save(Demonstration_COVID_SGP_Observed, file = file.path(ampute.directory, "Demonstration_COVID_SGP_Observed.rda"))

  Demonstration_COVID_Observed_Wide <- dcast(Demonstration_COVID_SGP_Observed, VALID_CASE+YEAR+ID+CONTENT_AREA+GRADE ~ AMP_N,
    sep=".AMP_", value.var = c("SCALE_SCORE", "SGP_OBSERVED","SGP_BASELINE_OBSERVED"))
  setkeyv(Demonstration_COVID_Observed_Wide, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE"))
  save(Demonstration_COVID_Observed_Wide, file = file.path(ampute.directory, "Demonstration_COVID_Observed_Wide.rda"))

  if (complete_analysis) {
    ###   Jump directly to Step 3A
    if (!dir.exists(complete.directory)) dir.create(complete.directory, recursive = TRUE)

    Demonstration_COVID_Data_LONG <- copy(Amputed_Data_LONG)[,
                grep("^AMP_", names(Amputed_Data_LONG)) := NULL]

    #####
    ###   Run analysis
    #####

    Demonstration_COVID_SGP <- abcSGP(
            sgp_object = Demonstration_COVID_Data_LONG,
            steps = c("prepareSGP", "analyzeSGP", "combineSGP"),
            sgp.config = DEMO_COVID_CONFIG_STEP_3,
            sgp.percentiles = TRUE,
            sgp.projections = FALSE,
            sgp.projections.lagged = FALSE,
            sgp.percentiles.baseline = TRUE,
            sgp.projections.baseline = FALSE,
            sgp.projections.lagged.baseline = FALSE,
            save.intermediate.results = FALSE,
            goodness.of.fit.print = FALSE,
            parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
    )

    Demonstration_COVID_SGP_Complete <- Demonstration_COVID_SGP@Data[,
      c(intersect(names(Demonstration_COVID_SGP@Data), names(Amputed_Data_LONG)), "SGP", "SGP_BASELINE"), with=FALSE]
    setnames(Demonstration_COVID_SGP_Complete,
      c("SGP", "SGP_BASELINE"), # "SCALE_SCORE",
      c("SGP_COMPLETE", "SGP_BASELINE_COMPLETE")) # "SCALE_SCORE_COMPLETE",
    setkeyv(Demonstration_COVID_SGP_Complete, c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE"))
    save(Demonstration_COVID_SGP_Complete, file = file.path(complete.directory, "Demonstration_COVID_SGP_Complete.rda"))
  } else {
    load(file.path(complete.directory, "Demonstration_COVID_SGP_Complete.rda"))
  }
  tmp.messages <- c(tmp.messages, paste("\n\tLow Participation data modification completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.lowpart))))
} else {
  load(file.path(ampute.directory, "Demonstration_COVID_Observed_Wide.rda"))
  load(file.path(complete.directory, "Demonstration_COVID_SGP_Complete.rda"))
}

#####
###   Scale Score Imputation and SGP Analyses
#####

if (imputation_analysis) {
  started.impute.analysis <- proc.time()
  started.ss.imp <- proc.time()

  ###   Read in STEP 0 SGP configuration scripts - returns `growth_config_2021` and `status_config_2021`
  source("SGP_CONFIG/STEP_0/Ampute_2021/Growth.R") # Based on STEP 3, PART A
  source("SGP_CONFIG/STEP_0/Ampute_2021/Status.R")

  diagn.dir <- file.path(ampute.directory, "Imputation_Plots")

  Imputed_Data <- vector(mode = "list", length = my.amputation.n)

  for (imp.m in seq(my.amputation.n)) {
    tmp.diagn.dir <- file.path(diagn.dir, paste0("M_", imp.m))
    if (!dir.exists(tmp.diagn.dir)) dir.create(tmp.diagn.dir, recursive = TRUE)

    tmp.amps <- paste0(c("SCALE_SCORE", "SGP_OBSERVED", "SGP_BASELINE_OBSERVED"), paste0(".AMP_", imp.m))
    Demonstration_COVID_SGP_LONG_Data <-
        Demonstration_COVID_Observed_Wide[,
            c(key(Demonstration_COVID_Observed_Wide), tmp.amps), with=FALSE][
        Demonstration_COVID_SGP_Complete][,  # Create "COMPLETE" vars
            ACH_LEV_COMPLETE := ACHIEVEMENT_LEVEL]

    setnames(Demonstration_COVID_SGP_LONG_Data, c("SCALE_SCORE", tmp.amps),
        c("SCALE_SCORE_COMPLETE", "SCALE_SCORE", "SGP_OBSERVED", "SGP_BASELINE_OBSERVED"))

    setkeyv(Demonstration_COVID_SGP_LONG_Data, key(Demonstration_COVID_SGP_Complete))
    Demonstration_COVID_SGP_LONG_Data[YEAR!="2021", SCALE_SCORE := SCALE_SCORE_COMPLETE]
    Demonstration_COVID_SGP_LONG_Data[YEAR=="2021" & is.na(SCALE_SCORE), ACHIEVEMENT_LEVEL := NA]

    Temp_Imputed_Scores <- imputeScaleScore(
        impute.data = Demonstration_COVID_SGP_LONG_Data,
        diagnostics.dir = tmp.diagn.dir,
        growth.config = growth_config_2021,
        status.config = status_config_2021,
        default.vars = c("CONTENT_AREA", "GRADE",
                         "SCALE_SCORE", "ACHIEVEMENT_LEVEL",
                         "SCALE_SCORE_COMPLETE", "ACH_LEV_COMPLETE",
                         "SGP_OBSERVED", "SGP_BASELINE_OBSERVED",
                         "SGP_COMPLETE", "SGP_BASELINE_COMPLETE"),
        demographics = imp.demographics,
        institutions = c("SCHOOL_NUMBER", "DISTRICT_NUMBER"),
        impute.factors = my.impute.factors,
        impute.long = my.impute.long,
        partial.fill = FALSE, # Already done in amputeScaleScore
        impute.method = my.impute.method,
        parallel.config = my.parallel.config, # define cores, packages, cluster.type
        cluster.institution = my.cluster.institution, # set to TRUE for multilevel (cross-sectional) methods
        M = imputation.m,
        allow.na=TRUE # Allow some priors (2018) to still be NA.
    )

    Imputed_Data[[imp.m]] <- Temp_Imputed_Scores
    rm(Demonstration_COVID_SGP_LONG_Data);rm(Temp_Imputed_Scores);gc()
    message(paste("Scale Score Imputation on Amputed dataset ", imp.m, " completed ", date()))
  }
  tmp.messages <- c(tmp.messages, paste("\n\t\t Raw Scale Score Imputation completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.ss.imp))))
  rm(list=c("Demonstration_COVID_Observed_Wide", "Demonstration_COVID_SGP_Complete")); gc()
  # save(Imputed_Data, file=file.path(ampute.directory, "Imputed_Data_2L_PAN.rda"))

  ###   Add Baseline matrices calculated in STEP 2A to SGPstateData
  load(file.path(baseline.matrices.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata"))
  SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

  ###   Read in STEP 3 SGP Configuration Scripts and Combine
  source("SGP_CONFIG/STEP_3/PART_A/ELA.R")
  source("SGP_CONFIG/STEP_3/PART_A/MATHEMATICS.R")

  DEMO_COVID_CONFIG_STEP_3 <- c(ELA_2021.config, MATHEMATICS_2021.config)

  M.AMP <- length(Imputed_Data)
  M.IMP <- length(grep("SCORE_IMP_", names(Imputed_Data[[1]])))

  priors.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")

  variables.to.get <- c("VALID_CASE", "ID", "YEAR", "CONTENT_AREA", "GRADE",
        "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "SGP_OBSERVED", "SGP_BASELINE_OBSERVED",
        "SCALE_SCORE_COMPLETE", "SGP_COMPLETE", "SGP_BASELINE_COMPLETE",
        "SCHOOL_NUMBER", "DISTRICT_NUMBER")

  variables.to.keep <- c(
        "ID", "SCHOOL_NUMBER", "DISTRICT_NUMBER", "YEAR", "CONTENT_AREA", "GRADE",
        "SCALE_SCORE_COMPLETE", "SCALE_SCORE_OBSERVED", "SCALE_SCORE",
        "SGP_COMPLETE", "SGP_OBSERVED", "SGP",
        "SGP_BASELINE_COMPLETE", "SGP_BASELINE_OBSERVED", "SGP_BASELINE")

  Demonstration_COVID_SGP <- prepareSGP(Imputed_Data[[1]][YEAR != "2021", priors.to.get, with=FALSE], state="DEMO_COVID", create.additional.variables=FALSE)

  Imputed_SGP_Data <- vector(mode = "list", length = M.AMP)

  for (AMP in seq(M.AMP)) {
    started.amp <- proc.time()
    TEMP_RESULTS <- data.table()
    for (IMP in seq(M.IMP)) {
      Demonstration_COVID_Data_LONG_2021 <- copy(Imputed_Data[[AMP]][YEAR == "2021", c(variables.to.get, paste0("SCORE_IMP_", IMP)), with=FALSE])
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

      if (IMP != max(M.IMP)) {
        TEMP_RESULTS <- rbindlist(list(TEMP_RESULTS, TEMP_SGP@Data[YEAR == "2021", variables.to.keep, with = FALSE][, IMP_N := IMP]))
      } else {
        Imputed_SGP_Data[[AMP]] <- rbindlist(list(TEMP_RESULTS, TEMP_SGP@Data[YEAR == "2021", variables.to.keep, with = FALSE][, IMP_N := IMP]))[, AMP_N := AMP]
      }
      message(paste("\n\tSGP Imputation analysis AMP ", AMP, " IMP ", IMP, " completed", date()))
    }  #  END IMP
    tmp.messages <- c(tmp.messages, paste("\n\t\t Amputed dataset ", AMP, " completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.amp))))
  }  #  END AMP

  assign(imputed.file.name, rbindlist(Imputed_SGP_Data))
  setnames(get(imputed.file.name), c("SCALE_SCORE", "SGP", "SGP_BASELINE"), c("SCALE_SCORE_IMPUTED", "SGP_IMPUTED", "SGP_BASELINE_IMPUTED"))
  save(list=imputed.file.name, file=file.path(ampute.directory, paste0(imputed.file.name, ".rda")), compress="xz")
  tmp.messages <- c(tmp.messages, paste("\n\tSGP Imputation analysis with ", M.AMP, " datasets with ", M.IMP, " imputations per dataset completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.impute.analysis))))
}

#####
###   Summaries/Imputation Statistics
#####

if (imputation_summaries) {
  setDTthreads(threads = min(cores, parallel::detectCores(logical = FALSE)), throttle = 1024)
  if (!dir.exists(file.path(ampute.directory, "Summary_Tables"))) dir.create(file.path(ampute.directory, "Summary_Tables"), recursive = TRUE)

  started.smry <- proc.time()
  Tmp_Summaries <- list()
  Tmp_Summaries[["STATE"]][["CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = "CONTENT_AREA")
  Tmp_Summaries[["STATE"]][["GRADE_CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = c("GRADE", "CONTENT_AREA"))
  Tmp_Summaries[["DISTRICT"]][["GLOBAL"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = NULL, institution.level = "DISTRICT_NUMBER")
  Tmp_Summaries[["DISTRICT"]][["CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = "CONTENT_AREA", institution.level = "DISTRICT_NUMBER")
  Tmp_Summaries[["DISTRICT"]][["GRADE_CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "DISTRICT_NUMBER")
  Tmp_Summaries[["SCHOOL"]][["GLOBAL"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = NULL, institution.level = "SCHOOL_NUMBER")
  Tmp_Summaries[["SCHOOL"]][["CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = "CONTENT_AREA", institution.level = "SCHOOL_NUMBER")
  Tmp_Summaries[["SCHOOL"]][["GRADE_CONTENT"]] <- summarizeImputation(data = get(imputed.file.name), summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "SCHOOL_NUMBER")
  tmp.messages <- c(tmp.messages, paste("\n\tSGP Imputation summaries with ", M.AMP, " datasets with ", M.IMP, " imputations per dataset completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.smry))))

  assign(summary.file.name, Tmp_Summaries)
  save(list=summary.file.name, file=file.path(ampute.directory, "Summary_Tables", paste0(summary.file.name, ".rda")))
}

steps.completed <-
  c("Academic Impact", "Data Amputation", "Complete Data Analysis", "Data Imputation", "Imputation Summaries")[
    c(covid_impact, low_participation, complete_analysis, imputation_analysis, imputation_summaries)]

tmp.messages <- c(tmp.messages, "\n\tSimulation with Steps ", paste(paste(head(steps.completed, -1), collapse=", "), tail(steps.completed, 1), sep=" and "), "completed in ", SGP:::convertTime(SGP:::timetakenSGP(started.at.overall)))
tmp.messages <- c(tmp.messages, "\n\t#####  END Full Amputation/Imputation Simulation  #####")
SGP:::messageSGP(tmp.messages)
