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
#debug(bootstrapSRS)


setwd("..")

### Load Data

load(file.path(output.directory, "Demonstration_COVID_SGP_2021_STEP_3a.Rdata"))

### Define parameters

aggregation_group <- c("CONTENT_AREA", "GRADE")
#aggregation_group <- c("CONTENT_AREA", "SCHOOL_NUMBER")


### bootstrapSRS_SGP (### NOTE USING CURRENT SCALE_SCORE_DECILE likely leads to biased proportions, especially if students have missing scores as in the COVID analyses)

Demonstration_COVID_SGP_Summaries_STEP_3d <- bootstrapSRS_SGP(
                                sgp_object=Demonstration_COVID_SGP,
                                strata_summaries=c("STATUS", "GROWTH"),
                                strata_variables=c("ETHNICITY", "FREE_REDUCED_LUNCH_STATUS", "SCALE_SCORE_DECILE"),
                                strata_proportions_years_status="2019",
                                strata_proportions_years_growth="2021",
                                summary_years="2021",
                                sample_size=10000,
                                aggregation_group=aggregation_group)


### Save results

save(Demonstration_COVID_SGP_Summaries_STEP_3d, file=file.path(output.directory, "Demonstration_COVID_SGP_Summaries_STEP_3d.Rdata"))
