################################################################################
###                                                                          ###
###   WIDA_CO Skip-Year Baseline SGP calculation for 2021                    ###
###                                                                          ###
################################################################################

###   Load packages
require(SGP)
require(data.table)

###   Load data and remove years that will not be used.
load("Data/WIDA_CO_Data_LONG.Rdata")

###   Add single-cohort baseline matrices to SGPstateData
SGPstateData <- SGPmatrices::addBaselineMatrices("WIDA_CO", "2021")

### NULL out assessment transition in 2019 (since already dealth with)
SGPstateData[["WIDA_CO"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL
SGPstateData[["WIDA_CO"]][["Assessment_Program_Information"]][["Scale_Change"]] <- NULL

###   Read in BASELINE percentiles configuration scripts and combine
source("SGP_CONFIG/2021/READING.R")

WIDA_CO_2021_Baseline_Config <- c(
	READING_2021.config
)

#####
###   Run BASELINE SGP analysis - create new Indiana_SGP object with historical data
#####

SGPstateData[["WIDA_CO"]][["Assessment_Program_Information"]][["CSEM"]] <- NULL

WIDA_CO_SGP <- abcSGP(
        sgp_object = WIDA_CO_Data_LONG,
        steps = c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
        sgp.config = WIDA_CO_2021_Baseline_Config,
        sgp.percentiles = FALSE,
        sgp.projections = FALSE,
        sgp.projections.lagged = FALSE,
        sgp.percentiles.baseline = TRUE,  #  Skip year SGPs for 2021 comparisons
        sgp.projections.baseline = FALSE, #  Calculated in next step
        sgp.projections.lagged.baseline = FALSE,
        save.intermediate.results = FALSE,
        parallel.config = list(
					BACKEND = "PARALLEL",
					WORKERS=list(BASELINE_PERCENTILES=8))
)

###   Save results
save(WIDA_CO_SGP, file="Data/WIDA_CO_SGP.Rdata")
