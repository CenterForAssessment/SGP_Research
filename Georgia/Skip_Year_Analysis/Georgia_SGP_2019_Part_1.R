################################################################################
###                                                                          ###
###   STEP 3: SGP analyses for skip year simulation: 2017 to 2019 Part 1     ###
###           Cohort and Baseline referenced SGP calculations                ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Official data and subset 2019
load("./Data/Georgia_Data_LONG_NO_SKIP.Rdata")  #  From Skip_Year_Analysis/Georgia_Data_LONG.R
load("./Data/Georgia_SGP-2017.Rdata")
load("./Data/GA_Skip_Year_Baseline_Matrices.Rdata")  #  From Skip_Year_Analysis/Georgia_SGP_2019_Baseline_Matrices.R

Georgia_Data_LONG_2019 <- Georgia_Data_LONG_NO_SKIP[SCHOOL_YEAR == "2019"]

###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2019_PART_1/ELA.R")
source("SGP_CONFIG/2019_PART_1/MATHEMATICS.R")

GA_2019.config <- c(
  MATHEMATICS_2019.config,
	COORDINATE_ALGEBRA_2019.config,
	ANALYTIC_GEOMETRY_2019.config,
	ALGEBRA_I_2019.config,
	GEOMETRY_2019.config,

  ELA_2019.config,
	GRADE_9_LIT_2019.config,
	AMERICAN_LIT_2019.config
)

### Setup SGPstateData with baseline coefficient matrices grade specific projection sequences

SGPstateData[["GA"]][["Growth"]][["System_Type"]] <- "Cohort and Baseline Referenced"
SGPstateData[["GA"]][["Baseline_splineMatrix"]][["Coefficient_Matrices"]] <- GA_Skip_Year_Baseline_Matrices

###
###    updateSGP - To produce SG Percentiles ONLY
###

Georgia_SGP <- updateSGP(
		what_sgp_object=Georgia_SGP,
		with_sgp_data_LONG=Georgia_Data_LONG_2019,
		sgp.config = GA_2019.config,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = FALSE,
		sgp.projections.lagged = FALSE,
		sgp.percentiles.baseline=TRUE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		calculate.simex = TRUE,
    calculate.simex.baseline = TRUE,
		###   Use these three lines for the small sample test run.  Delete/comment out and set calculate.simex = TRUE for full EOC run.
		###
			# calculate.simex = list(lambda=seq(0,2,0.5), simulation.iterations=25, simex.sample.size=2500, csem.data.vnames="SCALE_SCORE_CSEM", extrapolation="linear", save.matrices=TRUE),
      # calculate.simex.baseline = list(lambda=seq(0,2,0.5), simulation.iterations=25, simex.sample.size=2500, csem.data.vnames="SCALE_SCORE_CSEM",
      #                                 extrapolation="linear", save.matrices=FALSE, simex.use.my.coefficient.matrices=TRUE, use.cohort.for.ranking=TRUE),
			# sgp.test.cohort.size = 5000, # comment out for full run
			# return.sgp.test.results = "ALL_DATA", # TRUE
			# goodness.of.fit.print=FALSE,
		###
		###
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS=25, SIMEX=25)))

###   Quick checks

table(Georgia_SGP@Data[YEAR=='2019' & is.na(SGP) & !is.na(SGP_BASELINE), SGP_NOTE], exclude=NULL)
table(Georgia_SGP@Data[YEAR=='2019' & is.na(SGP) & !is.na(SGP_BASELINE), as.character(SGP_NORM_GROUP_BASELINE)])  #  small cohort N (<1500)
table(Georgia_SGP@Data[YEAR=='2019' & !is.na(SGP) & is.na(SGP_BASELINE), as.character(SGP_NORM_GROUP)]) #  (Same year) repeaters


###
### Convert matrices calculated in 2017 to 2019
###

### Utility functions

convertMatrixYear <- function(matrices_to_convert, years_to_convert, year_increment=2L, merge_matrices = TRUE) {
	unique_splineMatrix <-
		function(list.of.splineMatrices) {
			tmp.list.1 <- lapply(list.of.splineMatrices,
				function(x) list(Content_Areas=x@Content_Areas, Grade_Progression=x@Grade_Progression, Time=x@Time, Time_Lags=x@Time_Lags)) # Does not compare @Data like unique.splineMatrix
			tmp.list.2 <- lapply(list.of.splineMatrices,
				function(x) list(Content_Areas=x@Content_Areas, Grade_Progression=x@Grade_Progression, Time=x@Time, Time_Lags=x@Time_Lags, Version=x@Version)) # Data = x@.Data,
			if (any(duplicated(tmp.list.1))) {
				list.of.splineMatrices[!duplicated(tmp.list.1[order(as.character(unlist(sapply(tmp.list.2, function(x) x$Version[1]))), decreasing=TRUE)])]
			} else {
				list.of.splineMatrices
			}
		} ### END unique_splineMatrix

  tmp.list <- list()
  if (is.null(matrices_to_convert)) {
      return(NULL)
  } else {
		matrix.names <- grep("SIMEX", grep(paste(years_to_convert, collapse="|"), names(matrices_to_convert), value=TRUE), invert=TRUE, value=TRUE)
    for (i in matrix.names) {
      for (j in seq_along(matrices_to_convert[[i]])) {
          matrices_to_convert[[i]][[j]]@Time <- list(SGP:::yearIncrement(matrices_to_convert[[i]][[j]]@Time[[1]], year_increment))
      }
    }
		converted_year <- SGP:::yearIncrement(years_to_convert, year_increment)
		tmp.content_areas <- unique(sapply(strsplit(names(matrices_to_convert), "[.]"), '[', 1))
    for (i in tmp.content_areas) {
				tmp.name <- paste(i, SGP:::yearIncrement(years_to_convert, year_increment), sep=".")
        tmp.list[[tmp.name]] <-
						unlist(matrices_to_convert[grep(paste0("((?=^((?!SIMEX|BASELINE|", converted_year, ").)*$)", i, ")"), names(matrices_to_convert), perl=TRUE)], recursive=FALSE)
				names(tmp.list[[tmp.name]]) <- gsub(paste(i, years_to_convert, "", sep="."), "", names(tmp.list[[tmp.name]]))
    }
		if (merge_matrices) { # sapply(tmp.list, length)
			for (k in names(tmp.list)) {
				matrices_to_convert[[k]] <- unique_splineMatrix(c(matrices_to_convert[[k]], tmp.list[[k]]))
			}
			return(matrices_to_convert) # Return all matrices supplied
		} else {
	    return(tmp.list)  #  Return only converted matrices
		}
  }
}


###   Convert 2017 matrices to 2019 for "cohort referenced" projections in subsequent steps
Georgia_SGP@SGP$Coefficient_Matrices <- convertMatrixYear(Georgia_SGP@SGP$Coefficient_Matrices, "2017", merge_matrices=TRUE)
names(Georgia_SGP@SGP$Coefficient_Matrices[["MATHEMATICS.2019"]])

### Save results
save(Georgia_SGP, file="Data/Georgia_SGP-2019_Part_1.Rdata")
