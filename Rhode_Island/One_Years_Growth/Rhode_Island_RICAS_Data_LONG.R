####################################################################################
###
### Take LONG data and prep a RICAS only data file
###
####################################################################################

### Load packages

require(data.table)
require(SGP)


### Load data

load("Data/Rhode_Island_SGP_LONG_Data.Rdata")


### Filter out correct years and variables and stack data sets

variables.to.keep <- c("VALID_CASE", "YEAR", "CONTENT_AREA", "GRADE", "ID", "SCALE_SCORE", "SCALE_SCORE_CSEM", "DISTRICT_NUMBER", "DISTRICT_NAME",
                        "SCHOOL_NUMBER", "SCHOOL_NAME", "TEST_FORMAT", "FIRST_NAME", "LAST_NAME", "GENDER", "GRADE_ENROLLED",
                        "ETHNICITY", "ELL_STATUS", "GIFTED_AND_TALENTED_STATUS", "MIGRANT_STATUS", "FREE_REDUCED_LUNCH_STATUS",
                        "IEP_STATUS", "DISABILITY_TYPE", "SCALE_SCORE_THETA", "ACHIEVEMENT_LEVEL", "STATE_ENROLLMENT_STATUS",
                        "DISTRICT_ENROLLMENT_STATUS", "SCHOOL_ENROLLMENT_STATUS", "VALID_CASE", "EMH_LEVEL", "MIDDLE_INITIAL",
                        "SCALE_SCORE_ACTUAL", "SCALE_SCORE_ACTUAL_CSEM", "FORM_CODE")

Rhode_Island_RICAS_Data_LONG <- Rhode_Island_SGP_LONG_Data[YEAR >= "2017_2018" & GRADE %in% as.character(3:8)][,variables.to.keep, with=FALSE]
tmp.2016_2017 <- Rhode_Island_SGP_LONG_Data[YEAR=="2016_2017" & GRADE %in% as.character(3:8)][,variables.to.keep, with=FALSE]


Rhode_Island_RICAS_Data_LONG[,SCALE_SCORE:=SCALE_SCORE_ACTUAL]
Rhode_Island_RICAS_Data_LONG[,SCALE_SCORE_CSEM:=SCALE_SCORE_ACTUAL_CSEM]
Rhode_Island_RICAS_Data_LONG[,c("SCALE_SCORE_ACTUAL", "SCALE_SCORE_ACTUAL_CSEM", "SCALE_SCORE_THETA"):=NULL]
tmp.2016_2017[,c("SCALE_SCORE_ACTUAL", "SCALE_SCORE_ACTUAL_CSEM", "SCALE_SCORE_THETA"):=NULL]

Rhode_Island_RICAS_Data_LONG <- rbindlist(list(tmp.2016_2017, Rhode_Island_RICAS_Data_LONG))
Rhode_Island_RICAS_Data_LONG[,SCALE_SCORE_ORIGINAL:=SCALE_SCORE]
setkey(Rhode_Island_RICAS_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)


### Put 2016_2017 scores on 2017_2018 scale using equate SGP.

SGPstateData[["RI"]][["Assessment_Program_Information"]][["Assessment_Transition"]][["Year"]] <- "2017_2018"

data.for.equate <- Rhode_Island_RICAS_Data_LONG[YEAR <= "2017_2018"]
tmp.equate.linkages <- SGP:::equateSGP(
                                tmp.data=data.for.equate,
                                state="RI",
                                current.year="2017_2018",
                                equating.method=c("identity", "mean", "linear", "equipercentile"))

setkey(data.for.equate, VALID_CASE, CONTENT_AREA, YEAR, GRADE, SCALE_SCORE)

data.for.equate <- SGP:::convertScaleScore(data.for.equate, "2017_2018", tmp.equate.linkages, "OLD_TO_NEW", "equipercentile", "RI")
data.for.equate[YEAR=="2016_2017", SCALE_SCORE:=SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW]
data.for.equate[,SCALE_SCORE_EQUATED_EQUIPERCENTILE_OLD_TO_NEW:=NULL]

Rhode_Island_RICAS_Data_LONG <- rbindlist(list(data.for.equate, Rhode_Island_RICAS_Data_LONG[YEAR=="2018_2019"]))
setkey(Rhode_Island_RICAS_Data_LONG, VALID_CASE, CONTENT_AREA, YEAR, ID)



### Save results

save(Rhode_Island_RICAS_Data_LONG, file="Data/Rhode_Island_RICAS_Data_LONG.Rdata")
