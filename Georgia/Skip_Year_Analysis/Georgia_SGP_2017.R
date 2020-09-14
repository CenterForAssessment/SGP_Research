################################################################################
###                                                                          ###
###  STEP 1: Initial SGP analyses for skip year simulation: 2017             ###
###          Historical One-Year Gap SGPs for Georgia 2021 Contingency Plan  ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Official data and subset 2016-2017

load("./Data/Georgia_Data_LONG_NO_SKIP.Rdata") # From Skip_Year_Analysis/Georgia_Data_LONG.R
Georgia_Data_LONG <- Georgia_Data_LONG_NO_SKIP[SCHOOL_YEAR <= "2017"]


###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2017/ELA.R")
source("SGP_CONFIG/2017/MATHEMATICS.R")

GA_2017.config <- c(
  MATHEMATICS_2017.config,
	COORDINATE_ALGEBRA_2017.config,
	ANALYTIC_GEOMETRY_2017.config,
	ALGEBRA_I_2017.config,
	GEOMETRY_2017.config,

  ELA_2017.config,
	GRADE_9_LIT_2017.config,
	AMERICAN_LIT_2017.config
)


###
###    abcSGP - To produce SG Percentiles and Projections
###

Georgia_SGP <- abcSGP(
		Georgia_Data_LONG,
		sgp.config = GA_2017.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		# sgp.target.scale.scores=TRUE,
		calculate.simex = TRUE,
		###   Use these three lines for the small sample test run.  Delete/comment out and set calculate.simex = TRUE for full EOC run.
		###
			# calculate.simex = list(lambda=seq(0,2,0.5), simulation.iterations=40, csem.data.vnames="SCALE_SCORE_CSEM", extrapolation="linear", save.matrices=TRUE),
			# sgp.test.cohort.size = 2500, # comment out for full run
			# return.sgp.test.results = "ALL_DATA", # TRUE, #
			# goodness.of.fit.print=FALSE,
		###
		###
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS=11, SIMEX=11)))

grep("SGP_TARGET", names(Georgia_SGP@Data), value=TRUE)  # Need to have SGP_TARGET_3_YEAR

save(Georgia_SGP, file="Data/Georgia_SGP-2017.Rdata")
