################################################################################
###                                                                          ###
###   STEP 2: SGP baseline analyses for skip year simulation: 2017 to 2019   ###
###           Baseline SGP Matrices for Georgia 2021 Contingency Plan        ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load data
load("./Data/Georgia_Data_LONG_NO_SKIP.Rdata") # From Skip_Year_Analysis/Georgia_Data_LONG.R
Georgia_Data_LONG <- Georgia_Data_LONG_NO_SKIP[SCHOOL_YEAR != "2019",
												list(VALID_CASE, GTID, SCHOOL_YEAR, SUBJECT_CODE, YEAR_WITHIN, GRADE, SCALE_SCORE, CONDSEM, PERFORMANCE_LEVEL)]

###   Read in Baseline SGP Configuration Scripts and Combine
source("/SGP_CONFIG/BASELINE/ELA.R")
source("/SGP_CONFIG/BASELINE/MATHEMATICS.R")

GA.Baseline.config <- c(
	ELA_BASELINE.config,
	GRADE_9_LIT_BASELINE.config,
	AMERICAN_LIT_BASELINE.config,

	MATHEMATICS_BASELINE.config,
	ALGEBRA_I_BASELINE.config,
	GEOMETRY_BASELINE.config,
	COORDINATE_ALGEBRA_BASELINE.config,
	ANALYTIC_GEOMETRY_BASELINE.config
)

###
###    baselineSGP - To produce uncorrected and SIMEX baseline matrices
###

Georgia_SGP <- prepareSGP(Georgia_Data_LONG, create.additional.variables=FALSE)

Georgia_SGP@Data[, VC_COMPLETE := VALID_CASE]


setkeyv(Georgia_SGP@Data, SGP:::getKey(Georgia_SGP@Data))
setkey(Georgia_SGP@Data, VALID_CASE, CONTENT_AREA, ID, GRADE, YEAR_WITHIN)
dups <- data.table(Georgia_SGP@Data[unique(c(which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data)))-1, which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data))))), ], key=key(Georgia_SGP@Data))
table(dups$VALID_CASE) # 3111 duplicates within GRADE are already INVALID_CASEs - 181012 still VALID_CASEs
table(dups[VALID_CASE=="VALID_CASE", YEAR, CONTENT_AREA])
table(dups[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), YEAR, GRADE])
Georgia_SGP@Data[which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data)))-1, VALID_CASE := "INVALID_CASE"]
# Georgia_SGP@Data[!CONTENT_AREA %in% c("ELA", "MATHEMATICS"), VALID_CASE := VC_COMPLETE] #  Only dups in ELA/Math should be excluded

###   Might need to re-think YEAR_WITHIN in the context of baselineSGPs...  Baseline on first/last observation?  Do repeaters manually outside baselineSGP?
###   Add in a prepareSGP call in baselineSGP to re-work FIRST/LAST_OBSERVATION? Run without this next invalidation chunk to get error/data stack...
###   Repeaters with 3 (or more records)
setkeyv(Georgia_SGP@Data, SGP:::getKey(Georgia_SGP@Data))
setkey(Georgia_SGP@Data, VALID_CASE, CONTENT_AREA, ID, GRADE)
dups <- data.table(Georgia_SGP@Data[unique(c(which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data)))-1, which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data))))), ], key=key(Georgia_SGP@Data))
table(dups$VALID_CASE) # 3111 duplicates within GRADE are already INVALID_CASEs - 181012 still VALID_CASEs
table(dups[VALID_CASE=="VALID_CASE", YEAR, CONTENT_AREA])
Georgia_SGP@Data[which(duplicated(Georgia_SGP@Data, by=key(Georgia_SGP@Data)))-1, VALID_CASE := "INVALID_CASE"]

Georgia_SGP <- prepareSGP(Georgia_SGP, create.additional.variables=FALSE) # to re-do FIRST/LAST_OBSERVATION if necessary

table(Georgia_SGP@Data[, VALID_CASE, VC_COMPLETE])


GA_Skip_Year_Baseline_Matrices <- baselineSGP(
	Georgia_SGP,
	sgp.baseline.config=GA.Baseline.config,
	return.matrices.only=TRUE,
	calculate.baseline.sgps=FALSE,
	calculate.simex.baseline=list(csem.data.vnames="SCALE_SCORE_CSEM", lambda=seq(0,2,0.5), simulation.iterations=75, # 25,
																simex.sample.size=10000, extrapolation="linear", save.matrices=TRUE, use.cohort.for.ranking=TRUE), # simex.sample.size=2000
	###
	# sgp.test.cohort.size = 10000, # comment out for full run
	###
	sgp.cohort.size=1500,
	goodness.of.fit.print=FALSE,
	parallel.config=list(BACKEND="PARALLEL", WORKERS=list(TAUS=25, SIMEX=25)))

save(GA_Skip_Year_Baseline_Matrices, file="Data/GA_Skip_Year_Baseline_Matrices.Rdata")
