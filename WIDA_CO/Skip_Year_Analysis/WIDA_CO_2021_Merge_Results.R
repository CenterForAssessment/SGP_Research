##################################################################################################
###
### Merge skip year baseline results with consecutive year baseline results
###
##################################################################################################

### Load packages
require(data.table)


### Load data sets
load("Data/WIDA_CO_SGP_LONG_Data_2021.Rdata")
WIDA_CO_SGP_LONG_Data_2021_SKIP_YEAR_BASELINE <- WIDA_CO_SGP_LONG_Data_2021
load("Data/NON_SKIP_YEAR_DATA/WIDA_CO_SGP_LONG_Data_2021.Rdata")


### Rename and select variables
setnames(WIDA_CO_SGP_LONG_Data_2021_SKIP_YEAR_BASELINE, "SGP_BASELINE", "SGP_BASELINE_SKIP_YEAR")
variables.to.keep <- c("VALID_CASE", "CONTENT_AREA", "YEAR", "GRADE", "ID", "SGP_BASELINE_SKIP_YEAR")
WIDA_CO_SGP_LONG_Data_2021_SKIP_YEAR_BASELINE <- WIDA_CO_SGP_LONG_Data_2021_SKIP_YEAR_BASELINE[,variables.to.keep, with=FALSE]

### Merge data
WIDA_CO_SGP_LONG_Data_2021 <- WIDA_CO_SGP_LONG_Data_2021_SKIP_YEAR_BASELINE[WIDA_CO_SGP_LONG_Data_2021]

### Individual correlations
WIDA_CO_SGP_LONG_Data_2021[,list(COR=cor(SGP_BASELINE, SGP_BASELINE_SKIP_YEAR, use="na.or.complete"), MEAN_ABS_DIFF=mean(abs(SGP_BASELINE-SGP_BASELINE_SKIP_YEAR), na.rm=TRUE), COUNT=sum(!is.na(SGP_BASELINE) & !is.na(SGP_BASELINE_SKIP_YEAR))), keyby="GRADE"]

### School level correlations
school_level.summaries <- WIDA_CO_SGP_LONG_Data_2021[,list(MEAN_SGP_BASELINE=mean(SGP_BASELINE, na.rm=TRUE), MEAN_SGP_BASELINE_SKIP_YEAR=mean(SGP_BASELINE_SKIP_YEAR, na.rm=TRUE), COUNT=sum(!is.na(SGP_BASELINE_SKIP_YEAR))), keyby="SCHOOL_NUMBER"]
cor(school_level.summaries[COUNT>=10]$MEAN_SGP_BASELINE, school_level.summaries[COUNT>=10]$MEAN_SGP_BASELINE_SKIP_YEAR, use="na.or.complete")
