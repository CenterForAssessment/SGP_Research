################################################################################
###
### Initial SGP analyses for skip year simulation: 2016-2017
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Create subset of data

Demonstration_Data_LONG <- sgpData_LONG[YEAR <= "2016_2017"]


### Load configurations

source("SGP_CONFIG/2016_2017/READING.R")
source("SGP_CONFIG/2016_2017/MATHEMATICS.R")

SGP_CONFIG_2016_2017 <- c(READING_2016_2017.config, MATHEMATICS_2016_2017.config)


### Run analysis

Demonstration_SGP <- abcSGP(
                        Demonstration_Data_LONG,
                        steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                        sgp.percentiles=TRUE,
                        sgp.projections=TRUE,
                        sgp.projections.lagged=TRUE,
                        sgp.percentiles.baseline=FALSE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=FALSE,
                        sgp.target.scale.scores=TRUE,
                        sgp.config=SGP_CONFIG_2016_2017)


### Save results

save(Demonstration_SGP, file="Data/Demonstration_SGP.Rdata")
