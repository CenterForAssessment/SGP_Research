################################################################################
###
### Script to investigate summary (e.g., mean SGP) comparisons with BASIC_ANALYSIS
### inferred values from functions such as bootstrapSRS
###
################################################################################

### Get output_directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/BASIC_ANALYSIS"


### Load packages

require(SGP)
require(cfaTools)
require(data.table)

setwd("..")

### Load Data

load(file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"))

### Define parameters

aggregation_group <- c("CONTENT_AREA", "GRADE")


### bootstrapSRS_SGP

Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_6 <- bootstrapSRS_SGP(
                                sgp_object=Demonstration_COVID_SGP,
                                strata_variables=c("ETHNICITY", "FREE_REDUCED_LUNCH_STATUS", "SCALE_SCORE_DECILE"),
                                strata_proportions_years="2021",
                                summary_years="2021",
                                sample_size=10000,
                                aggregation_group=aggregation_group)


### Merge in BASIC summaries for comparison

load(file.path("Data/BASIC_ANALYSIS/Demonstration_COVID_SGP_Summaries_STEP_6.Rdata"))
setnames(Demonstration_COVID_SGP_Summaries_STEP_6, c("MEAN_SCALE_SCORE", "MEAN_SGP"), c("MEAN_SCALE_SCORE_ACTUAL", "MEAN_SGP_ACTUAL"))
Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_6[,c("MEAN_SCALE_SCORE_ACTUAL", "MEAN_SGP_ACTUAL"):=Demonstration_COVID_SGP_Summaries_STEP_6[,c("MEAN_SCALE_SCORE_ACTUAL", "MEAN_SGP_ACTUAL")]]
setcolorder(Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_6, c(aggregation_group, "MEAN_SCALE_SCORE_ACTUAL", "MEAN_SCALE_SCORE", "MEAN_SCALE_SCORE_INFERRED", "MEAN_SGP_ACTUAL", "MEAN_SGP", "MEAN_SGP_INFERRED", "MEAN_SCALE_SCORE_INFERRED_SE", "MEAN_SGP_INFERRED_SE"))

### Save results

save(Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_6, file=file.path(output.directory, "Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_6.Rdata"))
