################################################################################
###                                                                          ###
###    R Script for pre-COVID (2017-2019) Demonstration COVID SGP analyses   ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
#setwd("Learning_Loss_Analysis")
setwd("..")

###   Load SGP package
require(SGP)
require(SGPdata)

###   Create subset of pre-COVID (2016-2019) data
Demonstration_COVID_Data_LONG <- SGPdata::sgpData_LONG_COVID[YEAR <= 2019]

###   Read in STEP 3 SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_1/ELA.R")
source("SGP_CONFIG/STEP_1/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_1 <- c(
	ELA_2017.config,
	MATHEMATICS_2017.config,

	ELA_2018.config,
	MATHEMATICS_2018.config,

	ELA_2019.config,
	MATHEMATICS_2019.config)


#####
###   Run analysis
#####

Demonstration_COVID_SGP <- abcSGP(
	sgp_object = Demonstration_COVID_Data_LONG,
	steps = c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
	sgp.config=DEMO_COVID_CONFIG_STEP_1,
        sgp.percentiles = TRUE,
        sgp.projections = TRUE,
        sgp.projections.lagged = TRUE,
        sgp.percentiles.baseline = FALSE,
        sgp.projections.baseline = FALSE,
        sgp.projections.lagged.baseline = FALSE
	# parallel.config = ...  #  Optional parallel processing - see SGP package documentation for details.
)


###   Save results
save(Demonstration_COVID_SGP, file="Data/Demonstration_COVID_SGP_STEP_1.Rdata")
