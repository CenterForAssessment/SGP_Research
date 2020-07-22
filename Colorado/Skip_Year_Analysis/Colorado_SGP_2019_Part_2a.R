################################################################################
###
###   STEP 3: SGP baseline SGPs for skip year analysis: 2017 to 2019 Part 2a
###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Colorado_SGP-2019_Part_1.Rdata")
load("Data/Colorado_Baseline_Matrices_2019.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2a/ELA.R")
source("SGP_CONFIG/2019_PART_2a/MATHEMATICS.R")

SGP_CONFIG_2019_PART_2a <- c(ELA_2019.config, MATHEMATICS_2019.config)

### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["CO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Colorado_Baseline_Matrices_2019[["MATHEMATICS.BASELINE"]]
SGPstateData[["CO"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["ELA.BASELINE"]] <- Colorado_Baseline_Matrices_2019[["ELA.BASELINE"]]


### Run analysis

Colorado_SGP <- abcSGP(
                  Colorado_SGP,
                  steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
                  sgp.percentiles=FALSE,
                  sgp.projections=FALSE,
                  sgp.projections.lagged=FALSE,
                  sgp.percentiles.baseline=TRUE,
                  sgp.projections.baseline=FALSE,
                  sgp.projections.lagged.baseline=FALSE,
                  sgp.config=SGP_CONFIG_2019_PART_2a,
                  parallel.config = list(
                    BACKEND="PARALLEL",
                    WORKERS=list(PERCENTILES = 8)))


### Save results

save(Colorado_SGP, file="Data/Colorado_SGP-2019_Part_2a.Rdata")
