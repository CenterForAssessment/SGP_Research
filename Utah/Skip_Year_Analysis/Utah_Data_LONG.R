################################################################################
###                                                                          ###
###    Format Official Data for Utah Historical One-Year Gap SGP Analysis    ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Original Utah data from 2019 UT SGP Analyses

load("../../../Utah/Data/Utah_SGP_LONG_Data.Rdata")
Utah_Data_LONG_NO_SKIP <- Utah_SGP_LONG_Data[CONTENT_AREA != "SEC_MATH_I"]

###   Rename derived/related variables by pre-pending 'NO_SKIP_SGP' (Official data reported by USBOE)
original.names <- c(grep("^SGP", names(Utah_Data_LONG_NO_SKIP), value=TRUE),
                    grep("STATUS_3_YEAR", names(Utah_Data_LONG_NO_SKIP), value=TRUE),
                    grep("PRIOR", names(Utah_Data_LONG_NO_SKIP), value=TRUE))
new.names <- gsub('(_SGP)+','_SGP', paste0("NO_SKIP_SGP_", gsub("^SGP_", "", original.names)))
setnames(Utah_Data_LONG_NO_SKIP, original.names, new.names)


###   Remove Bio/Earth Sci Duplicates in priors (Grade 9 not used in Grade 10 analysis)
setkeyv(Utah_Data_LONG_NO_SKIP, c("VALID_CASE", "CONTENT_AREA", "SchoolYear", "GRADE", "StudentID", "SCALE_SCORE"))
setkeyv(Utah_Data_LONG_NO_SKIP, c("VALID_CASE", "CONTENT_AREA", "SchoolYear", "GRADE", "StudentID"))
dups <- data.table(Utah_Data_LONG_NO_SKIP[unique(c(which(duplicated(Utah_Data_LONG_NO_SKIP, by=key(Utah_Data_LONG_NO_SKIP)))-1, which(duplicated(Utah_Data_LONG_NO_SKIP, by=key(Utah_Data_LONG_NO_SKIP))))), ], key=key(Utah_Data_LONG_NO_SKIP))
table(dups$VALID_CASE) # 4,080 VALID_CASEs
table(dups[VALID_CASE=="VALID_CASE", SchoolYear, CONTENT_AREA_ACTUAL])
Utah_Data_LONG_NO_SKIP[which(duplicated(Utah_Data_LONG_NO_SKIP, by=key(Utah_Data_LONG_NO_SKIP)))-1, VALID_CASE := "INVALID_CASE"]
setkeyv(Utah_Data_LONG_NO_SKIP, c("VALID_CASE", "CONTENT_AREA", "SchoolYear", "GRADE", "StudentID"))

###   Save data for skip year analyses
# dir.create("Data")
save(Utah_Data_LONG_NO_SKIP, file="Data/Utah_Data_LONG_NO_SKIP.Rdata")
