################################################################################
###                                                                          ###
###  STEP 4: Demonstration COVID SGP analyses for 2022: Year 1 of recovery   ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("Learning_Loss_Analysis")

###   Load packages
require(SGP)
require(SGPdata)

###   Load data
load("Data/Demonstration_COVID_SGP_2021_STEP_3.Rdata")
# load("Data/Demonstration_COVID_SGP_2021_STEP_3c.Rdata") # load this object if projections (steps 3b & 3c) have been run
load("Data/DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata")

###   Create 2022 subset of COVID data
Demonstration_COVID_Data_LONG_2022 <- SGPdata::sgpData_LONG_COVID[YEAR == "2022"]

###   Add Baseline matrices calculated in STEP 2 to SGPstateData
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices


###   Load configurations

source("SGP_CONFIG/STEP_4/ELA.R")
source("SGP_CONFIG/STEP_4/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_4 <- c(ELA_2022.config, MATHEMATICS_2022.config)


#####
###   Run analysis
#####

Demonstration_COVID_SGP <- updateSGP(
        Demonstration_COVID_SGP,
        Demonstration_COVID_Data_LONG_2022,
        steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
        sgp.config=DEMO_COVID_CONFIG_STEP_4,
        sgp.percentiles=TRUE,
        sgp.projections=TRUE,
        sgp.projections.lagged=TRUE,
        sgp.percentiles.baseline=TRUE,
        sgp.projections.baseline=TRUE,
        sgp.projections.lagged.baseline=TRUE,
        sgp.target.scale.scores=TRUE,
  			save.intermediate.results=FALSE
        # parallel.config = ...  #  Optional parallel processing - see SGP
				# 	 									 	 #  package documentation for details.
)


###   Save results
save(Demonstration_COVID_SGP, file="Data/Demonstration_COVID_SGP_2022_STEP_4.Rdata")
