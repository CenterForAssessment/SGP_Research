################################################################################
###                                                                          ###
###     Historical One-Year Gap SGPs for Colorado 2021 Contingency Plan      ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Official data and subset 2016-2017

load("./Data/Colorado_Data_LONG_NO_SKIP.Rdata") # From 2019 CO SGP Analyses & Colorado_Data_LONG.R
Colorado_Data_LONG <- Colorado_Data_LONG_NO_SKIP[YEAR <= "2017"]


###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2017/ELA.R")
source("SGP_CONFIG/2017/MATHEMATICS.R")


CO.2017.config <- c(
	ELA.2017.config,
	MATHEMATICS.2017.config
)

###   Setup SGPstateData with CMAS ONLY projection sequences
SGPstateData[["CO"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    ELA=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS=c(3, 4, 5, 6, 7, 8))
SGPstateData[["CO"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    ELA=rep("ELA", 6),
    MATHEMATICS=rep("MATHEMATICS", 6))
SGPstateData[["CO"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
    ELA=3,
    MATHEMATICS=3)
SGPstateData[["CO"]][["SGP_Configuration"]][["year_lags.projection.sequence"]] <- list(
		ELA = rep(1L, 5),
		MATHEMATICS = rep(1L, 5))

SGPstateData[["CO"]][['SGP_Progression_Preference']] <- NULL

###   Remove CSEM from SGPstateData
SGPstateData[["CO"]][["Assessment_Program_Information"]][["CSEM"]] <- NULL


###
###    abcSGP - To produce SG Percentiles and Projections
###

Colorado_SGP <- abcSGP(
		Colorado_Data_LONG,
		sgp.config = CO.2017.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		sgp.target.scale.scores=TRUE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(PERCENTILES = 8, PROJECTIONS=5, LAGGED_PROJECTIONS=2)))

grep("SGP_TARGET", names(Colorado_SGP@Data), value=TRUE)  # Need to have SGP_TARGET_3_YEAR

save(Colorado_SGP, file="Data/Colorado_SGP-2017.Rdata")
