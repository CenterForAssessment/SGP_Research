################################################################################
###
### STEP 5: SGP lagged projections for skip year analysis: 2017 to 2019 Part 2c
###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Colorado_SGP-2019_Part_2b.Rdata")
load("Data/Colorado_Baseline_Matrices_2019.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2c/ELA.R")
source("SGP_CONFIG/2019_PART_2c/MATHEMATICS.R")

SGP_CONFIG_2019_PART_2c <- c(ELA_2019.config, MATHEMATICS_2019.config)


### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["CO"]][["Growth"]][["System_Type"]] <- "Baseline Referenced"
SGPstateData[["CO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Colorado_Baseline_Matrices_2019[["MATHEMATICS.BASELINE"]]
SGPstateData[["CO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["ELA.BASELINE"]] <- Colorado_Baseline_Matrices_2019[["ELA.BASELINE"]]
SGPstateData[["CO"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    ELA_GRADE_3=c(3, 4, 5, 6, 7, 8),
    ELA_GRADE_4=c(3, 4, 5, 6, 7, 8),
    ELA_GRADE_5=c(3, 5, 6, 7, 8),
    ELA_GRADE_6=c(3, 4, 6, 7, 8),
    ELA_GRADE_7=c(3, 4, 5, 7, 8),
    ELA_GRADE_8=c(3, 4, 5, 6, 8),
    MATHEMATICS_GRADE_3=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_4=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS_GRADE_5=c(3, 5, 6, 7, 8),
    MATHEMATICS_GRADE_6=c(3, 4, 6, 7, 8),
    MATHEMATICS_GRADE_7=c(3, 4, 5, 7, 8),
    MATHEMATICS_GRADE_8=c(3, 4, 5, 6, 8))
SGPstateData[["CO"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    ELA_GRADE_3=rep("ELA", 6),
    ELA_GRADE_4=rep("ELA", 6),
    ELA_GRADE_5=rep("ELA", 5),
    ELA_GRADE_6=rep("ELA", 5),
    ELA_GRADE_7=rep("ELA", 5),
    ELA_GRADE_8=rep("ELA", 5),
    MATHEMATICS_GRADE_3=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_4=rep("MATHEMATICS", 6),
    MATHEMATICS_GRADE_5=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_6=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_7=rep("MATHEMATICS", 5),
    MATHEMATICS_GRADE_8=rep("MATHEMATICS", 5))
SGPstateData[["CO"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
    ELA_GRADE_3=3,
    ELA_GRADE_4=3,
    ELA_GRADE_5=3,
    ELA_GRADE_6=3,
    ELA_GRADE_7=3,
    ELA_GRADE_8=3,
    MATHEMATICS_GRADE_3=3,
    MATHEMATICS_GRADE_4=3,
    MATHEMATICS_GRADE_5=3,
    MATHEMATICS_GRADE_6=3,
    MATHEMATICS_GRADE_7=3,
    MATHEMATICS_GRADE_8=3)


### Run analysis

Colorado_SGP <- abcSGP(
                  Colorado_SGP,
                  steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                  sgp.percentiles=FALSE,
                  sgp.projections=FALSE,
                  sgp.projections.lagged=FALSE,
                  sgp.percentiles.baseline=FALSE,
                  sgp.projections.baseline=FALSE,
                  sgp.projections.lagged.baseline=TRUE,
                  sgp.target.scale.scores=TRUE,
                  sgp.config=SGP_CONFIG_2019_PART_2c,
                  parallel.config = list(
                    BACKEND="PARALLEL",
                    WORKERS=list(LAGGED_PROJECTIONS = 2)))


### Save results

save(Colorado_SGP, file="Data/Colorado_SGP_2019_PART_2c.Rdata")



#####
###   Quick descriptives
#####

Colorado_SGP@Data$DIFF<- as.numeric(NA)
Colorado_SGP@Data[, DIFF := SGP - NO_SKIP]

Colorado_SGP@Data[!is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP, SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  SGP_Corr = format(round(cor(NO_SKIP, SGP, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  N_Size = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE)]
