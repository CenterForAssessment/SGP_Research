##########
#####
###   Summarize SGP and Imputed Scale Score Results by 1) Amputation and 2) Imputation
#####
##########

###   Load packages
require(data.table)

###   Set working directory to the "Summary_Tables" subdirectory
setwd("Data/IMPUTATION_SIMULATION/NO_IMPACT/MISSING_30/MCAR/Summary_Tables")

###   Load summary tables
for (f in list.files()) load(f)

###   Algorithm Comparison
PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
L2LMER_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
L2PAN_LONG_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores
L2LMER_LONG_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Comparison"]][, 1:6]  #  Scale Scores

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
      copy(L2LMER_LONG_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2l.lmer LONG"],
      copy(L2PAN_LONG_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2l.pan LONG"],
      copy(L2LMER_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2l.lmer"],
      copy(L2PAN_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "2l.pan"],
      copy(RQ_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "rq"],
      copy(PMM_Summaries[["SCHOOL"]][["GRADE_CONTENT"]][["Evaluation"]])[, Algorithm := "pmm"],
      Observed
))

ALL_Summaries_SCH_GC[, Algorithm := factor(Algorithm, levels = rev(c("None", "pmm", "rq", "2l.pan", "2l.lmer", "2l.pan LONG", "2l.lmer LONG")))] # , "2L_PMM", "2L_NORM"

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SS_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean Scale Score by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SGP_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean SGP by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p

p <- ggplot(ALL_Summaries_SCH_GC, aes(x=SGPB_Raw_Bias, y=Algorithm)) + geom_boxplot() +
      labs(title="School-Level Mean Baseline SGP by Grade by Content Area: ", x="Raw Bias", y = "Algorithm")
p
