################################################################################
###                                                                          ###
###          STEP 2A: Create Demonstration COVID Baseline Matrices           ###
###                                                                          ###
################################################################################

###   Set working directory to Learning_Loss_Analysis repo
setwd("..")


### Get output_directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/BASIC_ANALYSIS"


### Load necessary packages
require(SGP)
require(SGPdata)
require(data.table)


###  Create a smaller subset of the LONG data to work with.
Demonstration_COVID_Data_LONG <- data.table(sgpData_LONG_COVID[,
	c("ID", "CONTENT_AREA", "YEAR", "GRADE", "SCALE_SCORE", "ACHIEVEMENT_LEVEL", "VALID_CASE"),])


###   Read in Baseline SGP Configuration Scripts and Combine
source("SGP_CONFIG/STEP_2/PART_A/SingleCohort/ELA.R")
source("SGP_CONFIG/STEP_2/PART_A/SingleCohort/MATHEMATICS.R")
# source("SGP_CONFIG/STEP_2_BASELINE/PART_A/SuperCohort/ELA.R")
# source("SGP_CONFIG/STEP_2_BASELINE/PART_A/SuperCohort/MATHEMATICS.R")

DEMO_COVID_BASELINE_CONFIG_STEP_2 <- c(
	ELA_BASELINE.config,
	MATHEMATICS_BASELINE.config
)


###   Create Baseline Matrices

Demonstration_COVID_SGP <- prepareSGP(Demonstration_COVID_Data_LONG, create.additional.variables=FALSE)

DEMO_COVID_Baseline_Matrices <- baselineSGP(
				Demonstration_COVID_SGP,
				sgp.baseline.config=DEMO_COVID_BASELINE_CONFIG_STEP_2,
				return.matrices.only=TRUE,
				calculate.baseline.sgps=FALSE,
				goodness.of.fit.print=FALSE
				# parallel.config = ...  #  Optional parallel processing - see SGP
				# 	 									 	 #  package documentation for details.
)


###   Save results
save(DEMO_COVID_Baseline_Matrices, file=file.path(output.directory, "DEMO_COVID_Baseline_Matrices-SingleCohort.Rdata"))
# save(DEMO_COVID_Baseline_Matrices, file="Data/DEMO_COVID_Baseline_Matrices-SuperCohort.Rdata")
