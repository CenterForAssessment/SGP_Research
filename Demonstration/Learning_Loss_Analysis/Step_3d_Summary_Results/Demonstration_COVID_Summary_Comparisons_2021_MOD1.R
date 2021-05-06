################################################################################
###
### Script to investigate summary (e.g., mean SGP) comparisons with BASIC_ANALYSIS
### inferred values from functions such as bootstrapSRS
###
################################################################################

### Get output_directory set up for analyses
if (!exists("output.directory")) output.directory <- "Data/LOW_PARTICIPATION_MOD1"
if (!exists("output.file")) output.file <- "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"


### Load packages

require(SGP)
require(cfaTools)
require(data.table)

setwd("..")

### Load Data

load(file.path(output.directory, output.file))

### Define parameters

aggregation_group <- c("CONTENT_AREA", "GRADE")


### bootstrapSRS_SGP

Demonstration_COVID_SGP_Summaries_STEP_3d_MOD1 <- bootstrapSRS_SGP(
                                sgp_object=Demonstration_COVID_SGP,
                                strata_summaries=c("STATUS", "GROWTH"),
                                strata_variables=c("ETHNICITY", "FREE_REDUCED_LUNCH_STATUS", "SCALE_SCORE_DECILE"),
                                strata_proportions_years_status="2019",
                                strata_proportions_years_growth="2021",
                                summary_years="2021",
                                sample_size=10000,
                                aggregation_group=aggregation_group)


### Merge in BASIC summaries for comparison

load(file.path("Data/BASIC_ANALYSIS/Demonstration_COVID_SGP_Summaries_STEP_3d.Rdata"))
setnames(Demonstration_COVID_SGP_Summaries_STEP_3d, c("MEAN_SCALE_SCORE", "MEAN_SGP", "MEAN_SGP_BASELINE"), c("MEAN_SCALE_SCORE_COMPLETE", "MEAN_SGP_COMPLETE", "MEAN_SGP_BASELINE_COMPLETE"))
Demonstration_COVID_SGP_Summaries_STEP_3d_MOD1[,c("MEAN_SCALE_SCORE_COMPLETE", "MEAN_SGP_COMPLETE", "MEAN_SGP_BASELINE_COMPLETE"):=Demonstration_COVID_SGP_Summaries_STEP_3d[,c("MEAN_SCALE_SCORE_COMPLETE", "MEAN_SGP_COMPLETE", "MEAN_SGP_BASELINE_COMPLETE")]]
setcolorder(Demonstration_COVID_SGP_Summaries_STEP_3d_MOD1, c(aggregation_group, "MEAN_SCALE_SCORE_COMPLETE", "MEAN_SCALE_SCORE", "MEAN_SCALE_SCORE_INFERRED", "MEAN_SGP_COMPLETE", "MEAN_SGP", "MEAN_SGP_INFERRED", "MEAN_SGP_BASELINE_COMPLETE", "MEAN_SGP_BASELINE", "MEAN_SGP_BASELINE_INFERRED", "MEAN_SCALE_SCORE_INFERRED_SE", "MEAN_SGP_INFERRED_SE", "MEAN_SGP_BASELINE_INFERRED_SE"))

### Rename and Save results

Demonstration_COVID_SGP_Summaries_STEP_3d <- Demonstration_COVID_SGP_Summaries_STEP_3d_MOD1

save(Demonstration_COVID_SGP_Summaries_STEP_3d, file=file.path(output.directory, "Demonstration_COVID_SGP_Summaries_MODIFIED_STEP_3d.Rdata"))
