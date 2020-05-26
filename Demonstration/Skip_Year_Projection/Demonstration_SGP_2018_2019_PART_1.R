################################################################################
###
### Initial SGP analyses for skip year simulation: 2016-2017
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Load data

load("Data/Demonstration_SGP_2016_2017.Rdata")


### Create subset of data

Demonstration_Data_LONG_2018_2019 <- sgpData_LONG[YEAR == "2018_2019"]


### Load configurations

source("SGP_CONFIG/2018_2019/READING.R")
source("SGP_CONFIG/2018_2019/MATHEMATICS.R")

SGP_CONFIG_2018_2019 <- c(READING_2018_2019.config, MATHEMATICS_2018_2019.config)


### Run analysis

Demonstration_SGP_2018_2019 <- updateSGP(
                        Demonstration_SGP_2016_2017,
                        Demonstration_Data_LONG_2018_2019,
                        steps=c("prepareSGP", "analyzeSGP"),
                        sgp.percentiles=TRUE,
                        sgp.projections=FALSE,
                        sgp.projections.lagged=FALSE,
                        sgp.percentiles.baseline=FALSE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=FALSE,
                        sgp.target.scale.scores=TRUE,
                        save.intermediate.results=FALSE,
                        sgp.config=SGP_CONFIG_2018_2019)


### Save results

save(Demonstration_SGP_2018_2019, file="Data/Demonstration_SGP_2018_2019.Rdata")
