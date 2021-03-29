###########################################################
###
### Rhode Island SGP Analysis for the calculate of one year's growth
###
###########################################################

### Load SGP Package

require(SGP)
#debug(SGP:::getsplineMatrices)
#debug(studentGrowthProjections)

### Load 2019 RICAS data (2016-2017 data has been converted from PARCC to RICAS scale)

load("Data/Rhode_Island_RICAS_Data_LONG.Rdata")


### Modify SGPstateData

SGPstateData[["RI"]][["Achievement"]][["Cutscores"]] <- list(
	ELA =list(
		GRADE_3=c(470, 500, 530), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_4=c(470, 500, 530), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_5=c(470, 500, 530), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_6=c(470, 500, 530), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_7=c(470, 500, 530), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_8=c(470, 500, 530)), # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
	MATHEMATICS=list(
		GRADE_3=c(470, 500, 530),  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_4=c(470, 500, 530),  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_5=c(470, 500, 530),  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_6=c(470, 500, 530),  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_7=c(470, 500, 530),  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas
		GRADE_8=c(470, 500, 530)))  # c(470, 500, 530), # RICAS Scale Score Cuts for all grades/content areas

SGPstateData[["RI"]][["Growth"]][["Cutscores"]] <- list(
	Cuts=c(15, 20, 25, 30, 35, 50, 60, 70, 80, 90),
	Labels=c("1st - 14th", "15th - 19th", "20th - 24th", "25th - 29th", "30th - 34th", "35th - 49th", "50th - 59th", "60th - 69th", "70th - 79th", "80th - 89th", "90th - 99th"))

tmp.knots.boundaries <- createKnotsBoundaries(Rhode_Island_RICAS_Data_LONG)
SGPstateData[["RI"]][["Achievement"]][["Knots_Boundaries"]] <- tmp.knots.boundaries

SGPstateData[["RI"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL

SGPstateData[["RI"]][["SGP_Configuration"]] <- NULL
SGPstateData[["RI"]][["SGP_Configuration"]][["return.norm.group.scale.scores"]] <- TRUE
SGPstateData[["RI"]][["SGP_Configuration"]][["percentile.cuts"]] <- c(1,15,20,25,30,35,50,60,70,80,90,99)
SGPstateData[["RI"]][["SGP_Configuration"]][["sgp.target.scale.scores.merge"]] <- "all_years_lagged_current"

### abcSGP

Rhode_Island_RICAS_SGP <- abcSGP(
			Rhode_Island_RICAS_Data_LONG,
			years="2018_2019",
			steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
			state="RI",
			sgp.percentiles=TRUE,
			sgp.projections=TRUE,
			sgp.projections.lagged=TRUE,
			sgp.percentiles.baseline=FALSE,
			sgp.projections.baseline=FALSE,
			sgp.projections.lagged.baseline=FALSE,
			save.intermediate.results=FALSE,
			sgp.target.scale.scores=TRUE,
			parallel.config=list(BACKEND="PARALLEL", WORKERS=list(PERCENTILES=4)))


### Save results

save(Rhode_Island_RICAS_SGP, file="Data/Rhode_Island_RICAS_SGP.Rdata")
