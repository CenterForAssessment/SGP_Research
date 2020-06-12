##################################################################################
###
### Construct baseline matrices from matrices calculated in 2017 and ELA_2019
###
##################################################################################

### Load packages

require(SGP)


### Load SGP objects

load("Data/Demonstration_SGP_2018_2019_PART_1.Rdata")


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

Demonstration_Baseline_Matrices_2018_2019 <- convertToBaseline(Demonstration_SGP_2018_2019_PART_1@SGP$Coefficient_Matrices)

### Save 2018-2019 SGP object

save(Demonstration_Baseline_Matrices_2018_2019, file="Data/Demonstration_Baseline_Matrices_2018_2019.Rdata")
