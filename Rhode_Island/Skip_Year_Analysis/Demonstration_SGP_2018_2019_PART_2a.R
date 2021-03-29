################################################################################
###
### STEP 3: SGP baseline SGPs for skip year simulation: 2017 to 2019 Part 2a
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Load data

load("Data/Demonstration_SGP_2018_2019_PART_1.Rdata")
load("Data/Demonstration_Baseline_Matrices_2018_2019.Rdata")


### Load configurations

source("SGP_CONFIG/2018_2019_PART_2a/READING.R")
source("SGP_CONFIG/2018_2019_PART_2a/MATHEMATICS.R")

SGP_CONFIG_2018_2019_PART_2a <- c(READING_2018_2019.config, MATHEMATICS_2018_2019.config)


### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["DEMO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Demonstration_Baseline_Matrices_2018_2019$MATHEMATICS.BASELINE
SGPstateData[["DEMO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["READING.BASELINE"]] <- Demonstration_Baseline_Matrices_2018_2019$READING.BASELINE


### Run analysis

Demonstration_SGP_2018_2019_PART_2a <- abcSGP(
                        Demonstration_SGP_2018_2019_PART_1,
                        steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
                        sgp.percentiles=FALSE,
                        sgp.projections=FALSE,
                        sgp.projections.lagged=FALSE,
                        sgp.percentiles.baseline=TRUE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=FALSE,
                        sgp.config=SGP_CONFIG_2018_2019_PART_2a)


### Save results

save(Demonstration_SGP_2018_2019_PART_2a, file="Data/Demonstration_SGP_2018_2019_PART_2a.Rdata")
