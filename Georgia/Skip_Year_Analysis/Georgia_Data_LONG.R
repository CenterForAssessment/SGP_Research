################################################################################
###                                                                          ###
###  Format Official Data for Georgia Historical One-Year Gap SGP Analysis   ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Original Georgia data from 2019 GA SGP Analyses

load("../../../Georgia/Data/Georgia_SGP_LONG_Data.Rdata")
load("../../../Georgia/Data/Georgia_SGP_LONG_Data_2015.Rdata")
setnames(Georgia_SGP_LONG_Data_2015,
          c("SCALE_SCORE_CSEM", "CATCH_UP_KEEP_UP_STATUS", "MOVE_UP_STAY_UP_STATUS"),
          c("CONDSEM", "CATCH_UP_KEEP_UP_STATUS_3_YEAR", "MOVE_UP_STAY_UP_STATUS_3_YEAR"))
Georgia_SGP_LONG_Data_2015[, names(Georgia_SGP_LONG_Data_2015)[!names(Georgia_SGP_LONG_Data_2015) %in% names(Georgia_SGP_LONG_Data)] := NULL]
Georgia_SGP_LONG_Data_2015 <- Georgia_SGP_LONG_Data_2015[!SUBJECT_CODE %in% c("PHYSICAL_SCIENCE", "SCIENCE", "SOCIAL_STUDIES", "US_HISTORY", "BIOLOGY", "ECONOMICS")]

Georgia_Data_LONG_NO_SKIP <- rbindlist(list(Georgia_SGP_LONG_Data, Georgia_SGP_LONG_Data_2015), fill=TRUE)
Georgia_Data_LONG_NO_SKIP[, SGP_FROM_2015 := NULL]

###   Rename variables as 'NO_SKIP_SGP' (Official data reported by GDOE)
original.names <- c(grep("^SGP", names(Georgia_Data_LONG_NO_SKIP), value=TRUE),
                    grep("STATUS_3_YEAR", names(Georgia_Data_LONG_NO_SKIP), value=TRUE),
                    grep("PRIOR", names(Georgia_Data_LONG_NO_SKIP), value=TRUE))
new.names <- gsub('(_SGP)+','_SGP', paste0("NO_SKIP_SGP_", gsub("^SGP_", "", original.names)))
setnames(Georgia_Data_LONG_NO_SKIP, original.names, new.names)


###  Clean up ACHIEVEMENT_LEVEL
Georgia_Data_LONG_NO_SKIP[PERFORMANCE_LEVEL == "", PERFORMANCE_LEVEL := as.character(NA)]

###   Save LONG data object
save(Georgia_Data_LONG_NO_SKIP, file="Data/Georgia_Data_LONG_NO_SKIP.Rdata")
