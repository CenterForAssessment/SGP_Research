######################################################################################
###
### SGP analyses for 2021 data
###
######################################################################################

### Load packages
require(SGP)

### Load data
load("Data/ACTUAL/Demonstration_SGP_LONG_Data_ACTUAL.Rdata")

### Only use 2 priors
SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 2

### Create baseline matrices



### abcSGP
Demonstration_SGP_2021_ACTUAL <- abcSGP(
                                    Demonstration_SGP_LONG_Data_ACTUAL,
                                    steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                                    years=c("2020_2021"),
                                    sgp.percentiles=TRUE,
                                    sgp.projections=FALSE,
                                    sgp.projections.lagged=FALSE,
                                    sgp.percentiles.baseline=TRUE,
                                    sgp.projections.baseline=FALSE,
                                    sgp.projections.lagged.baseline=FALSE,
                                    outputSGP.directory="Data/ACTUAL"

)

### Save results
save(Demonstration_SGP_2021_ACTUAL, file="Data/ACTUAL/Demonstration_SGP_2021_ACTUAL.Rdata")
