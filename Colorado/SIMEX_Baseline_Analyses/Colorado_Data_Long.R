##########################################################################################
###                                                                                    ###
###   Create LONG Data with All SGP Orders and CSEMs for CMAS SIMEX/Baseline Analyses  ###
###                                                                                    ###
##########################################################################################

setwd("/Users/avi/Data/CO/SIMEX_Baseline_Analyses")

###   Load required packages
require(SGP)
require(data.table)

###   Load data and subset CMAS Subjects and Grades
load("/Users/avi/Dropbox (SGP)/SGP/Colorado/Data/Colorado_SGP_LONG_Data.Rdata")
Colorado_SGP_LONG_Data <- Colorado_SGP_LONG_Data[CONTENT_AREA %in% c("ELA", "MATHEMATICS") & GRADE %in% 3:8]

###   Rename ORIGINAL 'SGP' variables as 'ORIG'
setnames(Colorado_SGP_LONG_Data, "SGP", "ORIG")


###   Read in 2018 and 2019 SGP Configuration Scripts and Combine
source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2018/ELA.R')
source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2018/MATHEMATICS.R')

source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2019/ELA.R')
source('~/Dropbox (SGP)/Github_Repos/Projects/Colorado/SGP_CONFIG/2019/MATHEMATICS.R')

CO_Historical.config <- c(
	ELA.2019.config,
	MATHEMATICS.2019.config,

	ELA.2018.config,
	MATHEMATICS.2018.config
)

SGPstateData[["CO"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["CO"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE

###
###    abcSGP - To produce SG Percentiles of All Orders
###

Colorado_SGP <- abcSGP(
		Colorado_SGP_LONG_Data,
		sgp.config = CO_Historical.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = FALSE,
		sgp.projections.lagged = FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		simulate.sgps = FALSE,
		save.intermediate.results=FALSE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS=8)))

names(Colorado_SGP@Data)

table(Colorado_SGP@Data[, !is.na(SGP), YEAR])
table(Colorado_SGP@Data[, !is.na(SGP_ORDER_1), YEAR])
table(Colorado_SGP@Data[, !is.na(SGP_ORDER_2), YEAR])
table(Colorado_SGP@Data[, !is.na(SGP_ORDER_3), YEAR])

table(Colorado_SGP@Data[, SGP == ORIG, YEAR])

table(Colorado_SGP@Data[YEAR %in% c("2018", "2019"), !is.na(ORIG), !is.na(SGP)])

missing <- Colorado_SGP@Data[YEAR %in% c("2018", "2019") & !grepl("SAT", CONTENT_AREA) & !is.na(ORIG) & is.na(SGP),] # All missing are PSAT/SAT (not re-run)
missing <- Colorado_SGP@Data[YEAR %in% c("2018", "2019") & !grepl("SAT", CONTENT_AREA) & is.na(ORIG) & !is.na(SGP),] #
dim(missing)

###   Save just in case, but not really needed...
# save(Colorado_SGP, file="Data/Colorado_SGP-TEMP_All_Orders.Rdata")

###   Clean up SGP variable after checks
Colorado_SGP@Data[, SGP := NULL]
setnames(Colorado_SGP@Data, "ORIG", "SGP")


######
######
######


co.csem <- fread("/Users/avi/Syncplicity Folders/NCIEA_CMAS/CMAS 2015-2019 student level CSEMs.csv")
setnames(co.csem, c("FPRC_DASY_KEY", "FPRC_SUMMATIVE_CSEM", "FPRC_SUMMATIVE_SCALE_SCORE"), c("YEAR", "SCALE_SCORE_CSEM", "SCALE_SCORE"))
co.csem[, FPRC_KEY := as.character(FPRC_KEY)]
co.csem[, YEAR := as.character(YEAR)]

Colorado_Data_LONG <- copy(Colorado_SGP@Data)

dim(Colorado_Data_LONG)

##   Merge CSEM variables with 2015 - 2018 data
setkey(co.csem, FPRC_KEY, YEAR, SCALE_SCORE)
setkey(Colorado_Data_LONG, FPRC_KEY, YEAR, SCALE_SCORE)

Colorado_Data_LONG <- merge(Colorado_Data_LONG, co.csem, all.x = TRUE)

table(Colorado_Data_LONG[, YEAR, is.na(SCALE_SCORE_CSEM)])
table(Colorado_Data_LONG[VALID_CASE=="VALID_CASE", GRADE, is.na(SCALE_SCORE_CSEM)])
tmp.tbl <- Colorado_Data_LONG[VALID_CASE=="VALID_CASE" & is.na(SCALE_SCORE_CSEM) & GRADE %in% 3:8, as.list(summary(SCALE_SCORE)), keyby = c("CONTENT_AREA", "GRADE", "YEAR")]
tmp.tbl[!is.na(Median)]

#  3rd Grade ELA missing CSEMs
table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & SCALE_SCORE==765, SCALE_SCORE_CSEM], exclude=NULL) # 650

CSEM_Function <- splinefun(
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & !is.na(SCALE_SCORE), SCALE_SCORE],
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & !is.na(SCALE_SCORE), SCALE_SCORE_CSEM], method="natural")
Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE_CSEM :=
                    round(CSEM_Function(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE]), 1)]

table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "ELA" & GRADE == 3 & SCALE_SCORE==765, SCALE_SCORE_CSEM], exclude=NULL)

#  7th Grade MATHEMATICS missing CSEMs
table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & SCALE_SCORE==754, SCALE_SCORE_CSEM], exclude=NULL) # 650

CSEM_Function <- splinefun(
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & !is.na(SCALE_SCORE), SCALE_SCORE],
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & !is.na(SCALE_SCORE), SCALE_SCORE_CSEM], method="natural")
Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE_CSEM :=
                    round(CSEM_Function(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE]), 1)]

table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 7 & SCALE_SCORE==754, SCALE_SCORE_CSEM], exclude=NULL)

#  8th Grade MATHEMATICS missing CSEMs
table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & SCALE_SCORE==831, SCALE_SCORE_CSEM], exclude=NULL) # 650

CSEM_Function <- splinefun(
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & !is.na(SCALE_SCORE), SCALE_SCORE],
                    Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & !is.na(SCALE_SCORE), SCALE_SCORE_CSEM], method="natural")
Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE_CSEM :=
                    round(CSEM_Function(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & !is.na(SCALE_SCORE) & is.na(SCALE_SCORE_CSEM), SCALE_SCORE]), 1)]

table(Colorado_Data_LONG[YEAR == "2015" & CONTENT_AREA == "MATHEMATICS" & GRADE == 8 & SCALE_SCORE==831, SCALE_SCORE_CSEM], exclude=NULL)

grep("SGP", names(Colorado_Data_LONG), value=TRUE)
setnames(Colorado_Data_LONG, gsub("SGP", "ORIG", names(Colorado_Data_LONG)))
setnames(Colorado_Data_LONG, gsub("STATUS_3_YEAR", "STATUS_3_YEAR_ORIG", names(Colorado_Data_LONG)))

Colorado_Data_LONG[, VC_ORIG := VALID_CASE]

table(Colorado_Data_LONG[, !is.na(ORIG), YEAR])
table(Colorado_Data_LONG[, !is.na(ORIG_ORDER_1), YEAR])
table(Colorado_Data_LONG[, !is.na(ORIG_ORDER_2), YEAR])
table(Colorado_Data_LONG[, !is.na(ORIG_ORDER_3), YEAR])

save(Colorado_Data_LONG, file="Data/Colorado_Data_LONG.rda")
