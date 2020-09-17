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
load("../../../Dropbox/Indiana/Data/Indiana_SGP_LONG_Data.Rdata") ### AWS data path

### Rename SGP derived/related variables by pre-pending NO_SKIP

original.names <- c(grep("^SGP", names(Utah_Data_LONG_NO_SKIP), value=TRUE),
                    grep("STATUS_3_YEAR", names(Utah_Data_LONG_NO_SKIP), value=TRUE),
                    grep("PRIOR", names(Utah_Data_LONG_NO_SKIP), value=TRUE))
new.names <- paste0("NO_SKIP_SGP_", gsub("^SGP_", "", original.names))
setnames(Indiana_SGP_LONG_Data, original.names, new.names)


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
		sgp_object=Indiana_SGP_LONG_Data,
		sgp.config=IN.config,
		sgp.minimum.default.panel.years=2,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
		sgp.percentiles=TRUE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline=FALSE,
		sgp.projections.lagged.baseline=FALSE,
		sgp.percentiles.equated=FALSE,
		parallel.config = list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=8)))


### Save results

save(Indiana_SGP, file="Data/Indiana_SGP.Rdata")
