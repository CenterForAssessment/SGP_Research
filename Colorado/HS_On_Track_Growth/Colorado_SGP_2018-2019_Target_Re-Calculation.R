################################################################################
###                                                                          ###
###   Calculate 2018 & 2019 CO Projections with new P/SAT Proficiency Cuts   ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Official 2019 SGP Object
load("../Colorado/Data/Colorado_SGP.Rdata")

###   Subset data to only use CMAS ELA/Math and PSAT/SAT content areas
table(Colorado_SGP@Data[grepl("ELA|MATHEMATICS|ALGEBRA", CONTENT_AREA) & CONTENT_AREA != "ALGEBRA_II", YEAR, CONTENT_AREA])
table(Colorado_SGP@Data[grepl("ELA|MATHEMATICS|ALGEBRA", CONTENT_AREA) & CONTENT_AREA != "ALGEBRA_II", GRADE, CONTENT_AREA])

Colorado_SGP@Data <- Colorado_SGP@Data[grepl("ELA|MATHEMATICS|ALGEBRA", CONTENT_AREA) & CONTENT_AREA != "ALGEBRA_II" & VALID_CASE=="VALID_CASE",]


###   Remove old Targets/Projections variables and projection calculations

##    Remove variables
grep('TARGET|PROJECTION|STATUS_3_YEAR|PERCENTILE_CUT', names(Colorado_SGP@Data), value=TRUE, perl=TRUE)
Colorado_SGP@Data[, grep("TARGET|PROJECTION|STATUS_3_YEAR|PERCENTILE_CUT", names(Colorado_SGP@Data), value=TRUE) := NULL]

##    Remove projection calculations
Colorado_SGP@SGP$SGProjections <- NULL

###  Fix ACHIEVEMENT_LEVEL

##   Transform ACHIEVEMENT_LEVEL VARIABLE to original and revised versions
table(Colorado_SGP@Data[, ACHIEVEMENT_LEVEL, CONTENT_AREA], exclude=NULL)
Colorado_SGP@Data[, ACHIEVEMENT_LEVEL := factor(ACHIEVEMENT_LEVEL, levels=c("Level 1", "Level 2", "Level 3", "Level 4", "Level 5"), ordered=TRUE)]

setnames(Colorado_SGP@Data, "ACHIEVEMENT_LEVEL", "ACH_LEVEL_ORIG") # Preserve original levels to check revisions
Colorado_SGP@Data <- SGP:::getAchievementLevel(Colorado_SGP@Data, state="CO")

##   PSAT/SAT levels are still labeled using CMAS labels - relabel using correct conventions
table(Colorado_SGP@Data[grepl("SAT", CONTENT_AREA), ACHIEVEMENT_LEVEL, CONTENT_AREA], exclude=NULL)
Colorado_SGP@Data[grepl("SAT", CONTENT_AREA) & ACHIEVEMENT_LEVEL == "Level 3", ACHIEVEMENT_LEVEL := "Level 2+"]
Colorado_SGP@Data[grepl("SAT", CONTENT_AREA) & ACHIEVEMENT_LEVEL == "Level 4", ACHIEVEMENT_LEVEL := "Level 3"]
Colorado_SGP@Data[grepl("SAT", CONTENT_AREA) & ACHIEVEMENT_LEVEL == "Level 5", ACHIEVEMENT_LEVEL := "Level 4"]

##   Final checks of revised achievement levels
table(Colorado_SGP@Data[, ACHIEVEMENT_LEVEL, ACH_LEVEL_ORIG], exclude=NULL)
table(Colorado_SGP@Data[ACHIEVEMENT_LEVEL != ACH_LEVEL_ORIG, YEAR, CONTENT_AREA], exclude=NULL) # Changes to cuts after 2015?  Doesn't matter for this analysis...
Colorado_SGP@Data[, as.list(summary(SCALE_SCORE)), keyby=c("CONTENT_AREA", "GRADE", "ACHIEVEMENT_LEVEL")]

##   Reset the class of the ACHIEVEMENT_LEVEL variables to character and remove orgiginal levels
Colorado_SGP@Data[, ACHIEVEMENT_LEVEL := as.character(ACHIEVEMENT_LEVEL)]
Colorado_SGP@Data[, ACH_LEVEL_ORIG := NULL]


######
######   2019 Projection/Target Recalculations
######

###   Load (official) 2019 configuration scripts and revise Math/ELA SAT to use single prior
source('../Colorado/SGP_CONFIG/2019/ELA.R')
source('../Colorado/SGP_CONFIG/2019/MATHEMATICS.R')

ELA_SAT.2019.config <- list(
	ELA_SAT.2019 = list(
		sgp.content.areas=c("ELA_PSAT_10", "ELA_SAT"),
		sgp.panel.years=c("2018", "2019"),
		sgp.grade.sequences=list(c("10", "11")))
)

MATHEMATICS_SAT.2019.config <- list(
	MATHEMATICS_SAT.2019 = list(
		sgp.content.areas=c("MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"),
		sgp.panel.years=c("2018", "2019"),
		sgp.grade.sequences=list(c("10", "11")))
)

COLO_2019.config <- c(
	ELA.2019.config,
	ELA_PSAT_9.2019.config,
	ELA_PSAT_10.2019.config,
	ELA_SAT.2019.config,

	MATHEMATICS.2019.config,
	MATHEMATICS_PSAT_9.2019.config,
	MATHEMATICS_PSAT_10.2019.config,
	MATHEMATICS_SAT.2019.config
)

##    Remove extraneous course configurations not used for projection calculations
COLO_2019.config <- COLO_2019.config[!sapply(COLO_2019.config, function(f) any(grepl("NO_PROJECTIONS", f)))]


###    analyzeSGP - To (re) produce SG Projections

Colorado_SGP <- analyzeSGP(
		Colorado_SGP,
		sgp.config = COLO_2019.config,
		sgp.percentiles = FALSE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE)


###   combineSGP - produce target scale scores as well

Colorado_SGP <- combineSGP(Colorado_SGP,
													 years = "2019",
													 sgp.config = COLO_2019.config,
													 sgp.target.scale.scores = TRUE)


###   Output results and save SGP object

outputSGP(Colorado_SGP, output.type=c("LONG_Data", "LONG_FINAL_YEAR_Data"))

save(Colorado_SGP, file="./Data/Colorado_SGP.Rdata")


###   Produce Growth Achievement Plots

visualizeSGP(Colorado_SGP,
		plot.types = c("growthAchievementPlot"),
		gaPlot.years = "2019",
		gaPlot.max.order.for.progression=2
)


######
######   2018 Projection/Target Recalculations  (NOT RUN)
######

###   NOTE:  Can't get PSAT 10 lagged targets in 2018 - no 2017 PSAT 9 to use in calculations for 2018

###   Read in 2018 SGP Configuration Scripts and Combine

source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2018/ELA.R')
source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2018/MATHEMATICS.R')

COLO_2018.config <- c(
	ELA.2018.config,
	ELA_PSAT_9.2018.config,
	ELA_PSAT_10.2018.config,
	ELA_SAT.2018.config,

	MATHEMATICS.2018.config,
	MATHEMATICS_PSAT_9.2018.config
	MATHEMATICS_PSAT_10.2018.config,
	MATHEMATICS_SAT.2018.config
)


###   Manually change the SGPstateData to align with available data

SGPstateData[["CO"]][["SGP_Configuration"]][["grade.projection.sequence"]] = list(
		ELA    =    c("3", "4", "5", "6", "7", "8", "9", "10", "11"), # Available in 2019.  No "ELA_PSAT_9" to "ELA_PSAT_10" available in 2018
		ELA_PSAT_9 =c("3", "4", "5", "6", "7", "8", "9", "10", "11"),
		ELA_PSAT_10=c("3", "4", "5", "6", "7", "8", "9", "10", "11"),
		ELA_SAT  =  c("3", "4", "5", "6", "7", "8", "9", "10", "11"),

		MATHEMATICS=c("3", "4", "5", "6", "7", "8", "9", "10", "11"), # Available in 2019.  No "MATHEMATICS_PSAT_9" to "MATHEMATICS_PSAT_10" available in 2018
		ALGEBRA_I = c("3", "4", "5", "6", "7", "8", "EOCT", "10", "11"),
		MATHEMATICS_PSAT_9 =c("3", "4", "5", "6", "7", "8", "9", "10", "11"),
		MATHEMATICS_PSAT_10=c("3", "4", "5", "6", "7", "8", "9", "10", "11"),
		MATHEMATICS_SAT  =  c("3", "4", "5", "6", "7", "8", "9", "10", "11")) #  No "MATHEMATICS_PSAT_9" to "MATHEMATICS_PSAT_10" available in 2018 - use 2017 Algebra I -- Add MATHEMATICS_PSAT_9 in 2020
SGPstateData[["CO"]][["SGP_Configuration"]][["content_area.projection.sequence"]] = list(
		ELA = c(rep("ELA", 7), "ELA_PSAT_10", "ELA_SAT"),
		ELA_PSAT_9 =c(rep("ELA", 6), "ELA_PSAT_9", "ELA_PSAT_10", "ELA_SAT"),
		ELA_PSAT_10=c(rep("ELA", 7), "ELA_PSAT_10", "ELA_SAT"),
		ELA_SAT  =  c(rep("ELA", 7), "ELA_PSAT_10", "ELA_SAT"), #  No "ELA_PSAT_9" to "ELA_PSAT_10" available in 2019 - use 2017 9th Grade ELA -- Add ELA_PSAT_9 in 2020

		MATHEMATICS = c(rep("MATHEMATICS", 6), "MATHEMATICS_PSAT_9", "MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"), # Available in 2019.  No "MATHEMATICS_PSAT_9" to "MATHEMATICS_PSAT_10" available in 2018
		ALGEBRA_I= c(rep("MATHEMATICS", 6), "ALGEBRA_I", "MATHEMATICS_PSAT_9", "MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"),
		MATHEMATICS_PSAT_9 =c(rep("MATHEMATICS", 3), "MATHEMATICS_PSAT_9", "MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"),
		MATHEMATICS_PSAT_10=c(rep("MATHEMATICS", 3), "MATHEMATICS_PSAT_9", "MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"),
		MATHEMATICS_SAT  =  c("MATHEMATICS", "MATHEMATICS", "ALGEBRA_I", "MATHEMATICS_PSAT_10", "MATHEMATICS_SAT"))#  No "MATHEMATICS_PSAT_9" to "MATHEMATICS_PSAT_10" available in 2018 - use 2017 Algebra I -- Add MATHEMATICS_PSAT_9 in 2020
SGPstateData[["CO"]][["SGP_Configuration"]][["year_lags.projection.sequence"]] = list(
		ELA = rep(1L, 8),
		ELA_PSAT_9 = rep(1L, 8),
		ELA_PSAT_10= rep(1L, 8),
		ELA_SAT  =   rep(1L, 8),

		MATHEMATICS = rep(1L, 8),
		ALGEBRA_I =rep(1L, 6),
		MATHEMATICS_PSAT_9 = rep(1L, 8),
		MATHEMATICS_PSAT_10= rep(1L, 8),
		MATHEMATICS_SAT  =   rep(1L, 8))


###
###    analyzeSGP - To (re) produce SG Projections
###

Colorado_SGP <- analyzeSGP(
		Colorado_SGP,
		sgp.config = COLO_2018.config,
		sgp.percentiles = FALSE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(PROJECTIONS= 6, LAGGED_PROJECTIONS=2)))
