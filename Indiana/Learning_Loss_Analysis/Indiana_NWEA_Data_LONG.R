#######################################################################################
###
### Script for create NWEA LONG data file for summary analyses
###
#######################################################################################

### Load packages

require(data.table)


### Load data

#tmp.fall <- fread("Data/Base_Files/NWEA_FALL_2020_2021.txt")
#tmp.winter <- fread("Data/Base_Files/NWEA_WINTER_2020_2021.txt")

#tmp.nwea.data <- rbindlist(list(tmp.fall, tmp.winter))

### Investigate properties of SGPs

#round(prop.table(table(tmp.fall[Subject=="Language Arts" & GRADE_ID==3]$FallToFallConditionalGrowthPercentile)), digits=2)
#round(prop.table(table(tmp.fall[Subject=="Language Arts" & GRADE_ID==4]$FallToFallConditionalGrowthPercentile)), digits=2)

#for (content_area.iter in c("Language Arts", "Mathematics")) {
#    for (grade.iter in 1:8) {
#        pdf(file=paste0(content_area.iter, "_", grade.iter, ".pdf"), width="11in", height="8.5in")
#            tmp.data <- tmp.nwea.data[Subject==content_area.iter & GRADE_ID==grade.iter]
#            plot(tmp.data$TestPercentile, tmp.data$FallToFallConditionalGrowthPercentile, xlab="Status Percentile", ylab="Fall-to-Fall Student Growth Percentile",
#                    main=paste("Status by Growth: Grade", grade.iter, "content_area.iter"))
#        dev.off()
#    }
#}

#count.function <- function(tmp.data, upper.number){
#    tmp.table <- table(tmp.data)
#    100*sum(tmp.table[1:upper.number])/sum(tmp.table)
#}

#tmp.nwea.data[Subject=="Language Arts" & GRADE_ID==3][!is.na(FallToFallConditionalGrowthPercentile), list(SGP_1_to_5=count.function(FallToFallConditionalGrowthPercentile, 5)), keyby="TestPercentile"]



### Look at some summaries

tmp.nwea.FALL_to_FALL.data <- tmp.nwea.data[!is.na(FallToFallConditionalGrowthPercentile),list(MEAN_FALL_TO_FALL_SGP=round(mean(FallToFallConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject","GRADE_ID")]
tmp.nwea.WINTER_to_WINTER.data <- tmp.nwea.data[!is.na(WinterToWinterConditionalGrowthPercentile),list(MEAN_WINTER_TO_WINTER_SGP=round(mean(WinterToWinterConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject", "GRADE_ID")]
tmp.nwea.FALL_to_WINTER.data <- tmp.nwea.data[!is.na(FallToWinterConditionalGrowthPercentile),list(MEAN_FALL_TO_WINTER_SGP=round(mean(FallToWinterConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject", "GRADE_ID")]

tmp.nwea.FALL_to_FALL.data.ethnicity <- tmp.nwea.data[!is.na(FallToFallConditionalGrowthPercentile),list(MEAN_FALL_TO_FALL_SGP=round(mean(FallToFallConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject","GRADE_ID", "ETHNICITY")]
tmp.nwea.WINTER_to_WINTER.data.ethnicity <- tmp.nwea.data[!is.na(WinterToWinterConditionalGrowthPercentile),list(MEAN_WINTER_TO_WINTER_SGP=round(mean(WinterToWinterConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject", "GRADE_ID", "ETHNICITY")]
tmp.nwea.FALL_to_WINTER.data.ethnicity <- tmp.nwea.data[!is.na(FallToWinterConditionalGrowthPercentile),list(MEAN_FALL_TO_WINTER_SGP=round(mean(FallToWinterConditionalGrowthPercentile, na.rm=TRUE), digits=1), COUNT=.N), keyby=c("Subject", "GRADE_ID", "ETHNICITY")]
