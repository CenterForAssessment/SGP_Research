################################################################################
###                                                                          ###
###   STEP 2C: Demonstration COVID Skip-year Baseline Projections for 2019   ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")

###   Load packages
require(SGP)

###   Load data from baseline SGP analyses
load("Data/Demonstration_COVID_SGP_2019_STEP_2b.Rdata")

###   Add Baseline matrices calculated in STEP 2, PART A to SGPstateData
load("Data/DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata") # Alternatively add 'SuperCohort' version if preferred
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices

###   Read in STEP 3, PART C SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_2/PART_C/ELA.R")
source("SGP_CONFIG/STEP_2/PART_C/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_2C <- c(ELA_2019.config, MATHEMATICS_2019.config)

#####
###   Run projections analysis - run abcSGP on object from BASELINE SGP analysis
#####

###   Update SGPstateData with grade/course/lag progression information
source("SGP_CONFIG/STEP_2/PART_C/Skip_Year_Projections_MetaData.R")

Demonstration_COVID_SGP <- abcSGP(
        sgp_object = Demonstration_COVID_SGP,
        steps = c("prepareSGP", "analyzeSGP"), # no changes to @Data - don't combine or output
        sgp.config = DEMO_COVID_CONFIG_STEP_2C,
        sgp.percentiles = FALSE,
        sgp.projections = FALSE,
        sgp.projections.lagged = FALSE,
        sgp.percentiles.baseline = FALSE,
        sgp.projections.baseline = TRUE, # Need P50_PROJ_YEAR_1_CURRENT for Ho's Fair Trend/Equity Check metrics
        sgp.projections.lagged.baseline = FALSE,
        save.intermediate.results = FALSE,
				# parallel.config = ...  #  Optional parallel processing - see SGP
				# 	 									 	 #  package documentation for details.
)

###   Save results
save(Demonstration_COVID_SGP, file="Data/Demonstration_COVID_SGP_2019_STEP_2c.Rdata")
