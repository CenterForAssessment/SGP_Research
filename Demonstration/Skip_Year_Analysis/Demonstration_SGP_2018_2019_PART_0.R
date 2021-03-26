################################################################################
###
### STEP 2: SGP sequential analyses for skip year comparison: 2017/2018 to 2019
###
################################################################################

###   Load packages

require(SGP)
require(SGPdata)

###   Create subset of data

Demonstration_Data_LONG <- sgpData_LONG[YEAR %in% c("2016_2017", "2017_2018", "2018_2019")]


###   Set SGPstateData to use a maximum of 2 priors
SGPstateData[["DEMO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 2

###   Run analysis

Demonstration_SGP <- abcSGP(
      state="DEMO",
      Demonstration_Data_LONG,
      years = "2018_2019",
      steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
      sgp.percentiles=TRUE,
      sgp.projections=FALSE,
      sgp.projections.lagged=FALSE,
      sgp.percentiles.baseline=FALSE,
      sgp.projections.baseline=FALSE,
      sgp.projections.lagged.baseline=FALSE,
			save.intermediate.results=FALSE,
      outputSGP.output.type="LONG_FINAL_YEAR_Data")


### DO NOT Save results - only use LONG_FINAL_YEAR_Data
# save(Demonstration_SGP, file="Data/Demonstration_SGP_2018_2019_PART_0.Rdata")
