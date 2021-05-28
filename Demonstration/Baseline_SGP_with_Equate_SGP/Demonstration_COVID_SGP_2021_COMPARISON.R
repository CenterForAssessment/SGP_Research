######################################################################################
###
### SGP analyses for 2021 data using ACTUAL, ASSESSMENT_CHANGE_2016, and
### ASSESSMENT_CHANGE_2017 coefficient matrices for SGP_BASELINE comparison
###
######################################################################################

### Load packages
require(SGP)
require(data.table)

### Set up parameters
parallel.config <- list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4, BASELINE_PERCENTILES=4, PROJECTIONS=4, LAGGED_PROJECTIONS=4, SGP_SCALE_SCORE_TARGETS=4))

### Load data
load("Data/ACTUAL/Demonstration_COVID_SGP_LONG_Data_ACTUAL.Rdata")

### Load matrices
load("Data/ACTUAL/DEMO_COVID_Baseline_Matrices-SingleCohort_ACTUAL.Rdata")
load("Data/ASSESSMENT_CHANGE_2016/DEMO_COVID_Baseline_Matrices-SingleCohort_ASSESSMENT_CHANGE_2016.Rdata")
load("Data/ASSESSMENT_CHANGE_2017/DEMO_COVID_Baseline_Matrices-SingleCohort_ASSESSMENT_CHANGE_2017.Rdata")

###   Read in SGP Configuration Scripts and Combine
source("SGP_CONFIG/SGP_Calculation/ELA.R")
source("SGP_CONFIG/SGP_Calculation/MATHEMATICS.R")

SGP_CONFIG <- c(
	ELA_2021.config,
	MATHEMATICS_2021.config
)

##########################################################################################
###
### SGPs based upon ACTUAL (non-perturbed) baseline matrices
###
##########################################################################################

### Plug matrices in
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices_ACTUAL

### abcSGP
Demonstration_COVID_SGP_2021_ACTUAL <- abcSGP(
                                    Demonstration_COVID_SGP_LONG_Data_ACTUAL,
                                    steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                                    sgp.percentiles=TRUE,
                                    sgp.projections=FALSE,
                                    sgp.projections.lagged=FALSE,
                                    sgp.percentiles.baseline=TRUE,
                                    sgp.projections.baseline=FALSE,
                                    sgp.projections.lagged.baseline=FALSE,
                                    outputSGP.directory="Data/ACTUAL",
                                    sgp.config=SGP_CONFIG,
									parallel.config=parallel.config)

### Save results
save(Demonstration_COVID_SGP_2021_ACTUAL, file="Data/ACTUAL/Demonstration_COVID_SGP_2021_ACTUAL.Rdata")

### Move Goodness_of_Fit plots
system("mv Goodness_of_Fit Data/ACTUAL")


##########################################################################################
###
### SGPs based upon ASSESSMENT_CHANGE_2016 (perturbed) baseline matrices
###
##########################################################################################

### Plug matrices in
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices_ASSESSMENT_CHANGE_2016

### abcSGP
Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2016 <- abcSGP(
                                    Demonstration_COVID_SGP_LONG_Data_ACTUAL,
                                    steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                                    sgp.percentiles=TRUE,
                                    sgp.projections=FALSE,
                                    sgp.projections.lagged=FALSE,
                                    sgp.percentiles.baseline=TRUE,
                                    sgp.projections.baseline=FALSE,
                                    sgp.projections.lagged.baseline=FALSE,
                                    outputSGP.directory="Data/ASSESSMENT_CHANGE_2017",
                                    sgp.config=SGP_CONFIG,
									parallel.config=parallel.config)

### Save results
save(Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2016, file="Data/ASSESSMENT_CHANGE_2016/Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2016.Rdata")

### Move Goodness_of_Fit plots
system("mv Goodness_of_Fit Data/ASSESSMENT_CHANGE_2016")


##########################################################################################
###
### SGPs based upon ASSESSMENT_CHANGE_2017 (perturbed) baseline matrices
###
##########################################################################################

### Plug matrices in
SGPstateData[["DEMO_COVID"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- DEMO_COVID_Baseline_Matrices_ASSESSMENT_CHANGE_2017

### abcSGP
Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2017 <- abcSGP(
                                    Demonstration_COVID_SGP_LONG_Data_ACTUAL,
                                    steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                                    sgp.percentiles=TRUE,
                                    sgp.projections=FALSE,
                                    sgp.projections.lagged=FALSE,
                                    sgp.percentiles.baseline=TRUE,
                                    sgp.projections.baseline=FALSE,
                                    sgp.projections.lagged.baseline=FALSE,
                                    outputSGP.directory="Data/ASSESSMENT_CHANGE_2017",
                                    sgp.config=SGP_CONFIG,
									parallel.config=parallel.config)

### Save results
save(Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2017, file="Data/ASSESSMENT_CHANGE_2017/Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2017.Rdata")

### Move Goodness_of_Fit plots
system("mv Goodness_of_Fit Data/ASSESSMENT_CHANGE_2017")
