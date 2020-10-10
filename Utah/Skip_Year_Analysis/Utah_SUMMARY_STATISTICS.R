##################################################################################
###
### Scripts that create summary statistics between one-year and skip-year SGPS
###
##################################################################################

### Load packages

require(data.table)


### Load data

load("Data/Utah_SGP_LONG_Data_2019.Rdata")

##################################################################
### Individual level one-year and skip-year SGP results
##################################################################

### Mean and standard deviation of one-year and skip-year SGPs

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(4:10) & VALID_CASE=="VALID_CASE", list(MEAN_NO_SKIP_SGP=mean(NO_SKIP_SGP, na.rm=TRUE), SD_NO_SKIP_SGP=sd(NO_SKIP_SGP, na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])
print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE), SD_SKIP_SGP=sd(SGP, na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])


### Correlation between one-year and skip-year SGPs

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="pairwise.complete")), key=c("CONTENT_AREA", "GRADE")])
print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="pairwise.complete")), key=c("CONTENT_AREA", "race_merged")])
print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="pairwise.complete")), key=c("CONTENT_AREA", "FRL_STATUS")])
print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="pairwise.complete")), key=c("CONTENT_AREA", "IEP_STATUS")])

### Differences between one-year and skip-year SGPs

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(MEAN_ABSOLUTE_SGP_DIFFERENCE=mean(abs(SGP - NO_SKIP_SGP), na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])
print(quantile(Utah_SGP_LONG_Data_2019$SGP - Utah_SGP_LONG_Data_2019$NO_SKIP_SGP, probs=1:9/10, na.rm=TRUE))

### Percentage of students with one-year SGP

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(4:10) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_with_SGP=100*sum(!is.na(NO_SKIP_SGP))/.N), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with skip-year SGP

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_with_SGP=100*sum(!is.na(SGP))/.N), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with one-year but no skip-year SGP

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(5:10) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_NO_SKIP_wout_SKIP=100*sum(!is.na(SGP))/sum(!is.na(NO_SKIP_SGP))), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with skip-year SGP but no one-year SGP

print(Utah_SGP_LONG_Data_2019[GRADE %in% as.character(4:10) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_SKIP_wout_NO_SKIP=100*sum(!is.na(SGP))/sum(is.na(NO_SKIP_SGP))), key=c("CONTENT_AREA", "GRADE")])


##################################################################
### Students with a one-year SGP but not a two-year SGP
##################################################################

Missing.skip.year.SGP.students <- Utah_SGP_LONG_Data_2019[is.na(SGP) & !is.na(NO_SKIP_SGP) & GRADE!="4" & CONTENT_AREA %in% c("ELA", "MATHEMATICS")]

### race_merged analysis

print(prop.table(table(Utah_SGP_LONG_Data_2019$GRADE, Utah_SGP_LONG_Data_2019$race_merged), margin=1))
print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$race_merged), margin=1))

### FRL_STATUS analysis

print(prop.table(table(Utah_SGP_LONG_Data_2019$GRADE, Utah_SGP_LONG_Data_2019$FRL_STATUS), margin=1))
print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$FRL_STATUS), margin=1))

### NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED analysis

print(Utah_SGP_LONG_Data_2019[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_PRIOR_STANDARDIZED=mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_PRIOR_STANDARDIZED=mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])

### SGP analysis

print(Utah_SGP_LONG_Data_2019[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_SGP=mean(NO_SKIP_SGP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_SGP=mean(NO_SKIP_SGP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])


##################################################################
### Create school level aggregates
##################################################################

Utah.school.summaries <- Utah_SGP_LONG_Data_2019[,
                        list(
                            MEAN_NO_SKIP_SGP=mean(NO_SKIP_SGP, na.rm=TRUE),
                            MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE),
                            MEAN_NO_SKIP_PRIOR_STANDARDIZED=mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                            MEAN_SKIP_PRIOR_STANDARDIZED=mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                            PERCENT_FREE_REDUCED_LUNCH=100*prop.table(table(FRL_STATUS))[2],
                            COUNT_NO_SKIP_SGP=sum(!is.na(NO_SKIP_SGP)),
                            COUNT_SKIP_SGP=sum(!is.na(SGP))),
                        keyby=c("SCHOOL_NUMBER", "EMH_LEVEL", "CONTENT_AREA")][,DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP:=abs(MEAN_SKIP_SGP-MEAN_NO_SKIP_SGP)]


### Correlations between skip-year SGPs and one-year SGPs by EMH, School, and CONTENT_AREA

Utah.school.EMH.correlations <- Utah.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="pairwise.complete")),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Utah.school.EMH.correlations)

Utah.school.correlations <- Utah.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="pairwise.complete")),
                        keyby=c("CONTENT_AREA")]
print(Utah.school.correlations)

### Absolute differences between SKIP-YEAR and ONE-YEAR SGPs

Utah.school.absolute.difference <- Utah.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(MEDIAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=median(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            MEAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=mean(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            NINETY_FIFTH_PERCENTILE_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=quantile(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP, probs=0.95, na.rm=TRUE),
                            MEDIAN_COUNT_NO_SKIP_SGP=median(COUNT_NO_SKIP_SGP),
                            MEDIAN_COUNT_SKIP_SGP=median(COUNT_SKIP_SGP)),
                        by=c("EMH_LEVEL", "CONTENT_AREA")]
print(Utah.school.absolute.difference)

### Correlation between mean SGP and mean prior achievement

Utah.school.Prior.Achievement.correlations <- Utah.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_SKIP_SGP, MEAN_SKIP_PRIOR_STANDARDIZED, use="pairwise.complete"),
                            COR_NO_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_NO_SKIP_SGP, MEAN_NO_SKIP_PRIOR_STANDARDIZED, use="pairwise.complete")),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Utah.school.Prior.Achievement.correlations)

### Correlation between mean SGP and percent free/reduced lunch

Utah.school.percent.free.reduced.lunch.correlations <- Utah.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="pairwise.complete"),
                            COR_NO_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_NO_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="pairwise.complete")),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Utah.school.percent.free.reduced.lunch.correlations)
