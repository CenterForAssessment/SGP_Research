###########################################################################
###
### Code for analysis and viaualization of a year's worth of growth
###
###########################################################################

### Load packages

require(SGP)
require(data.table)
require(RColorBrewer)


### Figure parameters

tmp.colors <- brewer.pal(10, "Spectral")
tmp.cuts <- c(470, 500, 530)
tmp.sequence <- seq(440, 560, by=2)


### Load data

load("Data/Rhode_Island_RICAS_SGP.Rdata")


### Create summary data set that will be used to curves

long.data <- copy(Rhode_Island_RICAS_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR=="2018_2019" & GRADE %in% as.character(4:8) & !is.na(SCALE_SCORE_PRIOR)])
summary.percentile.cut.data <- long.data[,.(PERCENTILE_CUT_15=mean(PERCENTILE_CUT_15, na.rm=TRUE),
                                            PERCENTILE_CUT_20=mean(PERCENTILE_CUT_20, na.rm=TRUE),
                                            PERCENTILE_CUT_25=mean(PERCENTILE_CUT_25, na.rm=TRUE),
                                            PERCENTILE_CUT_30=mean(PERCENTILE_CUT_30, na.rm=TRUE),
                                            PERCENTILE_CUT_35=mean(PERCENTILE_CUT_35, na.rm=TRUE),
                                            PERCENTILE_CUT_50=mean(PERCENTILE_CUT_50, na.rm=TRUE),
                                            PERCENTILE_CUT_60=mean(PERCENTILE_CUT_60, na.rm=TRUE),
                                            PERCENTILE_CUT_70=mean(PERCENTILE_CUT_70, na.rm=TRUE),
                                            PERCENTILE_CUT_80=mean(PERCENTILE_CUT_80, na.rm=TRUE),
                                            PERCENTILE_CUT_90=mean(PERCENTILE_CUT_90, na.rm=TRUE),
                                            MEAN_CATCH_UP_KEEP_UP_SCALE_SCORE=mean(SCALE_SCORE_SGP_TARGET_3_YEAR_PROJ_YEAR_1, na.rm=TRUE),
                                            PERCENT_CATCHING_UP=prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:2]),
                                            PERCENT_KEEPING_UP=prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[3:4]),
                                            PERCENT_CATCHING_UP_AND_KEEPING_UP=sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:4])),
                                            keyby=c("YEAR", "CONTENT_AREA", "GRADE", "SCALE_SCORE_PRIOR")]

summary.catch_up_keep_up.data <- long.data[,.(
                                        PERCENT_CATCHING_UP=100*prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_KEEPING_UP=100*prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_CATCHING_UP_AND_KEEPING_UP=100*sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA", "GRADE")]

summary.catch_up_keep_up.data.total <- long.data[,.(
                                        PERCENT_CATCHING_UP=100*prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_KEEPING_UP=100*prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_CATCHING_UP_AND_KEEPING_UP=100*sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(CATCH_UP_KEEP_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA")]


####
#### Up One Level Stay Up
####

ELA.gain.one.level.target.data <- copy(Rhode_Island_RICAS_SGP@SGP$SGProjections$ELA.2018_2019.LAGGED)
MATHEMATICS.gain.one.level.target.data <- copy(Rhode_Island_RICAS_SGP@SGP$SGProjections$MATHEMATICS.2018_2019.LAGGED)

ELA.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=min(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=max(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=min(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=max(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=min(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=max(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]

ELA.gain.one.level.target.data <- ELA.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1]
ELA.gain.one.level.target.data <- ELA.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
ELA.gain.one.level.target.data <- ELA.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]
ELA.gain.one.level.target.data <- ELA.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]

MATHEMATICS.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=min(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=max(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=min(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=max(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=min(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=max(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]

MATHEMATICS.gain.one.level.target.data <- MATHEMATICS.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1]
MATHEMATICS.gain.one.level.target.data <- MATHEMATICS.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
MATHEMATICS.gain.one.level.target.data <- MATHEMATICS.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]
MATHEMATICS.gain.one.level.target.data <- MATHEMATICS.gain.one.level.target.data[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]

variables.to.keep <- c("VALID_CASE", "CONTENT_AREA", "YEAR", "ID", "GRADE", "SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR")
ELA.gain.one.level.target.data[,CONTENT_AREA:="ELA"]
ELA.gain.one.level.target.data[,YEAR:="2018_2019"]
ELA.gain.one.level.target.data[,VALID_CASE:="VALID_CASE"]
ELA.gain.one.level.target.data <- ELA.gain.one.level.target.data[,variables.to.keep, with=FALSE]

MATHEMATICS.gain.one.level.target.data[,CONTENT_AREA:="MATHEMATICS"]
MATHEMATICS.gain.one.level.target.data[,YEAR:="2018_2019"]
MATHEMATICS.gain.one.level.target.data[,VALID_CASE:="VALID_CASE"]
MATHEMATICS.gain.one.level.target.data <- MATHEMATICS.gain.one.level.target.data[,variables.to.keep, with=FALSE]

tmp.ALL.gain.one.level.target.data <- rbindlist(list(ELA.gain.one.level.target.data, MATHEMATICS.gain.one.level.target.data))
setkey(tmp.ALL.gain.one.level.target.data, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)



tmp.Data <- copy(Rhode_Island_RICAS_SGP@Data)

tmp.Data <- tmp.ALL.gain.one.level.target.data[tmp.Data]
tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: Yes"]
tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: No"]

tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: Yes"]
tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: No"]

tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: Yes"]
tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: No"]

tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: Yes"]
tmp.Data[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: No"]

summary.up_one_level_stay_up.data <- tmp.Data[,.(
                                        PERCENT_UP_ONE_LEVEL=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_STAYING_UP=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_UP_ONE_LEVEL_AND_STAYING_UP=100*sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA", "GRADE")]

summary.up_one_level_stay_up.data.total <- tmp.Data[,.(
                                        PERCENT_UP_ONE_LEVEL=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_STAYING_UP=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_UP_ONE_LEVEL_AND_STAYING_UP=100*sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA")]


####
#### Up One Level (Not Meets or Partially Meets) Stay Up (Meets or Exceeds)
####

ELA.gain.one.level.target.data.modified <- copy(Rhode_Island_RICAS_SGP@SGP$SGProjections$ELA.2018_2019.LAGGED)
MATHEMATICS.gain.one.level.target.data.modified <- copy(Rhode_Island_RICAS_SGP@SGP$SGProjections$MATHEMATICS.2018_2019.LAGGED)

ELA.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=min(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=max(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=min(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=max(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=min(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
ELA.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=max(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]

ELA.gain.one.level.target.data.modified <- ELA.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1]
ELA.gain.one.level.target.data.modified <- ELA.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
ELA.gain.one.level.target.data.modified <- ELA.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
ELA.gain.one.level.target.data.modified <- ELA.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]

MATHEMATICS.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=min(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1:=max(LEVEL_1_SGP_TARGET_YEAR_1, LEVEL_1_SGP_TARGET_YEAR_2, LEVEL_1_SGP_TARGET_YEAR_3, LEVEL_1_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=min(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2:=max(LEVEL_2_SGP_TARGET_YEAR_1, LEVEL_2_SGP_TARGET_YEAR_2, LEVEL_2_SGP_TARGET_YEAR_3, LEVEL_2_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data.modified[,MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=min(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]
MATHEMATICS.gain.one.level.target.data.modified[,MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3:=max(LEVEL_3_SGP_TARGET_YEAR_1, LEVEL_3_SGP_TARGET_YEAR_2, LEVEL_3_SGP_TARGET_YEAR_3, LEVEL_3_SGP_TARGET_YEAR_4, na.rm=TRUE), keyby="ID"]

MATHEMATICS.gain.one.level.target.data.modified <- MATHEMATICS.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_1]
MATHEMATICS.gain.one.level.target.data.modified <- MATHEMATICS.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MIN_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
MATHEMATICS.gain.one.level.target.data.modified <- MATHEMATICS.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Meeting", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_2]
MATHEMATICS.gain.one.level.target.data.modified <- MATHEMATICS.gain.one.level.target.data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding", SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR:=MAX_SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR_LEVEL_3]

variables.to.keep <- c("VALID_CASE", "CONTENT_AREA", "YEAR", "ID", "GRADE", "SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR")
ELA.gain.one.level.target.data.modified[,CONTENT_AREA:="ELA"]
ELA.gain.one.level.target.data.modified[,YEAR:="2018_2019"]
ELA.gain.one.level.target.data.modified[,VALID_CASE:="VALID_CASE"]
ELA.gain.one.level.target.data.modified <- ELA.gain.one.level.target.data.modified[,variables.to.keep, with=FALSE]

MATHEMATICS.gain.one.level.target.data.modified[,CONTENT_AREA:="MATHEMATICS"]
MATHEMATICS.gain.one.level.target.data.modified[,YEAR:="2018_2019"]
MATHEMATICS.gain.one.level.target.data.modified[,VALID_CASE:="VALID_CASE"]
MATHEMATICS.gain.one.level.target.data.modified <- MATHEMATICS.gain.one.level.target.data.modified[,variables.to.keep, with=FALSE]

tmp.ALL.gain.one.level.target.data.modified <- rbindlist(list(ELA.gain.one.level.target.data.modified, MATHEMATICS.gain.one.level.target.data.modified))
setkey(tmp.ALL.gain.one.level.target.data.modified, VALID_CASE, CONTENT_AREA, YEAR, GRADE, ID)



tmp.Data.modified <- copy(Rhode_Island_RICAS_SGP@Data)

tmp.Data.modified <- tmp.ALL.gain.one.level.target.data.modified[tmp.Data.modified]
tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: Yes"]
tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Not Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: No"]

tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: Yes"]
tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Partially Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Up One Level: No"]

tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Meeting" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: Yes"]
tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Meeting" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: No"]

tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding" & SGP >= SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: Yes"]
tmp.Data.modified[ACHIEVEMENT_LEVEL_PRIOR=="Exceeding" & SGP < SGP_TARGET_UP_ONE_LEVEL_STAY_UP_3_YEAR, UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR:="Stay Up: No"]

summary.up_one_level_stay_up.data.modified <- tmp.Data.modified[,.(
                                        PERCENT_UP_ONE_LEVEL=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_STAYING_UP=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_UP_ONE_LEVEL_AND_STAYING_UP=100*sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA", "GRADE")]

summary.up_one_level_stay_up.data.total.modified <- tmp.Data.modified[,.(
                                        PERCENT_UP_ONE_LEVEL=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[4]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[3:4]),
                                        PERCENT_STAYING_UP=100*prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[2]/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:2]),
                                        PERCENT_UP_ONE_LEVEL_AND_STAYING_UP=100*sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[c(2,4)])/sum(prop.table(table(UP_ONE_LEVEL_STAY_UP_STATUS_3_YEAR))[1:4])),
                                        keyby=c("YEAR", "CONTENT_AREA")]




### Create plots

for (content_area.iter in c("MATHEMATICS", "ELA")) {
    for (grade.iter in as.character(4:8)) {
        tmp.data <- summary.percentile.cut.data[CONTENT_AREA==content_area.iter & GRADE==grade.iter]
        tmp.splinefun15 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_15, method="monoH.FC")
        tmp.splinefun20 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_20, method="monoH.FC")
        tmp.splinefun25 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_25, method="monoH.FC")
        tmp.splinefun30 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_30, method="monoH.FC")
        tmp.splinefun35 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_35, method="monoH.FC")
        tmp.splinefun50 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_50, method="monoH.FC")
        tmp.splinefun60 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_60, method="monoH.FC")
        tmp.splinefun70 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_70, method="monoH.FC")
        tmp.splinefun80 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_80, method="monoH.FC")
        tmp.splinefun90 <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$PERCENTILE_CUT_90, method="monoH.FC")
        tmp.splinefunCUKU <- splinefun(tmp.data$SCALE_SCORE_PRIOR, tmp.data$MEAN_CATCH_UP_KEEP_UP_SCALE_SCORE, method="monoH.FC")

        pdf(file=paste0("Visualizations/", content_area.iter, "_GRADE_", grade.iter, ".pdf"), height=8.5, width=11)

        plot(x=500, y=500, type="n", xlim=c(440, 560), ylim=c(440, 560), axes=F,
            xlab=paste("Grade", as.numeric(grade.iter)-1, "Score"), ylab=paste("Grade", grade.iter, "Score"),
            main=paste("Equal Probability Year's Growth Curves: ", capwords(content_area.iter), " Grades ", as.numeric(grade.iter)-1, " to ", grade.iter))

            ### Achievement level cuts

        segments(tmp.cuts[1], 440, tmp.cuts[1], 560, lty=2, col="grey80")
        segments(tmp.cuts[2], 440, tmp.cuts[2], 560, lty=2, col="grey80")
        segments(tmp.cuts[3], 440, tmp.cuts[3], 560, lty=2, col="grey80")

        segments(440, tmp.cuts[1], 560, tmp.cuts[1], lty=2, col="grey80")
        segments(440, tmp.cuts[2], 560, tmp.cuts[2], lty=2, col="grey80")
        segments(440, tmp.cuts[3], 560, tmp.cuts[3], lty=2, col="grey80")

        segments(440, 440, 560, 560, lty=1, col=rgb(1,0,0,.25))

        points(tmp.sequence, tmp.splinefun15(tmp.sequence), type="l", col=tmp.colors[1])
        points(tmp.sequence, tmp.splinefun20(tmp.sequence), type="l", col=tmp.colors[2])
        points(tmp.sequence, tmp.splinefun25(tmp.sequence), type="l", col=tmp.colors[3])
        points(tmp.sequence, tmp.splinefun30(tmp.sequence), type="l", col=tmp.colors[4])
        points(tmp.sequence, tmp.splinefun35(tmp.sequence), type="l", col=tmp.colors[5])
        points(tmp.sequence, tmp.splinefun50(tmp.sequence), type="l", col=tmp.colors[6])
        points(tmp.sequence, tmp.splinefun60(tmp.sequence), type="l", col=tmp.colors[7])
        points(tmp.sequence, tmp.splinefun70(tmp.sequence), type="l", col=tmp.colors[8])
        points(tmp.sequence, tmp.splinefun80(tmp.sequence), type="l", col=tmp.colors[9])
        points(tmp.sequence, tmp.splinefun90(tmp.sequence), type="l", col=tmp.colors[10])
        points(tmp.sequence, tmp.splinefunCUKU(tmp.sequence), type="l", col="magenta")

        axis(1, at=seq(440, 560, by=10))
        axis(2, at=seq(440, 560, by=10))

        legend(x=440, y=555, legend=c(paste0(c(15, 20, 25, 30, 35, 50, 60, 70, 80, 90), "th percentile growth"), "y=x", "Catch-Up/Keep-Up Target"), col=c(tmp.colors[1:10], rgb(1,0,0,.25), "magenta"), lty=1, lwd=1)

        dev.off()
    }
}
