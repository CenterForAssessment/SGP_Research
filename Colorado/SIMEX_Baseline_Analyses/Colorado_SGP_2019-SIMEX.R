################################################################################
###                                                                          ###
###  Calculate CMAS SIMEX (2017-2019) and Baseline (2019) SGPs for Colorado  ###
###                                                                          ###
################################################################################

require(SGP)
require(data.table)

load("Data/Colorado_Data_LONG.rda")


##########
#####        SIMEX SGPs Only, 2017 & 2018
##########

###   Make changes to SGPstateData
SGPstateData[["CO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 2
SGPstateData[["CO"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["CO"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE

###    abcSGP - To produce CMAS SG Percentiles with SIMEX Only
Colorado_SGP <- abcSGP(
		sgp_object=Colorado_Data_LONG[YEAR %in% 2015:2018],
    years=c("2017", "2018"),
		content_areas=c("ELA", "MATHEMATICS"),
		steps=c("prepareSGP", "analyzeSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = TRUE,
		sgp.projections.lagged = TRUE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
    calculate.simex = TRUE,
		simulate.sgps = TRUE,
		# sgp.target.scale.scores = TRUE,
		# outputSGP.output.type= "LONG_Data", # c("LONG_FINAL_YEAR_Data"),
		save.intermediate.results=FALSE,
    parallel.config = list(
      BACKEND="FOREACH",
      TYPE="doParallel",
      WORKERS=list(TAUS=8, SIMEX=8)))

###  Save Colorado SGP object with 2017 & 2018 SIMEX SGPs
save(Colorado_SGP, file="Data/Colorado_SGP.Rdata")


##########
#####        BASELINE & SIMEX SGPs
##########

###  Invalidate first cases of repeater students

setkey(Colorado_SGP@Data, VALID_CASE, CONTENT_AREA, ID, GRADE, YEAR)
setkey(Colorado_SGP@Data, VALID_CASE, CONTENT_AREA, ID, GRADE)
dups <- data.table(Colorado_SGP@Data[unique(c(which(duplicated(Colorado_SGP@Data, by=key(Colorado_SGP@Data)))-1, which(duplicated(Colorado_SGP@Data, by=key(Colorado_SGP@Data))))), ], key=key(Colorado_SGP@Data))
table(dups$VALID_CASE) # 1145 duplicates within GRADE are already INVALID_CASEs - 8888 still VALID_CASEs
Colorado_SGP@Data[which(duplicated(Colorado_SGP@Data, by=key(Colorado_SGP@Data)))-1, VALID_CASE := "INVALID_CASE"]

table(Colorado_SGP@Data[, VALID_CASE, VC_ORIG])

Colorado_SGP@Data <- rbindlist(list(Colorado_SGP@Data, Colorado_Data_LONG[YEAR == 2019]), fill = TRUE)
setkeyv(Colorado_SGP@Data, SGP:::getKey(Colorado_SGP@Data))


###   Make changes to SGPstateData
SGPstateData[["CO"]][["SGP_Configuration"]][["max.order.for.percentile"]] <- 2
SGPstateData[["CO"]][["SGP_Configuration"]][["max.order.for.projection"]] <- 3 # Force uncorrected to match SIMEX
SGPstateData[["CO"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["CO"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE
SGPstateData[["CO"]][["Growth"]][["System_Type"]] <- "Cohort and Baseline Referenced"


###		Calculate SIMEX/Baseline SGPs for CMAS Content Areas
	Colorado_SGP <- analyzeSGP(
		Colorado_SGP,
		years="2019",
		content_areas=c("ELA", "MATHEMATICS"),
		sgp.percentiles=TRUE,
		sgp.projections=TRUE,
		sgp.projections.lagged=TRUE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline=TRUE,
		sgp.projections.lagged.baseline=TRUE,
		sgp.baseline.panel.years=c("2015", "2016", "2017", "2018"),
		simulate.sgps = TRUE,
    calculate.simex=list(csem.data.vnames="SCALE_SCORE_CSEM", lambda=seq(0,2,0.5), simulation.iterations=75,
                                  simex.sample.size=5000, extrapolation="linear", save.matrices=TRUE),
		calculate.simex.baseline=list(csem.data.vnames="SCALE_SCORE_CSEM", lambda=seq(0,2,0.5), simulation.iterations=75,
                                  simex.sample.size=10000, extrapolation="linear", save.matrices=TRUE, use.cohort.for.ranking=TRUE),
    parallel.config = list(
        BACKEND="FOREACH",
        TYPE="doParallel",
        WORKERS=list(TAUS=8, SIMEX=8))
  )

names(Colorado_SGP@SGP[[1]][["ELA.BASELINE.SIMEX"]][[2]])
names(Colorado_SGP@SGP[[5]][["ELA.2019.BASELINE"]])

Colorado_SGP@Data[, VC_BASELINE := VALID_CASE]
Colorado_SGP@Data[, VALID_CASE := VC_ORIG]
setkeyv(Colorado_SGP@Data, SGP:::getKey(Colorado_SGP@Data))

Colorado_SGP <- combineSGP(Colorado_SGP,
                    sgp.target.scale.scores = TRUE,
                    parallel.config = list(
                      BACKEND="PARALLEL",
                      WORKERS=list(SGP_SCALE_SCORE_TARGETS=2)))

###  Save 2019 Colorado SGP object
save(Colorado_SGP, file="./Data/Colorado_SGP.Rdata")


###   Clean up unecessary variables and order for output

table(Colorado_SGP@Data[, YEAR, SGP==ORIG])
table(Colorado_SGP@Data[, YEAR, SGP_ORDER_1==ORIG_ORDER_1])
table(Colorado_SGP@Data[, YEAR, SGP_ORDER_2==ORIG_ORDER_2])

table(Colorado_SGP@Data[YEAR=='2017' & SGP!=ORIG, as.character(SGP_NORM_GROUP)]) # Not sure why some of these changed...

Colorado_SGP@Data[, grep("PERCENTILE_CUT", names(Colorado_SGP@Data), value=TRUE) := NULL]
Colorado_SGP@Data[, grep("CURRENT", names(Colorado_SGP@Data), value=TRUE) := NULL]
Colorado_SGP@Data[, ORIG_PROJECTION_GROUP_SCALE_SCORES := NULL]
Colorado_SGP@Data[, GRADE_REPORTED := NULL] # Same as GRADE for CMAS
Colorado_SGP@Data[, PREFERENCE := NULL]
Colorado_SGP@Data[, ORIG_NOTE := NULL]
Colorado_SGP@Data[, VC_ORIG := NULL]

table(Colorado_SGP@Data[!is.na(SGP_NORM_GROUP_BASELINE), as.character(SGP_NORM_GROUP_BASELINE) == as.character(SGP_NORM_GROUP)]) #  All 3 below are identical due to analysis design
Colorado_SGP@Data[, SGP_NORM_GROUP_BASELINE_SCALE_SCORES := NULL]
Colorado_SGP@Data[, SGP_NORM_GROUP_BASELINE := NULL]
Colorado_SGP@Data[, SGP_BASELINE_ORDER := NULL]

table(Colorado_SGP@Data[!is.na(SGP_TARGET_BASELINE_3_YEAR_CONTENT_AREA), SGP_TARGET_3_YEAR_CONTENT_AREA, SGP_TARGET_BASELINE_3_YEAR_CONTENT_AREA]) # Different -- keep
Colorado_SGP@Data[, SGP_TARGET_BASELINE_3_YEAR_CONTENT_AREA := NULL]

table(Colorado_SGP@Data[!is.na(SGP_LEVEL_BASELINE), SGP_LEVEL, SGP_LEVEL_BASELINE]) # Different -- keep
table(Colorado_SGP@Data[!is.na(CATCH_UP_KEEP_UP_STATUS_BASELINE_3_YEAR), CATCH_UP_KEEP_UP_STATUS_3_YEAR, CATCH_UP_KEEP_UP_STATUS_BASELINE_3_YEAR]) # Different -- keep

variable.order <- c(
  'VALID_CASE', 'VC_BASELINE', 'ID', 'LAST_NAME', 'FIRST_NAME', 'YEAR', 'CONTENT_AREA', 'GRADE',
  'SCALE_SCORE', 'SCALE_SCORE_CSEM', 'ACHIEVEMENT_LEVEL',
  'SCALE_SCORE_PRIOR', 'SCALE_SCORE_PRIOR_STANDARDIZED', 'ACHIEVEMENT_LEVEL_PRIOR',
  'TEST_FORMAT', 'FPRC_SUMM_SCORE_REC_UUID', 'FPRC_KEY', 'FSAT_KEY',
  'GENDER', 'ETHNICITY', 'FREE_REDUCED_LUNCH_STATUS', 'ELL_STATUS', 'IEP_STATUS', 'GIFTED_TALENTED_PROGRAM_STATUS',
  'EMH_LEVEL', 'SCHOOL_NAME', 'SCHOOL_NUMBER', 'DISTRICT_NAME', 'DISTRICT_NUMBER',
  'SCHOOL_ENROLLMENT_STATUS', 'DISTRICT_ENROLLMENT_STATUS', 'STATE_ENROLLMENT_STATUS',

  'SGP_LEVEL', 'SGP_NORM_GROUP', 'SGP_NORM_GROUP_SCALE_SCORES', 'SGP_ORDER',
  'SGP', 'SGP_ORDER_1', 'SGP_ORDER_2',
  'SGP_SIMEX', 'SGP_SIMEX_ORDER_1', 'SGP_SIMEX_ORDER_2',
  'SGP_SIMEX_RANKED', 'SGP_SIMEX_RANKED_ORDER_1', 'SGP_SIMEX_RANKED_ORDER_2',

  'SGP_LEVEL_BASELINE',
  'SGP_BASELINE', 'SGP_BASELINE_ORDER_1', 'SGP_BASELINE_ORDER_2',
  'SGP_SIMEX_BASELINE', 'SGP_SIMEX_BASELINE_ORDER_1', 'SGP_SIMEX_BASELINE_ORDER_2',
  'SGP_SIMEX_BASELINE_RANKED', 'SGP_SIMEX_BASELINE_RANKED_ORDER_1', 'SGP_SIMEX_BASELINE_RANKED_ORDER_2',

  'SGP_STANDARD_ERROR', 'SGP_ORDER_1_STANDARD_ERROR', 'SGP_ORDER_2_STANDARD_ERROR',
  'SGP_BASELINE_STANDARD_ERROR', 'SGP_BASELINE_ORDER_1_STANDARD_ERROR', 'SGP_BASELINE_ORDER_2_STANDARD_ERROR',

  'SGP_PROJECTION_GROUP', 'SGP_TARGET_3_YEAR_CONTENT_AREA',
  'SGP_TARGET_3_YEAR', 'SGP_TARGET_MOVE_UP_STAY_UP_3_YEAR',
  'CATCH_UP_KEEP_UP_STATUS_3_YEAR', 'MOVE_UP_STAY_UP_STATUS_3_YEAR',

  'SGP_TARGET_BASELINE_3_YEAR', 'SGP_TARGET_BASELINE_MOVE_UP_STAY_UP_3_YEAR',
  'CATCH_UP_KEEP_UP_STATUS_BASELINE_3_YEAR', 'MOVE_UP_STAY_UP_STATUS_BASELINE_3_YEAR',

  'ORIG_LEVEL', 'ORIG_NORM_GROUP', 'ORIG_NORM_GROUP_SCALE_SCORES', 'ORIG_ORDER',
  'ORIG', 'ORIG_ORDER_1', 'ORIG_ORDER_2', 'ORIG_ORDER_3',
  'ORIG_PROJECTION_GROUP', 'ORIG_TARGET_3_YEAR_CONTENT_AREA',
  'ORIG_TARGET_3_YEAR', 'ORIG_TARGET_MOVE_UP_STAY_UP_3_YEAR',
  'CATCH_UP_KEEP_UP_STATUS_3_YEAR_ORIG', 'MOVE_UP_STAY_UP_STATUS_3_YEAR_ORIG'
)

setcolorder(Colorado_SGP@Data, variable.order)

outputSGP(Colorado_SGP, output.type=c("LONG_Data"))
