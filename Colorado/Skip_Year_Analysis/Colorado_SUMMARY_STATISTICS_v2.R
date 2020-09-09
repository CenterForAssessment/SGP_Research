################################################################################
###                                                                          ###
###      Colorado One-Year Gap SGPs: Student and School-Level Analyses       ###
###                                                                          ###
################################################################################

###   Load required packages
require(SGP)
require(data.table)

###   Load CO Skip-year historical data
load("Data/Colorado_SGP.Rdata")
Colorado_Data <- copy(Colorado_SGP@Data)[SCHOOL_ENROLLMENT_STATUS == "Enrolled School: Yes" & VALID_CASE == "VALID_CASE" & YEAR == '2019']

### Utility function - Assumes first two "levels" are the main dichotomy
percent_demog <- function(demog) {
    return(100*as.numeric(table(demog)[2])/as.numeric(sum(table(demog)[1:2])))
}


Colorado_Data[, SCHOOL_SIZE := .N, by=c("CONTENT_AREA", "GRADE", "YEAR", "SCHOOL_NUMBER")]
Colorado_Data[, SCHOOL_N := length(unique(SCHOOL_NUMBER)), by=c("CONTENT_AREA", "GRADE", "YEAR")]
Colorado_Data[, AVG_SCH_SIZE := ceiling(median(SCHOOL_SIZE)), by=c("CONTENT_AREA", "GRADE", "YEAR")]

set.seed(589)
Colorado_Data[, RAND_KEY := sample(1:nrow(Colorado_Data))]
setkey(Colorado_Data, RAND_KEY)

Colorado_Data[, RAND_SCH_NUM_1 := sample(SCHOOL_NUMBER, .N), by=c("CONTENT_AREA", "GRADE", "YEAR")]
Colorado_Data[, RAND_SCH_SIZE1 := .N, by=c("CONTENT_AREA", "GRADE", "YEAR", "RAND_SCH_NUM_1")]

Colorado_Data[, RAND_SCH_NUM_2 := rep(seq(SCHOOL_N[1]), AVG_SCH_SIZE[1])[1:.N], by=c("CONTENT_AREA", "GRADE", "YEAR")]
Colorado_Data[, RAND_SCH_SIZE2 := .N, by=c("CONTENT_AREA", "GRADE", "YEAR", "RAND_SCH_NUM_2")]
setkeyv(Colorado_Data, SGP:::getKey(Colorado_Data))

table(Colorado_Data[YEAR=='2019', SCHOOL_NUMBER == RAND_SCH_NUM_1, CONTENT_AREA])

Colorado_Data[YEAR == "2019", as.list(summary(SCHOOL_SIZE, na.rm = TRUE)), by = c("CONTENT_AREA", "GRADE")]
Colorado_Data[YEAR == "2019", as.list(summary(RAND_SCH_SIZE1, na.rm = TRUE)), by = c("CONTENT_AREA", "GRADE")] # Should be the same as SCHOOL_SIZE
Colorado_Data[YEAR == "2019", as.list(summary(RAND_SCH_SIZE2, na.rm = TRUE)), by = c("CONTENT_AREA", "GRADE")] # Should NOT be the same as SCHOOL_SIZE (roughly equal size "Schools")

Colorado_Data[YEAR == "2019", list(round(cor(SCHOOL_SIZE, RAND_SCH_SIZE1), 3)), by = c("CONTENT_AREA", "GRADE")]


#####
###   Quick descriptives
#####

Colorado_Data[, DIFF := as.numeric(NA)]
Colorado_Data[, DIFF := SGP - NO_SKIP_SGP]

all.smry <- Colorado_Data[VALID_CASE=='VALID_CASE' & YEAR=='2019' & GRADE %in% 4:8, list(
  Mean_No_Skip = round(mean(NO_SKIP_SGP, na.rm = TRUE), 2),
  SD_No_Skip = round(sd(NO_SKIP_SGP, na.rm = TRUE), 2),
  Mean_Skip = round(mean(SGP, na.rm = TRUE), 2),
  SD_Skip = round(sd(SGP, na.rm = TRUE), 2),
  SGP_Corr = round(cor(NO_SKIP_SGP, SGP, use="pairwise.complete"), 3),
  Total_Students = .N,
  No_Skip_Count = sum(!is.na(NO_SKIP_SGP)),
  Skip_Count = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE)]
all.smry[, Difference := Skip_Count - No_Skip_Count]
all.smry[, Pct_No_Skip := round((No_Skip_Count/Total_Students)*100, 1)]
all.smry[, Pct_Skip := round((Skip_Count/Total_Students)*100, 1)]
all.smry[, Difference_Pct := Pct_Skip - Pct_No_Skip]
all.smry[GRADE %in% 4:8, c(1:8)] # Means/SDs/Cors
all.smry[GRADE %in% 4:8, c(1:2, 8:14)] # Percentages receiving SGPs

frl.smry <- Colorado_Data[VALID_CASE=='VALID_CASE'][YEAR=='2019' & !is.na(FREE_REDUCED_LUNCH_STATUS), list(
  Mean_No_Skip = round(mean(NO_SKIP_SGP, na.rm = TRUE), 2),
  SD_No_Skip = round(sd(NO_SKIP_SGP, na.rm = TRUE), 2),
  Mean_Skip = round(mean(SGP, na.rm = TRUE), 2),
  SD_Skip = round(sd(SGP, na.rm = TRUE), 2),
  Mean_SGP_Change = round(mean(NO_SKIP_SGP - SGP, na.rm = TRUE), 1),
  SGP_Corr = round(cor(NO_SKIP_SGP, SGP, use="pairwise.complete"), 3),
  Total_Students = .N,
  No_Skip_Count = sum(!is.na(NO_SKIP_SGP)),
  Skip_Count = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE, FREE_REDUCED_LUNCH_STATUS)]
frl.smry[, Difference_Count := Skip_Count - No_Skip_Count]
frl.smry[, Pct_No_Skip := round((No_Skip_Count/Total_Students)*100, 1)]
frl.smry[, Pct_Skip := round((Skip_Count/Total_Students)*100, 1)]
frl.smry[, Difference_Pct := Pct_Skip - Pct_No_Skip]
frl.smry[, FREE_REDUCED_LUNCH_STATUS := gsub("Free Reduced Lunch: ", "", FREE_REDUCED_LUNCH_STATUS)]

frl.smry[GRADE %in% 4:8, c(1:10)] # Means/SDs/Cors
frl.smry[GRADE %in% 4:8, c(1:3, 10, 14:16)] # Percentages receiving SGPs

# frl.smry.w <- dcast(frl.smry[GRADE %in% 4:8, c(1:4, 5:7)], ... ~ FREE_REDUCED_LUNCH_STATUS, value.var = names(frl.smry)[4:7], sep=" ")
# frl.pct.w <- dcast(frl.smry[GRADE %in% 4:8, c(1:3, 9, 13:15)], ... ~ FREE_REDUCED_LUNCH_STATUS, value.var = names(frl.smry)[c(4,8:10)], sep=" ")
# frl.pct.w[GRADE==4 & CONTENT_AREA == "ELA"]

ell.smry <- Colorado_Data[VALID_CASE=='VALID_CASE'][YEAR=='2019' & !is.na(ELL_STATUS), list(
  Mean_No_Skip = round(mean(NO_SKIP_SGP, na.rm = TRUE), 2),
  SD_No_Skip = round(sd(NO_SKIP_SGP, na.rm = TRUE), 2),
  Mean_Skip = round(mean(SGP, na.rm = TRUE), 2),
  SD_Skip = round(sd(SGP, na.rm = TRUE), 2),
  Mean_SGP_Change = round(mean(NO_SKIP_SGP - SGP, na.rm = TRUE), 1),
  SGP_Corr = round(cor(NO_SKIP_SGP, SGP, use="pairwise.complete"), 3),
  Total_Students = .N,
  No_Skip_Count = sum(!is.na(NO_SKIP_SGP)),
  Skip_Count = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE, ELL_STATUS)]
ell.smry[, Difference_Count := Skip_Count - No_Skip_Count]
ell.smry[, Pct_No_Skip := round((No_Skip_Count/Total_Students)*100, 1)]
ell.smry[, Pct_Skip := round((Skip_Count/Total_Students)*100, 1)]
ell.smry[, Difference_Pct := Pct_Skip - Pct_No_Skip]
ell.smry[, ELL_STATUS := gsub("ELL: ", "", ELL_STATUS)]

ell.smry[GRADE %in% 4:8, c(1:10)] # Means/SDs/Cors
ell.smry[GRADE %in% 4:8, c(1:3, 10, 14:16)] # Percentages receiving SGPs

table(Colorado_Data[, YEAR, IEP_STATUS])
swd.smry <- Colorado_Data[VALID_CASE=='VALID_CASE'][YEAR=='2019' & !is.na(IEP_STATUS), list(
  Mean_No_Skip = round(mean(NO_SKIP_SGP, na.rm = TRUE), 2),
  SD_No_Skip = round(sd(NO_SKIP_SGP, na.rm = TRUE), 2),
  Mean_Skip = round(mean(SGP, na.rm = TRUE), 2),
  SD_Skip = round(sd(SGP, na.rm = TRUE), 2),
  Mean_SGP_Change = round(mean(NO_SKIP_SGP - SGP, na.rm = TRUE), 1),
  SGP_Corr = round(cor(NO_SKIP_SGP, SGP, use="pairwise.complete"), 3),
  Total_Students = .N,
  No_Skip_Count = sum(!is.na(NO_SKIP_SGP)),
  Skip_Count = sum(!is.na(SGP))), keyby = list(CONTENT_AREA, GRADE, IEP_STATUS)]
swd.smry[, Difference_Count := Skip_Count - No_Skip_Count]
swd.smry[, Pct_No_Skip := round((No_Skip_Count/Total_Students)*100, 1)]
swd.smry[, Pct_Skip := round((Skip_Count/Total_Students)*100, 1)]
swd.smry[, Difference_Pct := Pct_Skip - Pct_No_Skip]
swd.smry[, IEP_STATUS := gsub("IEP: ", "", IEP_STATUS)]
swd.smry[GRADE %in% 4:8, c(1:10)] # Means/SDs/Cor
swd.smry[GRADE %in% 4:8, c(1:3, 10, 14:16)] # Percentages receiving SGPs

Colorado_Data[, PCT_SCHOOL_FRL := percent_demog(FREE_REDUCED_LUNCH_STATUS), by = c("YEAR", "CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")]
Colorado_Data[, PCT_SCHOOL_ELL := percent_demog(ELL_STATUS), by = c("YEAR", "CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")]
Colorado_Data[, PCT_SCHOOL_IEP := percent_demog(IEP_STATUS), by = c("YEAR", "CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")]
Colorado_Data[, as.list(round(summary(PCT_SCHOOL_FRL), 2)), keyby = c("CONTENT_AREA", "GRADE", "YEAR")]  #  make sure calcs look reasonable

indv.cor <- Colorado_Data[VALID_CASE=='VALID_CASE' & YEAR=='2019'][, list(
  Scores_No_Skip = round(cor(SCALE_SCORE, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  Scores_Skip = round(cor(SCALE_SCORE, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  Skip = format(round(cor(SGP, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  SGP_Corr = format(round(cor(NO_SKIP_SGP, SGP, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr = format(round(cor(DIFF, SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2),
  Diff_Corr_X = format(round(cor(DIFF, NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use='pairwise.complete'), 2), nsmall = 2), # 'Unobserved' prior score

  No_Skip = format(round(cor(NO_SKIP_SGP, PCT_SCHOOL_FRL, use='pairwise.complete'), 2), nsmall = 2),
  Skip = format(round(cor(SGP, PCT_SCHOOL_FRL, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, PCT_SCHOOL_ELL, use='pairwise.complete'), 2), nsmall = 2),
  Skip = format(round(cor(SGP, PCT_SCHOOL_ELL, use='pairwise.complete'), 2), nsmall = 2),
  No_Skip = format(round(cor(NO_SKIP_SGP, PCT_SCHOOL_IEP, use='pairwise.complete'), 2), nsmall = 2),
  Skip = format(round(cor(SGP, PCT_SCHOOL_IEP, use='pairwise.complete'), 2), nsmall = 2),

  N_Size = .N), keyby = list(CONTENT_AREA, GRADE)] # , N2 = sum(!is.na(SGP))


#####
###   School Summaries
#####

###   By school (across grades)
sch.msgp <- Colorado_Data[VALID_CASE=='VALID_CASE' & YEAR == "2019" & !is.na(SCHOOL_NUMBER),
              list(
                MEAN_NO_SKIP = mean(NO_SKIP_SGP, na.rm = TRUE),
                SD_NO_SKIP = sd(NO_SKIP_SGP, na.rm = TRUE),
                MEAN_SKIP = mean(SGP, na.rm = TRUE),
                SD_SKIP = sd(SGP, na.rm = TRUE),

                COUNT_NO_SKIP = sum(!is.na(NO_SKIP_SGP)),
                COUNT_SKIP = sum(!is.na(SGP)),
                COUNT_TOTAL = .N,

                MEAN_SCALE_SCORE = mean(SCALE_SCORE, na.rm=TRUE),
                MEAN_SCALE_SCORE_PRIOR = mean(SCALE_SCORE_PRIOR, na.rm=TRUE),
                MEAN_SCALE_SCORE_PRIOR_STANDARDIZED = mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED = mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                PERCENT_FRED = PCT_SCHOOL_FRL[1],
                PERCENT_ELL = PCT_SCHOOL_ELL[1],
                PERCENT_IEP = PCT_SCHOOL_IEP[1]),
              keyby = c("CONTENT_AREA", "SCHOOL_NUMBER")] # "YEAR", SCHOOL_NUMBER RAND_SCH_NUM_1, RAND_SCH_NUM_2

sch.cor <- sch.msgp[COUNT_TOTAL > 9, list(
    Skip_x_No_Skip = round(cor(MEAN_NO_SKIP, MEAN_SKIP, use="complete.obs"), 2),
    Prior_Ach_x_No_Skip = round(cor(MEAN_NO_SKIP, MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2),
    Prior_Ach_x_Skip = round(cor(MEAN_SKIP, MEAN_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2),
    PCT_FRL_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_FRED, use="complete.obs"), 2),
    PCT_FRL_x_Skip = round(cor(MEAN_SKIP, PERCENT_FRED, use="complete.obs"), 2),
    PCT_ELL_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_ELL, use="complete.obs"), 2),
    PCT_ELL_x_Skip = round(cor(MEAN_SKIP, PERCENT_ELL, use="complete.obs"), 2),
    PCT_SWD_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_IEP, use="complete.obs"), 2),
    PCT_SWD_x_Skip = round(cor(MEAN_SKIP, PERCENT_IEP, use="complete.obs"), 2), N = .N), keyby = c("CONTENT_AREA")]

###   By grade within school
sch.grd.msgp <- Colorado_Data[VALID_CASE=='VALID_CASE' & YEAR == "2019" & !is.na(SCHOOL_NUMBER),
              list(
                MEAN_NO_SKIP = mean(NO_SKIP_SGP, na.rm = TRUE),
                SD_NO_SKIP = sd(NO_SKIP_SGP, na.rm = TRUE),
                MEAN_SKIP = mean(SGP, na.rm = TRUE),
                SD_SKIP = sd(SGP, na.rm = TRUE),

                COUNT_NO_SKIP = sum(!is.na(NO_SKIP_SGP)),
                COUNT_SKIP = sum(!is.na(SGP)),
                COUNT_TOTAL = .N,

                MEAN_SCALE_SCORE = mean(SCALE_SCORE, na.rm=TRUE),
                MEAN_SCALE_SCORE_PRIOR = mean(SCALE_SCORE_PRIOR, na.rm=TRUE),
                MEAN_SCALE_SCORE_PRIOR_STANDARDIZED = mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED = mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
                PERCENT_FRED = PCT_SCHOOL_FRL[1],
                PERCENT_ELL = PCT_SCHOOL_ELL[1],
                PERCENT_IEP = PCT_SCHOOL_IEP[1]),
              keyby = c("CONTENT_AREA", "GRADE", "SCHOOL_NUMBER")] # "YEAR", SCHOOL_NUMBER RAND_SCH_NUM_1, RAND_SCH_NUM_2

sch.grd.cor <- sch.grd.msgp[!is.na(MEAN_SKIP) & COUNT_TOTAL > 9, list(
    Skip_x_No_Skip = round(cor(MEAN_NO_SKIP, MEAN_SKIP, use="complete.obs"), 2),
    Prior_Ach_x_No_Skip = round(cor(MEAN_NO_SKIP, MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2),
    Prior_Ach_x_Skip = round(cor(MEAN_SKIP, MEAN_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2),
    PCT_FRL_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_FRED, use="complete.obs"), 2),
    PCT_FRL_x_Skip = round(cor(MEAN_SKIP, PERCENT_FRED, use="complete.obs"), 2),
    PCT_ELL_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_ELL, use="complete.obs"), 2),
    PCT_ELL_x_Skip = round(cor(MEAN_SKIP, PERCENT_ELL, use="complete.obs"), 2),
    PCT_SWD_x_No_Skip = round(cor(MEAN_NO_SKIP, PERCENT_IEP, use="complete.obs"), 2),
    PCT_SWD_x_Skip = round(cor(MEAN_SKIP, PERCENT_IEP, use="complete.obs"), 2), N = .N), keyby = c("CONTENT_AREA", "GRADE")] # , N2 = sum(!is.na(MEAN_SKIP))


sch.frl.msgp <- Colorado_Data[VALID_CASE=='VALID_CASE' & YEAR == "2019" & !is.na(SCHOOL_NUMBER) & !is.na(FREE_REDUCED_LUNCH_STATUS),
                  list(
                    MEAN_NO_SKIP = mean(NO_SKIP_SGP, na.rm = TRUE),
                    SD_NO_SKIP = sd(NO_SKIP_SGP, na.rm = TRUE),
                    MEAN_SKIP = mean(SGP, na.rm = TRUE),
                    SD_SKIP = sd(SGP, na.rm = TRUE),
                    MEAN_SCALE_SCORE_PRIOR_STANDARDIZED = round(mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE), 2),
                    MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED = round(mean(NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE), 2)),
                  keyby = c("CONTENT_AREA", "GRADE", "FREE_REDUCED_LUNCH_STATUS", "SCHOOL_NUMBER")]

sch.frl.cor <- sch.frl.msgp[GRADE %in% 5:10 & !is.na(MEAN_SKIP), list( # need !is.na(MEAN_SKIP) for 5th grade SCIENCE
    Mean_MSGP_No_Skip = round(mean(MEAN_NO_SKIP, na.rm=TRUE), 2),
    SD_MSGP_No_Skip = round(sd(MEAN_NO_SKIP, na.rm=TRUE), 2),
    Mean_MSGP_Skip = round(mean(MEAN_SKIP, na.rm=TRUE), 2),
    SD_MSGP_Skip = round(sd(MEAN_SKIP, na.rm=TRUE), 2),
    Prior_Ach_x_No_Skip = round(cor(MEAN_NO_SKIP, MEAN_NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2),
    Prior_Ach_x_Skip = round(cor(MEAN_SKIP, MEAN_SCALE_SCORE_PRIOR_STANDARDIZED, use="complete.obs"), 2), N = .N), keyby = c("CONTENT_AREA", "GRADE", "FREE_REDUCED_LUNCH_STATUS")]


#####
###   Plots
#####

require(ggplot2)
dir.create("Plots")

diff.grd.sch <- Colorado_Data[!is.na(NO_SKIP_SGP) & GRADE %in% c(5:10) & YEAR == '2019' & !is.na(SCHOOL_NUMBER), # %in% c('2018', '2019'),
list(Mean_No_Skip = round(mean(NO_SKIP_SGP, na.rm=T), 1), Median_No_Skip = median(as.numeric(NO_SKIP_SGP), na.rm=T),
     Mean__Skip___Year = round(mean(SGP, na.rm=T), 1), Median__Skip___Year = median(as.numeric(SGP), na.rm=T),
     Mean_Prior_Achievement = mean(SCALE_SCORE_PRIOR_STANDARDIZED, na.rm=TRUE),
     PERCENT_FRED = PCT_SCHOOL_FRL[1],
     PERCENT_ELL = PCT_SCHOOL_ELL[1],
     PERCENT_IEP = PCT_SCHOOL_IEP[1], N=.N), # NO_SKIP_SGP_SCALE_SCORE_PRIOR_STANDARDIZED
  keyby=c("SCHOOL_NUMBER", "CONTENT_AREA", "GRADE", "YEAR")] # SCHOOL_NUMBER RAND_SCH_NUM_1, RAND_SCH_NUM_2

diff.grd.sch[, Mean_Difference := Mean__Skip___Year - Mean_No_Skip]
diff.grd.sch[, Median_Difference := Median__Skip___Year - Median_No_Skip]
diff.grd.sch[, GRADE := as.numeric(GRADE)]
setkey(diff.grd.sch, GRADE)

cor.grd.sch <- diff.grd.sch[N > 9 & !is.na(Mean__Skip___Year), list(cors=round(cor(Mean_No_Skip, Mean__Skip___Year, use="complete.obs"), 2)), keyby=c("CONTENT_AREA", "GRADE")]
cor.diff  <- diff.grd.sch[N > 9 & !is.na(Mean_Difference), list(
                          cors=round(cor(Mean_Difference, Mean_Prior_Achievement, use="complete.obs"), 2),
                          cors.frl=round(cor(Mean_Difference, PERCENT_FRED, use="complete.obs"), 2),
                          cors.ell=round(cor(Mean_Difference, PERCENT_ELL, use="complete.obs"), 2),
                          cors.swd=round(cor(Mean_Difference, PERCENT_IEP, use="complete.obs"), 2)), keyby=c("CONTENT_AREA", "GRADE")]

# my.colors <- c("#CC0000", "#0000CC") # "darkred","darkblue"  # only needed with multiple years

###   Grade Level ELA/MATH

#     Mean SGP By Skip Year or No-Skip

for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, Mean_No_Skip, Mean__Skip___Year, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(Mean_No_Skip),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP With and Without Skipped Year:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=3) + coord_fixed(xlim=c(0,100), ylim=c(0, 100)) # xlim(0,100) + ylim(0, 100)

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = Mean__Skip___Year, y = Mean_No_Skip, size = N), alpha = 0.75, colour="blue") +
             scale_size_continuous(range = c(1, 7)) # , shape=YEAR, color=YEAR

    p <- p + theme(legend.position = "none") #  Needed when N size used for bubbles
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
    p <- p + scale_x_continuous(name="School Mean SGP with Skip Year")
    p <- p + scale_y_continuous(name="School Mean SGP Continuous")
    p <- p + geom_text(data=cor.grd.sch[CONTENT_AREA == content.area], aes(label=paste("r = ", cors, sep="")), x = 75, y = 25, size = 4.0, colour = "red")
    p <- p + geom_abline(slope=1, intercept = 0)

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_SGP_Skip.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}


#     Mean Difference By Prior Achievement

for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, Mean_Prior_Achievement, Mean_Difference, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(Mean_Prior_Achievement),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP Difference by Prior Achievement:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=2) # + coord_fixed(xlim=c(-2, 2), ylim=c(-30, 30))

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = Mean_Prior_Achievement, y = Mean_Difference, size = N), alpha = 0.5, colour="blue") +
             scale_size_continuous(range = c(1, 7)) # , shape=YEAR, color=YEAR
    p <- p + geom_smooth(data = tmp.data[N > 9], aes(x = Mean_Prior_Achievement, y = Mean_Difference), se=FALSE, colour="black")
    p <- p + geom_text(data=cor.diff[CONTENT_AREA == content.area], aes(label=paste("r = ", cors, sep="")), x = 0.9, y = -15.5, size = 4.0, colour = "red") # x = 1.25, y = -15 # x = 0.65, y = -7

    p <- p + theme(legend.position = "none") #  Needed when N size used for bubbles
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
    p <- p + scale_x_continuous(name="Mean Prior (Standardized) Scores")
    p <- p + scale_y_continuous(name="School Mean SGP Differences")

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_SGP_x_SS.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}

#     Difference by School/Grade Size
for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, Mean_Difference, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(Mean_Difference),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP Differences by Grade Size:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=3)

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = N, y = Mean_Difference), size=3, alpha = 0.5, colour="blue") # , shape=YEAR, color=YEAR
    p <- p + geom_hline(data = tmp.data[N > 9], aes(yintercept=0), colour="black", linetype="dashed")

    # p <- p + theme(legend.position = "none")
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
		p <- p + scale_x_continuous(name="School Size")
    p <- p + scale_y_continuous(name="School Mean SGP Differences")

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_Diff_x_N.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}

#     Mean Difference By FREE_REDUCED_LUNCH_STATUS
for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, PERCENT_FRED, Mean_Difference, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(PERCENT_FRED),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP Difference by Percent FRL:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=2) # + coord_fixed(xlim=c(-2, 2), ylim=c(-30, 30))

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = PERCENT_FRED, y = Mean_Difference, size = N), alpha = 0.5, colour="blue") +
             scale_size_continuous(range = c(1, 7)) # , shape=YEAR, color=YEAR
    p <- p + geom_smooth(data = tmp.data[N > 9], aes(x = PERCENT_FRED, y = Mean_Difference), se=FALSE, colour="black")
    p <- p + geom_text(data=cor.diff[CONTENT_AREA == content.area], aes(label=paste("r = ", cors.frl, sep="")), x = 12, y = -15.5, size = 4.0, colour = "red") # x = 1.25, y = -15 # x = 0.65, y = -7

    p <- p + theme(legend.position = "none") #  Needed when N size used for bubbles
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
    p <- p + scale_x_continuous(name="School Percent FRL Eligible")
    p <- p + scale_y_continuous(name="School Mean SGP Differences")

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_SGP_x_FRL.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}

#     Mean Difference By ELL_STATUS
for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, PERCENT_ELL, Mean_Difference, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(PERCENT_ELL),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP Difference by Percent ELL:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=2) # + coord_fixed(xlim=c(-2, 2), ylim=c(-30, 30))

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = PERCENT_ELL, y = Mean_Difference, size = N), alpha = 0.5, colour="blue") +
             scale_size_continuous(range = c(1, 7)) # , shape=YEAR, color=YEAR
    p <- p + geom_smooth(data = tmp.data[N > 9], aes(x = PERCENT_ELL, y = Mean_Difference), se=FALSE, colour="black")
    p <- p + geom_text(data=cor.diff[CONTENT_AREA == content.area], aes(label=paste("r = ", cors.ell, sep="")), x = 12, y = -15.5, size = 4.0, colour = "red") # x = 1.25, y = -15 # x = 0.65, y = -7

    p <- p + theme(legend.position = "none") #  Needed when N size used for bubbles
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
    p <- p + scale_x_continuous(name="School Percent English Learners")
    p <- p + scale_y_continuous(name="School Mean SGP Differences")

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_SGP_x_ELL.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}

#     Mean Difference By IEP_STATUS
for (content.area in c("ELA", "MATHEMATICS", "SCIENCE")) {
  tmp.data <- diff.grd.sch[CONTENT_AREA == content.area, list(GRADE, PERCENT_IEP, Mean_Difference, N)] # YEAR,
	if (content.area=="MATHEMATICS") ca.name <- "Math" else ca.name <- capwords(content.area)

  if (nrow(tmp.data[!is.na(PERCENT_IEP),]) > 10) { # YEAR %in% c("2018", "2019") &
    ###   School-Level Mean SGP Distributions - Original vs Skip Year -- Content Area x Grade (facet)

    p <- ggplot() +
			# scale_color_manual(values = my.colors) +
			ggtitle(paste("Mean SGP Difference by Percent with IEP:", ca.name)) +
			theme(plot.title = element_text(size=18, face="bold.italic"), axis.title.x=element_text(size=15), axis.title.y=element_text(size=15), axis.text.x=element_text(size=14), axis.text.y=element_text(size=14))
    p <- p + facet_wrap( ~ GRADE, ncol=2) # + coord_fixed(xlim=c(-2, 2), ylim=c(-30, 30))

    p <- p + geom_point(data = tmp.data[N > 9], aes(x = PERCENT_IEP, y = Mean_Difference, size = N), alpha = 0.5, colour="blue") +
             scale_size_continuous(range = c(1, 7)) # , shape=YEAR, color=YEAR
    p <- p + geom_smooth(data = tmp.data[N > 9], aes(x = PERCENT_IEP, y = Mean_Difference), se=FALSE, colour="black")
    p <- p + geom_text(data=cor.diff[CONTENT_AREA == content.area], aes(label=paste("r = ", cors.swd, sep="")), x = 12, y = -15.5, size = 4.0, colour = "red") # x = 1.25, y = -15 # x = 0.65, y = -7

    p <- p + theme(legend.position = "none") #  Needed when N size used for bubbles
    # p <- p + guides(color = guide_legend(override.aes = list(shape=16:17), title = "School\nYear", title.theme = element_text(size = 16), label.theme = element_text(size = 15)), shape="none")
    p <- p + scale_x_continuous(name="School Percent Students with Disabilities")
    p <- p + scale_y_continuous(name="School Mean SGP Differences")

		ggsave(filename = paste("Plots/Skip_Year_SGP_Comp_", ca.name, "_SGP_x_IEP.pdf", sep=""), plot=p, device = "pdf", width = 7, height = 6.5, units = "in")
  }
}
