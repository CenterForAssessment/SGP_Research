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
load("Data/ACTUAL/Demonstration_COVID_SGP_2021_ACTUAL.Rdata")
load("Data/ASSESSMENT_CHANGE_2016/Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2016.Rdata")
load("Data/ASSESSMENT_CHANGE_2017/Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2017.Rdata")


### Add calculated SGPs to a single data set
tmp.ACTUAL <- copy(Demonstration_COVID_SGP_2021_ACTUAL@Data)
tmp.ACTUAL[,SGP_BASELINE_ASSESSMENT_CHANGE_2016:=Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2016@Data$SGP_BASELINE]
tmp.ACTUAL[,SGP_BASELINE_ASSESSMENT_CHANGE_2017:=Demonstration_COVID_SGP_2021_ASSESSMENT_CHANGE_2017@Data$SGP_BASELINE]
tmp.ACTUAL <- tmp.ACTUAL[YEAR=="2021"]

### INDIVIDUAL COMPARISONS
print("Individual level correlations by Grade and Content Area\n")
print(cor(tmp.ACTUAL[,c("SGP_BASELINE", "SGP_BASELINE_ASSESSMENT_CHANGE_2016", "SGP_BASELINE_ASSESSMENT_CHANGE_2017"), with=FALSE], use="na.or.complete"))

print(summary(tmp.ACTUAL$SGP_BASELINE - tmp.ACTUAL$SGP_BASELINE_ASSESSMENT_CHANGE_2016))
print(summary(tmp.ACTUAL$SGP_BASELINE - tmp.ACTUAL$SGP_BASELINE_ASSESSMENT_CHANGE_2017))

print(quantile(tmp.ACTUAL$SGP_BASELINE - tmp.ACTUAL$SGP_BASELINE_ASSESSMENT_CHANGE_2016, probs=1:99/100, na.rm=TRUE))
print(quantile(tmp.ACTUAL$SGP_BASELINE - tmp.ACTUAL$SGP_BASELINE_ASSESSMENT_CHANGE_2017, probs=1:99/100, na.rm=TRUE))

### SUMMARY COMPARISONS
print("School level mean SGP correlations by Content Area\n")
tmp.SCHOOL_SUMMARIES <- tmp.ACTUAL[,list(MEAN_SGP_ACTUAL=mean(SGP_BASELINE, na.rm=TRUE), MEAN_SGP_ASSESSMENT_CHANGE_2016=mean(SGP_BASELINE_ASSESSMENT_CHANGE_2016, na.rm=TRUE), MEAN_SGP_ASSESSMENT_CHANGE_2017=mean(SGP_BASELINE_ASSESSMENT_CHANGE_2017, na.rm=TRUE), COUNT=.N), keyby=c("CONTENT_AREA", "SCHOOL_NUMBER")]
print(cor(tmp.SCHOOL_SUMMARIES[,c("MEAN_SGP_ACTUAL", "MEAN_SGP_ASSESSMENT_CHANGE_2016", "MEAN_SGP_ASSESSMENT_CHANGE_2017"), with=FALSE], use="na.or.complete"))

print(summary(tmp.SCHOOL_SUMMARIES$MEAN_SGP_ACTUAL - tmp.SCHOOL_SUMMARIES$MEAN_SGP_ASSESSMENT_CHANGE_2016))
print(summary(tmp.SCHOOL_SUMMARIES$MEAN_SGP_ACTUAL - tmp.SCHOOL_SUMMARIES$MEAN_SGP_ASSESSMENT_CHANGE_2017))

print("District level mean SGP correlations by Content Area\n")
tmp.DISTRICT_SUMMARIES <- tmp.ACTUAL[,list(MEAN_SGP_ACTUAL=mean(SGP_BASELINE, na.rm=TRUE), MEAN_SGP_ASSESSMENT_CHANGE_2016=mean(SGP_BASELINE_ASSESSMENT_CHANGE_2016, na.rm=TRUE), MEAN_SGP_ASSESSMENT_CHANGE_2017=mean(SGP_BASELINE_ASSESSMENT_CHANGE_2017, na.rm=TRUE), COUNT=.N), keyby=c("CONTENT_AREA", "DISTRICT_NUMBER")]
print(cor(tmp.DISTRICT_SUMMARIES[,c("MEAN_SGP_ACTUAL", "MEAN_SGP_ASSESSMENT_CHANGE_2016", "MEAN_SGP_ASSESSMENT_CHANGE_2017"), with=FALSE], use="na.or.complete"))

print(summary(tmp.DISTRICT_SUMMARIES$MEAN_SGP_ACTUAL - tmp.DISTRICT_SUMMARIES$MEAN_SGP_ASSESSMENT_CHANGE_2016))
print(summary(tmp.DISTRICT_SUMMARIES$MEAN_SGP_ACTUAL - tmp.DISTRICT_SUMMARIES$MEAN_SGP_ASSESSMENT_CHANGE_2017))
