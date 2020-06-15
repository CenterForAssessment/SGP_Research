################################################################################
###
### STEP 2: SGP analyses for skip year simulation: 2017 to 2019 Part 1
###
################################################################################

### Load packages

require(SGP)
require(SGPdata)


### Load data

load("Data/Demonstration_SGP_2019_2020_PART_2c.Rdata")


### Create subset of data

Demonstration_Data_LONG_2019_2020 <- sgpData_LONG[YEAR == "2019_2020"]


### Load configurations

source("SGP_CONFIG/2019_2019_PART_1/READING.R")
source("SGP_CONFIG/2019_2020_PART_1/MATHEMATICS.R")

SGP_CONFIG_2019_2020 <- c(READING_2019_2020.config, MATHEMATICS_2019_2020.config)


### Run analysis

Demonstration_SGP_2019_2020 <- updateSGP(
                        Demonstration_SGP_2018_2019_PART_2c,
                        Demonstration_Data_LONG_2019_2020,
                        steps=c("prepareSGP", "analyzeSGP"),
                        sgp.percentiles=TRUE,
                        sgp.projections=TRUE,
                        sgp.projections.lagged=TRUE,
                        sgp.percentiles.baseline=FALSE,
                        sgp.projections.baseline=FALSE,
                        sgp.projections.lagged.baseline=FALSE,
                        sgp.target.scale.scores=TRUE,
                        save.intermediate.results=FALSE,
                        sgp.config=SGP_CONFIG_2019_2020)


### Save results

save(Demonstration_SGP_2019_2020, file="Data/Demonstration_SGP_2019_2020.Rdata")


##################################################################################
###
### Construct baseline matrices from matrices calculated in 2016_2017 and 2019_2020
###
##################################################################################

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

Demonstration_Baseline_Matrices_2019_2020 <- convertToBaseline(Demonstration_SGP_2019_2020_PART_1@SGP$Coefficient_Matrices)

### Save 2018-2019 SGP object

save(Demonstration_Baseline_Matrices_2019_2020, file="Data/Demonstration_Baseline_Matrices_2019_2020.Rdata")
