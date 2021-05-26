####################################################################################
###
###          Summaries investigating equateSGP impact on iindividual and group level
###          SGPs
###
####################################################################################

### Load packages
require(SGP)
require(data.table)


### Load data
load("Data/ACTUAL/Demonstration_SGP_LONG_Data_2020_2021.Rdata")
tmp.ACTUAL <- Demonstration_SGP_LONG_Data_2020_2021
load("Data/ASSESSMENT_CHANGE_2020/Demonstration_SGP_LONG_Data_2020_2021.Rdata")
tmp.ASSESSMENT_CHANGE_2020 <- Demonstration_SGP_LONG_Data_2020_2021
load("Data/ASSESSMENT_CHANGE_2021/Demonstration_SGP_LONG_Data_2020_2021.Rdata")
tmp.ASSESSMENT_CHANGE_2021 <- Demonstration_SGP_LONG_Data_2020_2021


### Add calculated SGPs to a single data set
tmp.ALL <- copy(tmp.ACTUAL)
tmp.ALL[,SGP_CHANGE_2020:=tmp.ASSESSMENT_CHANGE_2020$SGP]
tmp.ALL[,SGP_CHANGE_2021:=tmp.ASSESSMENT_CHANGE_2021$SGP]

### INDIVIDUAL COMPARISONS
print("Individual level correlations by Grade and Content Area\n")
print(tmp.ALL[,list(COR_ACTUAL_CHANGE_2021=cor(SGP, SGP_CHANGE_2021, use="na.or.complete"), COR_ACTUAL_CHANGE_2020=cor(SGP, SGP_CHANGE_2020, use="na.or.complete")), keyby=c("CONTENT_AREA", "GRADE")])



### SUMMARY COMPARISONS
print("School level mean SGP correlations by Content Area\n")
tmp.SCHOOL_SUMMARIES <- tmp.ALL[,list(MEAN_SGP_ACTUAL=mean(SGP, na.rm=TRUE), MEAN_CHANGE_2021=mean(SGP_CHANGE_2021, na.rm=TRUE), MEAN_CHANGE_2020=mean(SGP_CHANGE_2020, na.rm=TRUE), COUNT=.N), keyby=c("CONTENT_AREA", "SCHOOL_NUMBER")]
print(tmp.SCHOOL_SUMMARIES[,list(COR_SCHOOL_ACTUAL_CHANGE_2021=cor(MEAN_SGP_ACTUAL, MEAN_CHANGE_2021, use="na.or.complete"), COR_SCHOOL_ACTUAL_CHANGE_2020=cor(MEAN_SGP_ACTUAL, MEAN_CHANGE_2020, use="na.or.complete"))])

print("District level mean SGP correlations by Content Area\n")
tmp.SCHOOL_SUMMARIES <- tmp.ALL[,list(MEAN_SGP_ACTUAL=mean(SGP, na.rm=TRUE), MEAN_CHANGE_2021=mean(SGP_CHANGE_2021, na.rm=TRUE), MEAN_CHANGE_2020=mean(SGP_CHANGE_2020, na.rm=TRUE), COUNT=.N), keyby=c("CONTENT_AREA", "DISTRICT_NUMBER")]
print(tmp.SCHOOL_SUMMARIES[,list(COR_SCHOOL_ACTUAL_CHANGE_2021=cor(MEAN_SGP_ACTUAL, MEAN_CHANGE_2021, use="na.or.complete"), COR_SCHOOL_ACTUAL_CHANGE_2020=cor(MEAN_SGP_ACTUAL, MEAN_CHANGE_2020, use="na.or.complete"))])
