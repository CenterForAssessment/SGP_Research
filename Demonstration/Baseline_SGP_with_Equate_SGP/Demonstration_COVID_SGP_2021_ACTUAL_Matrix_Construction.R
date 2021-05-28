######################################################################################
###
### Baseline matrix calculation using ACTUAL (non-perturbed) data (2016, 2017, 2019)
###
######################################################################################

### Load packages
require(SGP)
require(data.table)

### Set up parameters
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4, BASELINE_MATRICES=4))

### Load data
load("Data/ACTUAL/Demonstration_COVID_SGP_LONG_Data_ACTUAL.Rdata")

########################################################################
### Create baseline matrices
########################################################################

###  Create a smaller subset of the LONG data to work with.
Demonstration_COVID_Data_LONG <- data.table(Demonstration_COVID_SGP_LONG_Data_ACTUAL[,
		c("ID", "CONTENT_AREA", "YEAR", "GRADE", "SCALE_SCORE", "VALID_CASE"),])

###   Read in Baseline SGP Configuration Scripts and Combine
source("SGP_CONFIG/Baseline_Matrix/ELA.R")
source("SGP_CONFIG/Baseline_Matrix/MATHEMATICS.R")

BASELINE_MATRIX_CONFIG <- c(
	ELA_BASELINE.config,
	MATHEMATICS_BASELINE.config
)

Demonstration_COVID_SGP <- prepareSGP(Demonstration_COVID_Data_LONG, create.additional.variables=FALSE)

DEMO_COVID_Baseline_Matrices_ACTUAL <- baselineSGP(
				Demonstration_COVID_SGP,
				sgp.baseline.config=BASELINE_MATRIX_CONFIG,
				return.matrices.only=TRUE,
				calculate.baseline.sgps=FALSE,
				goodness.of.fit.print=FALSE,
				parallel.config=parallel.config  #  Optional parallel processing - see SGP package documentation for details.
)

###   Save results
save(DEMO_COVID_Baseline_Matrices_ACTUAL, file="Data/ACTUAL/DEMO_COVID_Baseline_Matrices-SingleCohort_ACTUAL.Rdata")
