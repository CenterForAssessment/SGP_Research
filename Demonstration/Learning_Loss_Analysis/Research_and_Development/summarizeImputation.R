##########
#####
###   Summarize SGP and Imputed Scale Score Results by 1) Imputation and 2) Amputation
#####
##########

summarizeImputation <- function(
  data,
  institution.level = NULL,
  summary.level = NULL,
  extra.table=FALSE
) {

  ###   Load packages
  require(data.table)

  # se <- function(x, na.rm=FALSE) {
  #   if (na.rm) x <- na.omit(x)
  #   sqrt(var(x)/length(x))
  # }

#####
###   summarize at institution.level and summary.level first -- 1 for each IMP/AMP
###   This is eq Qhat_l 2.16 -- https://stefvanbuuren.name/fimd/sec-whyandwhen.html
#####

  smry_amp <- data[, list(
        Mean_SS_Complete = mean(SCALE_SCORE_COMPLETE, na.rm = TRUE),
        Mean_SS_Observed = mean(SCALE_SCORE_OBSERVED, na.rm = TRUE),
        Mean_SS_Imputed = mean(SCALE_SCORE_IMPUTED, na.rm = TRUE),  #  Q_l_SS
        SS_U_Imp = var(SCALE_SCORE_IMPUTED, na.rm = TRUE),  #  Ubar_l_SS
        # SS_U_Imp2 = ((mean(SCALE_SCORE^2, na.rm = TRUE)) - mean(SCALE_SCORE, na.rm = TRUE)^2),  #  Ubar_l_SS alternative (always smaller)
        Mean_SGP_Complete = mean(SGP_COMPLETE, na.rm = TRUE),
        Mean_SGP_Observed = mean(SGP_OBSERVED, na.rm = TRUE),
        Mean_SGP_Imputed = mean(SGP_IMPUTED, na.rm = TRUE),  #  Q_l_SGP
        SGP_U_Imp = var(SGP_IMPUTED, na.rm = TRUE),  #  Ubar_l_SGP
        Mean_SGPB_Complete = mean(SGP_BASELINE_COMPLETE, na.rm = TRUE),
        Mean_SGPB_Observed = mean(SGP_BASELINE_OBSERVED, na.rm = TRUE),
        Mean_SGPB_Imputed = mean(SGP_BASELINE_IMPUTED, na.rm = TRUE),  #  Q_l_SGP_Baseline
        SGPB_U_Imp = var(SGP_BASELINE_IMPUTED, na.rm = TRUE),  #  Ubar_l_SGP_Baseline
        Percent_Missing = (sum(is.na(SCALE_SCORE_OBSERVED))/.N)*100, N=.N),
    keyby=c(institution.level, summary.level, "AMP_N", "IMP_N")]

  ##    Long-hand verification of stat calculations
  # smry_amp[, Mean_SS_Qbar := mean(Mean_SS_Imputed, na.rm = TRUE), keyby=c(summary.level)]
  # smry_amp[, Mean_SGP_Qbar := mean(Mean_SGP_Imputed, na.rm = TRUE), keyby=c(summary.level)]
  # smry_amp[, Mean_SGPB_Qbar := mean(Mean_SGPB_Imputed, na.rm = TRUE), keyby=c(summary.level)]

  ##  Does not add anything to do regressions at this high level of summaries
  # if (extra.table) {
  #   smry_amp_extra <- copy(smry_amp[,
  #     c(institution.level, summary.level, "AMP_N", "IMP_N", grep("Mean_", names(smry_amp), value=T), "Percent_Missing", "N"), with=FALSE])
  #   smry_amp_extra[, SS_Obs_Raw_Bias := Mean_SS_Observed - Mean_SS_Complete]
  #   smry_amp_extra[, SGP_Obs_Raw_Bias := Mean_SGP_Observed - Mean_SGP_Complete]
  #   smry_amp_extra[, SGPB_Obs_Raw_Bias := Mean_SGPB_Observed - Mean_SGPB_Complete]
  #
  #   smry_amp_extra[, SS_Raw_Bias := Mean_SS_Imputed - Mean_SS_Complete]
  #   smry_amp_extra[, SGP_Raw_Bias := Mean_SGP_Imputed - Mean_SGP_Complete]
  #   smry_amp_extra[, SGPB_Raw_Bias := Mean_SGPB_Imputed - Mean_SGPB_Complete]
  # }

  #####
  ###   Pool results at institution.level and summary.level over imputations -- 1 for each IMP
  #####

  MM <- max(smry_amp$IMP_N)

  smry_amp_pool <- smry_amp[, list(
      Mean_SS_Complete = Mean_SS_Complete[1],
      Mean_SS_Observed = mean(Mean_SS_Observed, na.rm = TRUE), # should be the same as Mean_SS_Observed[1] here - same within imp
      Mean_SS_Imputed = mean(Mean_SS_Imputed, na.rm = TRUE),
      SS_U_bar = mean(SS_U_Imp, na.rm = TRUE),
      SS_B = var(Mean_SS_Imputed),
      # SS_B = sum((Mean_SS_Imputed - Mean_SS_Qbar)^2)/(MM-1), # B - eq 2.19
      Mean_SGP_Complete = Mean_SGP_Complete[1],
      Mean_SGP_Observed = Mean_SGP_Observed[1],
      Mean_SGP_Imputed = mean(Mean_SGP_Imputed, na.rm = TRUE),
      SGP_U_bar = mean(SGP_U_Imp, na.rm = TRUE),
      SGP_B = var(Mean_SGP_Imputed),
      # SGP_B = sum((Mean_SGP_Imputed - Mean_SGP_Qbar)^2)/(MM-1), # B - eq 2.19
      Mean_SGPB_Complete = Mean_SGPB_Complete[1],
      Mean_SGPB_Observed = Mean_SGPB_Observed[1],
      Mean_SGPB_Imputed = mean(Mean_SGPB_Imputed, na.rm = TRUE),
      SGPB_U_bar = mean(SGPB_U_Imp, na.rm = TRUE),
      SGPB_B = var(Mean_SGPB_Imputed),
      Percent_Missing = Percent_Missing[1], N=N[1]),
    keyby=c(institution.level, summary.level, "AMP_N")]

  if (extra.table) {
    smry_amp_extra <- copy(smry_amp_pool[,
      c(institution.level, summary.level, "AMP_N", grep("Mean_", names(smry_amp_pool), value=T), "Percent_Missing", "N"), with=FALSE])
    smry_amp_extra[, SS_Obs_Raw_Bias := Mean_SS_Observed - Mean_SS_Complete]
    smry_amp_extra[, SGP_Obs_Raw_Bias := Mean_SGP_Observed - Mean_SGP_Complete]
    smry_amp_extra[, SGPB_Obs_Raw_Bias := Mean_SGPB_Observed - Mean_SGPB_Complete]

    smry_amp_extra[, SS_Raw_Bias := Mean_SS_Imputed - Mean_SS_Complete]
    smry_amp_extra[, SGP_Raw_Bias := Mean_SGP_Imputed - Mean_SGP_Complete]
    smry_amp_extra[, SGPB_Raw_Bias := Mean_SGPB_Imputed - Mean_SGPB_Complete]
  }

  ##    T - Total Variance
  smry_amp_pool[, SS_T := SS_U_bar + (1 + 1/MM)*SS_B]
  smry_amp_pool[, SGP_T := SGP_U_bar + (1 + 1/MM)*SGP_B]
  smry_amp_pool[, SGPB_T := SGPB_U_bar + (1 + 1/MM)*SGPB_B]

  ###   Variance Ratios :: 2.3.5

  ##    Lambda -- proportion of variation attributed to the missing data. eq 2.24
  smry_amp_pool[, SS_Lamda := ((SS_B + SS_B/MM)/SS_T)]
  smry_amp_pool[, SGP_Lamda := ((SGP_B + SGP_B/MM)/SGP_T)]
  smry_amp_pool[, SGPB_Lamda := ((SGPB_B + SGPB_B/MM)/SGPB_T)]

  ##    RIV (r) -- relative increase in variance due to nonresponse. eq 2.25
  # smry_amp_pool[, SS_RIV := ((SS_B + SS_B/MM)/SS_U_bar)]
  smry_amp_pool[, SS_RIV := (SS_Lamda/(1-SS_Lamda))]
  smry_amp_pool[, SGP_RIV := (SGP_Lamda/(1-SGP_Lamda))]
  smry_amp_pool[, SGPB_RIV := (SGPB_Lamda/(1-SGPB_Lamda))]

  ##    Adjusted Degrees of Freedom -- eq 2.31
  smry_amp_pool[, SS_ADF := (((N-1)+1)/((N-1)+3))*((N-1)*(1-SS_Lamda))]
  smry_amp_pool[, SGP_ADF := (((N-1)+1)/((N-1)+3))*((N-1)*(1-SGP_Lamda))]
  smry_amp_pool[, SGPB_ADF := (((N-1)+1)/((N-1)+3))*((N-1)*(1-SGPB_Lamda))]

  ##    Gamma -- fraction of information about Q missing due to nonresponse
  # smry_amp_pool[, SS_Gamma2 := (((SS_ADF+1)/(SS_ADF+3))*SS_Lamda) + (2/(SS_ADF+3))]
  smry_amp_pool[, SS_Gamma := (SS_RIV+(2/(SS_ADF+3)))/(1+SS_RIV)] # cor(smry_amp_pool[, SS_Gamma2, SS_Gamma])
  smry_amp_pool[, SGP_Gamma := (SGP_RIV+(2/(SGP_ADF+3)))/(1+SGP_RIV)]
  smry_amp_pool[, SGPB_Gamma := (SGP_RIV+(2/(SGPB_ADF+3)))/(1+SGPB_RIV)]


  ###   Statistical Inference -- Section 2.4.2

  ##    Confidence intervals
  smry_amp_pool[!is.na(SS_ADF) & SS_ADF != 0, SS_tStat := qt(0.975, df=SS_ADF)*(sqrt(SS_T))]
  smry_amp_pool[!is.na(SGP_ADF) & SGP_ADF != 0, SGP_tStat := qt(0.975, df=SGP_ADF)*(sqrt(SGP_T))]
  smry_amp_pool[!is.na(SGPB_ADF) & SGPB_ADF != 0, SGPB_tStat := qt(0.975, df=SGPB_ADF)*(sqrt(SGPB_T))]

  smry_amp_pool[!is.na(SS_tStat), SS_CI_low := Mean_SS_Imputed-SS_tStat]
  smry_amp_pool[!is.na(SS_tStat), SS_CI_high := Mean_SS_Imputed+SS_tStat]
  smry_amp_pool[!is.na(SS_tStat), SS_CIW := SS_CI_high - SS_CI_low]

  smry_amp_pool[!is.na(SGP_tStat), SGP_CI_low := Mean_SGP_Imputed - SGP_tStat]
  smry_amp_pool[!is.na(SGP_tStat), SGP_CI_high := Mean_SGP_Imputed + SGP_tStat]
  smry_amp_pool[!is.na(SGP_tStat), SGP_CIW := SGP_CI_high - SGP_CI_low]

  smry_amp_pool[!is.na(SGPB_tStat), SGPB_CI_low := Mean_SGPB_Imputed - SGPB_tStat]
  smry_amp_pool[!is.na(SGPB_tStat), SGPB_CI_high := Mean_SGPB_Imputed + SGPB_tStat]
  smry_amp_pool[!is.na(SGPB_tStat), SGPB_CIW := SGPB_CI_high - SGPB_CI_low]

  ##    Simplified Confidence Invervals - when you have entire population, see Vink and Van Buuren, 2014
  nu <- MM-1
  qtSimp <- qt(0.975, df=nu)
  #  (1 + 1/MM)*SS_B is the "simplified" T value (U_bar = 0)
  smry_amp_pool[!is.na(SS_B) & SS_B != 0, SS_tSimp := qtSimp*(sqrt((1 + 1/MM)*SS_B))]
  smry_amp_pool[!is.na(SGP_B) & SGP_B != 0, SGP_tSimp := qtSimp*(sqrt((1 + 1/MM)*SGP_B))]
  smry_amp_pool[!is.na(SGPB_B) & SGPB_B != 0, SGPB_tSimp := qtSimp*(sqrt((1 + 1/MM)*SGPB_B))]

  smry_amp_pool[!is.na(SS_tSimp), SS_CI_low_simp := Mean_SS_Imputed-SS_tSimp]
  smry_amp_pool[!is.na(SS_tSimp), SS_CI_high_simp := Mean_SS_Imputed+SS_tSimp]
  smry_amp_pool[!is.na(SS_tSimp), SS_CIW_simp := SS_CI_high_simp - SS_CI_low_simp]

  smry_amp_pool[!is.na(SGP_tSimp), SGP_CI_low_simp := Mean_SGP_Imputed - SGP_tSimp]
  smry_amp_pool[!is.na(SGP_tSimp), SGP_CI_high_simp := Mean_SGP_Imputed + SGP_tSimp]
  smry_amp_pool[!is.na(SGP_tSimp), SGP_CIW_simp := SGP_CI_high_simp - SGP_CI_low_simp]

  smry_amp_pool[!is.na(SGPB_tSimp), SGPB_CI_low_simp := Mean_SGPB_Imputed - SGPB_tSimp]
  smry_amp_pool[!is.na(SGPB_tSimp), SGPB_CI_high_simp := Mean_SGPB_Imputed + SGPB_tSimp]
  smry_amp_pool[!is.na(SGPB_tSimp), SGPB_CIW_simp := SGPB_CI_high_simp - SGPB_CI_low_simp]


  ###   Analyses done across all amputed data sets:
  ###   Explore "proper"ness ("proper"ties?) of the estimates :: Sections 2.3.3 & 2.5.2

  ##    Unbiased Mean Estimates

  smry_all_pool <- smry_amp_pool[, list(
      Mean_SS_Complete = Mean_SS_Complete[1],
      Mean_SGP_Complete = Mean_SGP_Complete[1],
      Mean_SGPB_Complete = Mean_SGPB_Complete[1],

      Mean_SS_Observed = mean(Mean_SS_Observed, na.rm = TRUE), # should be different than Mean_SS_Observed[1] here - diff between AMP
      Mean_SGP_Observed = mean(Mean_SGP_Observed, na.rm = TRUE),
      Mean_SGPB_Observed = mean(Mean_SGPB_Observed, na.rm = TRUE),

      SS_Obs_Raw_Bias = (mean(Mean_SS_Observed, na.rm=TRUE) - Mean_SS_Complete[1]),
      SGP_Obs_Raw_Bias = (mean(Mean_SGP_Observed, na.rm=TRUE) - Mean_SGP_Complete[1]),
      SGPB_Obs_Raw_Bias = (mean(Mean_SGPB_Observed, na.rm=TRUE) - Mean_SGPB_Complete[1]),

      Mean_SS_Imputed = mean(Mean_SS_Imputed, na.rm=TRUE),
      Mean_SGP_Imputed= mean(Mean_SGP_Imputed, na.rm=TRUE),
      Mean_SGPB_Imputed = mean(Mean_SGPB_Imputed, na.rm=TRUE),

      SS_T = mean(SS_T, na.rm = TRUE),
      SS_B = mean(SS_B, na.rm = TRUE),
      SS_ADF = mean(SS_ADF, na.rm = TRUE),

      SGP_T = mean(SGP_T, na.rm = TRUE),
      SGP_B = mean(SGP_B, na.rm = TRUE),
      SGP_ADF = mean(SGP_ADF, na.rm = TRUE),

      SGPB_T = mean(SGP_T, na.rm = TRUE),
      SGPB_B = mean(SGP_B, na.rm = TRUE),
      SGPB_ADF = mean(SGP_ADF, na.rm = TRUE),

      SS_Raw_Bias = (mean(Mean_SS_Imputed, na.rm=TRUE) - Mean_SS_Complete[1]),
      SS_Coverage = mean((SS_CI_low < Mean_SS_Complete) & (Mean_SS_Complete < SS_CI_high), na.rm = TRUE),
      SS_Mean_CIW = mean(SS_CIW, na.rm = TRUE),
      # SS_Mean_CIW2 = mean((SS_CI_high - SS_CI_low), na.rm = TRUE),
      SS_Coverage_Simp = mean((SS_CI_low_simp < Mean_SS_Complete) & (Mean_SS_Complete < SS_CI_high_simp), na.rm = TRUE),
      SS_Mean_CIW_Simp = mean(SS_CIW_simp, na.rm = TRUE),
      SS_RIV = mean(SS_RIV, na.rm=TRUE),
      SS_Lamda = mean(SS_Lamda, na.rm=TRUE),
      SS_Gamma = mean(SS_Gamma, na.rm=TRUE),
      SS_RMSE = sqrt(mean(((Mean_SS_Imputed - Mean_SS_Complete[1])^2), na.rm=TRUE)),

      SGP_Raw_Bias = (mean(Mean_SGP_Imputed, na.rm=TRUE) - Mean_SGP_Complete[1]),
      SGP_Coverage = mean((SGP_CI_low < Mean_SGP_Complete) & (Mean_SGP_Complete < SGP_CI_high), na.rm = TRUE),
      SGP_Mean_CIW = mean(SGP_CIW, na.rm = TRUE),
      SGP_Coverage_Simp = mean((SGP_CI_low_simp < Mean_SGP_Complete) & (Mean_SGP_Complete < SGP_CI_high_simp), na.rm = TRUE),
      SGP_Mean_CIW_Simp = mean(SGP_CIW_simp, na.rm = TRUE),
      SGP_RIV = mean(SGP_RIV, na.rm=TRUE),
      SGP_Lamda = mean(SGP_Lamda, na.rm=TRUE),
      SGP_Gamma = mean(SGP_Gamma, na.rm=TRUE),
      SGP_RMSE = sqrt(mean(((Mean_SGP_Imputed - Mean_SGP_Complete[1])^2), na.rm=TRUE)),

      SGPB_Raw_Bias = (mean(Mean_SGPB_Imputed, na.rm=TRUE) - Mean_SGPB_Complete[1]),
      SGPB_Coverage = mean((SGPB_CI_low < Mean_SGPB_Complete) & (Mean_SGPB_Complete < SGPB_CI_high), na.rm = TRUE),
      SGPB_Mean_CIW = mean(SGPB_CIW, na.rm = TRUE),
      SGPB_Coverage_Simp = mean((SGPB_CI_low_simp < Mean_SGPB_Complete) & (Mean_SGPB_Complete < SGPB_CI_high_simp), na.rm = TRUE),
      SGPB_Mean_CIW_Simp = mean(SGPB_CIW_simp, na.rm = TRUE),
      SGPB_RIV = mean(SGPB_RIV, na.rm=TRUE),
      SGPB_Lamda = mean(SGPB_Lamda, na.rm=TRUE),
      SGPB_Gamma = mean(SGPB_Gamma, na.rm=TRUE),
      SGPB_RMSE = sqrt(mean(((Mean_SGPB_Imputed - Mean_SGPB_Complete[1])^2), na.rm=TRUE)),

      Percent_Missing = mean(Percent_Missing, na.rm = TRUE), N = mean(N, na.rm = TRUE)),
    keyby=c(institution.level, summary.level)]

  smry_all_pool[, SS_Pct_Bias := 100*(abs(SS_Raw_Bias/Mean_SS_Complete))]
  smry_all_pool[, SGP_Pct_Bias := 100*(abs(SGP_Raw_Bias/Mean_SGP_Complete))]
  smry_all_pool[, SGPB_Pct_Bias := 100*(abs(SGPB_Raw_Bias/Mean_SGPB_Complete))]

  ##    F-test of NULL hypotheses (F1 - Complete vs Imputed, F2 - Observed vs Imputed)
  smry_all_pool[, SS_F1_Stat := ((Mean_SS_Complete - Mean_SS_Imputed)^2)/SS_T]
  smry_all_pool[!is.na(SS_ADF) & SS_ADF != 0, SS_F1_pValue := pf(SS_F1_Stat, df1=1, df2=SS_ADF, lower.tail=FALSE)]
  smry_all_pool[, SS_F2_Stat := ((Mean_SS_Observed - Mean_SS_Imputed)^2)/SS_T]
  smry_all_pool[!is.na(SS_ADF) & SS_ADF != 0, SS_F2_pValue := pf(SS_F2_Stat, df1=1, df2=SS_ADF, lower.tail=FALSE)]

  smry_all_pool[, SS_F1_Simp := ((Mean_SS_Complete - Mean_SS_Imputed)^2)/((1 + 1/MM)*SS_B)]
  smry_all_pool[, SS_F1_pSimp := pf(SS_F1_Simp, df1=1, df2=nu, lower.tail=FALSE)]
  smry_all_pool[, SS_F2_Simp := ((Mean_SS_Observed - Mean_SS_Imputed)^2)/((1 + 1/MM)*SS_B)]
  smry_all_pool[, SS_F2_pSimp := pf(SS_F2_Simp, df1=1, df2=nu, lower.tail=FALSE)]

  smry_all_pool[, SGP_F1_Stat := ((Mean_SGP_Complete - Mean_SGP_Imputed)^2)/SGP_T]
  smry_all_pool[!is.na(SGP_ADF) & SGP_ADF != 0, SGP_F1_pValue := pf(SGP_F1_Stat, df1=1, df2=SGP_ADF, lower.tail=FALSE)]
  smry_all_pool[, SGP_F2_Stat := ((Mean_SGP_Observed - Mean_SGP_Imputed)^2)/SGP_T]
  smry_all_pool[!is.na(SGP_ADF) & SGP_ADF != 0, SGP_F2_pValue := pf(SGP_F2_Stat, df1=1, df2=SGP_ADF, lower.tail=FALSE)]

  smry_all_pool[, SGP_F1_Simp := ((Mean_SGP_Complete - Mean_SGP_Imputed)^2)/((1 + 1/MM)*SGP_B)]
  smry_all_pool[, SGP_F1_pSimp := pf(SGP_F1_Simp, df1=1, df2=nu, lower.tail=FALSE)]
  smry_all_pool[, SGP_F2_Simp := ((Mean_SGP_Observed - Mean_SGP_Imputed)^2)/((1 + 1/MM)*SGP_B)]
  smry_all_pool[, SGP_F2_pSimp := pf(SGP_F2_Simp, df1=1, df2=nu, lower.tail=FALSE)]

  smry_all_pool[, SGPB_F1_Stat := ((Mean_SGPB_Complete - Mean_SGPB_Imputed)^2)/SGPB_T]
  smry_all_pool[!is.na(SGPB_ADF) & SGPB_ADF != 0, SGPB_F1_pValue := pf(SGPB_F1_Stat, df1=1, df2=SGPB_ADF, lower.tail=FALSE)]
  smry_all_pool[, SGPB_F2_Stat := ((Mean_SGPB_Observed - Mean_SGPB_Imputed)^2)/SGPB_T]
  smry_all_pool[!is.na(SGPB_ADF) & SGPB_ADF != 0, SGPB_F2_pValue := pf(SGPB_F2_Stat, df1=1, df2=SGPB_ADF, lower.tail=FALSE)]

  smry_all_pool[, SGPB_F1_Simp := ((Mean_SGPB_Complete - Mean_SGPB_Imputed)^2)/((1 + 1/MM)*SGPB_B)]
  smry_all_pool[, SGPB_F1_pSimp := pf(SGPB_F1_Simp, df1=1, df2=nu, lower.tail=FALSE)]
  smry_all_pool[, SGPB_F2_Simp := ((Mean_SGPB_Observed - Mean_SGPB_Imputed)^2)/((1 + 1/MM)*SGPB_B)]
  smry_all_pool[, SGPB_F2_pSimp := pf(SGPB_F2_Simp, df1=1, df2=nu, lower.tail=FALSE)]

  #####
  ###   Overall Summary/Comparison of Imputed vs Observed (w.r.t. Complete)
  #####

  overall_smry <- smry_all_pool[, list(
      Mean_SS_Diff_Comp_Obs = round(mean(Mean_SS_Complete-Mean_SS_Observed, na.rm=TRUE), 3),
      Mean_SS_Diff_Comp_Imp = round(mean(Mean_SS_Complete-Mean_SS_Imputed, na.rm=TRUE), 3),
      Cor_SS_Comp_Obs = round(cor(Mean_SS_Complete, Mean_SS_Observed, use="na.or.complete"), 3),
      Cor_SS_Comp_Imp = round(cor(Mean_SS_Complete, Mean_SS_Imputed, use="na.or.complete"), 3),

      Mean_SGP_Diff_Comp_Obs = round(mean(Mean_SGP_Complete-Mean_SGP_Observed, na.rm=TRUE), 3),
      Mean_SGP_Diff_Comp_Imp = round(mean(Mean_SGP_Complete-Mean_SGP_Imputed, na.rm=TRUE), 3),
      Cor_SGP_Comp_Obs = round(cor(Mean_SGP_Complete, Mean_SGP_Observed, use="na.or.complete"), 3),
      Cor_SGP_Comp_Imp = round(cor(Mean_SGP_Complete, Mean_SGP_Imputed, use="na.or.complete"), 3),

      Mean_SGPB_Diff_Comp_Obs = round(mean(Mean_SGPB_Complete-Mean_SGPB_Observed, na.rm=TRUE), 3),
      Mean_SGPB_Diff_Comp_Imp = round(mean(Mean_SGPB_Complete-Mean_SGPB_Imputed, na.rm=TRUE), 3),
      Cor_SGPB_Comp_Obs = round(cor(Mean_SGPB_Complete, Mean_SGPB_Observed, use="na.or.complete"), 3),
      Cor_SGPB_Comp_Imp = round(cor(Mean_SGPB_Complete, Mean_SGPB_Imputed, use="na.or.complete"), 3)
  ), keyby=summary.level]
  if (extra.table) {
    list(Amp_Level = smry_amp_extra, Evaluation = smry_all_pool, Comparison = overall_smry)
  } else list(Evaluation = smry_all_pool, Comparison = overall_smry)
}
