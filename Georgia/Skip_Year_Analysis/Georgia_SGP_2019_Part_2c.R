################################################################################
###                                                                          ###
###  STEP 5: SGP lagged projections for skip year analysis: 2017 to 2019 Part 2c
###          "Augmented" cohort referenced and traditional baseline referenced
###                                                                          ###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Georgia_SGP-2019_Part_2b.Rdata")
load("Data/GA_Skip_Year_Baseline_Matrices.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2c/ELA.R")
source("SGP_CONFIG/2019_PART_2c/MATHEMATICS.R")

GA_2019_PART_2c.config <- c(
  MATHEMATICS_2019.config,
  COORDINATE_ALGEBRA_2019.config,
	ANALYTIC_GEOMETRY_2019.config,
	ALGEBRA_I_2019.config,
	GEOMETRY_2019.config,

  ELA_2019.config,
  GRADE_9_LIT_2019.config,
  AMERICAN_LIT_2019.config
)


### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["GA"]][["Growth"]][["System_Type"]] <- "Cohort and Baseline Referenced"
SGPstateData[["GA"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- GA_Skip_Year_Baseline_Matrices
SGPstateData[["GA"]][["SGP_Configuration"]][["Skip_Year_Projections"]] <- TRUE

SGPstateData[["GA"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    ELA_GRADE_3=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_4=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_5=c(3, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_6=c(3, 4, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_7=c(3, 4, 5, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_8=c(3, 4, 5, 6, 8, "EOCT", "EOCT"),
    GRADE_9_LIT_GRADE_EOCT=c(3, 4, 5, 6, 7, "EOCT", "EOCT"),
    AMERICAN_LIT_GRADE_EOCT=c(3, 4, 5, 6, 7, 8, "EOCT"),

    MATHEMATICS_GRADE_3=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_4=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_5=c(3, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_6=c(3, 4, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_7=c(3, 4, 5, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_8=c(3, 4, 5, 6, 8, "EOCT", "EOCT"),
    MATH_COORD_ALG_GRADE_8=c(3, 4, 5, 6, 8, "EOCT", "EOCT"),
    COORDINATE_ALGEBRA_GRADE_EOCT= c(3, 4, 5, 6, 7, "EOCT", "EOCT"),
    ANALYTIC_GEOMETRY_GRADE_EOCT = c(3, 4, 5, 6, 7, 8, "EOCT"),
    ALGEBRA_I_GRADE_EOCT=c(3, 4, 5, 6, 7, "EOCT", "EOCT"),
    GEOMETRY_GRADE_EOCT =c(3, 4, 5, 6, 7, 8, "EOCT"))

SGPstateData[["GA"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    ELA_GRADE_3=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_4=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_5=c(rep("ELA", 5), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_6=c(rep("ELA", 5), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_7=c(rep("ELA", 5), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_8=c(rep("ELA", 5), "GRADE_9_LIT", "AMERICAN_LIT"),
    GRADE_9_LIT_GRADE_EOCT=c(rep("ELA", 5), "GRADE_9_LIT", "AMERICAN_LIT"),
    AMERICAN_LIT_GRADE_EOCT=c(rep("ELA", 6), "AMERICAN_LIT"),

    MATHEMATICS_GRADE_3=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_4=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_5=c(rep("MATHEMATICS", 5), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_6=c(rep("MATHEMATICS", 5), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_7=c(rep("MATHEMATICS", 5), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_8=c(rep("MATHEMATICS", 5), "ALGEBRA_I", "GEOMETRY"),
    MATH_COORD_ALG_GRADE_8=c(rep("MATHEMATICS", 5), "COORDINATE_ALGEBRA", "ANALYTIC_GEOMETRY"),
    COORDINATE_ALGEBRA_GRADE_EOCT= c(rep("MATHEMATICS", 5), "COORDINATE_ALGEBRA", "ANALYTIC_GEOMETRY"),
    ANALYTIC_GEOMETRY_GRADE_EOCT = c(rep("MATHEMATICS", 6), "ANALYTIC_GEOMETRY"),
    ALGEBRA_I_GRADE_EOCT=c(rep("MATHEMATICS", 5), "ALGEBRA_I", "GEOMETRY"),
    GEOMETRY_GRADE_EOCT= c(rep("MATHEMATICS", 6), "GEOMETRY"))

  SGPstateData[["GA"]][["SGP_Configuration"]][["year_lags.projection.sequence"]] <- list(
		ELA_GRADE_3 = c(rep(1L, 6), 2),
		ELA_GRADE_4 = c(rep(1L, 6), 2),
		ELA_GRADE_5 = c(2, 1, 1, 1, 1, 2),
		ELA_GRADE_6 = c(1, 2, 1, 1, 1, 2),
		ELA_GRADE_7 = c(1, 1, 2, 1, 1, 2),
		ELA_GRADE_8 = c(1, 1, 1, 2, 1, 2),
		GRADE_9_LIT_GRADE_EOCT= c(rep(1L, 4), 2, 2),
		AMERICAN_LIT_GRADE_EOCT=c(rep(1L, 5), 3),

		MATHEMATICS_GRADE_3 = rep(1L, 7),
		MATHEMATICS_GRADE_4 = rep(1L, 7),
		MATHEMATICS_GRADE_5 = c(2, 1, 1, 1, 1, 1),
		MATHEMATICS_GRADE_6 = c(1, 2, 1, 1, 1, 1),
		MATHEMATICS_GRADE_7 = c(1, 1, 2, 1, 1, 1),
		MATHEMATICS_GRADE_8 = c(1, 1, 1, 2, 1, 1),
	 MATH_COORD_ALG_GRADE_8=c(1, 1, 1, 2, 1, 1),
		COORDINATE_ALGEBRA_GRADE_EOCT=c(1, 1, 1, 1, 2, 1),
		ANALYTIC_GEOMETRY_GRADE_EOCT =c(1, 1, 1, 1, 1, 2),
		ALGEBRA_I_GRADE_EOCT=c(1, 1, 1, 1, 2, 1),
		GEOMETRY_GRADE_EOCT= c(1, 1, 1, 1, 1, 2))

  SGPstateData[["GA"]][["SGP_Configuration"]][["max.forward.projection.sequence"]] <- list(
		ELA_GRADE_3 = 3,
		ELA_GRADE_4 = 3,
		ELA_GRADE_5 = 3,
		ELA_GRADE_6 = 3,
		ELA_GRADE_7 = 3,
		ELA_GRADE_8 = 3,
		GRADE_9_LIT_GRADE_EOCT = 3,
		AMERICAN_LIT_GRADE_EOCT = 3,

		MATHEMATICS_GRADE_3 = 3,
		MATHEMATICS_GRADE_4 = 3,
		MATHEMATICS_GRADE_5 = 3,
		MATHEMATICS_GRADE_6 = 3,
		MATHEMATICS_GRADE_7 = 3,
		MATHEMATICS_GRADE_8 = 3,
		MATH_COORD_ALG_GRADE_8 = 3,
		COORDINATE_ALGEBRA_GRADE_EOCT = 3,
		ANALYTIC_GEOMETRY_GRADE_EOCT = 3,
		ALGEBRA_I_GRADE_EOCT = 3,
		GEOMETRY_GRADE_EOCT = 3)


### Run analysis

Georgia_SGP <- abcSGP(
                  Georgia_SGP,
                  steps=c("prepareSGP", "analyzeSGP", "combineSGP", "outputSGP"),
                  sgp.config=GA_2019_PART_2c.config,
                  sgp.percentiles=FALSE,
                  sgp.projections=FALSE,
                  sgp.projections.lagged=TRUE,
                  sgp.percentiles.baseline=FALSE,
                  sgp.projections.baseline=FALSE,
                  sgp.projections.lagged.baseline=TRUE,
                  # sgp.target.scale.scores=TRUE,  ###  XXX  Needed?
                  goodness.of.fit.print=FALSE,
                  outputSGP.output.type=c("LONG_Data", "LONG_FINAL_YEAR_Data"),
                  parallel.config = list(
                    BACKEND="PARALLEL",
                    WORKERS=list(LAGGED_PROJECTIONS = 4)))


### Save results

save(Georgia_SGP, file="Data/Georgia_SGP-2019_PART_2c.Rdata")


#####
###   Rename variables as 'NO_SKIP_SGP' (Official data reported by GDOE)
#####

Georgia_SGP@Data[[68]] <- NULL # Duplicate "NO_SKIP" variable that's blank?

original.names <- grep("NO_SKIP", names(Georgia_SGP@Data), value=TRUE)
new.names <- gsub("NO_SKIP", "NO_SKIP_SGP", original.names)
new.names[grep("_NO_SKIP", original.names)] <- paste0("NO_SKIP_SGP_", gsub("_NO_SKIP", "", grep("_NO_SKIP", original.names, value=TRUE)))
setnames(Georgia_SGP@Data, original.names, new.names)

outputSGP(Georgia_SGP, output.type=c("LONG_Data", "LONG_FINAL_YEAR_Data"))
save(Georgia_SGP, file="Data/Georgia_SGP-2019_PART_2c.Rdata")


#####
###   Quick descriptives
#####

Georgia_SGP@Data$DIFF<- as.numeric(NA)
Georgia_SGP@Data[, DIFF := SGP - NO_SKIP_SGP]

Georgia_SGP@Data[YEAR == '2019' & !is.na(SGP) & VALID_CASE=='VALID_CASE'][, list(
  Test_Scores = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  SGP_Corr = format(round(cor(NO_SKIP_SGP, SGP, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  Corr_N = sum(!is.na(SGP) & !is.na(NO_SKIP_SGP))), keyby = list(CONTENT_AREA, GRADE)]
