#############################################################################################
###
### Script to merge data sets and create SGP_SKIP_YEAR
###
#############################################################################################

### Load packages

require(SGP)
require(data.table)


### Load data

load("/Users/conet/Github/CenterForAssessment/Indiana/master/Data/Indiana_SGP_LONG_Data.Rdata")
Indiana_SGP_LONG_Data <- Indiana_SGP_LONG_Data[SCHOOL_YEAR >= "2015"]
Indiana_SGP_LONG_Data_NO_SKIP <- Indiana_SGP_LONG_Data
load("Data/Indiana_SGP_LONG_Data.Rdata")


### Rename variables

original.names <- c("SGP", "SCALE_SCORE_PRIOR", "SCALE_SCORE_PRIOR_STANDARDIZED", "SGP_LEVEL", "SGP_NORM_GROUP", "SGP_NORM_GROUP_SCALE_SCORES", "SGP_PROJECTION_GROUP",
                        "SGP_TARGET_3_YEAR_CURRENT", "SGP_TARGET_MOVE_UP_STAY_UP_3_YEAR_CURRENT", "SGP_TARGET_3_YEAR", "ACHIEVEMENT_LEVEL_PRIOR", "SGP_TARGET_MOVE_UP_STAY_UP_3_YEAR",
                        "SGP_TARGET_3_YEAR_CONTENT_AREA", "SGP_NOTE", "SGP_ORDER_1", "SGP_ORDER_2", "SGP_ORDER_3", "SGP_ORDER", "SGP_PROJECTION_GROUP_SCALE_SCORES",
                        "CATCH_UP_KEEP_UP_STATUS", "MOVE_UP_STAY_UP_STATUS")
original.names <- intersect(names(Indiana_SGP_LONG_Data_NO_SKIP), original.names)
new.names <- paste0(original.names, "_NO_SKIP")
setnames(Indiana_SGP_LONG_Data_NO_SKIP, original.names, new.names)


### Merge in new columns

Indiana_SGP_LONG_Data[,eval(new.names):=Indiana_SGP_LONG_Data_NO_SKIP[,new.names, with=FALSE]]


### Save data

save(Indiana_SGP_LONG_Data, file="Data/Indiana_SGP_LONG_Data.Rdata")
