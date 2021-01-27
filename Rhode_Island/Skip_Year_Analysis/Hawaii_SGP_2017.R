################################################################################
###                                                                          ###
###  STEP 1: 2017 SGP analyses (no-skip matrices for baseline projections)   ###
###     Historical Skip-Year SGP Analysis -- Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load cleaned 'no-skip' data
load("./Data/Hawaii_Data_LONG_NO_SKIP.Rdata") # From 2019 HI SGP Analyses & Hawaii_Data_LONG_Skip_Year.R
Hawaii_Data_LONG <- Hawaii_Data_LONG_NO_SKIP[YEAR <= "2017"]

###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2017/READING.R")
source("SGP_CONFIG/2017/MATHEMATICS.R")

HI_Skip_Year_2017.config <- c(
	READING_2017.config,
	MATHEMATICS_2017.config)

###   Setup SGPstateData with projection sequences excluding 11th grade
SGPstateData[["HI"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    READING=c(3, 4, 5, 6, 7, 8),
    MATHEMATICS=c(3, 4, 5, 6, 7, 8))
SGPstateData[["HI"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    READING=rep("READING", 6),
    MATHEMATICS=rep("MATHEMATICS", 6))
SGPstateData[["HI"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
    READING=3,
    MATHEMATICS=3)
SGPstateData[["HI"]][["SGP_Configuration"]][["year_lags.projection.sequence"]] <- list(
		READING = rep(1L, 5),
		MATHEMATICS = rep(1L, 5))

###   Make other necessary changes to SGPstateData
SGPstateData[["HI"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL
SGPstateData[["HI"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["HI"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE

###
###    abcSGP - To produce SG Percentiles and Projections
###

Hawaii_SGP <- abcSGP(
		Hawaii_Data_LONG,
		sgp.config = HI_Skip_Year_2017.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		sgp.target.scale.scores=TRUE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS=8)))

grep("SGP_TARGET", names(Hawaii_SGP@Data), value=TRUE)  # Need to have SGP_TARGET_3_YEAR

save(Hawaii_SGP, file="Data/Hawaii_SGP-SkipYear.Rdata")
