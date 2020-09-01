##################################################################################
###
### Scripts that create summary statistics between one-year and skip-year SGPS
###
##################################################################################

### Load packages

require(data.table)


### Load data

load("Data/Colorado_SGP_LONG_Data_2019.Rdata")

##################################################################
### Individual level one-year and skip-year SGP results
##################################################################

### Mean and standard deviation of one-year and skip-year SGPs

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE", list(MEAN_NO_SKIP_SGP=mean(NO_SKIP, na.rm=TRUE), SD_NO_SKIP_SGP=sd(NO_SKIP, na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])
print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE), SD_SKIP_SGP=sd(SGP, na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])


### Correlation between one-year and skip-year SGPs

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP, use="complete.obs")), key=c("CONTENT_AREA", "GRADE")])
print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP, use="complete.obs")), key=c("CONTENT_AREA", "ETHNICITY")])
print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP, use="complete.obs")), key=c("CONTENT_AREA", "FREE_REDUCED_LUNCH_STATUS")])
print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP, use="complete.obs")), key=c("CONTENT_AREA", "IEP_STATUS")])

### Differences between one-year and skip-year SGPs

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(MEAN_ABSOLUTE_SGP_DIFFERENCE=mean(abs(SGP - NO_SKIP), na.rm=TRUE)), key=c("CONTENT_AREA", "GRADE")])
print(quantile(Colorado_SGP_LONG_Data_2019$SGP - Colorado_SGP_LONG_Data_2019$NO_SKIP, probs=1:9/10, na.rm=TRUE))

### Percentage of students with one-year SGP

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_with_SGP=100*sum(!is.na(NO_SKIP))/.N), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with skip-year SGP

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_with_SGP=100*sum(!is.na(SGP))/.N), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with one-year but no skip-year SGP

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_NO_SKIP_wout_SKIP=100*sum(!is.na(SGP))/sum(!is.na(NO_SKIP))), key=c("CONTENT_AREA", "GRADE")])

### Percentage of students with skip-year SGP but no one-year SGP

print(Colorado_SGP_LONG_Data_2019[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE", list(PERCENTAGE_SKIP_wout_NO_SKIP=100*sum(!is.na(SGP))/sum(is.na(NO_SKIP))), key=c("CONTENT_AREA", "GRADE")])


##################################################################
### Students with a one-year SGP but not a two-year SGP
##################################################################

Missing.skip.year.SGP.students <- Colorado_SGP_LONG_Data_2019[is.na(SGP) & !is.na(NO_SKIP) & GRADE!="4" & CONTENT_AREA %in% c("ELA", "MATHEMATICS")]

### ETHNICITY analysis

print(prop.table(table(Colorado_SGP_LONG_Data_2019$GRADE, Colorado_SGP_LONG_Data_2019$ETHNICITY), margin=1))
print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$ETHNICITY), margin=1))

### FREE_REDUCED_LUNCH_STATUS analysis

print(prop.table(table(Colorado_SGP_LONG_Data_2019$GRADE, Colorado_SGP_LONG_Data_2019$FREE_REDUCED_LUNCH_STATUS), margin=1))
print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$FREE_REDUCED_LUNCH_STATUS), margin=1))

### SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED analysis

print(Colorado_SGP_LONG_Data_2019[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_PRIOR_STANDARDIZED=mean(SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_PRIOR_STANDARDIZED=mean(SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])

### SGP analysis

print(Colorado_SGP_LONG_Data_2019[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_SGP=mean(NO_SKIP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_SGP=mean(NO_SKIP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])


##################################################################
### Create school level aggregates
##################################################################

Colorado.school.summaries <- Colorado_SGP_LONG_Data_2019[,
                        list(
                            MEAN_NO_SKIP_SGP=mean(NO_SKIP, na.rm=TRUE),
                            MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE),
                            MEAN_NO_SKIP_PRIOR_STANDARDIZED=mean(SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED, na.rm=TRUE),
                            MEAN_SKIP_PRIOR_STANDARDIZED=mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                            PERCENT_FREE_REDUCED_LUNCH=100*prop.table(table(FREE_REDUCED_LUNCH_STATUS))[2],
                            COUNT_NO_SKIP_SGP=sum(!is.na(NO_SKIP)),
                            COUNT_SKIP_SGP=sum(!is.na(SGP))),
                        keyby=c("SCHOOL_NUMBER", "EMH_LEVEL", "CONTENT_AREA")][,DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP:=abs(MEAN_SKIP_SGP-MEAN_NO_SKIP_SGP)]


### Correlations between skip-year SGPs and one-year SGPs by EMH, School, and CONTENT_AREA

Colorado.school.EMH.correlations <- Colorado.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="complete.obs")),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Colorado.school.EMH.correlations)

Colorado.school.correlations <- Colorado.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="complete.obs")),
                        keyby=c("CONTENT_AREA")]
print(Colorado.school.correlations)

### Absolute differences between SKIP-YEAR and ONE-YEAR SGPs

Colorado.school.absolute.difference <- Colorado.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(MEDIAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=median(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            NINETY_FIFTH_PERCENTILE_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=mean(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            NINETY_FIFTH_PERCENTILE_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=quantile(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP, probs=0.95, na.rm=TRUE),
                            MEDIAN_COUNT_NO_SKIP_SGP=median(COUNT_NO_SKIP_SGP),
                            MEDIAN_COUNT_SKIP_SGP=median(COUNT_SKIP_SGP)),
                        by=c("EMH_LEVEL", "CONTENT_AREA")]
print(Colorado.school.absolute.difference)

### Correlation between mean SGP and mean prior achievement

Colorado.school.Prior.Achievement.correlations <- Colorado.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_SKIP_SGP, MEAN_SKIP_PRIOR_STANDARDIZED, use="complete.obs"),
                            COR_NO_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_NO_SKIP_SGP, MEAN_NO_SKIP_PRIOR_STANDARDIZED, use="complete.obs")
                        ),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Colorado.school.Prior.Achievement.correlations)

### Correlation between mean SGP and percent free/reduced lunch

Colorado.school.percent.free.reduced.lunch.correlations <- Colorado.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="complete.obs"),
                            COR_NO_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_NO_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="complete.obs")
                        ),
                        keyby=c("EMH_LEVEL", "CONTENT_AREA")]
print(Colorado.school.percent.free.reduced.lunch.correlations)
