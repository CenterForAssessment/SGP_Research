################################################################################
###                                                                          ###
###     Historical Two-Year Skip SGPs for Indiana 2021 Contingency Plan       ###
###     including merging SKIP and NO_SKIP SGPs into a single file           ###
###                                                                          ###
################################################################################

###   Load required packages

require(SGP)
require(data.table)


###   Load Official data and subset data for 2018 and 2019 skip year analyses

#load("/Users/conet/Github/CenterForAssessment/Indiana/master/Data/Indiana_SGP_LONG_Data.Rdata")
load("../../../Dropbox/Indiana/Data/Indiana_SGP_LONG_Data.Rdata")
Indiana_Data_LONG <- Indiana_SGP_LONG_Data[SCHOOL_YEAR %in% c("2015", "2016", "2017", "2018", "2019"), c("VALID_CASE", "CONTENT_AREA", "SCHOOL_YEAR", "STUDENT_ID", "GRADE_ID", "SCALE_SCORE", "ACHIEVEMENT_LEVEL")]


### Rename SGP derived/related variables by pre-pending NO_SKIP

original.names <- c("SGP", "SCALE_SCORE_PRIOR", "SCALE_SCORE_PRIOR_STANDARDIZED", "SGP_LEVEL", "SGP_NORM_GROUP", "SGP_NORM_GROUP_SCALE_SCORES", "SGP_PROJECTION_GROUP",
                        "SGP_TARGET_3_YEAR_CURRENT", "SGP_TARGET_MOVE_UP_STAY_UP_3_YEAR_CURRENT", "SGP_TARGET_3_YEAR", "ACHIEVEMENT_LEVEL_PRIOR", "SGP_TARGET_MOVE_UP_STAY_UP_3_YEAR",
                        "SGP_TARGET_3_YEAR_CONTENT_AREA", "SGP_NOTE", "SGP_ORDER_1", "SGP_ORDER_2", "SGP_ORDER_3", "SGP_ORDER", "SGP_PROJECTION_GROUP_SCALE_SCORES",
                        "CATCH_UP_KEEP_UP_STATUS", "MOVE_UP_STAY_UP_STATUS")
original.names <- intersect(names(Indiana_SGP_LONG_Data_NO_SKIP), original.names)
new.names <- paste0("NO_SKIP_", original.names)
setnames(Indiana_SGP_LONG_Data_NO_SKIP, original.names, new.names)


###   Read in 2018 and 2019 SGP Configuration Scripts and Combine

source("SGP_CONFIG/2018/ELA.R")
source("SGP_CONFIG/2018/MATHEMATICS.R")
source("SGP_CONFIG/2019/ELA.R")
source("SGP_CONFIG/2019/MATHEMATICS.R")


IN.config <- c(
	ELA.2018.config,
	MATHEMATICS.2018.config,
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
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "summarizeSGP", "outputSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline=FALSE,
		sgp.projections.lagged.baseline=FALSE,
		outputSGP.directory="SKIP_SGP_Data",
		parallel.config = list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES = 8)))


### Save results

save(Indiana_SGP, file="Data/SKIP_SGP_Data/Indiana_SGP.Rdata")
