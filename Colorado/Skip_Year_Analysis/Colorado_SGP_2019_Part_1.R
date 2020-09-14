################################################################################
###                                                                          ###
###     Historical One-Year Gap SGPs for Colorado 2021 Contingency Plan      ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load Official data and subset 2019

load("./Data/Colorado_Data_LONG_NO_SKIP.Rdata") # From 2019 CO SGP Analyses
load("Data/Colorado_SGP-2017.Rdata")
Colorado_Data_LONG_2019 <- Colorado_Data_LONG_NO_SKIP[YEAR == "2019"]


###   Read in 2017 SGP Configuration Scripts and Combine
source("SGP_CONFIG/2019_PART_1/ELA.R")
source("SGP_CONFIG/2019_PART_1/MATHEMATICS.R")


CO.2019.config <- c(
	ELA.2019.config,
	MATHEMATICS.2019.config
)

###
###    updateSGP - To produce SG Percentiles ONLY
###

SGPstateData[["CO"]][["Assessment_Program_Information"]][["CSEM"]] <- NULL

Colorado_SGP <- updateSGP(
		what_sgp_object=Colorado_SGP,
		with_sgp_data_LONG=Colorado_Data_LONG_2019,
		sgp.config = CO.2019.config,
		sgp.minimum.default.panel.years=2,
		steps=c("prepareSGP", "analyzeSGP", "combineSGP"),
		sgp.percentiles = TRUE,
		sgp.projections = FALSE,
		sgp.projections.lagged = FALSE,
		sgp.percentiles.baseline=FALSE,
		sgp.projections.baseline = FALSE,
		sgp.projections.lagged.baseline = FALSE,
		parallel.config = list(
			BACKEND="PARALLEL", WORKERS=list(TAUS = 11)))


### Save results

save(Colorado_SGP, file="Data/Colorado_SGP-2019_Part_1.Rdata")



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

Colorado_Baseline_Matrices_2019 <- convertToBaseline(Colorado_SGP@SGP$Coefficient_Matrices)

### Save 2019 SGP object

save(Colorado_Baseline_Matrices_2019, file="Data/Colorado_Baseline_Matrices_2019.Rdata")
