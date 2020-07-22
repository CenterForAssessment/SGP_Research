################################################################################
###                                                                          ###
###  Format Official Data for Colorado Historical One-Year Gap SGP Analysis  ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Original Colorado data from 2019 CO SGP Analyses

load("../../../Colorado/Data/Colorado_SGP_LONG_Data.Rdata")
Colorado_Data_LONG_NO_SKIP <- Colorado_SGP_LONG_Data[YEAR != "2015"]

###   Rename 'SGP' variables as 'NO_SKIP' (originally reported by CDE)
grep("SGP", names(Colorado_Data_LONG_NO_SKIP), value=TRUE, perl=TRUE)
setnames(Colorado_Data_LONG_NO_SKIP, gsub("SGP", "NO_SKIP", names(Colorado_Data_LONG_NO_SKIP)))

###   Rename 'CUKU' variables as 'NO_SKIP'
grep("STATUS_3_YEAR", names(Colorado_Data_LONG_NO_SKIP), value=TRUE, perl=TRUE)
setnames(Colorado_Data_LONG_NO_SKIP, gsub("STATUS_3_YEAR", "STATUS_NO_SKIP", names(Colorado_Data_LONG_NO_SKIP)))

###   Rename 'PRIOR' variables as 'NO_SKIP'
grep("PRIOR", names(Colorado_Data_LONG_NO_SKIP), value=TRUE, perl=TRUE)
setnames(Colorado_Data_LONG_NO_SKIP, gsub("PRIOR", "NO_SKIP_PRIOR", names(Colorado_Data_LONG_NO_SKIP)))

##    Remove PERCENTILE_CUT variables
grep("PERCENTILE_CUT", names(Colorado_Data_LONG_NO_SKIP), value=TRUE, perl=TRUE)
Colorado_Data_LONG_NO_SKIP[, grep("PERCENTILE_CUT", names(Colorado_Data_LONG_NO_SKIP), value=TRUE) := NULL]

save(Colorado_Data_LONG_NO_SKIP, file="Data/Colorado_Data_LONG_NO_SKIP.Rdata")
