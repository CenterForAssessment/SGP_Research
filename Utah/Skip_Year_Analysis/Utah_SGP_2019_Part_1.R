################################################################################
###                                                                          ###
###       Historical One-Year Gap SGPs for Utah 2021 Contingency Plan        ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load data created in Skip_Year_Analysis/Utah_Data_LONG.R
load("./Data/Utah_Data_LONG_NO_SKIP.Rdata")

###   Make changes and additions to SGPstateData
SGPstateData[["UT"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["UT"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE

##    Use 2019 Knots and Boundaries (since not doing equated SGPs)
load("UT_Knots_Boundaries.Rdata") # added to Skip_Year_Analysis repo
SGPstateData[["UT"]][["Achievement"]][["Knots_Boundaries"]] <- UT_Knots_Boundaries


###   Create SGP Configurations and Combine

ELA.2019.config <- list(
	ELA.2019 = list(
		sgp.content.areas=rep("ELA", 5),
		sgp.panel.years=c("2014", "2015", "2016", "2017", "2019"),
		sgp.grade.sequences=list(c("3", "5"), c("3", "4", "6"), c("3", "4", "5", "7"), c("3", "4", "5", "6", "8"),
														 c("4", "5", "6", "7", "9"), c("5", "6", "7", "8", "10")))
)

MATHEMATICS.2019.config <- list(
	MATHEMATICS.2019 = list(
		sgp.content.areas=rep("MATHEMATICS", 5),
		sgp.panel.years=c("2014", "2015", "2016", "2017", "2019"),
		sgp.grade.sequences=list(c("3", "5"), c("3", "4", "6"), c("3", "4", "5", "7"), c("3", "4", "5", "6", "8"),
														 c("4", "5", "6", "7", "9"), c("5", "6", "7", "8", "10")))
)

SCIENCE.2019.config <- list(
	SCIENCE.2019 = list(
		sgp.content.areas=rep("SCIENCE", 5),
		sgp.panel.years=c("2014", "2015", "2016", "2017", "2019"),
		sgp.grade.sequences=list(c("4", "6"), c("4", "5", "7"), c("4", "5", "6", "8"),
														 c("4", "5", "6", "7", "9"), c("5", "6", "7", "8", "10")))
)

UT.2019.config <- c(
	ELA.2019.config,
	MATHEMATICS.2019.config,
	SCIENCE.2019.config
)

###
###    abcSGP - To produce SG Percentiles ONLY
###

Utah_SGP <- abcSGP(
		Utah_Data_LONG_NO_SKIP,
		sgp.config = UT.2019.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = FALSE,
		sgp.projections.lagged = FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		sgp.percentiles.equated=FALSE,
		sgp.target.scale.scores=FALSE,
		outputSGP.output.type=c("LONG_Data", "LONG_FINAL_YEAR_Data"),
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS = 11)))


save(Utah_SGP, file="Data/Utah_SGP.Rdata")

#####
###   Quick descriptives
#####

Utah_SGP@Data$DIFF<- as.numeric(NA)
Utah_SGP@Data[, DIFF := SGP - NO_SKIP_SGP]

Utah_SGP@Data[GRADE %in% 5:10, as.list(summary(DIFF)), keyby = list(CONTENT_AREA, GRADE)]
Utah_SGP@Data[GRADE %in% 5:10, as.list(quantile(DIFF, probs=c(0, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 1), na.rm=TRUE)), keyby = list(CONTENT_AREA, GRADE)] # seq(0, 1, 0.1)

Utah_SGP@Data[!is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Skip_Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
	No_Skip_Test_Scores = round(cor(SCALE_SCORE, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  SGP_Corr = format(round(cor(NO_SKIP_SGP, SGP, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  N_Size = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE)]


missing <- Utah_SGP@Data[YEAR =="2019" & is.na(NO_SKIP_SGP) & !is.na(SGP),]
dim(missing)
table(missing[, CONTENT_AREA, GRADE], exclude=NULL)
