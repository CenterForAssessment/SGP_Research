################################################################################
###
### STEP 5: SGP lagged projections for skip year simulation: 2017 to 2019 Part 2c
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Load data

load("Data/Demonstration_SGP_2018_2019_PART_2b.Rdata")
load("Data/Demonstration_Baseline_Matrices_2018_2019.Rdata")


### Load configurations

source("SGP_CONFIG/2018_2019_PART_2c/READING.R")
source("SGP_CONFIG/2018_2019_PART_2c/MATHEMATICS.R")

SGP_CONFIG_2018_2019_PART_2c <- c(READING_2018_2019.config, MATHEMATICS_2018_2019.config)


### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["DEMO"]][["Growth"]][["System_Type"]] <- "Baseline Referenced"
SGPstateData[["DEMO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Demonstration_Baseline_Matrices_2018_2019$MATHEMATICS.BASELINE
SGPstateData[["DEMO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["READING.BASELINE"]] <- Demonstration_Baseline_Matrices_2018_2019$READING.BASELINE
SGPstateData[["DEMO"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    READING_GRADE_3=c(3, 4, 5, 6, 7, 8, 9, 10),
    READING_GRADE_4=c(3, 4, 5, 6, 7, 8, 9, 10),
    READING_GRADE_5=c(3, 5, 6, 7, 8, 9, 10),
    READING_GRADE_6=c(3, 4, 6, 7, 8, 9, 10),
    READING_GRADE_7=c(3, 4, 5, 7, 8, 9, 10),
    READING_GRADE_8=c(3, 4, 5, 6, 8, 9, 10),
    READING_GRADE_9=c(3, 4, 5, 6, 7, 9, 10),
    READING_GRADE_10=c(3, 4, 5, 6, 7, 8, 10),
    MATHEMATICS_GRADE_3=c(3, 4, 5, 6, 7, 8, 9, 10),
    MATHEMATICS_GRADE_4=c(3, 4, 5, 6, 7, 8, 9, 10),
    MATHEMATICS_GRADE_5=c(3, 5, 6, 7, 8, 9, 10),
    MATHEMATICS_GRADE_6=c(3, 4, 6, 7, 8, 9, 10),
    MATHEMATICS_GRADE_7=c(3, 4, 5, 7, 8, 9, 10),
    MATHEMATICS_GRADE_8=c(3, 4, 5, 6, 8, 9, 10),
    MATHEMATICS_GRADE_9=c(3, 4, 5, 6, 7, 9, 10),
    MATHEMATICS_GRADE_10=c(3, 4, 5, 6, 7, 8, 10))
SGPstateData[["DEMO"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    READING_GRADE_3=rep("READING", 8),
    READING_GRADE_4=rep("READING", 8),
    READING_GRADE_5=rep("READING", 7),
    READING_GRADE_6=rep("READING", 7),
    READING_GRADE_7=rep("READING", 7),
    READING_GRADE_8=rep("READING", 7),
    READING_GRADE_9=rep("READING", 7),
    READING_GRADE_10=rep("READING", 7),
    MATHEMATICS_GRADE_3=rep("MATHEMATICS", 8),
    MATHEMATICS_GRADE_4=rep("MATHEMATICS", 8),
    MATHEMATICS_GRADE_5=rep("MATHEMATICS", 7),
    MATHEMATICS_GRADE_6=rep("MATHEMATICS", 7),
    MATHEMATICS_GRADE_7=rep("MATHEMATICS", 7),
    MATHEMATICS_GRADE_8=rep("MATHEMATICS", 7),
    MATHEMATICS_GRADE_9=rep("MATHEMATICS", 7),
    MATHEMATICS_GRADE_10=rep("MATHEMATICS", 7))
SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
    READING_GRADE_3=3,
    READING_GRADE_4=3,
    READING_GRADE_5=3,
    READING_GRADE_6=3,
    READING_GRADE_7=3,
    READING_GRADE_8=3,
    READING_GRADE_9=3,
    READING_GRADE_10=3,
    MATHEMATICS_GRADE_3=3,
    MATHEMATICS_GRADE_4=3,
    MATHEMATICS_GRADE_5=3,
    MATHEMATICS_GRADE_6=3,
    MATHEMATICS_GRADE_7=3,
    MATHEMATICS_GRADE_8=3,
    MATHEMATICS_GRADE_9=3,
    MATHEMATICS_GRADE_10=3)


### Run analysis

Demonstration_SGP_2018_2019_PART_2c <- abcSGP(
                        Demonstration_SGP_2018_2019_PART_2b,
                        steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                        sgp.percentiles=FALSE,
                        sgp.projections=FALSE,
                        sgp.projections.lagged=FALSE,
                        sgp.percentiles.baseline=FALSE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=TRUE,
                        sgp.target.scale.scores=TRUE,
                        sgp.config=SGP_CONFIG_2018_2019_PART_2c)


### Save results

save(Demonstration_SGP_2018_2019_PART_2c, file="Data/Demonstration_SGP_2018_2019_PART_2c.Rdata")
