################################################################################
###                                                                          ###
###  STEP 5: Lagged baseline-referenced SGP projections (Part 2c)            ###
###     Historical Skip-Year SGP Analysis -- Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Hawaii_SGP-SkipYear.Rdata")
load("Data/Hawaii_Baseline_Matrices_2019.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2c/READING.R")
source("SGP_CONFIG/2019_PART_2c/MATHEMATICS.R")

HI_Skip_Year_P2c.config <- c(
  READING_2019.config,
  MATHEMATICS_2019.config)

### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences
SGPstateData[["HI"]][["Growth"]][["System_Type"]] <- "Baseline Referenced"
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["MATHEMATICS.BASELINE"]]
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["READING.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["READING.BASELINE"]]
SGPstateData[["HI"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    READING_GRADE_3=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_4=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_5=c(3, 5, 6, 7, 8),
    READING_GRADE_6=c(3, 4, 6, 7, 8),
    READING_GRADE_7=c(3, 4, 5, 7, 8),
    READING_GRADE_8=c(3, 4, 5, 6, 8),
    MATHEMATICS_GRADE_3=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_4=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_5=c(3, 5, 6, 7, 8),
    MATHEMATICS_GRADE_6=c(3, 4, 6, 7, 8),
    MATHEMATICS_GRADE_7=c(3, 4, 5, 7, 8),
    MATHEMATICS_GRADE_8=c(3, 4, 5, 6, 8))
SGPstateData[["HI"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    READING_GRADE_3=rep("READING", 6),
    READING_GRADE_4=rep("READING", 6),
    READING_GRADE_5=rep("READING", 5),
    READING_GRADE_6=rep("READING", 5),
    READING_GRADE_7=rep("READING", 5),
    READING_GRADE_8=rep("READING", 5),
    MATHEMATICS_GRADE_3=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_4=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_5=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_6=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_7=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_8=rep("MATHEMATICS", 5))
SGPstateData[["HI"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
    READING_GRADE_3=3,
    READING_GRADE_4=3,
    READING_GRADE_5=3,
    READING_GRADE_6=3,
    READING_GRADE_7=3,
    READING_GRADE_8=3,
    MATHEMATICS_GRADE_3=3,
    MATHEMATICS_GRADE_4=3,
    MATHEMATICS_GRADE_5=3,
    MATHEMATICS_GRADE_6=3,
    MATHEMATICS_GRADE_7=3,
    MATHEMATICS_GRADE_8=3)

SGPstateData[["HI"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL
SGPstateData[["HI"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["HI"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE


###
###    abcSGP - To produce SG BASELINE lagged projections ONLY
###

Hawaii_SGP <- abcSGP(
                Hawaii_SGP,
                sgp.config=HI_Skip_Year_P2c.config,
                steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"), # , "summarizeSGP"
                sgp.percentiles=FALSE,
                sgp.projections=FALSE,
                sgp.projections.lagged=FALSE,
                sgp.percentiles.baseline=FALSE,
                sgp.projections.baseline=FALSE,
                sgp.projections.lagged.baseline=TRUE,
                sgp.target.scale.scores=TRUE,
                parallel.config = list(
                  BACKEND="PARALLEL",
                  WORKERS=list(LAGGED_PROJECTIONS = 2))) # , SUMMARY = 8


### Save results

save(Hawaii_SGP, file="Data/Hawaii_SGP-SkipYear.Rdata")



#####
###   Quick descriptives
#####

Hawaii_SGP@Data$DIFF<- as.numeric(NA)
Hawaii_SGP@Data[, DIFF := SGP - NO_SKIP_SGP]

Hawaii_SGP@Data[YEAR == '2019' & !is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  SGP_Corr = format(round(cor(NO_SKIP_SGP, SGP, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  Corr_N = sum(!is.na(SGP) & !is.na(NO_SKIP_SGP))), keyby = list(CONTENT_AREA, GRADE)]
