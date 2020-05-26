#################################################################################
###                                                                           ###
###       SGP analysis script for PARCC Illinois - Spring 2019 Analyses       ###
###                                                                           ###
#################################################################################

workers <- parallel::detectCores()/2

### Load Packages
require(SGP)
require(data.table)

###  Load Data
load("../../../PARCC/Illinois/Data/Archive/2018_2019.2/Illinois_SGP_LONG_Data.Rdata")

##    Remove Projection/Target variables
grep('TARGET|PROJECTION|STATUS_3_YEAR|PERCENTILE_CUT', names(Illinois_SGP_LONG_Data), value=TRUE, perl=TRUE)
Illinois_SGP_LONG_Data[, grep("TARGET|PROJECTION|STATUS_3_YEAR|PERCENTILE_CUT", names(Illinois_SGP_LONG_Data), value=TRUE) := NULL]

##    Remove SIMEX variables
grep('SIMEX', names(Illinois_SGP_LONG_Data), value=TRUE, perl=TRUE)
Illinois_SGP_LONG_Data[, grep("SIMEX", names(Illinois_SGP_LONG_Data), value=TRUE) := NULL]

###   Rename No Skip_Year 'SGP' variables as 'ORIG' (except TARGET and PROJECTION variables)
grep('SGP', names(Illinois_SGP_LONG_Data), value=TRUE, perl=TRUE)
setnames(Illinois_SGP_LONG_Data, grep('SGP', names(Illinois_SGP_LONG_Data), value=TRUE, perl=TRUE),
			gsub("SGP", "ORIG", grep('SGP', names(Illinois_SGP_LONG_Data), value=TRUE, perl=TRUE)))

###   Rename No Skip Year prior scores
setnames(Illinois_SGP_LONG_Data, c("SCALE_SCORE_PRIOR_STANDARDIZED", "SCALE_SCORE_PRIOR"), c("SCALE_SCORE_PRIOR_STANDARDIZED_ORIG", "SCALE_SCORE_PRIOR_ORIG"))

###   Retain only Math and ELA grades 3-8 (only tests from spring 2019).  Remove SS (scale score) versions as well
Illinois_SGP_LONG_Data <- Illinois_SGP_LONG_Data[CONTENT_AREA %in% c("ELA", "MATHEMATICS") & GRADE %in% 3:8]


###  Read in the Spring 2018 configuration code and combine into a single list.
source("../SGP_CONFIG/2018_2019.2/ELA.R")
source("../SGP_CONFIG/2018_2019.2/MATHEMATICS.R")

IL_2018_2019.2.config <- c(
	ELA.2018_2019.2.config,
	MATHEMATICS.2018_2019.2.config) # Only Grades 3-8 Math and ELA in 2019

### abcSGP

Illinois_SGP <- abcSGP(
		state="IL",
		sgp_object=Illinois_SGP_LONG_Data,
		sgp.config = IL_2018_2019.2.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
		prepareSGP.create.additional.variables=FALSE,
		sgp.percentiles=TRUE,
		sgp.projections=FALSE,
		sgp.projections.lagged=FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline=FALSE,
		sgp.projections.lagged.baseline=FALSE,
		save.intermediate.results=FALSE,
		outputSGP.output.type=c("LONG_Data", "LONG_FINAL_YEAR_Data"),
    parallel.config=list(
			BACKEND = "FOREACH", TYPE = "doParallel",
			WORKERS = list(TAUS = workers)))

### Save results
save(Illinois_SGP, file="./Data/Illinois_SGP.Rdata")


#####
###   Quick descriptives
#####

Illinois_SGP@Data[, DIFF := SGP_ORDER_1 - ORIG_ORDER_1]

Illinois_SGP@Data[!is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(ORIG, SCALE_SCORE_PRIOR_STANDARDIZED_ORIG, use='pairwise.complete'), 2), nsmall = 2),
	SGP_Corr = format(round(cor(ORIG_ORDER_1, SGP_ORDER_1, use='pairwise.complete'), 2), nsmall = 2),
	Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  N_Size = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE)]

table(Illinois_SGP@Data[!is.na(ORIG), is.na(SGP), YEAR])
table(Illinois_SGP@Data[YEAR == "2018_2019.2", !is.na(ORIG), !is.na(SGP)])

added <- Illinois_SGP@Data[YEAR == "2018_2019.2" & is.na(ORIG) & !is.na(SGP),] # 15,888 that have SGPs now
dim(added)
table(added[, YEAR, as.character(SGP_NORM_GROUP)])

missing <- Illinois_SGP@Data[YEAR == "2018_2019.2" & !is.na(ORIG) & is.na(SGP),] # 310,709 fewer SGPs produced (mostly 4th grade)
dim(missing)
table(missing[, YEAR, as.character(ORIG_NORM_GROUP)])

missing <- Illinois_SGP@Data[YEAR == "2018_2019.2" & !is.na(ORIG) & is.na(SGP) & GRADE != "4",] # 40,509 (non-4th grade) fewer SGPs produced
dim(missing)
