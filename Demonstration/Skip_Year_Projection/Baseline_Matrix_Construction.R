##################################################################################
###
### Construct baseline matrices from matrices calculated in 2017 and ELA_2019
###
##################################################################################

### Load packages

require(SGP)


### Load SGP objects

load("Data/Demonstration_SGP_2016_2017.Rdata")
load("Data/Demonstration_SGP_2018_2019.Rdata")


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

tmp.baseline.matrices.2018_2019 <- convertToBaseline(Demonstration_SGP_2018_2019@SGP$Coefficient_Matrices)


### Embed matrices into 2018_2019 SGP object to run projections

Demonstration_SGP_2018_2019@SGP$Coefficient_Matrices$MATHEMATICS.BASELINE <- tmp.baseline.matrices.2018_2019$MATHEMATICS.BASELINE
Demonstration_SGP_2018_2019@SGP$Coefficient_Matrices$READING.BASELINE <- tmp.baseline.matrices.2018_2019$READING.BASELINE


### Save 2018-2019 SGP object

save(Demonstration_SGP_2018_2019, file="Data/Demonstration_SGP_2018_2019.Rdata")
