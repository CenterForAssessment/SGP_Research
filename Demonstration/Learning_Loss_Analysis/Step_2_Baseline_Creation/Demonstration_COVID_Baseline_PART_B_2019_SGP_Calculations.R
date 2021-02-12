################################################################################
###                                                                          ###
###  STEP 2B: Demonstration COVID Skip-year Baseline SGP analyses for 2019   ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("Learning_Loss_Analysis")

###   Load packages
require(SGP)

###   Load data
load("Data/Demonstration_COVID_SGP_STEP_1.Rdata")
load("Data/DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata") # Alternatively add 'SuperCohort' version if preferred

###   Add Baseline matrices calculated in STEP 2 to SGPstateData
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

###   Read in STEP 3 SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_2/PART_B/ELA.R")
source("SGP_CONFIG/STEP_2/PART_B/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_2B <- c(ELA_2019.config, MATHEMATICS_2019.config)


#####
###   Run analysis - run abcSGP on object from Step 1 (with BASELINE matrices and configurations - no additional data)
#####

Demonstration_COVID_SGP <- abcSGP(
        sgp_object = Demonstration_COVID_SGP,
        steps = c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
        sgp.config = DEMO_COVID_CONFIG_STEP_2B,
        sgp.percentiles = FALSE,
        sgp.projections = FALSE,
        sgp.projections.lagged = FALSE,
        sgp.percentiles.baseline = TRUE,
        sgp.projections.baseline = FALSE,
        sgp.projections.lagged.baseline = FALSE,
        save.intermediate.results = FALSE
        # parallel.config = ...  #  Optional parallel processing - see SGP
				# 	 									 	 #  package documentation for details.
)

###   Save results
save(Demonstration_COVID_SGP, file="Data/Demonstration_COVID_SGP_2019_STEP_2B.Rdata")
