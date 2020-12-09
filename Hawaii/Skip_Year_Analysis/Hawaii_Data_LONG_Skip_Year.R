################################################################################
###                                                                          ###
###    Format data from the offical 2019 SGP data analysis for use in the    ###
###    'Historical Skip-Year SGP Analysis' - Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Original Hawaii data from 2019 HI SGP Analyses

load("../../../Hawaii/Data/Hawaii_SGP_LONG_Data.Rdata")

Hawaii_Data_LONG_NO_SKIP <- Hawaii_SGP_LONG_Data[YEAR %in% c(2014:2017, 2019)]
Hawaii_Data_LONG_NO_SKIP[, SGP_FROM_2015 := NULL]
Hawaii_Data_LONG_NO_SKIP[, grep("BASELINE", names(Hawaii_Data_LONG_NO_SKIP), value=TRUE) := NULL]

###   Rename variables as 'NO_SKIP_SGP' (Official data reported by GDOE)
original.names <- c(grep("^SGP", names(Hawaii_Data_LONG_NO_SKIP), value=TRUE),
                    grep("STATUS_3_YEAR", names(Hawaii_Data_LONG_NO_SKIP), value=TRUE),
                    grep("PRIOR", names(Hawaii_Data_LONG_NO_SKIP), value=TRUE))
new.names <- gsub('(_SGP)+','_SGP', paste0("NO_SKIP_SGP_", gsub("^SGP_", "", original.names)))
setnames(Hawaii_Data_LONG_NO_SKIP, original.names, new.names)

###   Save LONG data object
save(Hawaii_Data_LONG_NO_SKIP, file="Data/Hawaii_Data_LONG_NO_SKIP.Rdata")
