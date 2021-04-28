################################################################################
###
### Script to investigate summary (e.g., mean SGP) comparisons with LOW_PARTICIPATION_MOD1
### inferred values from functions such as bootstrapSRS
###
################################################################################

### Load packages

require(SGP)
require(cfaTools)
require(data.table)

setwd("..")

### Load Data

load("Data/LOW_PARTICIPATION_MOD1/Demonstration_COVID_SGP_2021_STEP_3c.Rdata")


### bootstrapSRS_SGP

tmp.summaries <- bootstrapSRS_SGP(
                                sgp_object=Demonstration_COVID_SGP,
                                strata_variables=c("ETHNICITY", "FREE_REDUCED_LUNCH_STATUS", "SCALE_SCORE_DECILE"),
                                strata_proportions_years="2021",
                                summary_years="2021",
                                sample_size=10000)
