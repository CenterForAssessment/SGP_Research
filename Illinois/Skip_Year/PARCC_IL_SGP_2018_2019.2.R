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
load("../../../PARCC/Illinois/Data/Archive/2015_2016.2/Illinois_SGP_LONG_Data.Rdata")
Illinois_Data_1 <- Illinois_SGP_LONG_Data[grep("_SS|INTEGRATED|ALGEBRA|GEOMETRY", CONTENT_AREA, invert =TRUE),]

load("../../../PARCC/Illinois/Data/Archive/2018_2019.2/Illinois_SGP_LONG_Data.Rdata")
Illinois_Data_2 <- Illinois_SGP_LONG_Data[grep("_SS", CONTENT_AREA, invert =TRUE),]

names(Illinois_Data_1)[!names(Illinois_Data_1) %in% (names(Illinois_Data_2))]
names(Illinois_Data_2)[!names(Illinois_Data_2) %in% (names(Illinois_Data_1))]

Illinois_Data_LONG <- rbindlist(list(Illinois_Data_1[YEAR != "2015_2016.1",], Illinois_Data_2), fill=TRUE)

##    Clean up YEAR variable - only using spring, so no need for .2 convention
Illinois_Data_LONG[, YEAR := gsub("[.]2", "", YEAR)]
Illinois_Data_LONG[, SGP_NORM_GROUP := gsub("[.]2", "", as.character(SGP_NORM_GROUP))]

##    Remove Projection/Target variables
grep('TARGET|PROJECTION|STATUS|PERCENTILE_CUT', names(Illinois_Data_LONG), value=TRUE, perl=TRUE)
Illinois_Data_LONG[, grep("TARGET|PROJECTION|STATUS|PERCENTILE_CUT", names(Illinois_Data_LONG), value=TRUE) := NULL]

##    Remove SIMEX variables
grep('SIMEX', names(Illinois_Data_LONG), value=TRUE, perl=TRUE)
Illinois_Data_LONG[, grep("SIMEX", names(Illinois_Data_LONG), value=TRUE) := NULL]

##    Remove other extraneous variables
Illinois_Data_LONG[, c("EXACT_DUPLICATE", "Period", "PREFERENCE") := NULL]

###   Rename No Skip_Year 'SGP' variables as 'NO_SKIP_SGP' (except TARGET and PROJECTION variables)
grep('SGP', names(Illinois_Data_LONG), value=TRUE, perl=TRUE)
setnames(Illinois_Data_LONG, grep('SGP', names(Illinois_Data_LONG), value=TRUE, perl=TRUE),
			gsub("SGP", "NO_SKIP_SGP", grep('SGP', names(Illinois_Data_LONG), value=TRUE, perl=TRUE)))

###   Rename No Skip Year prior scores
setnames(Illinois_Data_LONG, c("SCALE_SCORE_PRIOR_STANDARDIZED", "SCALE_SCORE_PRIOR"), c("SCALE_SCORE_PRIOR_STANDARDIZED_NO_SKIP", "SCALE_SCORE_PRIOR_NO_SKIP"))

###   Retain only Math and ELA grades 3-8 (only tests from spring 2019).  Remove SS (scale score) versions as well
# Illinois_Data_LONG <- Illinois_Data_LONG[CONTENT_AREA %in% c("ELA", "MATHEMATICS") & GRADE %in% 3:8]


###  Read in the Spring 2018 configuration code and combine into a single list.
source("../SGP_CONFIG/2017_2018/ELA.R")
source("../SGP_CONFIG/2017_2018/MATHEMATICS.R")
source("../SGP_CONFIG/2018_2019/ELA.R")
source("../SGP_CONFIG/2018_2019/MATHEMATICS.R")

IL_Skip_Year.configs <- c(
	ELA_2017_2018.config,
	MATHEMATICS_2017_2018.config,
	ALGEBRA_I_2017_2018.config,

	ELA_2018_2019.config,
	MATHEMATICS_2018_2019.config) # Only Grades 3-8 Math and ELA in 2019

### abcSGP

Illinois_SGP <- abcSGP(
		state="IL",
		sgp_object=Illinois_Data_LONG,
		sgp.config = IL_Skip_Year.configs,
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

Illinois_SGP@Data[, DIFF := SGP - NO_SKIP_SGP]
# Illinois_SGP@Data[, DIFF := SGP_ORDER_1 - NO_SKIP_SGP]

Illinois_SGP@Data[!is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, SCALE_SCORE_PRIOR_STANDARDIZED_NO_SKIP, use='pairwise.complete'), 2), nsmall = 2),
	SGP_Corr = format(round(cor(NO_SKIP_SGP, SGP, use='pairwise.complete'), 2), nsmall = 2),
	SGP_Corr_2 = format(round(cor(NO_SKIP_SGP, SGP_ORDER_1, use='pairwise.complete'), 2), nsmall = 2),
	Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  N_Size = sum(!is.na(SGP))), keyby = list(YEAR, CONTENT_AREA, GRADE)]

table(Illinois_SGP@Data[!is.na(NO_SKIP_SGP), is.na(SGP), YEAR])
table(Illinois_SGP@Data[YEAR == "2018_2019", !is.na(NO_SKIP_SGP), !is.na(SGP)])

added <- Illinois_SGP@Data[YEAR  %in% c("2017_2018", "2018_2019") & is.na(NO_SKIP_SGP) & !is.na(SGP),] # 15,888 that have SGPs now
dim(added)
table(added[, YEAR, as.character(SGP_NORM_GROUP)])

missing <- Illinois_SGP@Data[YEAR %in% c("2017_2018", "2018_2019") & !is.na(NO_SKIP_SGP) & is.na(SGP),] # 310,709 fewer SGPs produced (mostly 4th grade)
dim(missing)
table(missing[, YEAR, as.character(NO_SKIP_SGP_NORM_GROUP)]) # Kids with only single prior
