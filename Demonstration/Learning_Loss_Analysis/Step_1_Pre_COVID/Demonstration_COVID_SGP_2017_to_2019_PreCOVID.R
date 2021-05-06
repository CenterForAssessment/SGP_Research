################################################################################
###                                                                          ###
###    R Script for pre-COVID (2017-2019) Demonstration COVID SGP analyses   ###
###                                                                          ###
################################################################################

###   Load packages
require(SGP)
require(SGPdata)


###   Set working directory to base Learning_Loss_Analysis directory
setwd("..")


### Get output_directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/BASIC_ANALYSIS"

### Set up parrallel.config if it doesn't exist
if (!exists("parallel.config")) parallel.config <- NULL

###   Create subset of pre-COVID (2016-2019) data
if (!exists("Demonstration_COVID_Data_LONG"))
	Demonstration_COVID_Data_LONG <- sgpData_LONG_COVID[YEAR <= 2019]


###   Read in STEP 3 SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_1/ELA.R")
source("SGP_CONFIG/STEP_1/MATHEMATICS.R")

DEMO_COVID_CONFIG_STEP_1 <- rev(c(
	ELA_2017.config,
	MATHEMATICS_2017.config,

	ELA_2018.config,
	MATHEMATICS_2018.config,

	ELA_2019.config,
	MATHEMATICS_2019.config))


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
	sgp.projections.lagged.baseline = FALSE,
	outputSGP.directory=output.directory,
	parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
)


###   Save results
save(Demonstration_COVID_SGP, file=file.path(output.directory, "Demonstration_COVID_SGP_STEP_1.Rdata"))
