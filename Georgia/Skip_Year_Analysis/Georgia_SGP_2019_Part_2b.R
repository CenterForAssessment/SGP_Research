################################################################################
###                                                                          ###
###  STEP 4: SGP straight projections for skip year analysis: 2017 to 2019 Part 2b
###          "Augmented" cohort referenced and traditional baseline referenced
###                                                                          ###
################################################################################

### Load packages
require(SGP)

### Load data
load("Data/Georgia_SGP-2019_Part_1.Rdata")
load("Data/GA_Skip_Year_Baseline_Matrices.Rdata")

### Load configurations
source("SGP_CONFIG/2019_PART_2b/ELA.R")
source("SGP_CONFIG/2019_PART_2b/MATHEMATICS.R")

GA_2019_PART_2b.config <- c(
  MATHEMATICS_2019.config,
  ALGEBRA_I_2019.config,
  COORDINATE_ALGEBRA_2019.config,

  ELA_2019.config,
  GRADE_9_LIT_2019.config)


### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["GA"]][["Growth"]][["System_Type"]] <- "Cohort and Baseline Referenced"
SGPstateData[["GA"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- GA_Skip_Year_Baseline_Matrices
SGPstateData[["GA"]][["SGP_Configuration"]][["Skip_Year_Projections"]] <- TRUE

SGPstateData[["GA"]][["SGP_Configuration"]][["grade.projection.sequence"]] <- list(
    ELA_GRADE_3=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_4=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_5=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_6=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_7=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    ELA_GRADE_8=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		GRADE_9_LIT_GRADE_EOCT= c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		AMERICAN_LIT_GRADE_EOCT=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),

    MATHEMATICS_GRADE_3 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_4 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_5 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_6 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_7 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
    MATHEMATICS_GRADE_8 = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		MATH_COORD_ALG_GRADE_8=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		COORDINATE_ALGEBRA_GRADE_EOCT= c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		ANALYTIC_GEOMETRY_GRADE_EOCT = c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		ALGEBRA_I_GRADE_EOCT=c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"),
		GEOMETRY_GRADE_EOCT= c(3, 4, 5, 6, 7, 8, "EOCT", "EOCT"))

SGPstateData[["GA"]][["SGP_Configuration"]][["content_area.projection.sequence"]] <- list(
    ELA_GRADE_3=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_4=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_5=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_6=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_7=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
    ELA_GRADE_8=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
		GRADE_9_LIT_GRADE_EOCT= c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),
		AMERICAN_LIT_GRADE_EOCT=c(rep("ELA", 6), "GRADE_9_LIT", "AMERICAN_LIT"),

    MATHEMATICS_GRADE_3=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_4=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_5=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_6=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_7=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
    MATHEMATICS_GRADE_8=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
		MATH_COORD_ALG_GRADE_8=c(rep("MATHEMATICS", 6), "COORDINATE_ALGEBRA", "ANALYTIC_GEOMETRY"),
		COORDINATE_ALGEBRA_GRADE_EOCT= c(rep("MATHEMATICS", 6), "COORDINATE_ALGEBRA", "ANALYTIC_GEOMETRY"),
		ANALYTIC_GEOMETRY_GRADE_EOCT = c(rep("MATHEMATICS", 6), "COORDINATE_ALGEBRA", "ANALYTIC_GEOMETRY"),
		ALGEBRA_I_GRADE_EOCT=c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"),
		GEOMETRY_GRADE_EOCT= c(rep("MATHEMATICS", 6), "ALGEBRA_I", "GEOMETRY"))

	SGPstateData[["GA"]][["SGP_Configuration"]][["year_lags.projection.sequence"]] <- list(
		ELA_GRADE_3 = c(rep(1L, 6), 2),
		ELA_GRADE_4 = c(rep(1L, 6), 2),
		ELA_GRADE_5 = c(rep(1L, 6), 2),
		ELA_GRADE_6 = c(rep(1L, 6), 2),
		ELA_GRADE_7 = c(rep(1L, 6), 2),
		ELA_GRADE_8 = c(rep(1L, 6), 2),
		GRADE_9_LIT_GRADE_EOCT= c(rep(1L, 6), 2),
		AMERICAN_LIT_GRADE_EOCT=c(rep(1L, 6), 2),

		MATHEMATICS_GRADE_3=rep(1L, 7),
		MATHEMATICS_GRADE_4=rep(1L, 7),
		MATHEMATICS_GRADE_5=rep(1L, 7),
		MATHEMATICS_GRADE_6=rep(1L, 7),
		MATHEMATICS_GRADE_7=rep(1L, 7),
		MATHEMATICS_GRADE_8=rep(1L, 7),
		MATH_COORD_ALG_GRADE_8=rep(1L, 7),
		COORDINATE_ALGEBRA_GRADE_EOCT=rep(1L, 7),
		ANALYTIC_GEOMETRY_GRADE_EOCT= rep(1L, 7),
		ALGEBRA_I_GRADE_EOCT=rep(1L, 7),
		GEOMETRY_GRADE_EOCT= rep(1L, 7))

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

Georgia_SGP <- analyzeSGP(
  Georgia_SGP,
  sgp.config = GA_2019_PART_2b.config,
  sgp.percentiles = FALSE,
  sgp.projections = TRUE,
  sgp.projections.lagged = FALSE,
  sgp.percentiles.baseline = FALSE,
  sgp.projections.baseline = TRUE,
  sgp.projections.lagged.baseline = FALSE,
  goodness.of.fit.print=FALSE,
  parallel.config = list(
    BACKEND="PARALLEL", WORKERS=list(PROJECTIONS = 4)))

grep("2019", names(Georgia_SGP@SGP$SGProjections), value=T)

### Save results

save(Georgia_SGP, file="Data/Georgia_SGP-2019_Part_2b.Rdata")
