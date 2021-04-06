################################################################################
###                                                                          ###
###    STEP 3c (Optional):                                                   ###
###           SGP LAGGED projections for skip year SGP analyses for 2021     ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")

###   Load packages
require(SGP)

###   Load data
load("Data/Demonstration_COVID_SGP_2021_STEP_3b.Rdata")
load("Data/DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata")

###   Load configurations
source("SGP_CONFIG/STEP_3/PART_C_Lagged_Projections/ELA.R")
source("SGP_CONFIG/STEP_3/PART_C_Lagged_Projections/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_3c <- c(ELA_2021.config, MATHEMATICS_2021.config)


###   Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

#  Add Baseline matrices calculated in STEP 2 to SGPstateData
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices
SGPstateData[["DEMO_COVID"]][["Growth"]][["System_Type"]] <- "Baseline Referenced"

#  Establish required meta-data for LAGGED projection sequences
SGPstateData[["DEMO_COVID"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
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
SGPstateData[["DEMO_COVID"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
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
SGPstateData[["DEMO_COVID"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
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

Demonstration_COVID_SGP <- abcSGP(
        Demonstration_COVID_SGP,
        steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
        sgp.config=DEMO_COVID_CONFIG_STEP_3c,
        sgp.percentiles=FALSE,
        sgp.projections=FALSE,
        sgp.projections.lagged=FALSE,
        sgp.percentiles.baseline=FALSE,
        sgp.projections.baseline=FALSE,
        sgp.projections.lagged.baseline=TRUE,
        sgp.target.scale.scores=TRUE,
        # parallel.config = ...  #  Optional parallel processing - see SGP
        # 	 									 	 #  package documentation for details.
)


###  Save results
save(Demonstration_COVID_SGP, file="Data/Demonstration_COVID_SGP_2021_STEP_3c.Rdata")
