##########
#####
###   Summarize SGP and Imputed Scale Score Results by 1) Amputation and 2) Imputation
#####
##########

###   Load packages
require(data.table)

source("Step_3d_Summary_Results/summarizeImputation.R")

###   Predictive Mean Matching (PMM)
###   Load data
load("Data/LOW_PARTICIPATION_AMPUTE/MISSING_30/STATUS_w_DEMOG/Imputed_SGP_Data_PMM.rda")

PMM_Summaries <- list()
PMM_Summaries[["STATE"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA")
PMM_Summaries[["STATE"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"))
PMM_Summaries[["DISTRICT"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "DISTRICT_NUMBER")
PMM_Summaries[["DISTRICT"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "DISTRICT_NUMBER")
PMM_Summaries[["SCHOOL"]][["GLOBAL"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = NULL, institution.level = "SCHOOL_NUMBER")
PMM_Summaries[["SCHOOL"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "SCHOOL_NUMBER")
PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "SCHOOL_NUMBER")


###   Quantile Regression (RQ - Qtools)
###   Load data
load("Data/LOW_PARTICIPATION_AMPUTE/MISSING_30/STATUS_w_DEMOG/Imputed_SGP_Data_RQ.rda")

RQ_Summaries <- list()
RQ_Summaries[["STATE"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA")
RQ_Summaries[["STATE"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"))
RQ_Summaries[["DISTRICT"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "DISTRICT_NUMBER")
RQ_Summaries[["DISTRICT"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "DISTRICT_NUMBER")
RQ_Summaries[["SCHOOL"]][["GLOBAL"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = NULL, institution.level = "SCHOOL_NUMBER")
RQ_Summaries[["SCHOOL"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "SCHOOL_NUMBER")
RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "SCHOOL_NUMBER")


###   2-Level (Cross Sectional/Schools) PAN
###   Load data
load("Data/LOW_PARTICIPATION_AMPUTE/MISSING_30/STATUS_w_DEMOG/Imputed_SGP_Data_2L_PAN.rda")

L2PAN_Summaries <- list()
L2PAN_Summaries[["STATE"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA")
L2PAN_Summaries[["STATE"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"))
L2PAN_Summaries[["DISTRICT"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "DISTRICT_NUMBER")
L2PAN_Summaries[["DISTRICT"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "DISTRICT_NUMBER")
L2PAN_Summaries[["SCHOOL"]][["GLOBAL"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = NULL, institution.level = "SCHOOL_NUMBER")
L2PAN_Summaries[["SCHOOL"]][["CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = "CONTENT_AREA", institution.level = "SCHOOL_NUMBER")
L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]] <- summarizeImputation(data = Imputed_SGP_Data_LONG, summary.level = c("GRADE", "CONTENT_AREA"), institution.level = "SCHOOL_NUMBER")

save(list=c("PMM_Summaries", "RQ_Summaries", "L2PAN_Summaries"),
     file = "Data/LOW_PARTICIPATION_AMPUTE/MISSING_30/STATUS_w_DEMOG/Demonstration_COVID_SGP_Imputation_Summaries.Rdata")

###   Algorithm Comparison
PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores

na.omit(PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,7:10)])  #  Cohort SGPs
na.omit(RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,7:10)])  #  Cohort SGPs
na.omit(L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,7:10)])  #  Cohort SGPs

na.omit(PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,11:14)])  #  Baseline SGPs
na.omit(RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,11:14)])  #  Baseline SGPs
na.omit(L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, c(1:2,11:14)])  #  Baseline SGPs

summary(PMM_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Raw_Bias)
summary(PMM_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Pct_Bias)
summary(RQ_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Raw_Bias)
summary(RQ_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Pct_Bias)
summary(L2PAN_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Raw_Bias)
summary(L2PAN_Summaries[["STATE"]][["CONTENT"]][["Evaluation"]]$SS_Pct_Bias)


require(ggplot2)

Observed <- copy(PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "None"]
Observed[, SS_Raw_Bias := SS_Obs_Raw_Bias]
Observed[, SGP_Raw_Bias := SGP_Obs_Raw_Bias]
Observed[, SGPB_Raw_Bias := SGPB_Obs_Raw_Bias]

ALL_Summaries_SCH_GC <- rbindlist(list(
      # copy(L2PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2L_PMM"],
      # copy(L2NORM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2L_NORM"],
      copy(L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2L_PAN"],
      copy(RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "RQ"],
      copy(PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "PMM"],
      Observed
))

ALL_Summaries_SCH_GC[, Algorithm := factor(Algorithm, levels = rev(c("None", "PMM", "RQ", "2L_PAN")))] # , "2L_PMM", "2L_NORM"

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SS_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean Scale Score by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SGP_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean SGP by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SGPB_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean Baseline SGP by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p
