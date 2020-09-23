################################################################################
###                                                                          ###
###  SGP Configuration code for Spring 2019 Grade Level Math - Skipped Year  ###
###                                                                          ###
################################################################################

MATHEMATICS_2017_2018.config <- list(
	MATHEMATICS018_2019 = list(
		sgp.content.areas=rep("MATHEMATICS", 3),
		sgp.panel.years=c("2014_2015", "2015_2016", "2017_2018"),
		sgp.grade.sequences=list(c("3", "5"), c("3", "4", "6"), c("4", "5", "7"), c("5", "6", "8")),
		sgp.norm.group.preference=0L)
)

###   ALGEBRA_I
###   Only SGP_NORM_GROUP with SGPs in 2018 is '2015_2016/MATHEMATICS_6; 2016_2017/MATHEMATICS_7; 2017_2018/ALGEBRA_I_EOCT'
ALGEBRA_I_2017_2018.config <- list(
	ALGEBRA_I017_2018 = list(
		sgp.content.areas=c("MATHEMATICS", "MATHEMATICS", "ALGEBRA_I"),
		sgp.panel.years=c("2014_2015", "2015_2016", "2017_2018"),
		sgp.grade.sequences=list(c("5", "6", "EOCT")), # 8th graders taking Alg 1
		sgp.norm.group.preference=1L)
)
