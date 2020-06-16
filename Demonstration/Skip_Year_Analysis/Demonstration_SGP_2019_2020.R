################################################################################
###
### STEP 6: SGP analyses for year after skip year: 2019 to 2020
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Load data

load("Data/Demonstration_SGP_2018_2019_PART_2c.Rdata")


### Create subset of data

Demonstration_Data_LONG_2019_2020 <- sgpData_LONG[YEAR == "2019_2020"]


### Update SGPstateData configurations

SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 1
SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.order.for.projection"]] <- 1


### Load configurations

source("SGP_CONFIG/2019_2020/READING.R")
source("SGP_CONFIG/2019_2020/MATHEMATICS.R")

SGP_CONFIG_2019_2020 <- c(READING_2019_2020.config, MATHEMATICS_2019_2020.config)


### Run analysis

Demonstration_SGP_2019_2020 <- updateSGP(
                        Demonstration_SGP_2018_2019_PART_2c,
                        Demonstration_Data_LONG_2019_2020,
                        steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                        sgp.percentiles=TRUE,
                        sgp.projections=TRUE,
                        sgp.projections.lagged=TRUE,
                        sgp.percentiles.baseline=FALSE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=FALSE,
                        sgp.target.scale.scores=TRUE,
                        sgp.config=SGP_CONFIG_2019_2020)


### Save results

save(Demonstration_SGP_2019_2020, file="Data/Demonstration_SGP_2019_2020.Rdata")
