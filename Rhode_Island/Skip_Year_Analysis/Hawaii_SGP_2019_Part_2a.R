################################################################################
###                                                                          ###
###  STEP 3: Baseline-referenced skip-year SGPs (2017 to 2019 -- Part 2a)    ###
###     Historical Skip-Year SGP Analysis -- Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Hawaii_SGP-SkipYear.Rdata")
load("Data/Hawaii_Baseline_Matrices_2019.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2a/READING.R")
source("SGP_CONFIG/2019_PART_2a/MATHEMATICS.R")

HI_Skip_Year_P2a.config <- c(
  READING_2019.config,
  MATHEMATICS_2019.config)

### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["MATHEMATICS.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["MATHEMATICS.BASELINE"]]
SGPstateData[["HI"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]][["READING.BASELINE"]] <- Hawaii_Baseline_Matrices_2019[["READING.BASELINE"]]

SGPstateData[["HI"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL
SGPstateData[["HI"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["HI"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE


###
###    abcSGP - To produce SG BASELINE Percentiles ONLY
###

Hawaii_SGP <- abcSGP(
                Hawaii_SGP,
                sgp.config=HI_Skip_Year_P2a.config,
                steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
                sgp.percentiles=FALSE,
                sgp.projections=FALSE,
                sgp.projections.lagged=FALSE,
                sgp.percentiles.baseline=TRUE,
                sgp.projections.baseline=FALSE,
                sgp.projections.lagged.baseline=FALSE,
                parallel.config = list(
                  BACKEND="PARALLEL",
                  WORKERS=list(PERCENTILES = 8)))


### Save results

save(Hawaii_SGP, file="Data/Hawaii_SGP-SkipYear.Rdata")
