################################################################################
###                                                                          ###
###     Historical Two-Year Gap SGPs for Indiana 2021 Contingency Plan       ###
###                                                                          ###
################################################################################

###   Load required packages

require(SGP)
require(data.table)


###   Load Official data and subset 2019

load("Data/Indiana_SGP_LONG_Data.Rdata")
Indiana_Data_LONG <- Indiana_SGP_LONG_Data[SCHOOL_YEAR %in% c("2015", "2016", "2017", "2018", "2019"), c("VALID_CASE", "CONTENT_AREA", "SCHOOL_YEAR", "STUDENT_ID", "GRADE_ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")]


###   Read in 2018 and 2019 SGP Configuration Scripts and Combine

source("SGP_CONFIG/2018/ELA.R")
source("SGP_CONFIG/2018/MATHEMATICS.R")
source("SGP_CONFIG/2019/ELA.R")
source("SGP_CONFIG/2019/MATHEMATICS.R")


IN.config <- c(
	ELA.2018.config,
	MATHEMATICS.2018.config
	ELA.2019.config,
	MATHEMATICS.2019.config
)


###
###    abcSGP
###


SGPstateData[["IN"]][["Assessment_Program_Information"]][["CSEM"]] <- NULL

Indiana_SGP <- abcSGP(
		sgp_object=Indiana_Data_LONG,
		sgp.config=IN.config,
		sgp.minimum.default.panel.years=2,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "summarizeSGP", "outputSGP")),
		sgp.percentiles=TRUE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline=FALSE,
		sgp.projections.lagged.baseline=FALSE,
		parallel.config = list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES = 8)))


### Save results

save(Indiana_SGP, file="Data/Indiana_SGP.Rdata")
