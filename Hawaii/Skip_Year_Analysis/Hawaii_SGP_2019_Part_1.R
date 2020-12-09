################################################################################
###                                                                          ###
###  STEP 2: Cohort-referenced skip-year SGPs (2017 to 2019 -- Part 1)       ###
###     Historical Skip-Year SGP Analysis -- Hawaii 2021 contingency plan    ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load SGP object from 2017 (pre-skip) analysis
load("Data/Hawaii_SGP-SkipYear.Rdata")

###   Load skip-year data and subset 2019
load("./Data/Hawaii_Data_LONG_NO_SKIP.Rdata")
Hawaii_Data_LONG_2019 <- Hawaii_Data_LONG_NO_SKIP[YEAR == "2019"]

###   Load 2019 Hawaii Instructor Number data
load("../../../Hawaii/Data/Hawaii_Data_LONG_2019_INSTRUCTOR_NUMBER.Rdata")

###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2019_PART_1/READING.R")
source("SGP_CONFIG/2019_PART_1/MATHEMATICS.R")

HI_Skip_Year_P1.config <- c(
	READING_2019.config,
	MATHEMATICS_2019.config)

###   Make necessary changes to SGPstateData
SGPstateData[["HI"]][["Assessment_Program_Information"]][["Assessment_Transition"]] <- NULL
SGPstateData[["HI"]][["SGP_Configuration"]][["print.other.gp"]] <- TRUE
SGPstateData[["HI"]][["SGP_Configuration"]][["print.sgp.order"]] <- TRUE


###
###   updateSGP - To produce SG Percentiles ONLY
###

Hawaii_SGP <- updateSGP(
		what_sgp_object=Hawaii_SGP,
		with_sgp_data_LONG=Hawaii_Data_LONG_2019,
		with_sgp_data_INSTRUCTOR_NUMBER=Hawaii_Data_LONG_2019_INSTRUCTOR_NUMBER,
		sgp.config = HI_Skip_Year_P1.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		save.intermediate.results=FALSE,
		sgp.percentiles = TRUE,
		sgp.projections = FALSE,
		sgp.projections.lagged = FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS = 11)))


### Save results

save(Hawaii_SGP, file="Data/Hawaii_SGP-SkipYear.Rdata")



################################################################################
###
### Construct baseline matrices from matrices calculated in 2017 and 2019
###
################################################################################

### Utility function

convertToBaseline <- function(baseline_matrices) {
  tmp.list <- list()
  if (is.null(baseline_matrices)) {
    return(NULL)
  } else {
    for (i in names(baseline_matrices)) {
      for (j in seq_along(baseline_matrices[[i]])) {
          baseline_matrices[[i]][[j]]@Time <- list(rep("BASELINE", length(unlist(baseline_matrices[[i]][[j]]@Time))))
      }
      names(baseline_matrices[[i]]) <- sub("[.][1234]_", "_", names(baseline_matrices[[i]]))
    }

    tmp.content_areas <- unique(sapply(strsplit(names(baseline_matrices), "[.]"), '[', 1))
    for (i in tmp.content_areas) {
      tmp.list[[paste(i, "BASELINE", sep=".")]] <- unlist(baseline_matrices[grep(i, names(baseline_matrices))], recursive=FALSE)
    }
    return(tmp.list)
  }
}


### Convert matrices to baseline

Hawaii_Baseline_Matrices_2019 <- convertToBaseline(Hawaii_SGP@SGP$Coefficient_Matrices)

### Save 2019 SGP object

save(Hawaii_Baseline_Matrices_2019, file="Data/Hawaii_Baseline_Matrices_2019.Rdata")
