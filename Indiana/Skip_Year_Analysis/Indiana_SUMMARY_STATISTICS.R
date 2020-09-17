##################################################################################
###
### Scripts that create summary statistics between one-year and skip-year SGPS
###
##################################################################################

### Load packages

require(data.table)


### Load data

load("Data/Indiana_SGP.Rdata")

##################################################################
### Individual level one-year and skip-year SGP results
##################################################################

### Counts of skip-year and one-year SGPs

print(Indiana_SGP@Data[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(COUNT_NO_SKIP_SGP=sum(!is.na(NO_SKIP_SGP)), COUNT_SKIP_SGP=sum(!is.na(SGP))), key=c("YEAR", "CONTENT_AREA", "GRADE")])


### Mean, Median and standard deviation of one-year and skip-year SGPs

print(Indiana_SGP@Data[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(MEAN_NO_SKIP_SGP=mean(NO_SKIP_SGP, na.rm=TRUE), MEDIAN_NO_SKIP_SGP=median(NO_SKIP_SGP, na.rm=TRUE), SD_NO_SKIP_SGP=sd(NO_SKIP_SGP, na.rm=TRUE)), key=c("YEAR", "CONTENT_AREA", "GRADE")])
print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE), MEDIAN_SKIP_SGP=median(SGP, na.rm=TRUE), SD_SKIP_SGP=sd(SGP, na.rm=TRUE)), key=c("YEAR", "CONTENT_AREA", "GRADE")])


### Correlation between one-year and skip-year SGPs (No demographic variables in Indiana data set)

print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="complete.obs")), key=c("YEAR", "CONTENT_AREA", "GRADE")])
#print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="complete.obs")), key=c("CONTENT_AREA", "ETHNICITY")])
#print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="complete.obs")), key=c("CONTENT_AREA", "FREE_REDUCED_LUNCH_STATUS")])
#print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE", list(CORRELATION_SGP_SKIP_YEAR_SGP=cor(SGP, NO_SKIP_SGP, use="complete.obs")), key=c("CONTENT_AREA", "IEP_STATUS")])

### Differences between one-year and skip-year SGPs

print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(MEAN_ABSOLUTE_SGP_DIFFERENCE=mean(abs(SGP - NO_SKIP_SGP), na.rm=TRUE), DECILES_SGP_DIFFERENCE=paste(as.character(quantile(SGP - NO_SKIP_SGP, probs=c(0.05, 1:9/10, 0.95), na.rm=TRUE)), collapse=", ")), key=c("YEAR", "CONTENT_AREA", "GRADE")])
print(quantile(Indiana_SGP@Data$SGP - Indiana_SGP@Data$NO_SKIP_SGP, probs=1:9/10, na.rm=TRUE))

### Percentage of students with one-year SGP

print(Indiana_SGP@Data[GRADE %in% as.character(4:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(PERCENTAGE_with_SGP=100*sum(!is.na(NO_SKIP_SGP))/.N), key=c("YEAR", "CONTENT_AREA", "GRADE")])

### Percentage of students with skip-year SGP

print(Indiana_SGP@Data[GRADE %in% as.character(5:8) & VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019"), list(PERCENTAGE_with_SGP=100*sum(!is.na(SGP))/.N), key=c("YEAR", "CONTENT_AREA", "GRADE")])

### Contingency table of students with one-year and skip-year SGPs

tmp.table.counts <- table(is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$SGP), is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$NO_SKIP_SGP))
rownames(tmp.table.counts) <- c("SKIP SGP: Yes", "SKIP SGP: No")
colnames(tmp.table.counts) <- c("NO SKIP SGP: Yes", "NO SKIP SGP: No")
print(tmp.table.counts)

tmp.table.prop <- prop.table(table(is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$SGP), is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$NO_SKIP_SGP)), margin=1)
rownames(tmp.table.prop) <- c("SKIP SGP: Yes", "SKIP SGP: No")
colnames(tmp.table.prop) <- c("NO SKIP SGP: Yes", "NO SKIP SGP: No")
print(tmp.table.prop)

tmp.table.prop <- prop.table(table(is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$NO_SKIP_SGP), is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$SGP)), margin=1)
rownames(tmp.table.prop) <- c("NO SKIP SGP: Yes", "NO SKIP SGP: No")
colnames(tmp.table.prop) <- c("SKIP SGP: Yes", "SKIP SGP: No")
print(tmp.table.prop)

tmp.table.prop <- prop.table(table(is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$NO_SKIP_SGP), is.na(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & YEAR %in% c("2018", "2019") & GRADE %in% as.character(5:8)]$SGP)))
rownames(tmp.table.prop) <- c("NO SKIP SGP: Yes", "NO SKIP SGP: No")
colnames(tmp.table.prop) <- c("SKIP SGP: Yes", "SKIP SGP: No")
print(tmp.table.prop)

##################################################################
### Students with a one-year SGP but not a two-year SGP
##################################################################

Missing.skip.year.SGP.students <- Indiana_SGP@Data[is.na(SGP) & !is.na(NO_SKIP_SGP) & GRADE!="4" & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & YEAR %in% c("2018", "2019")]

### ETHNICITY analysis

#print(prop.table(table(Indiana_SGP@Data$GRADE, Indiana_SGP@Data$ETHNICITY), margin=1))
#print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$ETHNICITY), margin=1))

### FREE_REDUCED_LUNCH_STATUS analysis

#print(prop.table(table(Indiana_SGP@Data$GRADE, Indiana_SGP@Data$FREE_REDUCED_LUNCH_STATUS), margin=1))
#print(prop.table(table(Missing.skip.year.SGP.students$GRADE, Missing.skip.year.SGP.students$FREE_REDUCED_LUNCH_STATUS), margin=1))

### SCALE_SCORE_NO_SKIP_PRIOR_STANDARDIZED analysis

print(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & YEAR %in% c("2018", "2019"), list(MEAN_PRIOR_STANDARDIZED=mean(NO_SKIP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE), COUNT=.N), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_PRIOR_STANDARDIZED=mean(NO_SKIP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE), COUNT=.N), by=c("CONTENT_AREA", "GRADE")])

### SGP analysis

print(Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & YEAR %in% c("2018", "2019"), list(MEAN_SGP=mean(NO_SKIP_SGP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])
print(Missing.skip.year.SGP.students[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS"), list(MEAN_SGP=mean(NO_SKIP_SGP, na.rm=TRUE)), by=c("CONTENT_AREA", "GRADE")])


##################################################################
### Create school level aggregates
##################################################################

Indiana.school.summaries <- Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & YEAR %in% c("2018", "2019") & (!is.na(SGP) | !is.na(NO_SKIP_SGP)),
                        list(
                            MEAN_NO_SKIP_SGP=mean(NO_SKIP_SGP, na.rm=TRUE),
                            MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE),
                            MEAN_NO_SKIP_PRIOR_STANDARDIZED=mean(NO_SKIP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                            MEAN_SKIP_PRIOR_STANDARDIZED=mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
#                            PERCENT_FREE_REDUCED_LUNCH=100*prop.table(table(FREE_REDUCED_LUNCH_STATUS))[2],
                            COUNT_NO_SKIP_SGP=sum(!is.na(NO_SKIP_SGP)),
                            COUNT_SKIP_SGP=sum(!is.na(SGP)),
                            GRADE_RANGE=paste(as.character(range(GRADE)), collapse=" ")),
                        keyby=c("SCHOOL_NUMBER", "CONTENT_AREA")][,DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP:=abs(MEAN_SKIP_SGP-MEAN_NO_SKIP_SGP)]

Indiana.school.summaries.SAME.STUDENTS <- Indiana_SGP@Data[VALID_CASE=="VALID_CASE" & CONTENT_AREA %in% c("ELA", "MATHEMATICS") & YEAR %in% c("2018", "2019") & !is.na(SGP) & !is.na(NO_SKIP_SGP),
                        list(
                            MEAN_NO_SKIP_SGP=mean(NO_SKIP_SGP, na.rm=TRUE),
                            MEAN_SKIP_SGP=mean(SGP, na.rm=TRUE),
                            MEAN_NO_SKIP_PRIOR_STANDARDIZED=mean(NO_SKIP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                            MEAN_SKIP_PRIOR_STANDARDIZED=mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                        #   PERCENT_FREE_REDUCED_LUNCH=100*prop.table(table(FREE_REDUCED_LUNCH_STATUS))[2],
                            COUNT_NO_SKIP_SGP=sum(!is.na(NO_SKIP_SGP)),
                            COUNT_SKIP_SGP=sum(!is.na(SGP)),
                            GRADE_RANGE=paste(as.character(range(GRADE)), collapse=" ")),
                        keyby=c("SCHOOL_NUMBER", "CONTENT_AREA")][,DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP:=abs(MEAN_SKIP_SGP-MEAN_NO_SKIP_SGP)]



### Correlations between skip-year SGPs and one-year SGPs by School, and CONTENT_AREA

Indiana.school.correlations <- Indiana.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="complete.obs"), COUNT=.N),
                        keyby=c("CONTENT_AREA")]
print(Indiana.school.correlations)

Indiana.school.correlations.SAME.STUDENTS <- Indiana.school.summaries.SAME.STUDENTS[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(COR_SKIP_NO_SKIP_MEAN_SGP=cor(MEAN_NO_SKIP_SGP, MEAN_SKIP_SGP, use="complete.obs"), COUNT=.N),
                        keyby=c("CONTENT_AREA")]
print(Indiana.school.correlations.SAME.STUDENTS)

### Absolute differences between SKIP-YEAR and ONE-YEAR SGPs

Indiana.school.absolute.difference <- Indiana.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(MEDIAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=median(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            MEAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=mean(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            NINETY_FIFTH_PERCENTILE_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=quantile(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP, probs=0.95, na.rm=TRUE),
                            MEDIAN_COUNT_NO_SKIP_SGP=as.numeric(median(COUNT_NO_SKIP_SGP)),
                            MEDIAN_COUNT_SKIP_SGP=as.numeric(median(COUNT_SKIP_SGP))),
                        by=c("CONTENT_AREA")]
print(Indiana.school.absolute.difference)

Indiana.school.absolute.difference.SAME.STUDENTS <- Indiana.school.summaries.SAME.STUDENTS[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(MEDIAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=median(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            MEAN_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=mean(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP),
                            NINETY_FIFTH_PERCENTILE_DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP=quantile(DIFFERENCE_SKIP_NO_SKIP_MEAN_SGP, probs=0.95, na.rm=TRUE),
                            MEDIAN_COUNT_NO_SKIP_SGP=as.numeric(median(COUNT_NO_SKIP_SGP)),
                            MEDIAN_COUNT_SKIP_SGP=as.numeric(median(COUNT_SKIP_SGP))),
                        by=c("CONTENT_AREA")]
print(Indiana.school.absolute.difference.SAME.STUDENTS)

### Correlation between mean SGP and mean prior achievement

Indiana.school.Prior.Achievement.correlations <- Indiana.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_SKIP_SGP, MEAN_SKIP_PRIOR_STANDARDIZED, use="complete.obs"),
                            COR_NO_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_NO_SKIP_SGP, MEAN_NO_SKIP_PRIOR_STANDARDIZED, use="complete.obs")
                        ),
                        keyby=c("CONTENT_AREA")]
print(Indiana.school.Prior.Achievement.correlations)

Indiana.school.Prior.Achievement.correlations.SAME.STUDENTS <- Indiana.school.summaries.SAME.STUDENTS[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
                        list(
                            COR_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_SKIP_SGP, MEAN_SKIP_PRIOR_STANDARDIZED, use="complete.obs"),
                            COR_NO_SKIP_SGP_PRIOR_ACHIEVEMENT=cor(MEAN_NO_SKIP_SGP, MEAN_NO_SKIP_PRIOR_STANDARDIZED, use="complete.obs")
                        ),
                        keyby=c("CONTENT_AREA")]
print(Indiana.school.Prior.Achievement.correlations.SAME.STUDENTS)

### Correlation between mean SGP and percent free/reduced lunch

#Indiana.school.percent.free.reduced.lunch.correlations <- Indiana.school.summaries[COUNT_NO_SKIP_SGP>=10 & COUNT_SKIP_SGP>=10,
#                        list(
#                            COR_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="complete.obs"),
#                            COR_NO_SKIP_SGP_FREE_REDUCED_LUNCH=cor(MEAN_NO_SKIP_SGP, PERCENT_FREE_REDUCED_LUNCH, use="complete.obs")
#                        ),
#                        keyby=c("CONTENT_AREA")]
#print(Indiana.school.percent.free.reduced.lunch.correlations)
