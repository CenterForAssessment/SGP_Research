################################################################################
###                                                                          ###
###  STEP 4: Straight baseline-referenced SGP projections (Part 2b)          ###
###     Historical Skip-Year SGP Analysis -- Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Hawaii_SGP-SkipYear.Rdata")
load("Data/Hawaii_Baseline_Matrices_2019.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2b/READING.R")
source("SGP_CONFIG/2019_PART_2b/MATHEMATICS.R")

HI_Skip_Year_P2b.config <- c(
  READING_2019.config,
  MATHEMATICS_2019.config)

### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences
SGPstateData[["HI"]][["Growth"]][["System_Type"]] <- "Cohort and Baseline Referenced" #
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["MATHEMATICS.BASELINE"]]
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["READING.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["READING.BASELINE"]]
SGPstateData[["HI"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    READING_GRADE_3=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_4=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_5=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_6=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_7=c(3, 4, 5, 6, 7, 8),
    READING_GRADE_8=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_3=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_4=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_5=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_6=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_7=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_8=c(3, 4, 5, 6, 7, 8))
SGPstateData[["HI"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    READING_GRADE_3=rep("READING", 6),
    READING_GRADE_4=rep("READING", 6),
    READING_GRADE_5=rep("READING", 6),
    READING_GRADE_6=rep("READING", 6),
    READING_GRADE_7=rep("READING", 6),
    READING_GRADE_8=rep("READING", 6),
    MATHEMATICS_GRADE_3=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_4=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_5=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_6=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_7=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_8=rep("MATHEMATICS", 6))
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
###    abcSGP - To produce SG BASELINE straight projections ONLY
###

Hawaii_SGP <- abcSGP(
                Hawaii_SGP,
                sgp.config=HI_Skip_Year_P2b.config,
                steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
                sgp.percentiles=FALSE,
                sgp.projections=FALSE,
                sgp.projections.lagged=FALSE,
                sgp.percentiles.baseline=FALSE,
                sgp.projections.baseline=TRUE,
                sgp.projections.lagged.baseline=FALSE,
                sgp.target.scale.scores=TRUE,
                parallel.config = list(
                  BACKEND="PARALLEL",
                  WORKERS=list(PROJECTIONS = 8)))


### Save results

save(Hawaii_SGP, file="Data/Hawaii_SGP-SkipYear.Rdata")
